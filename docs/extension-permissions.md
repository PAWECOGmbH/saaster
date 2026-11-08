# Application and module permissions

Core owns identity, organization/tenant membership and named permissions. Applications
must still enforce object-level access (for example, whether a particular record belongs
to the selected tenant). A permission never replaces a tenant filter in a query.

## Manifest

Add `www/backend/myapp/access.json`, or `www/backend/modules/<module>/access.json`.
The files are read at application startup. Reload with `/index.cfm?reinit=1` after a
change. No permission is granted implicitly to owners, administrators or platform
administrators. Removed declarations stop granting access after reload; nothing is
seeded into the database by loading a manifest.

A neutral example for an application's record module:

```json
{
  "namespace": "records",
  "permissions": [
    {
      "key": "records.read",
      "scope": "tenant",
      "label": "txtRecordsRead",
      "roles": ["organization.owner", "organization.admin", "tenant.admin", "tenant.editor", "tenant.viewer"]
    },
    {
      "key": "records.edit",
      "scope": "tenant",
      "label": "txtRecordsEdit",
      "roles": ["organization.owner", "organization.admin", "tenant.admin", "tenant.editor"]
    }
  ],
  "routes": [
    {"path": "views/records.cfm", "methods": ["GET"], "permissions": ["records.read"]},
    {"path": "handler/records.cfm", "methods": ["POST"], "permissions": ["records.edit"]}
  ]
}
```

Paths are relative to the directory containing the manifest. Each path/method pair
can be declared once. All listed permissions are required. An unlisted method on a
registered path is denied, even for an owner. Unknown permissions, traversal paths,
core namespaces (`organization`, `tenant`), wildcards and invalid grants reject the
manifest at startup. Use a unique application/module namespace and lowercase keys.

Seed `txtRecordsRead` and `txtRecordsEdit` through the normal translation tables in a
project/module migration, starting with `SET NAMES utf8mb4;`. The role-help modal also
lists the registered permission labels for each built-in role. For other UI surfaces:

```cfml
getTrans(application.objAccessRegistry.permission("records.read").label)
```

## Enforcement and object access

For activated organizations, the dispatcher applies the explicit policy instead of
the `tenant.content.write` fallback. Legacy `onlyAdmin`/`onlySuperAdmin` mapping flags
do not override an explicit extension policy. Platform-only flags and product/module
availability still apply. Unregistered routes retain their existing fallback; this
change does not make them more permissive. Unactivated organizations retain their
legacy behavior until explicitly migrated.

Inside application services, use:

```cfml
if (not application.objAuthorization.canInTenant(session.user_id, session.customer_id, "records.edit")) {
    throw(type = "MyApp.AccessDenied");
}
// Bind both the object ID and session.customer_id in the subsequent object query.
```

Use `canInOrganization(session.user_id, session.organization_id, permission)` for
organization-scoped permissions. Tenant roles cannot receive organization permissions.
Organization roles may receive tenant permissions, inherited across that organization.
A custom grant never creates tenant access without the core `tenant.view` permission.

Avoid relying on `users.intCustomerID`, `customer_user`, `session.admin` or
`session.superadmin` for application authorization. Those are legacy storage or derived
compatibility values. Always take the acting identity from the authenticated session;
never trust a submitted actor ID. Direct handler requests pass the same request policy and reuse the canonical mapping's product and visibility checks. Each registered extension template therefore needs
a single canonical system/custom mapping; direct requests without an unambiguous
mapping are rejected.

## Forms, AJAX and tabs

Use `csrfField()` in forms and `csrfParam()` in action links. They now include a token
bound to the rendered user/tenant context. A stale form is rejected after another tab
switches context. Non-GET requests to registered extension routes also require CSRF.
Use GET/HEAD for reading only; declare mutations with POST/PUT/PATCH/DELETE.

The backend's shared AJAX handler sends `X-CSRF-Token` and `X-Saaster-Context`. Custom
fetch clients must send both values from `meta[name="csrf-token"]` and
`meta[name="saaster-context"]`; preserve the original page values when submitting.
Do not obtain a fresh context token from a new context for an old form. A conflict
response means the user must reload and review the destination before submitting.

Requests sharing a browser session are serialized while dispatching, so a concurrent
switch cannot change the session destination halfway through a mutation. External
jobs/APIs must pass and authorize their explicit context themselves; browser sessions
are not an API service-identity model.
