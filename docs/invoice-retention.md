# Invoice documents and account deletion

Apply core migration V32 before deploying the corresponding application code. It is
idempotent and starts with `SET NAMES utf8mb4;`. Previously issued, non-draft invoices
are marked once; rerunning the migration does not mark new work in progress as issued.

V32 is the single migration for the entire account-deletion feature (#398), including
the subscription-stop and module-cleanup tables. During development the user
removes the local V32 Flyway entry and reruns the amended migration. Extend V32 with
existence checks for each added schema object; preserve snapshots and lifecycle progress
when upgrading an earlier V32 schema. Correct existing foreign keys remain untouched.

## Issuing and preserving invoices

`invoice_documents.cfc` captures a document when an invoice is opened or sent. It
stores the recipient address, billing information, issuer details, logo, document
language, formatted dates and Swiss QR payment data alongside the generated PDF.
Only document fields are copied; customer payment tokens and login data are excluded.
The original PDF lives in `invoice_documents.binPDF`, covered by database backups.
It is served as stored, including after subsequent payments or account deletion.

Automatic billing assembles invoice rows and positions before sending. Its intermediate
open status alone is not an issuance boundary. Updating payment totals does not render
or replace the document. Opening/sending/downloading the completed invoice captures it.
Draft previews do not freeze drafts. Issued documents cannot be edited, deleted or
changed back to drafts through the invoice service. Cancellation and payment tracking
remain available while the customer account exists. After account deletion, status and
payment records are read-only as well. The screen displays the current payment status separately from the
preserved PDF.

Existing invoices without a document are captured on access or before deleting their
customer. Their source is `legacy`, and the Sysadmin invoice screen explains that the
capture uses the data available at that time. It is **not** a reconstruction of the
historical recipient or issuer. New documents have source `issued`. The capture source
and timestamp are stored separately from the immutable snapshot.

## Deletion boundary

The customer foreign key now uses `RESTRICT`, not `CASCADE`. An account cannot be
removed by raw SQL while invoices are still attached. The archive foreign key also
prevents deleting an archived invoice accidentally.

The existing `customer.deleteAccount()` calls `retainForDeletion()` inside its deletion
transaction, before deleting files. This locks the customer, captures all remaining
non-drafts, removes unissued drafts, then detaches the retained invoices. Invoice
positions, VAT and payment rows survive. Live customer/user/booking references and
email download tokens are cleared. Capture failure rolls back deletion and leaves
files intact. Manual account/tenant deletion now uses the lifecycle service described below;
the legacy method remains guarded for compatibility with other callers.

Detached invoices remain searchable in the Sysadmin invoice list by captured customer
name/email, with their payments and original PDF. Customer links and email actions are
hidden. Edit forms and status/payment actions are removed. The service rejects all
mutations of detached invoices, and direct Sysadmin mutation requests return HTTP 403.
Only a platform administrator can download detached invoices; neither the
former customer nor an old email download token grants access.

## Lifecycle service and manual deletion UI

Customer and Sysadmin confirmation forms now use the same lifecycle service. The
customer finds deletion under **Account settings → My company**, and individual tenant
deletion under **Tenants → Action → Delete**. The Sysadmin action is on the customer's
details page. Activated organizations are supported; only their owner may delete them.
Every tenant must be deleted individually. A parent cannot be deleted while
any child still exists, including inactive tenants and pending/failed child deletions.
This applies to both the owner and Sysadmin; there is no cascade option. The existing
legacy deletion entry point enforces the same rule and no longer detaches children.
Accounts containing platform administrators remain protected.

`account_lifecycle.requestDeletion(actorID, customerID, password)` checks
the exact actor's password and owner/Sysadmin permission. Both handlers derive
`actorID` from the authenticated session and enforce CSRF/context protection, POST, an
explicit confirmation checkbox and password-attempt throttling. Support
impersonation cannot request deletion. The request transaction records the scope in
`account_deletions`, disables that account, and ends its bookings immediately. Repeated
requests preserve timestamps/progress; overlapping deletion roots are rejected.

Booking, invoice creation, payment, renewal and scheduler entry points now check the
persistent deletion marker. Tracked billing/jobs and dispatched backend web requests in `account_operations` must finish
before cleanup can start. An ambiguous Payrexx response retains the operation, invoice
ID and exact payment reference. Another charge for that account is blocked until the
outcome is reconciled. These records never expire automatically: a timeout is not proof
that a charge failed. The existing deletion method refuses accounts with a lifecycle
request, preventing it from bypassing these holds.

`account_deletion.process(rootCustomerID)` only accepts a persisted request and
serializes retries with database locks. It captures invoice documents, runs cleanup
hooks, revokes authorized Payrexx transaction tokens, removes account images and deletes
the core account data. Shared user identities survive when linked outside the deleted
scope. Completed cleanup steps are recorded in `account_deletion_steps`. Relational
finalization has a savepoint so a constraint failure cannot leave partial core deletion.
Cleanup rechecks that the account has no children before any side effects and rejects
obsolete batch requests. Tenant creation locks the same parent row and refuses parents
whose deletion has already started, preventing a race with core tenant creation.
A failed cleanup keeps the account disabled and its subscriptions stopped.

### Module and project contract

See [Customer cleanup for module developers](module-account-deletion.md) for generation,
delivery, implementation examples and testing.

Every installed module with CFML code supplies `backend/modules/<name>/deletion.cfc`;
the project supplies `backend/myapp/deletion.cfc`. Each exposes
`public struct function deleteCustomer(required numeric customerID)` and returns
`{success:true}` only after its own tables, files and external customer data have been
removed. Use explicitly scoped queries; never infer tables from a prefix and delete them
blindly. A partial failure must be safe to retry, including external requests and file
operations. The supplied hooks are empty because the shipped scaffolds contain no
customer data; real implementations must extend them when adding data or services.

Hooks run for all installed modules, including former subscribers. Missing cleanup code
for installed or registered module paths fails closed. When retiring a module, retain
its deletion hook until all historical customer data has been removed; an unregistered,
physically removed extension cannot be reconstructed from deleted booking history.

### Confirmation and status

The dialogs name the exact account. Both warn about irreversible deletion of access and
module data and immediate subscription cancellation. Only the English Sysadmin dialog
mentions retained invoices, original PDFs and recorded payments. The customer warning
contains no invoice-retention notice.

The confirming request releases only its own matching `request.accountOperation` before
cleanup; the dispatcher safely releases it again in `finally`. Other admitted work must
finish first. Accepted self-deletion ends the customer session even when cleanup is
pending. Success is shown only after finalization; otherwise the customer sees that
cleanup has started but has not finished. Sysadmin details show pending/failed cleanup,
running operation/payment references and a password-confirmed **Retry deletion** action.
Retries do not discard uncertain payments. Unknown outcomes still require investigation.
The obsolete tenant GET deletion URL is rejected.

The tenant management list includes inactive and pending-deletion tenants even in
activated organizations. Pending tenants cannot be reactivated using the tenant toggle.
The switcher continues to list only accessible tenants.

### Remaining integration before production release

- Custom API resources or background entry points outside the core dispatcher must
  participate in the same operation protocol.
- Coordinate already issued Payrexx checkout gateways and delayed authorization/payment
  webhooks before finalization; the current operation guards cover core synchronous
  charges, not the lifetime of an external browser checkout.
- Extend the Sysadmin retry interface with verified payment reconciliation. Unknown
  charges and abandoned operation/job records require explicit investigation before
  releasing their hold. There is intentionally no force-delete/clear-holds button.
- Verify deployment-specific cleanup hooks. The public scaffold cannot remove data
  owned by extensions whose implementation is not present in this repository.

No automatic subscription cancellation or expiry requests account deletion. No cron
schedule has been removed.

## Verification

Run the dedicated-database tests after applying V32:

```bash
bash www/tests/bin/migrate_test_db.sh
bash www/tests/bin/run_tests.sh 'reporter=mintext&bundles=tests.specs.integration.invoice_migration_spec,tests.specs.integration.invoice_documents_spec,tests.specs.integration.invoice_rendering_spec,tests.specs.integration.customer_delete_spec,tests.specs.unit.pdf_spec'
```

For a manual test, create a draft in Sysadmin, add positions, open it and download its
PDF. Change the customer's address and issuer settings: the original download must
remain identical. Record a payment: the editor's balance changes, while the PDF stays
unchanged. The integration suite also covers retained invoices after deletion, denied
customer access, revoked download tokens, QR slips, and failure rollback without
calling a live payment provider.

`invoice_migration_spec` runs the real V32 SQL against isolated legacy tables. It checks repeated execution, byte-preserved archived PDFs and snapshots, unchanged issuance flags, detached invoices and restoration of a missing customer foreign key.

`account_deletion_spec` exercises the lifecycle against the dedicated database and a
local Payrexx mock: actor/owner checks, immediate stop, unknown-charge holds, retained
PDFs/payments, missing hooks, token-revocation retry, shared identities and atomic account
finalization. `account_deletion_http_spec` additionally exercises actual rendered forms
and production dispatch: exact password, CSRF, confirmation, unrelated account denial,
self-deletion/logout, individual tenants, inactive/pending tenant visibility, parent
restriction and Sysadmin retry. Migration tests also preserve
pending operations, completed cleanup steps and customized translations on reruns.

The confirmation dialogs were opened in the browser for customers, individual tenants,
blocked parents and Sysadmin (including pending retry). Customer desktop/mobile layout
and evaluated dynamic values were inspected. These views share the backend layout;
there are no theme-specific copies. V32 was reapplied only to the dedicated test database.
No real account or live payment service was used. The open-checkout/webhook coordination
above remains a release prerequisite, even though the manual forms are now connected.

Validation of the GUI integration: all 787 specs passed in sequential batches.
The final HTTP deletion and membership-authorization checks also passed (31 specs).

## Demo-module regression coverage

The MailChimp registration in `config/db/dev/create-modules.sql` is demonstration
metadata; this repository does not implement a MailChimp integration. Its explicit
`backend/modules/mailchimp/deletion.cfc` follows the same empty-data contract as the
other shipped scaffolds. Implement real cleanup before adding module-owned data or
external synchronization. Missing hooks for other registered modules still stop deletion.

`dev_seeds_spec` now imports all actual development seeds and deletes an own tenant
through `submitDeletion` as both an owner and a Sysadmin, including a module booking
and a running request on the parent. It checks completed deletion and an unaffected
parent. This reproduces the previously missed MailChimp registration failure.
`account_deletion_http_spec` triggers a real missing-hook failure through the form,
checks the failed status/message and resumes the same request after fixing the test
registration. Both regressions failed before the fix and pass after it.

The tenant list distinguishes failed cleanup (red) from pending work (yellow). The
customer dialog and both handlers report failure explicitly. Retrying is labeled as
continuing the existing deletion. All 38 relevant seed, HTTP, lifecycle and migration
specs passed; these checks use only the dedicated test database.

`invoice_readonly_spec` checks rejected service mutations and forged authenticated
Sysadmin POST/GET requests after deletion, with exact comparisons of invoice rows,
positions, payment records, snapshot JSON and the PDF hash. It checks the rendered
invoice, list and payment dialog, and confirms payments/cancellation still work for
existing customer accounts.

Read-only follow-up validation: all 262 relevant invoice, payment, lifecycle and registry
specs passed. The actual backend was inspected at desktop and mobile widths; retained
invoices expose only viewing actions and the original PDF still downloads successfully.
This follow-up requires no additional migration.
