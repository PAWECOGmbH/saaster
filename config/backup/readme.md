# Borg backup and restore

These Linux server scripts use encrypted, deduplicated Borg 1.x repositories for Saaster. `backup.sh` and `restore.sh` are entry points for the Borg scripts; the former SSH/SFTP tar-backup format is no longer produced or restored. Existing backups are left untouched.

## Configure once

Run as root with Docker Compose v2, Borg 1.2 or newer within the 1.x series, Python 3, rsync, GNU coreutils, tar and flock installed. Remote repositories also require SSH and a compatible Borg server; SFTP-only access is insufficient. Allow enough free space in `BORG_WORK_DIR` for an uncompressed SQL dump, userdata and a copy of the deployed project.

### Install tools and prepare directories

On Debian/Ubuntu with Docker Compose already installed:

```bash
sudo apt update
sudo apt install -y borgbackup rsync openssh-client python3 coreutils tar util-linux logrotate
borg --version
docker compose version
sudo install -d -m 700 /backup /var/log/saaster-backup
```

Check that the installed Borg version is 1.2 or newer within the 1.x series; these scripts do not support Borg 2. See [Borg installation](https://borgbackup.readthedocs.io/en/1.4.0/installation.html) for other distributions. The examples use `/srv/saaster` for the project and `/var/log/saaster-backup` for logs; replace them with your installation's paths. Create your configured `BORG_WORK_DIR` if it differs from `/backup`.

### Configure the environment

Use the backup section in [`config/example.env`](../example.env) to configure the project's trusted, shell-compatible `.env`:

- Set `BACKUP_ENV=production` or `staging`. An empty value disables operations. `test` is reserved for the isolated test harness.
- Set `BORG_REPO` to an absolute local directory outside the project or an SSH repository URI. If empty, the scripts derive `ssh://SERVER_USER@SERVER_HOST:SERVER_PORT/./REMOTE_BACKUP_PATH/borg`. For an explicit URI, create its parent directory yourself.
- For SSH, set `SSH_KEY_PATH` and select the remote Borg executable with `BORG_REMOTE_PATH`. Verify the server's SSH host key before first use.
- Set `BORG_PASSPHRASE` in the server's private `.env`, using single quotes around the value. Keep `.env` readable only by the server administrator (`0600`) and out of Git. Keep recovery copies of the passphrase, SSH key and exported Borg key separately from the server and repository. `BORG_PASSPHRASE_FILE` and `BORG_PASSCOMMAND` remain optional alternatives; leave them unset when using `BORG_PASSPHRASE`.
- Retention defaults to 7 daily, 4 weekly and 12 monthly sets. At least one rule must retain backups. `BORG_WORK_DIR` defaults to `/backup` and must be outside the project.

### Prepare SSH access

For an SSH repository, install a dedicated private key from a secure location and register its matching public key with the backup provider. Replace `/secure/source/backup_ssh_key` with your existing key file:

```bash
sudo install -d -m 700 /root/.ssh
sudo install -m 600 /secure/source/backup_ssh_key /root/.ssh/saaster-backup
```

Ensure the backup account permits SSH access and Borg commands, and register the public key in that account's `authorized_keys` or through its administration interface. Use your own host, account and SSH port in these `.env` settings:

```dotenv
SERVER_USER=backup-user
SERVER_HOST=backup.example.com
SERVER_PORT=22
SSH_KEY_PATH=/root/.ssh/saaster-backup
REMOTE_BACKUP_PATH=saaster
BORG_REPO=
BORG_REMOTE_PATH=borg
```

`BORG_REMOTE_PATH` names the executable on the **backup server**, such as `borg` or `/usr/local/bin/borg`. Select a version compatible with your local Borg client; use a versioned executable name only if the server provides it. The local `borg --version` does not identify the remotely installed version.

Before accepting the first connection, obtain the backup server's host fingerprint through an independent trusted channel and compare it with the SSH prompt. Run the connection checks as root, as the scheduled backup will. Replace the example host, port and executable below to match your `.env`:

```bash
sudo ssh -4 -i /root/.ssh/saaster-backup -p 22 backup-user@backup.example.com pwd
sudo ssh -4 -o BatchMode=yes -o StrictHostKeyChecking=yes -i /root/.ssh/saaster-backup -p 22 backup-user@backup.example.com borg --version
```

The second command must succeed without a password or confirmation prompt. With `BORG_REPO` empty, `--init` creates `REMOTE_BACKUP_PATH` automatically and initializes its `borg` subdirectory. With an explicit repository URI, create its parent directory on the backup server first.

### Initialize and verify the first backup

Commands below run from the project root and read its `.env`. `ENV_FILE=/absolute/path` selects another trusted environment file. The standard server layout uses `compose.yml`; `BORG_COMPOSE_FILE` can select a project-relative alternative. Initialize a new repository only once:

`backup.sh` forwards to `backup_borg.sh`. If you are already in `config/backup/`, the equivalent initialization command is `sudo bash backup_borg.sh --init`.

```bash
cd /srv/saaster
sudo chmod 600 .env
sudo bash config/backup/backup.sh --init
# Export the Borg key to a separate, protected recovery location:
sudo install -d -m 700 /secure/recovery
sudo bash config/backup/backup.sh --export-key /secure/recovery/saaster-borg-key
sudo bash config/backup/backup.sh --backup
sudo bash config/backup/backup.sh --list
sudo bash config/backup/backup.sh --check
```

Keep an off-server copy of the exported key and passphrase. `--check` reads and verifies all repository data and can take a long time. A successful backup or repository check still needs a restore rehearsal before scheduling.

## What a backup contains

Each UTC timestamp (`YYYYMMDDTHHMMSSZ`) identifies four archives and a final `complete` record, prefixed with `COMPOSE_PROJECT_NAME-saaster-v1`:

| Archive | Contents |
| --- | --- |
| `db` | Logical dump of `MYSQL_DATABASE`, including Flyway histories, routines, events, triggers and binary values. |
| `userdata` | The project's named volume mounted at `/var/www/userdata`, including hidden files. |
| `config` | Deployed application code, `www/config.cfm`, server configuration, Compose files, Filebrowser database if present, and a protected copy of `.env`. Git metadata, logs, tests and demo data are excluded. |
| `lucee` | A temporary Docker snapshot of the stopped Lucee container, including administrator changes made since its original image was built. Mounted files are covered separately. |

Backups contain credentials and customer data. Keep repository access and recovery material private; never publish the snapshot image. Other host services, proxy configuration outside the project, external mounts, and MySQL system accounts are outside this recovery set. Additional Lucee mounts outside the supported project layout cause backup to fail.

Lucee and a running project Filebrowser are stopped while the dump, files and image snapshot are captured. Previously running services restart before Borg uploads the staged data. MySQL stays running. Pause deployments, migrations and any other database/file writers for the capture; the scripts cannot coordinate external processes. The SQL snapshot assumes transactional tables and no concurrent schema changes.

Only a finished four-archive set receives a `complete` record. Restore skips incomplete sets. Retention selects completion records, then removes their corresponding components, leaving other archive prefixes alone. Failed uploads may leave partial sets for inspection. If an existing completion record has missing components, retention stops with an error and preserves the remaining sets. A local lock prevents overlapping backup/restore runs for this project.

## Restore an existing installation

Pause external writers and select one timestamp for all recovery commands. Omitting `--timestamp` selects the newest complete set. First extract the configuration for inspection without changing the installation:

```bash
sudo bash config/backup/restore.sh --list
sudo bash config/backup/restore.sh --config --timestamp 20261113T020000Z
sudo bash config/backup/restore.sh --all --timestamp 20261113T020000Z --force
```

Copy the final `YYYYMMDDTHHMMSSZ` timestamp from a `...-complete-...` archive in `--list`, including `T` and `Z`; do not pass the full archive name as the timestamp.

`--config` prints the protected extraction directory and retains it. `--all` replaces application code and server configuration, restores `.env`, database and userdata, loads the archived image, and recreates MySQL plus services that were previously running. Local Git metadata, logs, tests and demo data remain excluded from synchronization. Review recovered configuration and paths before using `--all`.

The Compose project, database name, Compose file selection and MySQL credentials must match the backup. Use the recovered `.env` to prepare a new target when necessary: the application database dump does not restore MySQL system users. Configuration is sourced as trusted administrator code.

Individual actions are also available:

```bash
sudo bash config/backup/restore.sh --db --timestamp 20261113T020000Z --force
sudo bash config/backup/restore.sh --userdata --timestamp 20261113T020000Z --force
sudo bash config/backup/restore.sh --lucee-image --timestamp 20261113T020000Z --force
```

`--lucee-image` only loads the image; it does not recreate containers. Individual data restores keep the current code/configuration. Services that were stopped before restore remain stopped. Verify application access, customer data and uploads before reopening external writers.

Restore is not a database transaction. If an import or subsequent configuration change fails, data can be partially replaced. After changes have started, failure leaves Lucee/Filebrowser stopped and retains the staging directory and old userdata in a `.saaster-borg-rollback.*` directory inside its volume. Inspect and resolve the failure before restarting or retrying; do not delete the retained data blindly. Preflight failures leave application data unchanged.

### Recovery on a replacement host

1. Install the prerequisites and obtain these scripts plus repository credentials. Set the original `COMPOSE_PROJECT_NAME` and Borg access in a minimal trusted `.env`.
2. Run `--config` and `--lucee-image --force` for the same complete timestamp. Neither needs existing application containers.
3. Review the extracted `config/project` and `config/.env`, then place them in the intended project directory. The recovered `.env` selects the private snapshot image. Adjust host-specific paths/ports deliberately. Recreate required external Docker networks separately.
4. From that directory, run `docker compose up -d --no-deps mysql`, wait for MySQL to be ready, then `docker compose create lucee`. Enable/create Filebrowser separately if used. Do not start Flyway or other writers.
5. Run `restore.sh --all --timestamp ... --force`. Start the previously stopped Lucee with `docker compose up -d --no-deps lucee`, then verify the application before enabling other services.

## Scheduling and testing

### Restore rehearsal

Use a separate recovery host or Docker engine and follow [recovery on a replacement host](#recovery-on-a-replacement-host). Keep it isolated from live payment/mail services and scheduled jobs before starting the restored application. Record expected database records and uploaded-file hashes; make destructive test changes only in that disposable recovery copy. Restore one complete timestamp and verify login, database records, uploads and configuration afterward.

### Daily backup and log rotation

Schedule only after a successful manual backup and isolated restore. Scripts write to standard output/error and return a nonzero status on failure. Edit root's crontab with `sudo crontab -e`; this example runs daily at 02:00 in the server's timezone and captures both output streams:

```cron
0 2 * * * /bin/bash /srv/saaster/config/backup/backup.sh --backup >> /var/log/saaster-backup/backup.log 2>&1
```

The absolute script path works from cron's working directory. Because `/bin/bash` runs the script, no executable-bit change is needed. Check the log and monitor the exit status; [Borg also writes normal log output to stderr](https://borgbackup.readthedocs.io/en/1.4.0/usage/general.html#logging), so stderr output alone does not indicate failure.

Create root-owned `/etc/logrotate.d/saaster-backup` with these contents, adjusting the log path to match cron:

```conf
/var/log/saaster-backup/*.log {
    daily
    rotate 14
    maxage 14
    missingok
    notifempty
    compress
    delaycompress
    create 0600 root root
}
```

Check the configuration without rotating logs:

```bash
sudo logrotate --debug /etc/logrotate.d/saaster-backup
```

Ensure the server's logrotate timer or daily cron task is enabled. Each backup run opens the log again; an in-progress run can finish writing to the rotated file.

### Automated isolated test

Check snapshot metadata compatibility without Docker or credentials:

```bash
bash www/tests/bin/check_borg_metadata.sh
```

The manual integration test creates its own random credentials, test database, encrypted local Borg repository, containers and volumes. It restores after deleting the fixture's data volumes and checks application login, database objects, userdata, code/configuration and runtime settings:

```bash
bash www/tests/bin/check_borg_backup.sh
```

It requires a local Linux Docker engine (Docker Desktop works), Git, Bash and tar. It does not load the checkout's local credentials, use staging/production, or run automatically on development commits. See the [test workspace guide](../../www/tests/README.md).

## Docker 29 snapshot metadata

Older backup scripts stored a Docker 29 deprecation warning together with the image ID, causing restore to stop with `Invalid snapshot image identity`. Updated backup scripts inspect the snapshot image directly. Updated restore scripts recognize that specific historical warning and still require the loaded image ID to match the recorded SHA-256 identity. Affected backups can be restored without editing the repository archives.

A full restore also reinstates the backed-up scripts. If that backup predates this fix, reapply the updated backup/restore scripts afterward.
