# Backup for the Production and Staging Environments

## Purpose

This directory contains the scripts and configuration required to back up and restore the **database**, **user data**, and the **Lucee Docker image** in the **production** and **staging** environments.

The backup and restore processes are automated using Docker and shell scripts to ensure consistency, reliability, and minimal manual work.

> These scripts are **not** intended for the **development** environment.

Backup and restore support two modes, controlled by the `.env` variable `BACKUP_MODE`:

- `BACKUP_MODE=ssh` – Backups are sent to a normal SSH server with full shell access.
- `BACKUP_MODE=sftp` – Backups are sent to an SFTP-only target (e.g. Hetzner Storage Box, usually on port 23).


## Structure

### Entry scripts

- **backup.sh**  
  Main entry point for creating backups.
  - Loads the project `.env` from the repository root.
  - Reads `BACKUP_MODE` (`ssh` or `sftp`).
  - Delegates to:
    - `backup_ssh.sh` in SSH mode, or
    - `backup_sftp.sh` in SFTP mode.

- **restore.sh**  
  Main entry point for restoring backups.
  - Loads the project `.env`.
  - Reads `BACKUP_MODE` (`ssh` or `sftp`).
  - Delegates to:
    - `restore_ssh.sh` in SSH mode, or
    - `restore_sftp.sh` in SFTP mode.


### Backup scripts

- **backup_ssh.sh**  
  Creates timestamped backups and transfers them to a remote SSH server via `scp`:
  - **Database volume**
  - **User data volume**
  - **Lucee Docker image** (via `docker save`)

  Files are stored in subfolders under `REMOTE_BACKUP_PATH` on the remote server:

  - `${REMOTE_BACKUP_PATH}/db`
  - `${REMOTE_BACKUP_PATH}/userdata`
  - `${REMOTE_BACKUP_PATH}/lucee`

- **backup_sftp.sh**  
  Functionally equivalent to the SSH variant, but tailored for SFTP-only targets, such as Hetzner Storage Box:
  - Creates tar archives for:
    - **Database volume** (`database_YYYYMMDD_HHMM.tar.gz`)
    - **User data volume** (`userdata_YYYYMMDD_HHMM.tar.gz`)
    - **Lucee Docker image** (`image_<LUCEE_IMAGE>_<LUCEE_IMAGE_VERSION>_YYYYMMDD_HHMM.tar`)
  - Uploads files using `scp`/SFTP with:
    - `SSH_KEY_PATH`
    - `SERVER_USER`
    - `SERVER_HOST`
    - `SERVER_PORT`
  - Stores files under:
    - `${REMOTE_BACKUP_PATH}/db`
    - `${REMOTE_BACKUP_PATH}/userdata`
    - `${REMOTE_BACKUP_PATH}/lucee`
  - Performs **remote rotation**:
    - Only the last `MAX_BACKUPS` backups per folder are kept; older files are deleted via SFTP batch commands.
  - Writes backup logs to: `/var/log/backup-cron.log`


### Restore scripts

- **restore_ssh.sh / restore_sftp.sh**

  Both scripts offer the same CLI and behavior, but use different protocols under the hood:

  - **Database restore**
    - Downloads the selected `database_*.tar.gz` archive from `${REMOTE_BACKUP_PATH}/db`
    - Extracts contents into the database volume using a temporary Alpine container
    - Restarts the MySQL container (`MYSQL_CONTAINER_NAME`)

  - **User data restore**
    - Downloads the selected `userdata_*.tar.gz` archive from `${REMOTE_BACKUP_PATH}/userdata`
    - Extracts contents into the userdata volume
    - Restarts the Lucee container (`LUCEE_CONTAINER_NAME`)

  - **Lucee image restore**
    - Downloads the selected `image_<LUCEE_IMAGE>_<LUCEE_IMAGE_VERSION>_*.tar` from `${REMOTE_BACKUP_PATH}/lucee`
    - Loads it via `docker load`

  - **Automatic latest selection**
    - If you do **not** pass a timestamp, the scripts will automatically select the **newest** file based on the lexicographically last filename (timestamps in `YYYYMMDD_HHMM`).

  - **Listing**
    - `--list` prints all available backups in the three folders (`db`, `userdata`, `lucee`) on the remote server.


### Environment variables (`.env`)

The backup/restore scripts use the main project `.env` (in the repository root). Relevant variables include:

- Project / volumes:
  - `COMPOSE_PROJECT_NAME`
- Mode:
  - `BACKUP_MODE` (`ssh` or `sftp`)
- Backup retention:
  - `MAX_BACKUPS`
- Remote target:
  - `REMOTE_BACKUP_PATH`
  - `SERVER_USER`
  - `SERVER_HOST`
  - `SERVER_PORT`
  - `SSH_KEY_PATH`
- Docker / containers:
  - `LUCEE_IMAGE`, `LUCEE_IMAGE_VERSION`
  - `MYSQL_CONTAINER_NAME`
  - `LUCEE_CONTAINER_NAME`

There is **no separate `.env`** for the backup – everything is driven by the main project `.env` file.


## Usage

### 1. Creating a backup

To create a backup of the **database**, **user data**, and the **Lucee image**:

1. Make sure your project `.env` is correctly configured for the **staging** or **production** environment, including:
   - volume names (via `COMPOSE_PROJECT_NAME`)
   - `BACKUP_MODE` (`ssh` or `sftp`)
   - `REMOTE_BACKUP_PATH`
   - `SERVER_USER`, `SERVER_HOST`, `SERVER_PORT`
   - `SSH_KEY_PATH`
   - container names and image names

2. Change into the backup directory:

   ```bash
   cd config/backup/
   ```

3. Run the backup:

   ```bash
   bash backup.sh
   ```

The script will:

- Read `BACKUP_MODE` from `.env`
- Create backups for:
  - database volume
  - userdata volume
  - Lucee Docker image
- Name all backups with a timestamp, e.g. `YYYYMMDD_HHMM`
- Upload the files to the configured remote server
- Remove local backup files **only if** the corresponding file exists on the remote side (upload verification)


### 2. Restoring from a backup

1. Change into the backup directory:

   ```bash
   cd config/backup/
   ```

2. Run the restore script without arguments to see usage:

   ```bash
   bash restore.sh
   ```

   Example output:

   ```text
   Usage:
     restore.sh --db [TIMESTAMP]
     restore.sh --userdata [TIMESTAMP]
     restore.sh --lucee-image [TIMESTAMP]
     restore.sh --list
   ```

3. Examples:

   - **Restore the latest database backup:**

     ```bash
     bash restore.sh --db
     ```

   - **Restore a specific database backup by timestamp:**

     ```bash
     bash restore.sh --db 20241019_2300
     ```

   - **Restore the latest userdata backup:**

     ```bash
     bash restore.sh --userdata
     ```

   - **Restore the latest Lucee image backup:**

     ```bash
     bash restore.sh --lucee-image
     ```

   - **List available backups on the remote server:**

     ```bash
     bash restore.sh --list
     ```

For each restore:

- The selected file is downloaded to `/restore/`
- The archive is extracted or loaded
- The corresponding container (MySQL or Lucee) is restarted when required
- The temporary file in `/restore/` is deleted afterwards to keep the filesystem clean


## Automating backups

To automate the backup process, you can configure a cron job on the server.

Example: run the backup every night at 02:00:

```cron
0 2 * * * /path/to/your/project/config/backup/backup.sh
```

Backup logs are written to:

```text
/var/log/backup-cron.log
```

You can use this log file to verify that the backups ran successfully and to troubleshoot problems.


## Notes and guarantees

- These scripts are designed for **staging** and **production** environments.
- Always double-check your `.env` before running backup or restore.
- The scripts use:
  - `set -e` and
  - an `ERR` trap in the restore scripts  
  so the process aborts immediately on the first error. This avoids “half-finished” restores.
- Remote backups are **rotated automatically**:
  - Only the latest `MAX_BACKUPS` files per type (`db`, `userdata`, `lucee`) are kept.
- Transfer modes:
  - **SSH mode** (`BACKUP_MODE=ssh`): uses standard SSH/`scp` towards a server where you have full shell access.
  - **SFTP mode** (`BACKUP_MODE=sftp`): uses SFTP/`scp` towards an SFTP-only environment (e.g. Hetzner Storage Box, typically port 23, no custom scripts on the remote side).
- In both modes:
  - Local backup files are only deleted after a successful presence check on the remote destination.
  - When no timestamp is provided, the restore scripts will always pick the **most recent** backup file based on its name.
