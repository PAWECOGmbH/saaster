#!/usr/bin/env bash
# Create complete Saaster Borg backup sets with current Lucee runtime snapshots.
set -Eeuo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/borg_common.sh"

usage() {
    printf 'Usage: backup_borg.sh --init | --backup | --list | --check | --export-key /secure/path\n'
}
case "${1:-}" in
    ''|--help|-h) usage; exit 0 ;;
    --init|--backup|--list|--check|--export-key) MODE="$1" ;;
    *) usage >&2; exit 1 ;;
esac
if [[ "$MODE" == --export-key ]]; then
    (( $# == 2 )) && [[ "$2" == /* ]] || die "Supply an absolute key export path"
else
    (( $# == 1 )) || die "Unexpected arguments"
fi
load_backup_config
case "$MODE" in
    --init)
        if [[ "$BORG_DERIVED_REPO" == true ]]; then
            ssh -4 -p "$SERVER_PORT" -i "$SSH_KEY_PATH" -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
                "$SERVER_USER@$SERVER_HOST" "mkdir -p ./$REMOTE_BACKUP_PATH"
        fi
        borg_command init --encryption=repokey-blake2 "$BORG_REPO"
        log "Repository initialized. Store its passphrase and an exported Borg key separately."
        exit 0 ;;
    --export-key)
        [[ ! -e "$2" && ! -L "$2" ]] || die "Key export path already exists"
        borg_command key export "$BORG_REPO" "$2"
        log "Borg key exported; store it separately from the server and repository"
        exit 0 ;;
    --list) borg_command list --short "$BORG_REPO"; exit 0 ;;
    --check) borg_command check --verify-data "$BORG_REPO"; exit 0 ;;
esac
require_data_settings
for name in LUCEE_IMAGE LUCEE_IMAGE_VERSION; do require_var "$name"; done
BORG_KEEP_DAILY="${BORG_KEEP_DAILY:-7}"
BORG_KEEP_WEEKLY="${BORG_KEEP_WEEKLY:-4}"
BORG_KEEP_MONTHLY="${BORG_KEEP_MONTHLY:-12}"
for name in BORG_KEEP_DAILY BORG_KEEP_WEEKLY BORG_KEEP_MONTHLY; do
    [[ "${!name}" =~ ^[0-9]{1,5}$ ]] || die "Retention settings must be non-negative integers"
    printf -v "$name" '%d' "$((10#${!name}))"
done
(( BORG_KEEP_DAILY + BORG_KEEP_WEEKLY + BORG_KEEP_MONTHLY > 0 )) || die "At least one retention rule must keep backups"
MYSQL_CONTAINER="$(container_for mysql)"
LUCEE_CONTAINER="$(container_for lucee)"
assert_container "$MYSQL_CONTAINER"
assert_container "$LUCEE_CONTAINER"
running "$MYSQL_CONTAINER" || die "MySQL must be running"
USERDATA_VOLUME="$(userdata_volume "$LUCEE_CONTAINER")"
assert_mysql_settings "$MYSQL_CONTAINER"
docker inspect "$LUCEE_CONTAINER" | python3 -c '
import json,os,sys
root=sys.argv[1]
for mount in json.load(sys.stdin)[0]["Mounts"]:
    target=mount["Destination"]
    if target=="/var/www/userdata" and mount["Type"]=="volume": continue
    if mount["Type"]!="bind" or not os.path.realpath(mount["Source"]).startswith(root+"/"):
        sys.exit("Uncovered Lucee mount: "+target)
' "$PROJECT_ROOT"
[[ "$(docker inspect --format '{{.Image}}' "$LUCEE_CONTAINER")" == "$(docker image inspect --format '{{.Id}}' "$LUCEE_IMAGE:$LUCEE_IMAGE_VERSION")" ]] || die "The running Lucee image does not match the selected environment"
borg_command info "$BORG_REPO" >/dev/null
WORK_DIR="$(new_work_dir)"
TIMESTAMP="$(date -u +'%Y%m%dT%H%M%SZ')"
SNAPSHOT_IMAGE="saaster-borg-snapshot/$COMPOSE_PROJECT_NAME:$TIMESTAMP"
SNAPSHOT_CREATED=false
LUCEE_STOPPED=false
FILEBROWSER_STOPPED=false
FILEBROWSER_CONTAINER="$(container_for filebrowser 2>/dev/null || true)"
cleanup() {
    local result=$?
    trap - EXIT
    if [[ "$FILEBROWSER_STOPPED" == true ]]; then docker start "$FILEBROWSER_CONTAINER" >/dev/null || result=1; fi
    if [[ "$LUCEE_STOPPED" == true ]]; then docker start "$LUCEE_CONTAINER" >/dev/null || result=1; fi
    if [[ "$SNAPSHOT_CREATED" == true ]]; then docker image rm "$SNAPSHOT_IMAGE" >/dev/null || result=1; fi
    remove_work_dir
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
docker image inspect "$SNAPSHOT_IMAGE" >/dev/null 2>&1 && die "Snapshot image already exists"
if running "$LUCEE_CONTAINER"; then
    LUCEE_STOPPED=true
    log "Stopping Lucee for a consistent database/files/configuration backup"
    docker stop --time 60 "$LUCEE_CONTAINER" >/dev/null
fi
if [[ -n "$FILEBROWSER_CONTAINER" ]]; then
    assert_container "$FILEBROWSER_CONTAINER"
    if running "$FILEBROWSER_CONTAINER"; then
        FILEBROWSER_STOPPED=true
        docker stop --time 30 "$FILEBROWSER_CONTAINER" >/dev/null
    fi
fi
mkdir -p "$WORK_DIR/db" "$WORK_DIR/userdata" "$WORK_DIR/config/project" "$WORK_DIR/complete"
log "Dumping database"
docker exec "$MYSQL_CONTAINER" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysqldump "$@"' sh \
    --user=root --default-character-set=utf8mb4 --single-transaction --quick --skip-lock-tables \
    --routines --events --triggers --hex-blob --set-gtid-purged=OFF --no-tablespaces --column-statistics=0 \
    --databases "$MYSQL_DATABASE" --add-drop-database > "$WORK_DIR/db/database.sql"
tail -n 10 "$WORK_DIR/db/database.sql" | grep -q '^-- Dump completed on ' || die "Database dump is incomplete"
log "Copying userdata and project configuration"
docker run --rm --network none --mount "type=volume,src=$USERDATA_VOLUME,dst=/source,readonly" \
    --entrypoint tar "$BORG_HELPER_IMAGE" -C /source -cf - . | tar -C "$WORK_DIR/userdata" -xf -
[[ -z "$(find "$WORK_DIR/userdata" -maxdepth 1 -name '.saaster-borg-rollback.*' -print -quit)" ]] || die "Resolve the previous userdata restore rollback before backing up"
project_rsync "$PROJECT_ROOT/" "$WORK_DIR/config/project/"
# A custom test/operations compose file may live inside an excluded directory.
mkdir -p "$WORK_DIR/config/project/$(dirname "$BORG_COMPOSE_FILE")"
cp -p "$PROJECT_ROOT/$BORG_COMPOSE_FILE" "$WORK_DIR/config/project/$BORG_COMPOSE_FILE"
[[ -f "$WORK_DIR/config/project/www/config.cfm" && ! -L "$WORK_DIR/config/project/www/config.cfm" ]] || die "www/config.cfm is missing"
[[ -z "$(find "$WORK_DIR/config/project" -type l -print -quit)" ]] || die "Project/configuration symlinks are not supported by this recovery format"
log "Capturing the stopped Lucee container, including current administrator settings"
SNAPSHOT_ID="$(docker commit --pause=false "$LUCEE_CONTAINER" "$SNAPSHOT_IMAGE")"
SNAPSHOT_CREATED=true
python3 - "$ENV_FILE" "$WORK_DIR/config/.env" "$SNAPSHOT_IMAGE" <<'PY'
import pathlib,re,sys
source,target,image=sys.argv[1:]
text=pathlib.Path(source).read_text()
name,tag=image.rsplit(":",1)
for key,value in (("LUCEE_IMAGE",name),("LUCEE_IMAGE_VERSION",tag)):
    pattern=r"(?m)^"+key+r"=.*$"
    text=re.sub(pattern,key+"="+value,text) if re.search(pattern,text) else text+"\n"+key+"="+value+"\n"
pathlib.Path(target).write_text(text)
PY
CODE_REVISION="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || printf unknown)"
python3 - "$WORK_DIR/config/manifest.json" "$COMPOSE_PROJECT_NAME" "$MYSQL_DATABASE" "$TIMESTAMP" \
    "$SNAPSHOT_IMAGE" "$SNAPSHOT_ID" "$(credentials_hash)" "$BORG_COMPOSE_FILE" "$CODE_REVISION" <<'PY'
import json,pathlib,sys
path,project,database,timestamp,image,image_id,credentials,compose,revision=sys.argv[1:]
pathlib.Path(path).write_text(json.dumps(dict(format="saaster-borg-1",project=project,database=database,
    timestamp=timestamp,image=image,imageId=image_id,credentials=credentials,compose=compose,revision=revision),indent=2)+"\n")
PY
cp "$WORK_DIR/config/manifest.json" "$WORK_DIR/complete/manifest.json"
# The staged files and snapshot image are now immutable; uploading to Borg does
# not need to keep the application offline.
if [[ "$FILEBROWSER_STOPPED" == true ]]; then docker start "$FILEBROWSER_CONTAINER" >/dev/null; FILEBROWSER_STOPPED=false; fi
if [[ "$LUCEE_STOPPED" == true ]]; then docker start "$LUCEE_CONTAINER" >/dev/null; LUCEE_STOPPED=false; fi
for component in db userdata config; do
    log "Creating $component archive"
    create_archive "$component" "$WORK_DIR/$component"
done
log "Creating Lucee image archive"
borg_command create --stats --compression "${BORG_COMPRESSION:-lz4}" --files-cache disabled \
    --content-from-command --stdin-name lucee-image.tar "$BORG_REPO::$ARCHIVE_PREFIX-lucee-$TIMESTAMP" -- docker image save "$SNAPSHOT_IMAGE"
# Only this last archive declares the four components a complete recovery set.
create_archive complete "$WORK_DIR/complete"
log "Backup set $TIMESTAMP completed"

# Retention selects whole sets using their completion records, never components independently.
before="$(borg_command list --short "$BORG_REPO")"
assert_complete_records "$before"
borg_command prune --list --glob-archives "$ARCHIVE_PREFIX-complete-*" \
    --keep-daily "${BORG_KEEP_DAILY:-7}" --keep-weekly "${BORG_KEEP_WEEKLY:-4}" --keep-monthly "${BORG_KEEP_MONTHLY:-12}" "$BORG_REPO"
after="$(borg_command list --short "$BORG_REPO")"
while IFS= read -r archive; do
    [[ "$archive" == "$ARCHIVE_PREFIX-complete-"* ]] || continue
    removed_timestamp="${archive#"$ARCHIVE_PREFIX-complete-"}"
    [[ "$removed_timestamp" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || continue
    if ! grep -Fxq -- "$archive" <<< "$after"; then
        for component in db userdata config lucee; do
            candidate="$ARCHIVE_PREFIX-$component-$removed_timestamp"
            if grep -Fxq -- "$candidate" <<< "$before"; then borg_command delete "$BORG_REPO::$candidate"; fi
        done
    fi
done <<< "$before"
borg_command compact "$BORG_REPO"
