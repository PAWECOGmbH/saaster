# Saaster test workspace

TestBox specs for the CFML side of Saaster. Everything that only belongs to testing lives in this folder - product code and `config/db` stay untouched.

The tests run inside the local Lucee container, against a **dedicated test database** (`saaster_test_db`). They never touch the development database.

## Requirements

- Docker with the running dev stack (`docker compose -f compose-dev.yml up -d`)
- `bash` and `curl` (on Windows: Git Bash)
- No globally installed `box` / CommandBox needed

## Setup

Once, from the repository root:

```bash
bash www/tests/bin/install_test_dependencies.sh
bash www/tests/bin/prepare_test_db.sh
bash www/tests/bin/run_tests.sh "reporter=mintext"
```

This creates, in this order:

1. TestBox in `www/tests/vendor/testbox` (the version is pinned in `box.json`)
2. `www/tests/config/testing.json` from the `.env` - git-ignored
3. the empty database `saaster_test_db`
4. all migrations from `config/db/core` and `config/db/myapp` in it

There is no seed on purpose. Every spec creates the data it needs and removes it again (see "Writing specs").

## Daily use

In the browser: **http://localhost:8080/tests/runner.cfm** (use your `LUCEE_PORT`). Pick directories or single specs, run them, and see the failed expectations with file and line.

From the shell:

```bash
bash www/tests/bin/run_tests.sh                     # everything, JSON
bash www/tests/bin/run_tests.sh "reporter=mintext"  # everything, readable
bash www/tests/bin/run_tests.sh "reporter=mintext&directory=tests.specs.unit"
bash www/tests/bin/run_tests.sh "reporter=mintext&bundles=tests.specs.unit.global_spec"
```

The script exits with code 1 as soon as a spec fails - usable in pipelines and git hooks.

- **New migrations:** `bash www/tests/bin/migrate_test_db.sh`
- **Clean database:** `bash www/tests/bin/prepare_test_db.sh` again
- **Changed a component:** `run_tests.sh` reloads the test application automatically. In the browser, open `healthcheck.cfm?reinit=1` once.

## How it works

`www/tests/Application.cfc` is a separate application with its own name, so its application scope is independent of the running app under `/`.

- **Real bootstrap.** It calls the real `onApplicationStart` of Saaster, so `application.objGlobal`, `objUser`, `objCustomer` and all settings exist exactly as in the app.
- **Datasource redirect.** The test datasource is registered under its own name *and* under the name from `config.cfm` (`variables.datasource`). Every query the app knows of ends up in the test database, including the ones during the start.
- **Safety.** The application only starts if `config.cfm` says `variables.environment = "dev"`. Both the CFML side and every shell script refuse a database without `test` in its name. This folder is inside the webroot - when you deploy, exclude `www/tests` anyway.

## Writing specs

- `specs/unit/` - no database writes. Extend `testbox.system.BaseSpec`.
- `specs/integration/` - against the test database. Extend `tests.support.integration_spec`.

Integration specs get `variables.fixtures` (see `support/fixtures.cfc`):

```cfml
component extends="tests.support.integration_spec" {

    function run() {
        describe("My feature", () => {

            beforeEach(() => {
                variables.customer = variables.fixtures.createCustomer();
                variables.user = variables.fixtures.createUser(customerID = variables.customer, admin = true);
                loginAs(variables.user);
            });

            it("does something", () => {
                expect(application.objGlobal.checkTenantRange(variables.user.userID, variables.customer)).toBeTrue();
            });

        });
    }

}
```

Rules:

- Do **not** define `beforeAll` / `afterAll` in integration specs - the base class uses them for the safety check and the cleanup. Use `beforeEach` / `afterEach`.
- Fixtures write plain SQL on purpose, so a spec does not depend on the very function it is not testing.
- Test e-mail addresses end with `@saaster.invalid`. That domain is never deliverable and marks leftovers, which the next run removes automatically.
- Customers created through fixtures are deleted after the spec. Everything attached to them (users, bookings, invoices, ...) goes with them via `ON DELETE CASCADE`.

Helpers for side effects:

- **Logs:** `recordLogs()` replaces `application.objLog` with `support/log_recorder.cfc`. No log files are written, and `count()` / `getCalls()` let you check what would have been logged. The real logger comes back automatically after the spec.
- **Payrexx:** `support/payrexx_mock.cfm` stands in for the Payrexx API and echoes the request it received. See `specs/integration/payrexx_call_spec.cfc` for how to point `application.payrexxStruct` at it. Specs must never call the real Payrexx, even if `config.cfm` holds real credentials.

## Form registry

`support/form_registry.cfc` is the collection of every form and every action link in the core views and both themes - with its target, the field the handler reacts to, and what it does. `specs/integration/form_registry_spec.cfc` checks it entry by entry, so the runner lists every form on its own line.

The spec reads the sources as text and compares them with the registry in both directions. **Adding, moving or removing a form or an action link turns it red until the registry is updated.** That is intended: every form has to be classified consciously.

| List | What belongs there | What the spec checks |
| --- | --- | --- |
| `handlerForms()` | POST forms that change data | POST, `#csrfField()#` inside, target is a core handler covered by the CSRF rule, the handler reacts to the trigger |
| `viewForms()` | Search, sort, filter or navigation forms posting to a view | Only fields from `readOnlyFields()` |
| `inertForms()` | `<form>` tags that are never submitted | Still without fields |
| `protectedLinks()` | GET links that trigger an action and carry `#csrfParam()#` | Every occurrence has the token, the CSRF rule covers it |
| `openLinks()` | GET action links without a token, with a reason | `session`/`entry`: still unprotected as documented. `gap`: shown as **skipped** until closed |

To see only the open gaps: run with `labels=csrf-gap` (they are skipped, so they show up in the skipped count).

## Security specs

Next to the behaviour specs of the single rules (`csrf_spec`, `user_roles_spec`, `password_spec`, `login_throttle_spec`, `token_expiry_spec`, ...) a few specs guard the codebase as a whole:

| Spec | What it checks |
| --- | --- |
| `integration/sql_registry_spec` | Every value written into SQL directly (not bound) is listed in `support/sql_registry.cfc` with the reason why it is safe. A new interpolation turns it red until it is bound as a parameter or reviewed and listed. |
| `integration/sql_injection_spec` | Real payloads: injected sort values fall back to the default, quotes in search terms stay data, a forged tenant list cannot widen the DELETE in `updateUser()`. |
| `integration/output_encoding_spec` | Database fields in the core views, the themes and the frontend core are written with `encodeForHTML()`. Exceptions sit in an allowlist with their reason. Also renders the invoice address block with markup in the customer data. |
| `integration/upload_spec` | Real multipart uploads through `support/upload_probe.cfm`: allowed files are stored, forbidden or too large files leave nothing behind. |
| `integration/nginx_spec` | Security headers on every kind of response, no script execution below `/userdata`. Skipped without nginx in front of Lucee. |
| `unit/security_wiring_spec` | The handlers still call the security rules in the right branch and order (CSRF, login throttle, session rotation, password policy, token purposes, role checks, support login, sorting endpoint). |

`support/security_scanner.cfc` reads the sources for these specs - nothing is executed.

## Invoice language specs

An invoice is a document in one language (`invoices.cfc::getInvoiceLanguage`).

| Spec | What it checks |
| --- | --- |
| `integration/invoice_language_spec` | The rule (invoice person, main user, customer data, default), `createInvoice` with and without a language, total and VAT lines for all VAT types, a booking whose invoice title follows the booking language. |
| `integration/invoice_rendering_spec` | Invoice view and print rendered for real through `support/invoice_render_probe.cfm` by a user with another interface language; the print is read from the generated PDF. Invoice and payment mails sent and read back from Inbucket. A third language ("fr", added and removed by the spec) that is only partly translated falls back to the default language. |

The mail checks need `mailCatcherUrl` in `config/testing.json` (written by `bin/write_test_config.sh`, Inbucket of `compose-dev.yml`); without it they are skipped.

## Scheduler specs

The module scheduletasks run as jobs in `scheduler_jobs` (migration V23). Which jobs exist follows the bookings (`modules.cfc::syncCustomerScheduler`), the workers (`frontend/core/scheduletasks/tasks.cfm`) take them through `scheduler.cfc`.

| Spec | What it checks |
| --- | --- |
| `integration/scheduler_spec` | The single rules (#655): waiting, canceled and expired bookings, modules of a plan, plan change, idempotence, `getModuleStatus`, claiming and finishing jobs, four parallel workers never get the same job. |
| `integration/scheduler_scenarios_spec` | Sixteen customers with different booking situations, some with wrong jobs from before. After one `syncAllSchedulers()` each has exactly the expected jobs. |
| `integration/scheduler_booking_flow_spec` | The real booking code (`book.cfc`, `cancel.cfc`): booking with test days, free and paid, cycle change, plan with modules, cancel, revoke, withdraw, `updateBooking`. |
| `integration/scheduler_worker_spec` | Real runs of `tasks.cfm` through `support/scheduler_worker_probe.cfm`: what a task receives, failed and missing tasks, password, worker limit, held and stale worker slots, time budget. |
| `integration/scheduler_migration_spec` | Migration V23 from the shard tables `scheduler_01..20`: copy, merge of duplicates, existing jobs kept, safe to run twice. Reads the migration file from `/var/saaster/db` (read-only mount of `config/db` in `compose-dev.yml`); skipped without the mount. |

The fixtures create modules, scheduletasks and plans (`createModule`, `createScheduletask`, `createPlan`) and remove them with the customers.

## Files

| Path | Purpose |
| --- | --- |
| `Application.cfc` | Test application: guard, datasource redirect, real bootstrap |
| `runner.cfm`, `runner.js`, `runner.css` | Browser UI and HTTP interface for TestBox |
| `healthcheck.cfm` | JSON check: database, migrations, loaded objects |
| `box.json` | Pinned TestBox version |
| `config/testing.json.example` | Template for the generated, git-ignored `testing.json` |
| `bin/` | Install, prepare, reset, migrate and run scripts |
| `support/` | Settings loader, integration base spec, fixtures, log recorder, Payrexx mock, upload probe, form and SQL registries, scanners |
| `specs/` | The specs |
