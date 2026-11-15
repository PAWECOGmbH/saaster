#!/usr/bin/env bash
# Shared Borg 1.x configuration and project-scoped Docker operations.
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="${ENV_FILE:-$PROJECT_ROOT/.env}"

die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[%s] %s\n' "$(date -u +'%FT%TZ')" "$*"; }
require_command() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }
require_var() { [[ -n "${!1:-}" ]] || die "Required setting is missing: $1"; }

load_backup_config() {
    [[ -f "$ENV_FILE" && ! -L "$ENV_FILE" ]] || die "Environment file must be a regular file: $ENV_FILE"
    # The administrator owns this trusted shell-compatible environment file.
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    for name in COMPOSE_PROJECT_NAME BACKUP_ENV; do require_var "$name"; done
    [[ "$COMPOSE_PROJECT_NAME" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || die "Invalid Compose project name"
    case "$BACKUP_ENV" in production|staging|test) ;; *) die "Set BACKUP_ENV to production or staging (test is reserved for isolated fixtures)" ;; esac
    BORG_COMPOSE_FILE="${BORG_COMPOSE_FILE:-compose.yml}"
    [[ "$BORG_COMPOSE_FILE" =~ ^[A-Za-z0-9_./-]+$ && "$BORG_COMPOSE_FILE" != /* && "$BORG_COMPOSE_FILE" != *..* ]] || die "BORG_COMPOSE_FILE must be a project-relative path"
    ARCHIVE_PREFIX="${BORG_ARCHIVE_PREFIX:-$COMPOSE_PROJECT_NAME-saaster-v1}"
    [[ "$ARCHIVE_PREFIX" =~ ^[a-zA-Z0-9._-]+$ && "$ARCHIVE_PREFIX" == "$COMPOSE_PROJECT_NAME-"* ]] || die "Archive prefix must start with the Compose project name"
    BORG_ARGS=()
    # shellcheck disable=SC2034 # Read by backup_borg.sh after configuration is loaded.
    BORG_DERIVED_REPO=false
    if [[ -z "${BORG_REPO:-}" ]]; then
        for name in SERVER_USER SERVER_HOST SERVER_PORT SSH_KEY_PATH REMOTE_BACKUP_PATH; do require_var "$name"; done
        [[ "$SERVER_USER" =~ ^[A-Za-z0-9_-]+$ && "$SERVER_HOST" =~ ^[A-Za-z0-9.-]+$ && "$SERVER_PORT" =~ ^[0-9]{1,5}$ ]] || die "Invalid SSH destination"
        REMOTE_BACKUP_PATH="${REMOTE_BACKUP_PATH#/}"
        [[ "$REMOTE_BACKUP_PATH" =~ ^[A-Za-z0-9_./-]+$ && "$REMOTE_BACKUP_PATH" != *..* ]] || die "Invalid remote backup path"
        BORG_REPO="ssh://$SERVER_USER@$SERVER_HOST:$SERVER_PORT/./$REMOTE_BACKUP_PATH/borg"
        # shellcheck disable=SC2034
        BORG_DERIVED_REPO=true
    fi
    if [[ "$BORG_REPO" == ssh://* ]]; then
        require_command ssh
        require_var SSH_KEY_PATH
        [[ -r "$SSH_KEY_PATH" ]] || die "SSH key is not readable"
        local quoted_key
        printf -v quoted_key '%q' "$SSH_KEY_PATH"
        export BORG_RSH="${BORG_RSH:-ssh -4 -i $quoted_key -o BatchMode=yes -o StrictHostKeyChecking=accept-new}"
        BORG_ARGS=(--remote-path "${BORG_REMOTE_PATH:-borg-1.2}")
    else
        [[ "$BORG_REPO" == /* && "$BORG_REPO" != / && "$BORG_REPO" != *::* ]] || die "Local Borg repositories require an absolute directory"
        BORG_REPO="$(realpath -m "$BORG_REPO")"
        [[ "$BORG_REPO" != "$PROJECT_ROOT" && "$BORG_REPO" != "$PROJECT_ROOT/"* ]] || die "The Borg repository must be outside the project"
    fi
    if [[ "$BACKUP_ENV" == test ]]; then
        [[ "$COMPOSE_PROJECT_NAME" == saaster-borg-test-* && "$BORG_REPO" == /* ]] || die "Test mode requires a saaster-borg-test-* project and a local repository"
    fi
    export BORG_REPO
    if [[ -n "${BORG_PASSPHRASE_FILE:-}" ]]; then
        [[ -r "$BORG_PASSPHRASE_FILE" ]] || die "Borg passphrase file is not readable"
        BORG_PASSPHRASE="$(<"$BORG_PASSPHRASE_FILE")"
        [[ -n "$BORG_PASSPHRASE" ]] || die "Borg passphrase file is empty"
        export BORG_PASSPHRASE
    elif [[ -n "${BORG_PASSCOMMAND:-}" ]]; then
        export BORG_PASSCOMMAND
    else
        require_var BORG_PASSPHRASE
        export BORG_PASSPHRASE
    fi
    for command in borg python3 flock; do require_command "$command"; done
    [[ "$(borg --version)" =~ ^borg\ 1\.([2-9]|[1-9][0-9])\. ]] || die "Use Borg 1.2 or newer within the 1.x series"
    (( EUID == 0 )) || die "Run backup and restore as root"
    local lock_dir="${BORG_LOCK_DIR:-/run/saaster-backup}"
    [[ ! -L "$lock_dir" ]] || die "Lock directory must not be a symlink"
    mkdir -p "$lock_dir"
    [[ "$(stat -c %u "$lock_dir")" == 0 ]] || die "Lock directory is not owned by root"
    chmod 700 "$lock_dir"
    exec 9>>"$lock_dir/$COMPOSE_PROJECT_NAME.lock"
    flock -n 9 || die "Another backup or restore is already running"
    BORG_HELPER_IMAGE="${BORG_HELPER_IMAGE:-alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c}"
}

borg_command() { borg "${BORG_ARGS[@]}" "$@"; }
compose() { docker compose --project-directory "$PROJECT_ROOT" --env-file "$ENV_FILE" -p "$COMPOSE_PROJECT_NAME" -f "$PROJECT_ROOT/$BORG_COMPOSE_FILE" "$@"; }
container_for() { compose ps -a -q "$1"; }
running() { [[ "$(docker inspect --format '{{.State.Running}}' "$1")" == true ]]; }
assert_container() {
    [[ -n "$1" && "$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' "$1")" == "$COMPOSE_PROJECT_NAME" ]] || die "Container does not belong to the selected project"
}
userdata_volume() {
    local volume
    volume="$(docker inspect --format '{{range .Mounts}}{{if eq .Destination "/var/www/userdata"}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}{{end}}' "$1")"
    [[ -n "$volume" && "$(docker volume inspect --format '{{index .Labels "com.docker.compose.project"}}' "$volume")" == "$COMPOSE_PROJECT_NAME" ]] || die "Userdata volume is missing or belongs to another project"
    printf '%s\n' "$volume"
}
credentials_hash() {
    python3 -c 'import hashlib,json,os; print(hashlib.sha256(json.dumps([os.environ[k] for k in ("MYSQL_ROOT_PASSWORD","MYSQL_USER","MYSQL_PASSWORD")]).encode()).hexdigest())'
}
manifest_value() {
    python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))[sys.argv[2]])' "$1" "$2"
}
new_work_dir() {
    local base="${BORG_WORK_DIR:-/backup}"
    mkdir -p "$base"
    base="$(realpath "$base")"
    [[ "$base" != "$PROJECT_ROOT" && "$base" != "$PROJECT_ROOT/"* ]] || die "BORG_WORK_DIR must be outside the project"
    mktemp -d "$base/$COMPOSE_PROJECT_NAME-borg.XXXXXX"
}
remove_work_dir() {
    [[ -n "${WORK_DIR:-}" && -d "$WORK_DIR" && ! -L "$WORK_DIR" && "$(basename "$WORK_DIR")" == "$COMPOSE_PROJECT_NAME-borg."* ]] || return 0
    rm -rf -- "$WORK_DIR"
}
project_rsync() {
    rsync -a "$@" --exclude='/.git/' --exclude='/.env*' --exclude='/todo.md' \
        --exclude='/logs/' --exclude='/www/logs/' --exclude='/www/userdata/' \
        --exclude='/www/tests/' --exclude='/www/setup/mockdata/' --exclude='/config/db/dev/'
}
require_data_settings() {
    for name in MYSQL_DATABASE MYSQL_ROOT_PASSWORD MYSQL_USER MYSQL_PASSWORD; do require_var "$name"; done
    [[ "$MYSQL_DATABASE" =~ ^[A-Za-z0-9_]+$ ]] || die "Invalid database name"
    [[ "$BACKUP_ENV" != test || "$MYSQL_DATABASE" == *test* ]] || die "Test mode requires a dedicated test database"
    for command in docker rsync tar mktemp; do require_command "$command"; done
    compose config --quiet
}
assert_mysql_settings() {
    docker inspect "$1" | python3 -c '
import json,os,sys
actual=dict(item.split("=",1) for item in json.load(sys.stdin)[0]["Config"]["Env"] if "=" in item)
if any(actual.get(k)!=os.environ.get(k) for k in ("MYSQL_DATABASE","MYSQL_USER","MYSQL_PASSWORD","MYSQL_ROOT_PASSWORD")):
    sys.exit("MySQL container credentials/database do not match the selected environment file")'
}
mysql_ready() {
    local attempt
    for attempt in {1..60}; do
        if docker exec "$1" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqladmin ping --host=127.0.0.1 --user=root --silent' >/dev/null 2>&1; then return 0; fi
        sleep 2
    done
    die "MySQL did not become ready after $attempt checks"
}
create_archive() { (cd "$2"; borg_command create --stats --compression "${BORG_COMPRESSION:-lz4}" "$BORG_REPO::$ARCHIVE_PREFIX-$1-$TIMESTAMP" .); }

assert_complete_records() {
    local archive timestamp component
    while IFS= read -r archive; do
        [[ "$archive" == "$ARCHIVE_PREFIX-complete-"* ]] || continue
        timestamp="${archive#"$ARCHIVE_PREFIX-complete-"}"
        [[ "$timestamp" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || die "Retention skipped: invalid completion record $archive"
        for component in db userdata config lucee; do
            grep -Fxq -- "$ARCHIVE_PREFIX-$component-$timestamp" <<< "$1" || die "Retention skipped: incomplete completion record $archive"
        done
    done <<< "$1"
}

# Keep the old userdata inside its own volume until the entire restore succeeds.
replace_userdata() {
    ROLLBACK_NAME=".saaster-borg-rollback.$TIMESTAMP.$$"
    [[ -z "$(find "$WORK_DIR/userdata" -maxdepth 1 -name '.saaster-borg-rollback.*' -print -quit)" ]] || die "Reserved rollback directory in userdata archive"
    tar -C "$WORK_DIR/userdata" -cf - . | docker run --rm -i --network none \
        --mount "type=volume,src=$USERDATA_VOLUME,dst=/target" --entrypoint sh "$BORG_HELPER_IMAGE" -c '
        set -eu
        mkdir /staged
        tar -xf - -C /staged
        rollback="/target/$1"
        mkdir "$rollback"
        for item in /target/.[!.]* /target/..?* /target/*; do
            [ -e "$item" ] || [ -L "$item" ] || continue
            [ "$item" = "$rollback" ] && continue
            if ! mv -- "$item" "$rollback/"; then
                for saved in "$rollback"/.[!.]* "$rollback"/..?* "$rollback"/*; do
                    [ -e "$saved" ] || [ -L "$saved" ] || continue
                    mv -- "$saved" /target/
                done
                rmdir "$rollback"
                exit 1
            fi
        done
        if ! cp -a /staged/. /target/; then
            for item in /target/.[!.]* /target/..?* /target/*; do
                [ -e "$item" ] || [ -L "$item" ] || continue
                [ "$item" = "$rollback" ] || rm -rf -- "$item"
            done
            for saved in "$rollback"/.[!.]* "$rollback"/..?* "$rollback"/*; do
                [ -e "$saved" ] || [ -L "$saved" ] || continue
                mv -- "$saved" /target/
            done
            rmdir "$rollback"
            exit 1
        fi
        ' sh "$ROLLBACK_NAME"
}
discard_userdata_rollback() {
    [[ -n "${ROLLBACK_NAME:-}" && "$ROLLBACK_NAME" == .saaster-borg-rollback.* ]] || return 0
    docker run --rm --network none --mount "type=volume,src=$USERDATA_VOLUME,dst=/target" \
        --entrypoint sh "$BORG_HELPER_IMAGE" -c 'case "$1" in .saaster-borg-rollback.*) rm -rf -- "/target/$1" ;; *) exit 1 ;; esac' sh "$ROLLBACK_NAME"
}
