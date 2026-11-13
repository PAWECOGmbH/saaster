# Customize Saaster and update your fork

Start with the [development setup](../readme.md#development-setup). Keep your application in a fork with its own branch; use a separate branch for each Saaster update.

## Where your code belongs

| Change | Location |
| --- | --- |
| Application services, backend views and handlers | `www/backend/myapp/`, with subdirectories such as `com/`, `views/` and `handler/`. |
| Application lifecycle hooks | `www/backend/myapp/ownApplication.cfc`: `ownApplicationStart`, `ownSessionStart`, `ownRequestStart` and `ownRequest`. |
| Backend navigation and login integration | `www/backend/myapp/navigation.cfm` and `login_include.cfm`. |
| Feature modules | A uniquely named directory under `www/backend/modules/`; existing modules illustrate `navigation.cfm`, `login_include.cfm` and `deletion.cfc`. |
| Frontend templates, CSS, JavaScript and images | `www/frontend/custom_theme/`; select it with `variables.activeTheme = "custom_theme"` in `www/config.cfm`. |
| Project database changes | New versioned SQL files under `config/db/myapp/`. |
| Local configuration | `.env`, `www/config.cfm` and generated server configuration; keep credentials out of Git. |

These are extension locations, not automatic override directories. A new CFC can be called by your application; a new template is not automatically a public route. Register backend pages through the Sysadmin mappings/module configuration and apply the [extension permission contract](extension-permissions.md). A module directory alone does not activate a product or grant access.

Use a project-specific name for new files and module prefixes. The existing files in `myapp`, `modules` and `custom_theme` are also shipped by Saaster: updates can change them and cause conflicts. Prefer adding project files and calling them from the hooks over replacing core behavior. Changes to `www/backend/core/`, `www/frontend/core/`, `www/Application.cfc` or vendor assets require explicit reconciliation with upstream changes.

Keep lifecycle work appropriate to its frequency: application startup runs again after reinitialization, session startup runs for new sessions, and request hooks run on requests. Do not run schema migrations in these hooks. After changes, log in as a Sysadmin and reload configuration and permission manifests with `/index.cfm?reinit=1`.

Use explicit `<cfoutput>` blocks around dynamic HTML in included templates. Put custom styling in project stylesheets and use the locally hosted Tabler icons. See [AGENTS.md](../AGENTS.md) for coding conventions, [request access](request-access.md) for routed actions, and [account deletion](module-account-deletion.md) for application/module cleanup hooks.

## Project migrations

Choose the next unused version in your project's `config/db/myapp/` history, for example `V2__create_project_records.sql` after the supplied `V1__baseline.sql`. Start every file with `SET NAMES utf8mb4;` and save it as UTF-8. Keep already applied migrations unchanged; add another migration for a correction.

Core and project migrations have separate histories (`flyway_core` and `flyway_myapp`). Do not put project changes in `config/db/core/` or use `config/db/dev/` as a production migration folder. On a development copy, apply project migrations with:

```bash
FLYWAY_DB_FOLDER=myapp FLYWAY_MIGRATION_TYPE=migrate docker compose -f compose-dev.yml run --rm --no-deps flyway
```

For automated tests, apply pending migrations to the existing dedicated test database with `bash www/tests/bin/migrate_test_db.sh`. `prepare_test_db.sh` recreates that database and is intended for initial setup or an intentional reset.

## Bring a Saaster update into your fork

### 1. Select and inspect the upstream change

Run these commands in your local development checkout, not in a deployed server directory. `origin` should refer to your fork. Check the remotes; add `upstream` only if it is not already configured:

```bash
git remote -v
git remote add upstream https://github.com/PAWECOGmbH/saaster.git
git fetch upstream
```

Use a verified release tag when one is available. Until then, select a reviewed commit; a branch name moves over time. This example resolves `development` to one exact commit:

```bash
UPSTREAM_REF=upstream/development
UPSTREAM_COMMIT=$(git rev-parse --verify "${UPSTREAM_REF}^{commit}")
git log --oneline HEAD.."$UPSTREAM_COMMIT"
git diff --stat HEAD..."$UPSTREAM_COMMIT"
```

Read the changed documentation, runtime requirements, environment examples and both migration directories. Reconcile new example settings with your local configuration; do not replace `.env` or `www/config.cfm` with examples. Preserve Lucee administrator settings before recreating containers; see [custom images](../readme.md#preserve-configurations-with-a-custom-docker-image).

### 2. Prepare a local rehearsal

Start from your application's branch with a clean working tree. Save project changes in your fork before the update; `git status --short` must show no pending work. Local ignored configuration and userdata can still exist.

Use a separate project copy with disposable data. Give it its own Compose project/container names, ports and database names, and its own volumes. Review explicit volume names and external networks as well: changing the checkout directory alone does not isolate an installation. Replace payment/mail credentials with local mocks and Inbucket. Keep automated test writes in a dedicated database with `test` in its name.

Before changing an existing installation, create a complete [Borg backup](../config/backup/readme.md) and verify recovery in isolation. It must cover matching code, configuration, Lucee state, database and userdata. Stop other writers and deployments as described in that guide.

### 3. Merge on an update branch

Choose an unused update branch name. The following command leaves the merge uncommitted for review, including when the update could otherwise fast-forward:

```bash
git switch -c update/saaster
git merge --no-commit --no-ff "$UPSTREAM_COMMIT"
git status --short
```

For each conflict, compare your change with the upstream change and edit the result. Preserve the intended behavior of both; do not select an entire side blindly for hooks, templates, configuration or migrations. Stage each resolved file with `git add PATH`, then inspect the result:

```bash
git diff --name-only --diff-filter=U
git diff --cached --check
git diff --cached
```

The first command must return no paths. If both sides added the same project migration version, check the actual database history before choosing a new unused version. Never rename or edit a migration already applied to an installation; reconcile divergent histories before running Flyway. Do not use `repair` to conceal an unexplained checksum mismatch.

### 4. Verify the updated copy

Apply pending core migrations, then project migrations, against the isolated development copy:

```bash
FLYWAY_DB_FOLDER=core FLYWAY_MIGRATION_TYPE=migrate docker compose -f compose-dev.yml run --rm --no-deps flyway
FLYWAY_DB_FOLDER=myapp FLYWAY_MIGRATION_TYPE=migrate docker compose -f compose-dev.yml run --rm --no-deps flyway
```

Validate both histories and repeat the migration commands to check that the second run has nothing left to apply. For example:

```bash
FLYWAY_DB_FOLDER=core FLYWAY_MIGRATION_TYPE=validate docker compose -f compose-dev.yml run --rm --no-deps flyway
FLYWAY_DB_FOLDER=myapp FLYWAY_MIGRATION_TYPE=validate docker compose -f compose-dev.yml run --rm --no-deps flyway
```

If Lucee's template inspection is disabled, clear its template cache in the Lucee Administrator first; application reinitialization alone does not refresh cached code. See [Lucee's template-cache guidance](https://docs.lucee.org/recipes/supercharge-your-website.html).

While logged in as a Sysadmin, reload the application with `/index.cfm?reinit=1`. Check login, your application/module actions, permissions, uploads and local mail. Inspect rendered pages in your selected theme; review upstream fixes to the default theme for changes your customized copies also need. Shared frontend changes should be checked in both themes.

Run affected specs against the dedicated test database, and the full suite for shared changes. Follow the [test workspace guide](../www/tests/README.md); the manual staging-check runner requires a fresh checkout and refuses existing local configuration.

Review and commit the merge in your fork only after validation. Publishing, branch promotion and deployment are separate actions; pushes to Saaster's `staging` and `production` branches trigger deployments.

## Stop or recover an update

Before committing the merge, `git merge --abort` cancels the Git integration. It does not undo database migrations, configuration changes or writes made while testing. Keep the initial working tree clean so Git can restore the previous tracked state reliably.

If database changes have already run, restore the matching installation from the [Borg recovery set](../config/backup/readme.md#restore-an-existing-installation). Switching code back alone does not restore the database. Recheck the application before allowing other writers or deployments again.
