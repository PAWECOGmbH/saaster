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

# Ensure /restore directory exists
mkdir -p /restore

# -------------------------
# Restore functions
# -------------------------

restore_db() {
    local BACKUP_NAME
    if [ -z "$1" ]; then
        echo "[DB] Restoring latest backup..."
        BACKUP_NAME=$(ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} "ls -t ${REMOTE_BACKUP_PATH}/db | head -n 1")
    else
        echo "[DB] Restoring backup from timestamp: $1"
        BACKUP_NAME="database_$1.tar.gz"
    fi

    scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/db/${BACKUP_NAME} /restore/database.tar.gz
    docker run --rm -v ${DB_VOLUME}:/volume -v /restore:/restore alpine sh -c "tar -xzf /restore/database.tar.gz -C /volume"
    rm /restore/database.tar.gz
    docker restart ${MYSQL_CONTAINER_NAME}
    echo "[DB] Restore complete"
}

restore_userdata() {
    local BACKUP_NAME
    if [ -z "$1" ]; then
        echo "[USERDATA] Restoring latest backup..."
        BACKUP_NAME=$(ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} "ls -t ${REMOTE_BACKUP_PATH}/userdata | head -n 1")
    else
        echo "[USERDATA] Restoring backup from timestamp: $1"
        BACKUP_NAME="userdata_$1.tar.gz"
    fi

    scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/userdata/${BACKUP_NAME} /restore/userdata.tar.gz
    docker run --rm -v ${USERDATA_VOLUME}:/volume -v /restore:/restore alpine sh -c "tar -xzf /restore/userdata.tar.gz -C /volume"
    rm /restore/userdata.tar.gz
    docker restart ${LUCEE_CONTAINER_NAME}
    echo "[USERDATA] Restore complete"
}

restore_lucee_image() {
    local BACKUP_NAME
    if [ -z "$1" ]; then
        echo "[LUCEE] Restoring latest image..."
        BACKUP_NAME=$(ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} "ls -t ${REMOTE_BACKUP_PATH}/lucee | head -n 1")
    else
        echo "[LUCEE] Restoring image from timestamp: $1"
        BACKUP_NAME="image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_$1.tar"
    fi

    scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/lucee/${BACKUP_NAME} /restore/image.tar
    docker load -i /restore/image.tar
    rm /restore/image.tar
    echo "[LUCEE] Image restore complete"
}

list_backups() {
    echo "Available backups on remote server:"
    echo "-----------------------------------"
    echo "Database:"
    ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} "ls ${REMOTE_BACKUP_PATH}/db"
    echo ""
    echo "Userdata:"
    ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} "ls ${REMOTE_BACKUP_PATH}/userdata"
    echo ""
    echo "Lucee images:"
    ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} "ls ${REMOTE_BACKUP_PATH}/lucee"
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
