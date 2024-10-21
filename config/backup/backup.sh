#!/bin/bash

# Activates the automatic export of variables
set -a

# Load the .env file
source ../.env

# Deactivates the automatic export of variables
set +a

# Backup database
docker compose -f compose-backup.yml run db_backup
scp -i ${SSH_KEY_PATH} /backup/database.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}

# Backup userdata
docker compose -f compose-backup.yml run userdata_backup
scp -i ${SSH_KEY_PATH} /backup/userdata.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}

# Backup Lucee image
docker compose -f compose-backup.yml run lucee_image_backup
scp -i ${SSH_KEY_PATH} /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}.tar ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}