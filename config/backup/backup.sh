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

# Checks whether the /backup folder exists and creates it if required
if [ ! -d "/backup" ]; then
    mkdir -p /backup
fi

# Backup database
docker compose -f compose-backup.yml run db_backup
scp -i ${SSH_KEY_PATH} /backup/database.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}

# Backup userdata
docker compose -f compose-backup.yml run userdata_backup
scp -i ${SSH_KEY_PATH} /backup/userdata.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}

# Backup Lucee image
docker compose -f compose-backup.yml run lucee_image_backup
scp -i ${SSH_KEY_PATH} /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}.tar ${SERVER_USER}@${SERVER_IP}:${REMOTE_BACKUP_PATH}