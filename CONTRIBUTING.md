# Contributing to Saaster

Saaster accepts contributions to code, tests, and documentation. PAWECO maintains the project's direction and is responsible for merge, deployment, and release approval.

## Start with development

Use `development` as the starting point for your branch and as the base branch of your pull request. For substantial changes, discuss the intended behavior and scope in an issue before investing in implementation.

1. Fork the [Saaster repository](https://github.com/PAWECOGmbH/saaster).
2. Clone your fork and create a branch from `development`:

    ```bash
    git clone https://github.com/YOUR-USERNAME/saaster.git
    cd saaster
    git switch development
    git switch -c feature/short-description
    ```

3. Make a focused change, update relevant documentation, and run the appropriate checks.
4. Review your diff, commit the intended files, and push your branch to your fork.
5. Open a pull request against `PAWECOGmbH/saaster:development` with the information listed below.

The `staging` and `production` branches are managed by PAWECO. Pushes to these branches start deployments and database migrations; they are not contributor test environments.

## Follow the repository rules

[AGENTS.md](AGENTS.md) is the source of the shared project and coding rules. Read it before changing code. It covers project layout, CFML scopes and SQL parameters, template output, translations, shared UI assets, migration rules, and validation.

Keep changes focused, use four spaces, preserve existing line endings, and write comments and technical documentation in English. Customer-facing German text uses formal address; the Sysadmin interface remains in English.

Put project-specific application code in `www/backend/myapp/` or `www/backend/modules/`. Apply shared frontend changes to both themes where applicable. Existing extension contracts are documented in [extension permissions](docs/extension-permissions.md) and [module account deletion](docs/module-account-deletion.md).

Keep `.env`, `www/config.cfm`, generated test configuration, and credentials local. Review the files you stage and avoid including unrelated local changes or customer data in commits, issues, or pull requests. Keep `todo.md` ignored and never force-add it.

## Set up local development and testing

Follow [Development Setup](readme.md#development-setup) to configure and start the Docker Compose stack. The examples and commands describe the current repository; clean-install verification is still part of [release preparation](docs/releases.md#release-checklist).

The test tools require Bash and `curl` on the host; Git Bash can be used on Windows. A global CommandBox installation is not required. The test application requires `variables.environment = "dev"` in `www/config.cfm`.

Once the development stack is configured and running, install the test dependencies and prepare the dedicated test database from the repository root:

```bash
bash www/tests/bin/install_test_dependencies.sh
bash www/tests/bin/prepare_test_db.sh
```

`prepare_test_db.sh` drops and recreates the dedicated test database (`saaster_test_db` by default), writes the git-ignored `www/tests/config/testing.json`, and applies the core and project migrations. Use it for initial setup or an intentional reset. Keep the test database distinct from the application database, with `test` in its name.

For normal test runs, use the existing database:

```bash
bash www/tests/bin/run_tests.sh 'reporter=mintext&bundles=tests.specs.unit.global_spec'
bash www/tests/bin/run_tests.sh 'reporter=mintext&directory=tests.specs.integration'
bash www/tests/bin/run_tests.sh 'reporter=mintext'
```

The commands above select a single bundle, the integration directory, and the full suite respectively. Replace the bundle with the specs affected by your change. The runner reloads the test application before each run.

After adding migrations, apply them to the existing test database:

```bash
bash www/tests/bin/migrate_test_db.sh
```

Use fixtures, local payment mocks, and Inbucket. Automated tests must use the dedicated test database and local services, without real payment credentials, customer data, or live mail services. Tests do not need deployment secrets. Automated pull request checks are part of the planned release preparation; include local validation results in your pull request.

## Validate the change

- Run affected specs. Run the full suite when a change affects shared behavior or several subsystems, and report failures or skipped checks.
- Integration specs extend `tests.support.integration_spec`. Use `beforeEach` and `afterEach`; the base class owns `beforeAll` and `afterAll` for safety checks and cleanup.
- When forms, action links, or dynamic SQL change, review the form and SQL registries under `www/tests/support/` and run their associated specs.
- For UI changes, inspect rendered pages and interactions, including both themes and responsive layouts where affected. Check that dynamic CFML links and values are evaluated in the rendered HTML.
- For documentation-only changes, check links, paths, command syntax, and consistency with the current configuration and scripts. State which installation or runtime steps remain unverified.

See the [test workspace guide](www/tests/README.md) for fixtures, mocks, registries, available suites, and cleanup behavior.

## Handle migrations carefully

Core migrations belong in `config/db/core/`; project migrations belong in `config/db/myapp/`. Development demo-data scripts in `config/db/dev/` are separate from the versioned migrations.

Start every new migration with `SET NAMES utf8mb4;` as its first statement and save it as UTF-8. Preserve migrations that have already been released or applied to existing installations. Follow the feature-specific development instructions in [AGENTS.md](AGENTS.md), and describe migration requirements and compatibility implications in your pull request.

## Include in a pull request

- The problem and the resulting behavior, with an issue reference where relevant.
- Tests or manual checks performed, their results, and any remaining limits.
- Migration, configuration, extension, or upgrade implications.
- Documentation changes and screenshots for visible UI changes where useful.

Keep changes small enough to review independently. Release numbering, supported versions, and the confidential security-reporting route remain PAWECO decisions recorded in [Release preparation](docs/releases.md#pending-paweco-decisions).
