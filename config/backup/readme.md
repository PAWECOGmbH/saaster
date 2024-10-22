
# Backup for the Production and Staging Environments

**Purpose**

This directory contains the necessary configurations and scripts for backing up and restoring the **database**, **user data**, and the **Lucee image** in the **production** and **staging** environments. The backup and restore processes are automated using Docker and shell scripts to ensure consistency, reliability, and minimal manual intervention.

Note: These scripts are not intended for use in the **development** environment.


## **Structure**

-   **backup.sh**: A shell script that automates the process of creating backups for the **database volume**, **user data volume**, and **Lucee image**. Each backup is timestamped to ensure that multiple versions can be maintained. The script also uses `scp` to transfer the backups securely to a remote server.

-   **restore.sh**: A shell script that automates the process of restoring backups from the remote server. It retrieves the backups for the **database**, **user data**, and **Lucee image**, and restores them to the appropriate Docker volumes.

-   **.env**: Contains environment variables required for the backup and restore processes, such as volume names, SSH key, server IP, and remote paths. The backup does not have its own `.env` file; instead, it uses the `.env` file from the main project.

## **Usage**

### **Backup**

To create a backup of the **database**, **user data**, and **Lucee image**, follow these steps:

1.  Ensure that the `.env` file is correctly configured with your **production** or **staging** environment settings (e.g., volume names, remote server path, SSH keys, and server IP).

2.  Navigate to the `config/backup/` directory:
    `cd config/backup/`

3. Run the backup script:
`bash backup.sh`

This will:

-   Backup the **database volume**.
-   Backup the **user data volume**.
-   Backup the **Lucee image**.
-   Securely transfer all backups to the remote backup server.

Each backup will be **timestamped** in the format `YYYYMMDD_HHMM`, ensuring you can differentiate between multiple backup versions.

### **Restore**

To restore from a backup, first navigate to the `config/backup/` directory:
`cd config/backup/`

Then, if you run the restore script without any parameters:
`bash restore.sh`

It will display a list of available options, such as:
Usage: restore.sh [--db [TIMESTAMP]] [--userdata [TIMESTAMP]] [--lucee-image [TIMESTAMP]] [--list]

To perform a restore, you need to specify which backup you want to restore by using one of the following options:
 - To restore the **latest** backup for the **database**:
 `bash restore.sh --db`

 - To restore a **specific** database backup by **timestamp**:
 `bash restore.sh --db 20241019_2300`

- To list all available backups on the remote server:
 `bash restore.sh --list`


## **Automating Backups**

To automate the backup process, you can set up a **cron job** to run the backup script at regular intervals (e.g., daily). For example, to run the backup every night at midnight, add the following entry to your crontab:
`0 0 * * * /path/to/your/project/config/backup/backup.sh`


## **Notes**

-   These backups are intended for the **production** and **staging** environments. Ensure that the environment variables in the `.env` file are correctly configured before running any backups or restores.
-   The backup script automatically **rotates** backups, keeping only the **latest 30 backups** per backup type (database, user data, Lucee image) by removing older backups on the remote server.
-   Always ensure that your **SSH keys** and **server information** are secure, as they are used for transferring backups between the production or staging environment and the remote server.
