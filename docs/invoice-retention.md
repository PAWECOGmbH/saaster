# Invoice documents and account deletion

Core migration `V32__invoice-documents.sql` adds invoice archives, account-deletion
state, operation tracking, and checkout records. Apply it through Flyway before deploying
the corresponding application code. Existing non-draft invoices are marked as issued
once; stored invoice snapshots and lifecycle progress are preserved.

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

The customer foreign key uses `RESTRICT`, not `CASCADE`. An account cannot be
removed by raw SQL while invoices are still attached. The archive foreign key also
prevents deleting an archived invoice accidentally.

The existing `customer.deleteAccount()` calls `retainForDeletion()` inside its deletion
transaction, before deleting files. This locks the customer, captures all remaining
non-drafts, removes unissued drafts, then detaches the retained invoices. Invoice
positions, VAT and payment rows survive. Live customer/user/booking references and
email download tokens are cleared. Capture failure rolls back deletion and leaves
files intact. Manual account/tenant deletion uses the lifecycle service described below;
the legacy method remains guarded for compatibility with other callers.

Detached invoices remain searchable in the Sysadmin invoice list by captured customer
name/email, with their payments and original PDF. Customer links and email actions are
hidden. Edit forms and status/payment actions are removed. The service rejects all
mutations of detached invoices, and direct Sysadmin mutation requests return HTTP 403.
Only a platform administrator can download detached invoices; neither the
former customer nor an old email download token grants access.

## Lifecycle service and manual deletion UI

Customer and Sysadmin confirmation forms use the same lifecycle service. The
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

Booking, invoice creation, payment, renewal and scheduler entry points check the
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
Failed cleanup is marked red; pending work is marked yellow. Retrying continues the
existing deletion. The switcher lists only accessible tenants.

### Integration requirements

- Custom API resources or background entry points outside the core dispatcher must
  participate in the same operation protocol.
- Unknown charges and abandoned operation/job records require investigation.
  Retrying does not force-clear their holds.
- Verify deployment-specific cleanup hooks. The public scaffold cannot remove data
  owned by extensions whose implementation is not present in this repository.

Subscription cancellation or expiry does not request account deletion.

## Verification

Use the [test workspace guide](../www/tests/README.md) for execution, fixtures, and
local payment mocks. Verify that an issued PDF remains identical after address changes,
payment updates, and account deletion, while drafts remain editable. Exercise cleanup
retries with missing hooks or pending payments and confirm that another customer's
data remains untouched. Use the dedicated test database for these checks.

## Demo modules

The MailChimp registration in `config/db/dev/create-modules.sql` is demonstration
metadata; this repository does not implement a MailChimp integration. Its explicit
`backend/modules/mailchimp/deletion.cfc` follows the same empty-data contract as the
other shipped scaffolds. Implement real cleanup before adding module-owned data or
external synchronization. Missing hooks for other registered modules still stop deletion.

## External Payrexx checkouts and delayed webhooks

The `payrexx_checkouts` and `payrexx_checkout_events` tables retain references,
gateway/transaction IDs, amounts, currencies, and reconciliation status. They have no
customer cascade and do not copy full webhook payloads or card data.

Both core Gateway creation paths call `payrexx_checkouts.create()`. It stores the
customer, exact reference and optional invoice ID **before** the external request.
A creation still in flight or with an unknown outcome blocks finalization; another
creation is refused while the earlier result remains unknown. A browser returning to
a cancellation URL does not prove that the payment failed or release this hold.

The authenticated webhook handler locks the same customer row as deletion. It checks
checkout/reference ownership and records events idempotently. A confirmed invoice
payment with matching amount and currency is posted once without requiring a browser
return. The return handler checks that exact gateway/invoice instead of selecting the
customer's latest unrelated transaction. Delayed waiting notifications cannot downgrade
a confirmed payment. Refunds, disputed outcomes, amount/currency mismatches and
unassigned purchase payments require reconciliation rather than automatic posting.

Before module cleanup or invoice detachment, deletion retrieves each known gateway and
imports its transaction evidence, then closes the gateway through the API. Pending
transactions remain a hold after gateway closure. A retry reads their current status
from the transaction API. Neither elapsed time nor an unverified 404 clears a hold.
Uncertain creation responses, unsuccessful cancellation and incomplete provider data
leave the account stopped and pending. Sysadmin displays a checkout/payment-verification
message; the existing password-confirmed retry refreshes provider state.

Late authorizations for an already deleted account are revoked without recreating its
payment methods. If revocation fails, the durable event remains pending and the webhook
returns HTTP 503 so the provider can retry. Other storage failures also return HTTP 503.
Late financial confirmations are retained as `review` events and logged for investigation;
they do not modify immutable retained invoices, revive bookings or restore customer data.
Monitor these records/logs and ensure webhook retries are enabled in the Payrexx integration.
There is no dedicated operator reconciliation UI, automatic refund, or force-clear
operation. An unresolved financial event must be investigated using its provider
transaction and reference before any manual resolution.

### Existing installations and custom integrations

The old code did not persist every external Gateway ID. V32 cannot reconstruct an open
checkout for which no webhook has arrived. Before enabling account deletion after the
upgrade, close/reconcile those old links and in-flight transactions in Payrexx. Already
queued legacy webhooks are accepted through the same deletion-aware handler, even if
no registry row exists. Existing API/background integrations that create gateways must
use `payrexx_checkouts.create(customerID, payload, invoiceID)` as well.

The implementation uses Payrexx's documented [Gateway retrieval](https://developers.payrexx.com/reference/retrieve-a-gateway),
[Gateway deletion](https://developers.payrexx.com/reference/delete-a-gateway) and
[transaction statuses](https://docs.payrexx.com/developer/guides/webhook/transaction).
Gateway closure stops further use of the link; it is not treated as proof that every
previous payment attempt has settled. This is why pending attempts and late financial
events retain separate reconciliation state.
