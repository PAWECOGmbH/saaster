#!/bin/bash

# Enable automatic export of variables
set -a

# Load the .env file from the project root
source "$(dirname "$0")/../../.env"

# Dynamically generate volume names based on the project
DB_VOLUME="${COMPOSE_PROJECT_NAME}_db_volume"
USERDATA_VOLUME="${COMPOSE_PROJECT_NAME}_userdata_volume"

# Date format for versioning (e.g., 20241022_2300)
TIMESTAMP=$(date +"%Y%m%d_%H%M")

# Check if the /backup folder exists and create it if necessary
if [ ! -d "/backup" ]; then
    mkdir -p /backup
fi

# Create remote directories if they don't exist
ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "mkdir -p ${REMOTE_BACKUP_PATH}/db ${REMOTE_BACKUP_PATH}/userdata ${REMOTE_BACKUP_PATH}/lucee"

# Backup database volume and store in the remote db directory
docker run --rm -v ${DB_VOLUME}:/volume -v /backup:/backup alpine sh -c "tar -czf /backup/database_${TIMESTAMP}.tar.gz -C /volume ."
scp -i ${SSH_KEY_PATH} /backup/database_${TIMESTAMP}.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/db/

# Backup userdata volume and store in the remote userdata directory
docker run --rm -v ${USERDATA_VOLUME}:/volume -v /backup:/backup alpine sh -c "tar -czf /backup/userdata_${TIMESTAMP}.tar.gz -C /volume ."
scp -i ${SSH_KEY_PATH} /backup/userdata_${TIMESTAMP}.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/userdata/

# Backup Lucee image and store in the remote lucee directory
docker save -o /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar ${LUCEE_IMAGE}:${LUCEE_IMAGE_VERSION}
scp -i ${SSH_KEY_PATH} /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}/lucee/

# Rotate backups: Keep only the latest 30 backups per type

# For database backups
ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "cd ${REMOTE_BACKUP_PATH}/db && ls -tp | grep -v '/$' | tail -n +31 | xargs -I {} rm -- {}"

# For userdata backups
ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "cd ${REMOTE_BACKUP_PATH}/userdata && ls -tp | grep -v '/$' | tail -n +31 | xargs -I {} rm -- {}"

# For Lucee image backups
ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_IP} "cd ${REMOTE_BACKUP_PATH}/lucee && ls -tp | grep -v '/$' | tail -n +31 | xargs -I {} rm -- {}"

# Disable automatic export of variables
set +a
