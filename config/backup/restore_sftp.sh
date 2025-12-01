#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Print error line if something goes wrong
trap 'echo "ERROR: Restore failed at line $LINENO"; exit 1' ERR

# Enable automatic export of variables
set -a

# Load environment variables from the project root
source "$(dirname "$0")/../../.env"

# Generate volume names
DB_VOLUME="${COMPOSE_PROJECT_NAME}_db_volume"
USERDATA_VOLUME="${COMPOSE_PROJECT_NAME}_userdata_volume"

# SFTP flags (same as in backup_sftp.sh)
SFTP_FLAGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o CheckHostIP=no -o LogLevel=ERROR -4"

# Ensure /restore directory exists
mkdir -p /restore

# -------------------------
# Helper: get latest file in remote folder via SFTP
# -------------------------
get_latest_backup_file() {
    local FOLDER="$1"

    local RAW FILELIST

    RAW=$(
        sftp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
            "${SERVER_USER}@${SERVER_HOST}" <<EOF 2>/dev/null
ls -1 ${REMOTE_BACKUP_PATH}/${FOLDER}
EOF
    )

    FILELIST=$(echo "$RAW" \
        | grep -v "^sftp>" \
        | grep -v "^ls" \
        | grep -v "^Changing to:" \
        | sed 's/\r$//' \
        | sed "s#${REMOTE_BACKUP_PATH}/${FOLDER}/##" \
        | sed '/^$/d'
    )

    if [ -z "$FILELIST" ]; then
        echo ""
        return
    fi

    # lexicographically last = newest because of timestamp in name
    echo "$FILELIST" | sort | tail -n 1
}

# -------------------------
# Restore functions
# -------------------------

restore_db() {
    local BACKUP_NAME

    if [ -z "$1" ]; then
        echo "[DB] Restoring latest backup..."
        BACKUP_NAME=$(get_latest_backup_file "db")
        if [ -z "$BACKUP_NAME" ]; then
            echo "[DB] No remote DB backups found in ${REMOTE_BACKUP_PATH}/db"
            exit 1
        fi
    else
        echo "[DB] Restoring backup from timestamp: $1"
        BACKUP_NAME="database_$1.tar.gz"
    fi

    echo "[DB] Downloading ${BACKUP_NAME}..."
    scp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        "${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/db/${BACKUP_NAME}" \
        /restore/database.tar.gz

    echo "[DB] Extracting into volume ${DB_VOLUME}..."
    docker run --rm -v "${DB_VOLUME}":/volume -v /restore:/restore alpine sh -c \
        "tar -xzf /restore/database.tar.gz -C /volume"

    rm /restore/database.tar.gz

    echo "[DB] Restarting MySQL container ${MYSQL_CONTAINER_NAME}..."
    docker restart "${MYSQL_CONTAINER_NAME}"

    echo "[DB] Restore complete"
}

restore_userdata() {
    local BACKUP_NAME

    if [ -z "$1" ]; then
        echo "[USERDATA] Restoring latest backup..."
        BACKUP_NAME=$(get_latest_backup_file "userdata")
        if [ -z "$BACKUP_NAME" ]; then
            echo "[USERDATA] No remote userdata backups found in ${REMOTE_BACKUP_PATH}/userdata"
            exit 1
        fi
    else
        echo "[USERDATA] Restoring backup from timestamp: $1"
        BACKUP_NAME="userdata_$1.tar.gz"
    fi

    echo "[USERDATA] Downloading ${BACKUP_NAME}..."
    scp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        "${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/userdata/${BACKUP_NAME}" \
        /restore/userdata.tar.gz

    echo "[USERDATA] Extracting into volume ${USERDATA_VOLUME}..."
    docker run --rm -v "${USERDATA_VOLUME}":/volume -v /restore:/restore alpine sh -c \
        "tar -xzf /restore/userdata.tar.gz -C /volume"

    rm /restore/userdata.tar.gz

    echo "[USERDATA] Restarting Lucee container ${LUCEE_CONTAINER_NAME}..."
    docker restart "${LUCEE_CONTAINER_NAME}"

    echo "[USERDATA] Restore complete"
}

restore_lucee_image() {
    local BACKUP_NAME

    if [ -z "$1" ]; then
        echo "[LUCEE] Restoring latest image..."
        BACKUP_NAME=$(get_latest_backup_file "lucee")
        if [ -z "$BACKUP_NAME" ]; then
            echo "[LUCEE] No remote Lucee images found in ${REMOTE_BACKUP_PATH}/lucee"
            exit 1
        fi
    else
        echo "[LUCEE] Restoring image from timestamp: $1"
        BACKUP_NAME="image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_$1.tar"
    fi

    echo "[LUCEE] Downloading ${BACKUP_NAME}..."
    scp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        "${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/lucee/${BACKUP_NAME}" \
        /restore/image.tar

    echo "[LUCEE] Loading Docker image..."
    docker load -i /restore/image.tar

    rm /restore/image.tar

    echo "[LUCEE] Image restore complete"
}

list_backups() {
    echo "Available backups on remote server:"
    echo "-----------------------------------"

    echo "Database:"
    sftp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        "${SERVER_USER}@${SERVER_HOST}" <<EOF 2>/dev/null
ls ${REMOTE_BACKUP_PATH}/db
EOF
    echo ""

    echo "Userdata:"
    sftp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        "${SERVER_USER}@${SERVER_HOST}" <<EOF 2>/dev/null
ls ${REMOTE_BACKUP_PATH}/userdata
EOF
    echo ""

    echo "Lucee images:"
    sftp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        "${SERVER_USER}@${SERVER_HOST}" <<EOF 2>/dev/null
ls ${REMOTE_BACKUP_PATH}/lucee
EOF
    echo ""
}

# -------------------------
# CLI Argument handling
# -------------------------

if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  $0 --db [TIMESTAMP]             Restore database (latest if none given)"
    echo "  $0 --userdata [TIMESTAMP]       Restore userdata volume"
    echo "  $0 --lucee-image [TIMESTAMP]    Restore Lucee image"
    echo "  $0 --list                       List available backups"
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --db)
            if [[ -n "$2" && "$2" != --* ]]; then
                restore_db "$2"
                shift
            else
                restore_db
            fi
            ;;
        --userdata)
            if [[ -n "$2" && "$2" != --* ]]; then
                restore_userdata "$2"
                shift
            else
                restore_userdata
            fi
            ;;
        --lucee-image)
            if [[ -n "$2" && "$2" != --* ]]; then
                restore_lucee_image "$2"
                shift
            else
                restore_lucee_image
            fi
            ;;
        --list)
            list_backups
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

set +a
