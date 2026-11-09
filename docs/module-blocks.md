# Customer module access blocks (#670)

Platform administrators can block or unblock a module for one customer under
**Sysadmin → Customers → Details → Modules → Action**. The confirmation dialog
names the customer and module and explains the effect. Plan-included modules have
the same action. A blocked badge appears in the administrator's customer details
and the customer's booked-module overview.

This is an access restriction, not a subscription pause. Prices, invoices, booking
status, billing, subscription dates and application data are unchanged. Canceling,
renewing or changing the plan does not remove the block. Unblocking does not extend
a period or restore an expired booking; it only removes the restriction. Blocks
apply to the exact customer ID, not its parent or sibling tenants.

## Storage and authorization

Apply `V31__customer-module-blocks.sql`, then reload the application. The migration
creates `customer_module_blocks` and seeds German/English translations without
changing existing bookings or custom translations. It can be run repeatedly and
updates only the previous default block message to customer-facing wording.
The customer/module primary key
makes repeated block/unblock submissions idempotent. The record retains the actor
and creation time; changing access also writes a system log entry.

`objModuleBlocks.setBlocked(actorUserID, customerID, moduleID, blocked)` verifies the
current session and the actor's active platform-administrator status in the database.
Support sessions and organization administrators cannot manage these blocks.
Blocking requires a direct module booking or a plan booking containing the module;
unblocking remains possible after that booking disappears. The POST handler also
enforces CSRF and validates the requested operation and IDs.

## Enforcement

The browser dispatcher checks current block records on every request, independently
of role grants and the platform product-access exception. This covers custom-mapped
module routes and files under `backend/modules/<strTabPrefix>/`, including direct
unmapped handlers. Keep module paths/mappings associated with the correct module.
The billing and module-management screens remain available.

The regular entitlement query still describes bookings independently of blocks.
Use `objRequestAccess.moduleAccess(moduleID)` for current browser-context access;
`objModuleBlocks.isBlocked(customerID, moduleID)` is available for application jobs
or API resources which implement their own explicit identity and context checks.
Reading a booking or granting a role never removes a block.

Scheduler reconciliation excludes blocked modules from eligible tasks but preserves
their existing job rows and run history. Claiming a job checks the block even if
reconciliation has not run. The worker checks again immediately before execution.
A job already executing may finish; it is not interrupted or rolled back. Unblocking
reconciles against current bookings, recreating eligible missing jobs and removing
expired ones. Absent a valid booking, execution does not resume.

## Validation and manual checks

Automated specs cover permissions, idempotence, exact customer scope, unchanged
bookings, plan-included modules, stale direct URLs, CSRF, scheduler claims and running
job completion. HTTP tests exercise the rendered modal and actual POST handler.

For manual verification, use a local customer with a booked module, then repeat with
a module included in a plan:

1. Open the Modules tab as a platform administrator and choose **Block module**.
2. Check the confirmation text, submit, and confirm the blocked badge appears.
3. In a separate customer session, open the module or submit an already open form.
   Access must be denied; the booked-module overview still explains the restriction.
4. Check that no further scheduler job is claimed for that customer/module, while
   unrelated customers/modules continue to run.
5. Unblock the module. Access resumes only while a valid booking exists. Its original
   dates and billing remain unchanged.
