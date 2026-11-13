# Saaster

A CFML framework for building SaaS applications, with authentication, customer and tenant management, subscriptions, invoicing, and APIs. Extend it with your own application code, modules, and themes.

[Website](https://www.saaster.io) · [Demo](https://app.saaster.io) · [Documentation](https://docs.saaster.io) · [Contributing](CONTRIBUTING.md) · [MIT license](LICENSE)

**Stack:** Lucee 7 · NGINX · MySQL 8.1 · Docker Compose · Flyway

> **Development version:** No tagged release is available yet. Use `development` for local evaluation and contributions.

## Development setup

These instructions cover local development with the configuration examples in this repository.

You need Git, Docker with the Docker Compose plugin, and familiarity with CFML and SQL. Commands use Bash syntax; on Windows, use Git Bash. The test tools also require `curl`.

### 1. Clone and configure

```bash
git clone https://github.com/PAWECOGmbH/saaster
cd saaster
cp config/example.env .env
mkdir -p config/nginx/conf.d
cp config/example.base.conf config/nginx/conf.d/base.conf
cp config/example.config_dev.cfm www/config.cfm
```

Edit `.env` and `www/config.cfm` for your installation. Keep container names and published ports unique on the Docker host. If you change `LUCEE_PORT`, also update `variables.mainURL` in `www/config.cfm` and the browser URLs below.

The [environment example](config/example.env) currently selects `lucee/lucee:7.1.1.17-nginx`; both Compose files select `mysql:8.1`. Flyway and Inbucket currently use floating image tags.

### 2. Start the development stack

```bash
docker compose -f compose-dev.yml up -d
docker compose -f compose-dev.yml ps -a
docker compose -f compose-dev.yml logs flyway
```

The stack starts Lucee with NGINX, MySQL, Inbucket, and a one-off Flyway migration service. Confirm that Flyway finishes successfully before opening the setup wizard.

The example `.env` selects `FLYWAY_DB_FOLDER=core`. Flyway mounts and migrates the selected folder and records its history in `flyway_core` or `flyway_myapp`. To apply project migrations after the core migrations, run:

```bash
FLYWAY_DB_FOLDER=myapp docker compose -f compose-dev.yml run --rm --no-deps flyway
```

Keep `FLYWAY_MIGRATION_TYPE=migrate` for installation. The current project migration folder contains an empty baseline for future application-specific migrations.

### 3. Configure Lucee

Open the Lucee Server Administrator at [localhost:8080/lucee/admin/server.cfm](http://localhost:8080/lucee/admin/server.cfm). Use the password configured in `.env`.

| Setting | Value |
| --- | --- |
| MySQL datasource name | Match `variables.datasource` in `www/config.cfm`; the development example uses `saaster_dev`. |
| MySQL host and port | `MYSQL_CONTAINER_NAME` from `.env`, port `3306` inside the Docker network. |
| MySQL database and credentials | `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` from `.env`. |
| MySQL connection option | Enable **Allow Multiple Queries**. |
| Local SMTP host and port | `INBUCKET_CONTAINER_NAME` from `.env`, port `2500` inside the Docker network. |

The browser and other host tools use the published ports from `.env`. Container-to-container connections use the internal ports shown above.

### 4. Complete setup and registration

1. Open [localhost:8080/setup/index.cfm](http://localhost:8080/setup/index.cfm) and complete the wizard.
2. Complete the first registration **before importing demo customers**. On an empty installation, the first registered customer's user receives Sysadmin privileges.
3. Open [Inbucket at localhost:9000](http://localhost:9000) to read registration and other local emails.

After changing `www/config.cfm`, reload application configuration through [localhost:8080/index.cfm?reinit=1](http://localhost:8080/index.cfm?reinit=1).

## Optional: load test data

The scripts in [`config/db/dev/`](config/db/dev/) add demo data after setup and registration. Apply them in the order below. Tables are created by the migrations.

**Use a disposable development database.** Reimporting these scripts replaces fixed IDs and can remove linked bookings, translations, prices, and other dependent records. Read each script's header before importing it.

| Order | Script | Content |
| --- | --- | --- |
| 1 | `create-plans.sql` | Four plans, features, and prices in USD, EUR, and CHF; CHF examples use 8.1% VAT. |
| 2 | `create-modules.sql` | Three demo module definitions: Todo, Easy ERP, and MailChimp API, with prices and settings mappings. |
| 3 | `create-widgets.sql` | Five widgets demonstrating visibility, plan/module assignments, and deactivation. |
| 4 | `create-customers.sql` | Twelve customer records: ten main accounts and two sub-tenants, with users, bookings, invoices, payments, and notifications. |
| 5 | `create-notifications.sql` | Notifications for customer 1 and user 1, when that account exists. |

Replace the uppercase placeholders in this command with your values from `.env`:

```bash
for seed in create-plans create-modules create-widgets create-customers create-notifications; do
    docker exec -i MYSQL_CONTAINER_NAME mysql --user=MYSQL_USER --password=MYSQL_PASSWORD MYSQL_DATABASE < "config/db/dev/${seed}.sql"
done
```

The demo users share the password `Saaster-Demo-2026!`, for example `anna.meier@alpine-bakery.example` or `oliver.smith@brightpixel.example`. Their scenarios are listed at the top of `create-customers.sql`.

Module definitions are demonstration metadata, not complete product integrations. In particular, the repository does not implement a MailChimp API integration.

## Testing

The TestBox workspace in [`www/tests/`](www/tests/README.md) uses a dedicated database, `saaster_test_db` by default. The test application requires `variables.environment = "dev"` in `www/config.cfm`.

The full suite can exceed NGINX's default 60-second proxy timeout (HTTP 504). For local testing, add `proxy_read_timeout 300s;` inside `location @lucee` in `config/nginx/conf.d/base.conf`, then validate and reload NGINX:

```bash
docker compose -f compose-dev.yml exec -T lucee nginx -t
docker compose -f compose-dev.yml exec -T lucee nginx -s reload
```

With the configured development stack running, prepare the test environment once:

```bash
bash www/tests/bin/install_test_dependencies.sh
bash www/tests/bin/prepare_test_db.sh
```

`prepare_test_db.sh` drops and recreates the dedicated test database. Use it for initial setup or an intentional reset. For normal runs:

```bash
bash www/tests/bin/run_tests.sh 'reporter=mintext'
```

The browser runner is at [localhost:8080/tests/runner.cfm](http://localhost:8080/tests/runner.cfm). For new migrations, use `bash www/tests/bin/migrate_test_db.sh` on the existing test database.

Use the local payment mocks and Inbucket. See [CONTRIBUTING.md](CONTRIBUTING.md#validate-the-change) for validation expectations and the [test workspace guide](www/tests/README.md) for fixtures, targeted runs, and cleanup.

## Preserve configurations with a custom Docker image

Lucee administrator settings are stored inside the container unless separately persisted. You can save a configured development container as a local image:

```bash
docker compose -f compose-dev.yml stop lucee
docker commit "$(docker compose -f compose-dev.yml ps -a -q lucee)" saaster-local:dev-configured
```

Set the image name and tag separately in `.env`:

```dotenv
LUCEE_IMAGE=saaster-local
LUCEE_IMAGE_VERSION=dev-configured
```

Then recreate the Lucee service from the saved image:

```bash
docker compose -f compose-dev.yml up -d lucee
```

This saves changes in the container filesystem. Docker does **not** include bind mounts or named volumes in a [container commit](https://docs.docker.com/reference/cli/docker/container/commit/): application files, `.env`, `www/config.cfm`, database data, and user data need separate backups. The saved image can contain datasource or SMTP credentials; keep it private.

Changing Lucee through its Administrator does not update the source Docker image. Before recreating the container, preserve its settings or provide them through the replacement image/configuration.

## Live setup

The following notes describe the supplied deployment configuration.

### Production and staging with one compose.yml

[`compose.yml`](compose.yml) provides Lucee with NGINX, MySQL, a one-off Flyway service, and an optional File Browser. It connects to the external Docker network `npm_network`, which must already exist.

| `COMPOSE_PROFILES` in the server's `.env` | Services included by `docker compose -f compose.yml up -d` |
| --- | --- |
| Empty | Lucee, MySQL, and the one-off Flyway migration service. |
| `filebrowser` | The same services, plus File Browser. |

The environment example enables the `filebrowser` profile. Each server's `.env` determines its active profiles. As in development, Flyway applies only the migration folder selected by `FLYWAY_DB_FOLDER`.

Tests and fixtures (`www/tests/`), SQL demo data (`config/db/dev/`), and the legacy mock-data generator (`www/setup/mockdata/`) remain tracked in Git and are included in forks. Both deployment workflows use the shared [deployment filter](.github/deploy.rsync-filter) to omit these directories and remove previously deployed copies. Server configuration and user data retain their existing exclusions. The workflows run a local fixture check on the GitHub Actions runner before uploading files; they do not execute TestBox on the target server.

Before staging deployment, a separate GitHub test job runs the full TestBox suite in a disposable Docker stack. Failed checks block the upload and server migrations. This runs only for pushes to `staging`; pushes to `development` do not trigger tests. See the [test workspace guide](www/tests/README.md#staging-deployment-checks) to reproduce the job locally.

Inspect the selected services before starting them:

```bash
docker compose -f compose.yml config --services
```

If you disable a profile while its service is already running, stop and remove that service separately. For File Browser:

```bash
docker compose -f compose.yml stop filebrowser
docker compose -f compose.yml rm filebrowser
```

## Branches

| Branch | Purpose |
| --- | --- |
| `development` | Default branch for ongoing work and external pull requests; may contain incomplete changes. |
| `staging` | Integration and acceptance branch. |
| `production` | Approved deployment branch. |

Pushes to `staging` and `production` trigger deployment workflows and database migrations. Open contributions against `development`.

Use the instructions in this repository for the code you checked out. The public documentation still describes an older setup with `make`, different configuration files, and Mailslurper.

## Contributing

Create a branch from `development` in your fork and target `development` when opening a pull request. PAWECO maintains the project's direction and reviews changes before merging.

[CONTRIBUTING.md](CONTRIBUTING.md) covers the workflow and validation. Shared project and coding rules are maintained in [AGENTS.md](AGENTS.md).

## Dependencies

Key libraries used by the application and development tools include:

- **Interface:** [Tabler](https://github.com/tabler/tabler), [Bootstrap](https://github.com/twbs/bootstrap), [jQuery](https://github.com/jquery/jquery), and [Tabler Icons](https://github.com/tabler/tabler-icons).
- **Editor and uploads:** [HugeRTE](https://github.com/hugerte/hugerte) and [Dropify](https://github.com/JeremyFagis/dropify).
- **API:** [Taffy](https://github.com/atuttle/Taffy).
- **Password hashing and QR codes:** [Bouncy Castle](https://www.bouncycastle.org/about/license/) and [ZXing](https://github.com/zxing/zxing), bundled under `www/assets/java/`.
- **Development and tests:** [MockDataCFC](https://github.com/Ortus-Solutions/MockDataCFC) and [TestBox](https://github.com/Ortus-Solutions/TestBox).
