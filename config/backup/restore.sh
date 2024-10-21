#!/bin/bash

# Activates the automatic export of variables
set -a

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set the project root (assuming the script is two levels below the project root)
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Load the .env file from the project root
source "$PROJECT_ROOT/.env"

# Deactivates the automatic export of variables
set +a

# Checks whether the /restore folder exists and creates it if required
if [ ! -d "/restore" ]; then
    mkdir -p /restore
fi

# Restore database
scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/database.tar.gz /restore/
docker run --rm -v ${COMPOSE_PROJECT_NAME}_db_volume:/volume -v /restore:/backup alpine sh -c "cd /volume && tar -xzf /backup/database.tar.gz"
docker restart ${MYSQL_CONTAINER_NAME}

# Restore userdata
scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/userdata.tar.gz /restore/
docker run --rm -v ${COMPOSE_PROJECT_NAME}_userdata_volume:/volume -v /restore:/backup alpine sh -c "cd /volume && tar -xzf /backup/userdata.tar.gz"
docker restart ${LUCEE_CONTAINER_NAME}

# Restore Lucee image
scp -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}.tar /restore/
docker load -i /restore/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}.tar
