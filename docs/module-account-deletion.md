# Customer cleanup for module developers

Every module with CFML code must supply
`www/backend/modules/<prefix>/deletion.cfc`. Project-specific data uses the same
contract in `www/backend/myapp/deletion.cfc`.

Saaster coordinates account deletion, stops subscriptions and preserves existing
invoices. Each module is responsible for removing the customer data it owns:
database rows, files and data held by external services. Saaster cannot infer these
resources from a module's name or table prefix.

## Generating and delivering the file

In Sysadmin, create a module, then save its details with **Folder and table prefix**.
This is when the module generator creates the directory and missing starter files:
`navigation.cfm`, `login_include.cfm` and `deletion.cfc`. The initial module creation
only creates its database entry; the prefix is supplied on the details form.

The generated deletion component deliberately throws `AccountDeletion.NotImplemented`.
It must not report successful cleanup before a developer implements it. Replace the
exception with the module's cleanup code. Saving module details again never replaces
an existing deletion component. Saving an older module without that file creates the
same unfinished template; it does not infer cleanup for the existing module.

Commit the implemented component to the **module's own repository** and include it
in the module's release/deployment package. A Saaster core deployment only ships files
contained in that deployment: it does not install hooks into unrelated external
modules. A database migration does not generate these files either. Verify that your
deployment exclusions and file permissions allow the intended module files to arrive.

There is no separate readiness screen. If a required component is missing or its
implementation fails, account cleanup stops. The account remains disabled and its
subscriptions remain stopped. Deploy the corrected implementation, then continue the
existing deletion through the normal retry action.

## Component contract

```cfml
component output="false" {
    public struct function deleteCustomer(required numeric customerID) {
        // Remove all data owned by this module for exactly this customer.
        // Implement database, file and external-service cleanup here.
        throw(
            type="AccountDeletion.NotImplemented",
            message="Customer cleanup has not been implemented for this module."
        );
    }
}
```

- `customerID` identifies the exact account or tenant being deleted. Never expand it
  to a parent, sibling or every member of an organization. Tenants are deleted individually.
- Return `{success:true}` only when cleanup is complete. Throw an exception with a
  useful technical message, or return `{success:false}`, if it cannot be completed.
  Do not put credentials or sensitive customer data in error messages.
- Expect calls for inactive modules and former subscribers, even when no current
  booking exists. Having no records for this customer is a valid successful result.
- Make cleanup idempotent: repeated calls after a complete or partial run must be safe.
  Saaster records successful module steps; a failed step can run again from its beginning.
- Do not delete Saaster's customer, user, invoice, invoice-position, payment or lifecycle
  records. Core finalization handles them and retains invoices and recorded payments.
- Do not depend on the current session, selected tenant, UI language or the order of
  other modules' cleanup. Use the supplied ID and the configured application datasource.

## Example: a module with database records only

The following illustrative module owns only `notes_entries` and `notes_labels`.
Adapt the fixed table names and relationships to your actual schema. This is not a
complete implementation for a module that also owns files or external records.

```cfml
component output="false" {
    public struct function deleteCustomer(required numeric customerID) {
        local.params = {customerID: {type: "integer", value: arguments.customerID}};

        // Delete child rows before their parent records, scoped through the owner.
        queryExecute(
            options = {datasource: application.datasource},
            params = local.params,
            sql = "DELETE labels FROM notes_labels labels
                INNER JOIN notes_entries entries ON entries.intEntryID = labels.intEntryID
                WHERE entries.intCustomerID = :customerID"
        );
        queryExecute(
            options = {datasource: application.datasource},
            params = local.params,
            sql = "DELETE FROM notes_entries WHERE intCustomerID = :customerID"
        );

        return {success: true};
    }
}
```

Use explicitly named tables and typed parameters. Do not scan all tables matching a
prefix and delete them automatically. Preserve shared records still used by other
customers; delete only the affected customer's association where appropriate.

The lifecycle invokes hooks inside its database transaction. Do not commit or roll
back the surrounding transaction from a hook. File and external-service operations
cannot be rolled back by that transaction, so repeatability is required independently
of database rollback.

## Files and external services

Resolve owned file locations and external IDs before deleting the rows that identify
them. Restrict filesystem paths to your module's configured storage directory and the
specified customer. Treat an already absent owned file as success. Never remove a
shared folder or the invoice archive.

For external cleanup, use the provider's supported deletion/revocation operation.
Validate its response and handle an already absent resource according to that API's
contract. A timeout does not prove success: retain enough information for a safe retry
and propagate the failure. Never return success merely because a request was sent.
Prevent module jobs, APIs and integrations from recreating data after deletion starts;
entry points outside the core dispatcher must participate in the account lifecycle's
operation guards. See [the lifecycle documentation](invoice-retention.md#lifecycle-service-and-manual-deletion-ui).

## Modules without customer data and retired modules

A component returning only `{success:true}` is appropriate **only after confirming**
that the module owns no customer-specific database records, files or external data.
The supplied demo scaffolds use this pattern because they contain no such data. Extend
their hooks when adding real features.

Keep a retired module's cleanup component and its dependencies deployable while any
historical customer data remains. Removing its directory and registration does not
clean up that data and may prevent Saaster from discovering it later.

## Testing before release

Use the dedicated test database and fixture customers; use mocks for external services.
Verify that:

1. Deleting customer A removes all of A's module data and leaves customer B untouched.
2. Cleanup succeeds when no records exist, and when called twice.
3. A failure partway through cleanup is reported; retry finishes safely.
4. Inactive modules and customers without a current booking are covered.
5. Shared resources survive while another customer still uses them.
6. Account deletion through the lifecycle completes with the implemented hook, while
   the core invoice archive and recorded payments remain intact.

Do not test destructive cleanup against development, staging or production customer
records. See [the test workspace guide](../www/tests/README.md) for fixtures and execution.
