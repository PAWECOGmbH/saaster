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

## Files

| Path | Purpose |
| --- | --- |
| `Application.cfc` | Test application: guard, datasource redirect, real bootstrap |
| `runner.cfm`, `runner.js`, `runner.css` | Browser UI and HTTP interface for TestBox |
| `healthcheck.cfm` | JSON check: database, migrations, loaded objects |
| `box.json` | Pinned TestBox version |
| `config/testing.json.example` | Template for the generated, git-ignored `testing.json` |
| `bin/` | Install, prepare, reset, migrate and run scripts |
| `support/` | Settings loader, integration base spec, fixtures, log recorder, Payrexx mock |
| `specs/` | The specs |
