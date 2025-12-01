#!/bin/bash

set -a

# --------------------------------------
# CONFIGURATION
# --------------------------------------

LOGFILE="/var/log/backup-cron.log"
echo "[BACKUP START] $(date)" | tee -a $LOGFILE

# Load environment variables from .env
source "$(dirname "$0")/../../.env"

# Setup volume names and timestamp
DB_VOLUME="${COMPOSE_PROJECT_NAME}_db_volume"
USERDATA_VOLUME="${COMPOSE_PROJECT_NAME}_userdata_volume"
TIMESTAMP=$(date +"%Y%m%d_%H%M")

# Ensure local backup directory exists
mkdir -p /backup

# Create remote directories if they don't exist
ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} \
  "mkdir -p ${REMOTE_BACKUP_PATH}/{db,userdata,lucee}" >> $LOGFILE 2>&1

# --------------------------------------
# DATABASE BACKUP
# --------------------------------------

echo "[DB] Creating archive..." | tee -a $LOGFILE
docker run --rm -v ${DB_VOLUME}:/volume -v /backup:/backup alpine sh -c \
  "tar -czf /backup/database_${TIMESTAMP}.tar.gz -C /volume ." >> $LOGFILE 2>&1

echo "[DB] Uploading to remote..." >> $LOGFILE
scp -i ${SSH_KEY_PATH} /backup/database_${TIMESTAMP}.tar.gz \
  ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/db/ >> $LOGFILE 2>&1

# Verify and delete local backup if transfer succeeded
ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} \
  "[ -f ${REMOTE_BACKUP_PATH}/db/database_${TIMESTAMP}.tar.gz ]" \
  && { echo "[DB] Remote verified, deleting local file" | tee -a $LOGFILE; rm /backup/database_${TIMESTAMP}.tar.gz; } \
  || echo "[DB] Remote file missing – NOT deleted" | tee -a $LOGFILE

# --------------------------------------
# USERDATA BACKUP
# --------------------------------------

echo "[USERDATA] Creating archive..." | tee -a $LOGFILE
docker run --rm -v ${USERDATA_VOLUME}:/volume -v /backup:/backup alpine sh -c \
  "tar -czf /backup/userdata_${TIMESTAMP}.tar.gz -C /volume ." >> $LOGFILE 2>&1

echo "[USERDATA] Uploading to remote..." | tee -a $LOGFILE
scp -i ${SSH_KEY_PATH} /backup/userdata_${TIMESTAMP}.tar.gz \
  ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/userdata/ >> $LOGFILE 2>&1

ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} \
  "[ -f ${REMOTE_BACKUP_PATH}/userdata/userdata_${TIMESTAMP}.tar.gz ]" \
  && { echo "[USERDATA] Remote verified, deleting local file" | tee -a $LOGFILE; rm /backup/userdata_${TIMESTAMP}.tar.gz; } \
  || echo "[USERDATA] Remote file missing – NOT deleted" | tee -a $LOGFILE

# --------------------------------------
# LUCEE IMAGE BACKUP
# --------------------------------------

echo "[LUCEE] Saving Docker image..." | tee -a $LOGFILE
docker save -o /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar \
  ${LUCEE_IMAGE}:${LUCEE_IMAGE_VERSION} >> $LOGFILE 2>&1

echo "[LUCEE] Uploading to remote..." | tee -a $LOGFILE
scp -i ${SSH_KEY_PATH} /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar \
  ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/lucee/ >> $LOGFILE 2>&1

ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} \
  "[ -f ${REMOTE_BACKUP_PATH}/lucee/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar ]" \
  && { echo "[LUCEE] Remote verified, deleting local file" | tee -a $LOGFILE; rm /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar; } \
  || echo "[LUCEE] Remote file missing – NOT deleted" | tee -a $LOGFILE

# --------------------------------------
# REMOTE ROTATION
# --------------------------------------

echo "[ROTATE] Cleaning up old remote backups..." | tee -a $LOGFILE
for folder in db userdata lucee; do
  ssh -i ${SSH_KEY_PATH} ${SERVER_USER}@${SERVER_HOST} \
    "cd ${REMOTE_BACKUP_PATH}/$folder && ls -tp | grep -v '/$' | tail -n +$((${MAX_BACKUPS}+1)) | xargs -I {} rm -- {}" >> $LOGFILE 2>&1
done

echo "[BACKUP DONE] $(date)" | tee -a $LOGFILE

set +a
