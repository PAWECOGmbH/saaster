# Borg backup and restore

These Linux server scripts use encrypted, deduplicated Borg 1.x repositories for Saaster. `backup.sh` and `restore.sh` are entry points for the Borg scripts; the former SSH/SFTP tar-backup format is no longer produced or restored. Existing backups are left untouched.

## Configure once

Run as root with Docker Compose v2, Borg 1.2 or newer within the 1.x series, Python 3, rsync, GNU coreutils, tar and flock installed. Remote repositories also require SSH and a compatible Borg server; SFTP-only access is insufficient. Allow enough free space in `BORG_WORK_DIR` for an uncompressed SQL dump, userdata and a copy of the deployed project.

Use the backup section in [`config/example.env`](../example.env) to configure the project's trusted, shell-compatible `.env`:

- Set `BACKUP_ENV=production` or `staging`. An empty value disables operations. `test` is reserved for the isolated test harness.
- Set `BORG_REPO` to an absolute local directory outside the project or an SSH repository URI. If empty, the scripts derive `ssh://SERVER_USER@SERVER_HOST:SERVER_PORT/./REMOTE_BACKUP_PATH/borg`. For an explicit URI, create its parent directory yourself.
- For SSH, set `SSH_KEY_PATH` and the remote Borg executable in `BORG_REMOTE_PATH` (default `borg-1.2`). Verify the server's SSH host key before first use.
- Set `BORG_PASSPHRASE_FILE` to a root-readable file outside the checkout, with permissions `0600`. `BORG_PASSCOMMAND` or an exported `BORG_PASSPHRASE` also work. Keep recovery copies of the passphrase, SSH key and exported Borg key separately from the server and repository.
- Retention defaults to 7 daily, 4 weekly and 12 monthly sets. At least one rule must retain backups. `BORG_WORK_DIR` defaults to `/backup` and must be outside the project.

Commands below run from the project root and read its `.env`. `ENV_FILE=/absolute/path` selects another trusted environment file. The standard server layout uses `compose.yml`; `BORG_COMPOSE_FILE` can select a project-relative alternative.

```bash
sudo bash config/backup/backup.sh --init
# Export the Borg key to a separate, protected recovery location:
sudo bash config/backup/backup.sh --export-key /secure/recovery/saaster-borg-key
sudo bash config/backup/backup.sh --backup
sudo bash config/backup/backup.sh --list
sudo bash config/backup/backup.sh --check
```

`--check` reads and verifies all repository data and can take a long time.

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

Schedule only after a successful manual backup and isolated restore. Scripts write to standard output/error and return a nonzero status on failure. Redirect cron output to a protected log and monitor failures, for example:

```cron
0 2 * * * /bin/bash /srv/saaster/config/backup/backup.sh --backup >> /var/log/saaster-backup.log 2>&1
```

The manual integration test creates its own random credentials, test database, encrypted local Borg repository, containers and volumes. It restores after deleting the fixture's data volumes and checks application login, database objects, userdata, code/configuration and runtime settings:

```bash
bash www/tests/bin/check_borg_backup.sh
```

It requires a local Linux Docker engine (Docker Desktop works), Git, Bash and tar. It does not load the checkout's local credentials, use staging/production, or run automatically on development commits. See the [test workspace guide](../../www/tests/README.md).
