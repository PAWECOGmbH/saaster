#!/bin/bash
set -a

LOGFILE="/var/log/backup-cron.log"
echo "[BACKUP SFTP MODE] $(date)" | tee -a $LOGFILE

source "$(dirname "$0")/../../.env"

SFTP_FLAGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o CheckHostIP=no -o LogLevel=ERROR -4"

DB_VOLUME="${COMPOSE_PROJECT_NAME}_db_volume"
USERDATA_VOLUME="${COMPOSE_PROJECT_NAME}_userdata_volume"
TIMESTAMP=$(date +"%Y%m%d_%H%M")

mkdir -p /backup

# -----------------------------------------
# CREATE REMOTE FOLDERS
# -----------------------------------------
echo "[SFTP] Ensuring remote folders exists..." | tee -a $LOGFILE

sftp -q -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} \
    ${SERVER_USER}@${SERVER_HOST} >/dev/null 2>&1 <<EOF
mkdir ${REMOTE_BACKUP_PATH}/db
mkdir ${REMOTE_BACKUP_PATH}/userdata
mkdir ${REMOTE_BACKUP_PATH}/lucee
EOF


# -----------------------------------------
# DB BACKUP
# -----------------------------------------
echo "[DB] Creating archive..." | tee -a $LOGFILE
docker run --rm -v ${DB_VOLUME}:/volume -v /backup:/backup alpine sh -c \
    "tar -czf /backup/database_${TIMESTAMP}.tar.gz -C /volume ." >> $LOGFILE 2>&1

echo "[DB] Uploading..." | tee -a $LOGFILE
scp -q -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} \
    /backup/database_${TIMESTAMP}.tar.gz \
    ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/db/ >/dev/null 2>&1

# verify remove
FILE="database_${TIMESTAMP}.tar.gz"
sftp -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} ${SERVER_USER}@${SERVER_HOST} <<EOF | grep "$FILE" >/dev/null
ls ${REMOTE_BACKUP_PATH}/db
EOF
[[ $? -eq 0 ]] && rm /backup/${FILE}

# -----------------------------------------
# USERDATA BACKUP
# -----------------------------------------
echo "[USERDATA] Creating archive..." | tee -a $LOGFILE
docker run --rm -v ${USERDATA_VOLUME}:/volume -v /backup:/backup alpine sh -c \
    "tar -czf /backup/userdata_${TIMESTAMP}.tar.gz -C /volume ." >> $LOGFILE 2>&1

echo "[USERDATA] Uploading..." | tee -a $LOGFILE
scp -q -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} \
    /backup/userdata_${TIMESTAMP}.tar.gz \
    ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/userdata/ >/dev/null 2>&1

FILE="userdata_${TIMESTAMP}.tar.gz"
sftp -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} ${SERVER_USER}@${SERVER_HOST} <<EOF | grep "$FILE" >/dev/null
ls ${REMOTE_BACKUP_PATH}/userdata
EOF
[[ $? -eq 0 ]] && rm /backup/${FILE}

# -----------------------------------------
# LUCEE IMAGE BACKUP
# -----------------------------------------
echo "[LUCEE] Saving Docker image..." | tee -a $LOGFILE
docker save -o /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar \
    ${LUCEE_IMAGE}:${LUCEE_IMAGE_VERSION} >> $LOGFILE 2>&1

echo "[LUCEE] Uploading..." | tee -a $LOGFILE
scp -q -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} \
    /backup/image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar \
    ${SERVER_USER}@${SERVER_HOST}:${REMOTE_BACKUP_PATH}/lucee/ >/dev/null 2>&1

FILE="image_${LUCEE_IMAGE}_${LUCEE_IMAGE_VERSION}_${TIMESTAMP}.tar"
sftp -i ${SSH_KEY_PATH} ${SFTP_FLAGS} -P ${SERVER_PORT} ${SERVER_USER}@${SERVER_HOST} <<EOF | grep "$FILE" >/dev/null
ls ${REMOTE_BACKUP_PATH}/lucee
EOF
[[ $? -eq 0 ]] && rm /backup/${FILE}

echo "[ROTATE] Cleaning up old remote backups..." | tee -a $LOGFILE

for folder in db userdata lucee; do
    echo "[ROTATE] Folder: $folder" >> $LOGFILE

    RAW=$(
        sftp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
            -b - "${SERVER_USER}@${SERVER_HOST}" <<EOF 2>/dev/null
ls -1 ${REMOTE_BACKUP_PATH}/${folder}
EOF
    )

    FILELIST=$(echo "$RAW" \
        | grep -v "^sftp>" \
        | grep -v "^ls" \
        | sed "s#${REMOTE_BACKUP_PATH}/${folder}/##"
    )

    [ -z "$FILELIST" ] && continue

    SORTED=$(echo "$FILELIST" | sort -r)

    DELETE=$(echo "$SORTED" | tail -n +$((${MAX_BACKUPS}+1)))

    DELETE_COUNT=$(echo "$DELETE" | grep -c .)

    [ "$DELETE_COUNT" -eq 0 ] && continue

    echo "[ROTATE] $DELETE_COUNT files will be deleted..." >> $LOGFILE

    BATCHFILE=$(mktemp)

    for file in $DELETE; do
        echo "rm \"${REMOTE_BACKUP_PATH}/${folder}/$file\"" >> "$BATCHFILE"
    done

    sftp -q -i "${SSH_KEY_PATH}" ${SFTP_FLAGS} -P "${SERVER_PORT}" \
        -b "$BATCHFILE" "${SERVER_USER}@${SERVER_HOST}" >/dev/null 2>&1

    rm "$BATCHFILE"

    echo "[ROTATE] $DELETE_COUNT files from $folder were deleted." >> $LOGFILE
done


echo "[BACKUP DONE] $(date)" | tee -a $LOGFILE

set +a