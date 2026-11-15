#!/usr/bin/env bash
# Restore authenticated, complete Saaster backup sets produced by backup_borg.sh.
set -Eeuo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/borg_common.sh"
usage() {
    printf 'Usage: restore_borg.sh --list | --config | --all | --db | --userdata | --lucee-image\n'
    printf 'Selectors: --timestamp YYYYMMDDTHHMMSSZ. Data/config/image changes require --force.\n'
}
ACTION="${1:-}"
case "$ACTION" in
    ''|--help|-h) usage; exit 0 ;;
    --list|--config|--all|--db|--userdata|--lucee-image) shift ;;
    *) usage >&2; exit 1 ;;
esac
TIMESTAMP=""
FORCE=false
while (( $# )); do
    case "$1" in
        --timestamp) (( $# >= 2 )) || die "Missing timestamp"; [[ -z "$TIMESTAMP" ]] || die "Duplicate timestamp"; TIMESTAMP="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        *) die "Unknown argument: $1" ;;
    esac
done
[[ -z "$TIMESTAMP" || "$TIMESTAMP" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || die "Invalid timestamp"
load_backup_config
if [[ "$ACTION" == --list ]]; then borg_command list --short "$BORG_REPO"; exit 0; fi
[[ "$ACTION" == --config || "$FORCE" == true ]] || die "Restore changes data/configuration/images; use --force"
ARCHIVES="$(borg_command list --short "$BORG_REPO")"
complete_set() {
    local component
    for component in complete db userdata config lucee; do
        grep -Fxq -- "$ARCHIVE_PREFIX-$component-$1" <<< "$ARCHIVES" || return 1
    done
}
if [[ -z "$TIMESTAMP" ]]; then
    while IFS= read -r archive; do
        [[ "$archive" == "$ARCHIVE_PREFIX-complete-"* ]] || continue
        candidate="${archive#"$ARCHIVE_PREFIX-complete-"}"
        [[ "$candidate" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || continue
        if complete_set "$candidate"; then TIMESTAMP="$candidate"; break; fi
    done < <(printf '%s\n' "$ARCHIVES" | sort -r)
fi
[[ -n "$TIMESTAMP" ]] && complete_set "$TIMESTAMP" || die "No complete backup set found"
WORK_DIR="$(new_work_dir)"
KEEP_WORK=false
LUCEE_STOPPED=false
FILEBROWSER_STOPPED=false
MODIFIED=false
ROLLBACK_NAME=""
cleanup() {
    local result=$?
    trap - EXIT
    if (( result == 0 )); then
        if [[ "$FILEBROWSER_STOPPED" == true ]]; then
            if [[ "$ACTION" == --all ]]; then compose up -d --no-deps --force-recreate filebrowser >/dev/null || result=1;
            else docker start "$FILEBROWSER_CONTAINER" >/dev/null || result=1; fi
        fi
        if (( result == 0 )) && [[ "$LUCEE_STOPPED" == true ]]; then
            if [[ "$ACTION" == --all ]]; then compose up -d --no-deps --force-recreate lucee >/dev/null || result=1;
            else docker start "$LUCEE_CONTAINER" >/dev/null || result=1; fi
        fi
    fi
    if (( result == 0 )) && [[ -n "$ROLLBACK_NAME" ]]; then discard_userdata_rollback || result=1; fi
    if (( result != 0 )) && [[ "$MODIFIED" == true ]]; then
        compose stop lucee >/dev/null 2>&1 || true
        if [[ -n "$FILEBROWSER_CONTAINER" ]]; then compose stop filebrowser >/dev/null 2>&1 || true; fi
        log "Restore failed. Services remain stopped; inspect $WORK_DIR and userdata rollback $ROLLBACK_NAME."
        KEEP_WORK=true
    elif (( result != 0 )); then
        if [[ "$FILEBROWSER_STOPPED" == true ]]; then docker start "$FILEBROWSER_CONTAINER" >/dev/null || true; fi
        if [[ "$LUCEE_STOPPED" == true ]]; then docker start "$LUCEE_CONTAINER" >/dev/null || true; fi
    elif [[ "$MODIFIED" == true ]]; then
        log "Restore of $TIMESTAMP completed; verify the application before reopening external writers"
    fi
    if [[ "$KEEP_WORK" != true ]]; then remove_work_dir; fi
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
stage_archive() {
    mkdir "$WORK_DIR/$1"
    (cd "$WORK_DIR/$1"; borg_command extract "$BORG_REPO::$ARCHIVE_PREFIX-$1-$TIMESTAMP")
}
stage_archive complete
MANIFEST="$WORK_DIR/complete/manifest.json"
[[ "$(manifest_value "$MANIFEST" format)" == saaster-borg-1 ]] || die "Unsupported backup format"
[[ "$(manifest_value "$MANIFEST" project)" == "$COMPOSE_PROJECT_NAME" ]] || die "Backup belongs to another Compose project"
[[ "$(manifest_value "$MANIFEST" timestamp)" == "$TIMESTAMP" ]] || die "Backup timestamp mismatch"
SNAPSHOT_IMAGE="$(manifest_value "$MANIFEST" image)"
[[ "$SNAPSHOT_IMAGE" == "saaster-borg-snapshot/$COMPOSE_PROJECT_NAME:$TIMESTAMP" ]] || die "Invalid snapshot image reference"
SNAPSHOT_ID="$(manifest_value "$MANIFEST" imageId)"
[[ "$SNAPSHOT_ID" =~ ^sha256:[a-f0-9]{64}$ ]] || die "Invalid snapshot image identity"
load_snapshot_image() {
    require_command docker
    borg_command extract --stdout "$BORG_REPO::$ARCHIVE_PREFIX-lucee-$TIMESTAMP" lucee-image.tar | docker image load
    [[ "$(docker image inspect --format '{{.Id}}' "$SNAPSHOT_IMAGE")" == "$SNAPSHOT_ID" ]] || die "Loaded image identity differs from the manifest"
}
# Cold recovery must be able to load the image before any containers exist.
if [[ "$ACTION" == --lucee-image ]]; then
    load_snapshot_image
    log "Loaded $SNAPSHOT_IMAGE; existing containers were not recreated"
    exit 0
fi
if [[ "$ACTION" == --config || "$ACTION" == --all ]]; then
    stage_archive config
    cmp "$MANIFEST" "$WORK_DIR/config/manifest.json" || die "Configuration/complete manifests differ"
    [[ -f "$WORK_DIR/config/.env" && ! -L "$WORK_DIR/config/.env" ]] || die "Missing recovered environment"
    [[ -d "$WORK_DIR/config/project/www" && -z "$(find "$WORK_DIR/config/project" -type l -print -quit)" ]] || die "Invalid project configuration archive"
    validate_recovered_environment() (
        local expected_project expected_database expected_credentials expected_compose expected_image
        expected_project="$(manifest_value "$MANIFEST" project)"
        expected_database="$(manifest_value "$MANIFEST" database)"
        expected_credentials="$(manifest_value "$MANIFEST" credentials)"
        expected_compose="$(manifest_value "$MANIFEST" compose)"
        expected_image="$SNAPSHOT_IMAGE"
        set -a
        # shellcheck disable=SC1090
        source "$WORK_DIR/config/.env"
        set +a
        [[ "$COMPOSE_PROJECT_NAME" == "$expected_project" && "$MYSQL_DATABASE" == "$expected_database" &&
            "$(credentials_hash)" == "$expected_credentials" && "${BORG_COMPOSE_FILE:-compose.yml}" == "$expected_compose" &&
            "$LUCEE_IMAGE:$LUCEE_IMAGE_VERSION" == "$expected_image" ]] || die "Recovered environment differs from the backup manifest"
    )
    validate_recovered_environment
    if [[ "$ACTION" == --config ]]; then
        KEEP_WORK=true
        log "Recovered configuration/code available at $WORK_DIR/config; no application files changed"
        exit 0
    fi
fi
require_data_settings
[[ "$(manifest_value "$MANIFEST" database)" == "$MYSQL_DATABASE" ]] || die "Backup targets another database"
[[ "$(manifest_value "$MANIFEST" credentials)" == "$(credentials_hash)" ]] || die "Create the target MySQL container with the credentials from --config first"
[[ "$(manifest_value "$MANIFEST" compose)" == "$BORG_COMPOSE_FILE" ]] || die "Backup uses another Compose configuration"
LUCEE_CONTAINER="$(container_for lucee)"
MYSQL_CONTAINER="$(container_for mysql)"
assert_container "$LUCEE_CONTAINER"
assert_container "$MYSQL_CONTAINER"
assert_mysql_settings "$MYSQL_CONTAINER"
# shellcheck disable=SC2034 # Used by the shared userdata restore functions.
USERDATA_VOLUME="$(userdata_volume "$LUCEE_CONTAINER")"
FILEBROWSER_CONTAINER="$(container_for filebrowser 2>/dev/null || true)"
if [[ -n "$FILEBROWSER_CONTAINER" ]]; then assert_container "$FILEBROWSER_CONTAINER"; fi
if [[ "$ACTION" == --all || "$ACTION" == --db ]]; then
    running "$MYSQL_CONTAINER" || die "Target MySQL must be running"
    stage_archive db
    tail -n 10 "$WORK_DIR/db/database.sql" | grep -q '^-- Dump completed on ' || die "Incomplete SQL dump"
    grep -Fq -- "Current Database: \`$MYSQL_DATABASE\`" "$WORK_DIR/db/database.sql" || die "SQL dump targets another database"
fi
if [[ "$ACTION" == --all || "$ACTION" == --userdata ]]; then stage_archive userdata; fi
if [[ "$ACTION" == --all ]]; then load_snapshot_image; fi

# All selected archives have been extracted and checked before application changes.
if running "$LUCEE_CONTAINER"; then LUCEE_STOPPED=true; docker stop --time 60 "$LUCEE_CONTAINER" >/dev/null; fi
if [[ -n "$FILEBROWSER_CONTAINER" ]] && running "$FILEBROWSER_CONTAINER"; then
    FILEBROWSER_STOPPED=true
    docker stop --time 30 "$FILEBROWSER_CONTAINER" >/dev/null
fi
MODIFIED=true
if [[ "$ACTION" == --all || "$ACTION" == --userdata ]]; then replace_userdata; fi
if [[ "$ACTION" == --all || "$ACTION" == --db ]]; then
    log "Restoring database"
    docker exec -i "$MYSQL_CONTAINER" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --default-character-set=utf8mb4' < "$WORK_DIR/db/database.sql"
fi
if [[ "$ACTION" == --all ]]; then
    log "Restoring application code and server configuration"
    project_rsync --delete "$WORK_DIR/config/project/" "$PROJECT_ROOT/"
    cp -p "$WORK_DIR/config/project/$BORG_COMPOSE_FILE" "$PROJECT_ROOT/$BORG_COMPOSE_FILE"
    cp -p "$WORK_DIR/config/.env" "$ENV_FILE"
    # Reload the recovered image choice. Current MySQL credentials were verified above.
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    compose up -d --no-deps --force-recreate mysql >/dev/null
    MYSQL_CONTAINER="$(container_for mysql)"
    assert_container "$MYSQL_CONTAINER"
    mysql_ready "$MYSQL_CONTAINER"
fi
