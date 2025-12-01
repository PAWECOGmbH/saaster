#!/bin/bash

# Load env
source "$(dirname "$0")/../../.env"

# ensure restore scripts are executable
chmod +x "$(dirname "$0")"/backup_ssh.sh 2>/dev/null
chmod +x "$(dirname "$0")"/backup_sftp.sh 2>/dev/null

if [[ "$BACKUP_MODE" == "ssh" ]]; then
    exec "$(dirname "$0")/backup_ssh.sh"
elif [[ "$BACKUP_MODE" == "sftp" ]]; then
    exec "$(dirname "$0")/backup_sftp.sh"
else
    echo "[ERROR] BACKUP_MODE is invalid → use \"ssh\" or \"sftp\"."
    exit 1
fi