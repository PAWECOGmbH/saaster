# Saaster repository instructions

These are the shared project and coding rules for coding agents working in this repository. Maintain all repository-wide rules in this root `AGENTS.md`.

## Project and layout

Saaster is a modular CFML SaaS framework running on Lucee 7, NGINX, and MySQL 8.1 with Docker Compose. Frontend, backend, and APIs share the application configuration and database.

| Path | Purpose |
| --- | --- |
| `www/Application.cfc`, `www/index.cfm` | Application bootstrap and routing |
| `www/backend/core/com/` | Core business logic in CFML components |
| `www/backend/core/views/`, `www/backend/core/handler/` | Backend views and request handlers |
| `www/backend/myapp/`, `www/backend/modules/` | Project extensions and feature modules |
| `www/frontend/core/` | Frontend logic, mail templates, and scheduled tasks |
| `www/frontend/default_theme/`, `www/frontend/custom_theme/` | Frontend themes |
| `www/api/` | API resources, Taffy REST framework, and JWT support |
| `www/setup/` | Installation wizard and mock data tools |
| `config/` | Environment examples, NGINX configuration, and database scripts |
| `www/tests/` | TestBox specs, fixtures, and test scripts |

## Coding conventions

- Write code comments and technical documentation in English.
- Use 4 spaces for indentation, no tabs. Preserve existing line endings and avoid unrelated formatting changes.
- Follow the existing Lucee CFML structure: business logic in `.cfc` components, views and handlers in `.cfm` templates. Prefer CFScript for logic.
- Inside functions, use the `local` scope instead of `var` for local variables. Do not introduce `local` declarations outside functions.
- Prefer CFML `loop` statements over `for` loops.
- Write `queryExecute` named arguments in this order: `options`, `params`, `sql`. Bind data values with explicit parameter types, for example `{type: "string", value: arguments.importUUID}`. Validate dynamic SQL identifiers against fixed allowed values.
- Add API resources under `www/api/resources/` using the existing Taffy registration pattern. Keep JWT integration under `www/api/jwt/`.
- Put project-specific extensions under `www/backend/myapp/` or `www/backend/modules/`, following the existing module structure.

## User-facing language

- Keep the Sysadmin interface entirely in English, including buttons, modals, status labels, and notifications, regardless of the selected user language. Customer-facing screens remain translated.
- Use formal German address consistently in user-facing UI text, notifications, emails, and translations: `Sie`, `Ihnen`, and `Ihr/Ihre`. This applies to German text in both frontend themes and customer-facing backend screens.
- Use neutral infinitives for buttons and labels (for example, `Rolle speichern`). In instructions, use the formal imperative (for example, `Prüfen Sie die Vorschau`). Do not introduce `du`, `dir`, `dich`, `dein`, or informal imperatives.
- Follow the same convention when adding or changing translation seeds in SQL migrations. Preserve customized translations when correcting existing default wording.

## CFML template output

- When adding dynamic `#...#` expressions to HTML in a `.cfm` template, put the affected markup inside an explicit `<cfoutput>...</cfoutput>` block in that template.
- Do not rely on a `<cfoutput>` block in a parent template to evaluate expressions in an included file. Check existing output blocks before adding one.
- Apply shared frontend fixes to both `www/frontend/default_theme` and `www/frontend/custom_theme` where applicable.
- Inside output blocks, escape literal hash characters as `##` where needed, for example in anchor links, CSS colors, and JavaScript selectors.
- Verify the rendered HTML for changed dynamic links and text. Check that URLs and values are evaluated and no literal CFML expressions reach the browser; checking only the helper function is insufficient.

## Shared UI assets

- Reuse the existing UI components and patterns, including the shared drag-and-drop sorting handler.
- Use the locally hosted Tabler icons. Shared icon sizing lives in `www/backend/dist/css/icons.css`, loaded by the backend and both frontend themes.
- Put custom styles in project stylesheets; keep third-party vendor assets unchanged.
- Use `application.objGlobal.assetUrl()` for local shared assets that need cache invalidation; follow the existing fallback in backend includes used by the installer.

## Local development and migrations

- Follow [readme.md](readme.md) for initial setup, Lucee datasource/SMTP configuration, and custom Docker images. Environment examples live under `config/`; local settings are in `.env` and `www/config.cfm`.
- Start the development stack with `docker compose -f compose-dev.yml up -d`. SMTP testing uses the local Inbucket service.
- Reload application configuration through `/index.cfm?reinit=1` when needed.
- Add versioned Flyway migrations under `config/db/core/` for core changes or `config/db/myapp/` for project changes. `config/db/dev/` contains development data scripts, not versioned core migrations.
- Start every new SQL migration with `SET NAMES utf8mb4;` as its first statement and save the file as UTF-8. Apply this to core and project migrations.
- Keep released migrations unchanged unless explicitly asked to revise them. When a migration must be repeatable, preserve existing settings, customized translations, and user-defined ordering, and check for existing schema objects before creating them.
- Respect existing uncommitted changes. Keep `todo.md` local and ignored; never force-add it. Keep local credentials and generated test configuration out of Git.
- Do not create or amend Git commits unless the user explicitly requests it. Requests to create a branch, implement changes, or run tests do not authorize committing. Leave completed changes uncommitted for the user to review and commit.

## Validation

- Automated TestBox tests exist. Read [www/tests/README.md](www/tests/README.md) for setup, fixtures, registries, and available suites.
- Run relevant specs against the dedicated test database with `bash www/tests/bin/run_tests.sh 'reporter=mintext&bundles=tests.specs.unit.global_spec'`, replacing the bundle with those affected by the change.
- Run the full suite when needed with `bash www/tests/bin/run_tests.sh 'reporter=mintext'`. The runner reloads the test application automatically.
- Apply new migrations to the test database with `bash www/tests/bin/migrate_test_db.sh`. `prepare_test_db.sh` recreates the test database; do not use it as a routine test runner.
- Keep automated test writes in the dedicated test database. Use the existing fixtures, mocks, and Inbucket instead of live payment or mail services.
- Integration specs extend `tests.support.integration_spec`; use `beforeEach` and `afterEach` rather than overriding the base class's `beforeAll` or `afterAll`.
- When forms, action links, or dynamic SQL change, check the form and SQL registries under `www/tests/support/` and their associated specs.
- For frontend and visual changes, inspect rendered pages and interactions in the browser, including both themes or responsive layouts where affected. Report what was checked and any remaining limits.
