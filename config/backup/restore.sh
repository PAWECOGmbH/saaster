#!/bin/bash

# Enable automatic export of variables
set -a

# Load the .env file from the project root
source "$(dirname "$0")/../../.env"

# Dynamically generate volume names based on the project
DB_VOLUME="${COMPOSE_PROJECT_NAME}_db_volume"
USERDATA_VOLUME="${COMPOSE_PROJECT_NAME}_userdata_volume"

# Check if the /restore folder exists and create it if necessary
if [ ! -d "/restore" ]; then
    mkdir -p /restore
fi

# Functions for the various restore processes

restore_db() {
    if [ -z "$1" ]; then
        echo "Restoring the latest database backup..."
        # Get the latest database backup
        LATEST_DB_BACKUP=$(ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "ls -t ${REMOTE_BACKUP_PATH}/db | head -n 1")
    else
        echo "Restoring database backup from $1..."
        LATEST_DB_BACKUP="database_$1.tar.gz"
    fi
    scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/db/${LATEST_DB_BACKUP} /restore/database.tar.gz
    docker run --rm -v ${DB_VOLUME}:/volume -v /restore:/restore alpine sh -c "tar -xzf /restore/database.tar.gz -C /volume"
    docker restart ${MYSQL_CONTAINER_NAME}
}

restore_userdata() {
    if [ -z "$1" ]; then
        echo "Restoring the latest userdata backup..."
        # Get the latest userdata backup
        LATEST_USERDATA_BACKUP=$(ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "ls -t ${REMOTE_BACKUP_PATH}/userdata | head -n 1")
    else
        echo "Restoring userdata backup from $1..."
        LATEST_USERDATA_BACKUP="userdata_$1.tar.gz"
    fi
    scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/userdata/${LATEST_USERDATA_BACKUP} /restore/userdata.tar.gz
    docker run --rm -v ${USERDATA_VOLUME}:/volume -v /restore:/restore alpine sh -c "tar -xzf /restore/userdata.tar.gz -C /volume"
    docker restart ${LUCEE_CONTAINER_NAME}
}

restore_lucee_image() {
    if [ -z "$1" ]; then
        echo "Restoring the latest Lucee image backup..."
        # Get the latest Lucee image backup
        LATEST_LUCEE_BACKUP=$(ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "ls -t ${REMOTE_BACKUP_PATH}/lucee | head -n 1")
    else
        echo "Restoring Lucee image backup from $1..."
        LATEST_LUCEE_BACKUP="image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_$1.tar"
    fi
    scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/lucee/${LATEST_LUCEE_BACKUP} /restore/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}.tar
    docker load -i /restore/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}.tar
}

list_backups() {
    echo "Available backups on remote server:"
    echo "Database backups:"
    ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "ls ${REMOTE_BACKUP_PATH}/db"
    echo ""
    echo "Userdata backups:"
    ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "ls ${REMOTE_BACKUP_PATH}/userdata"
    echo ""
    echo "Lucee image backups:"
    ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "ls ${REMOTE_BACKUP_PATH}/lucee"
    echo ""
}

# Show help if no options have been specified
if [ $# -eq 0 ]; then
    echo "Usage: $0 [--db [TIMESTAMP]] [--userdata [TIMESTAMP]] [--lucee-image [TIMESTAMP]] [--list]"
    exit 1
fi

# Process the specified options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --db) restore_db "$2"; shift ;;
        --userdata) restore_userdata "$2"; shift ;;
        --lucee-image) restore_lucee_image "$2"; shift ;;
        --list) list_backups; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Disable automatic export of variables
set +a
