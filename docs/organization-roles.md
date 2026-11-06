# Organization memberships and roles

## Scope

A login belongs to one main organization and can access its directly associated
tenants. Membership in unrelated organizations and nested tenant hierarchies are
outside the model. Existing `customers` IDs remain the business-data boundary:
`intCustParentID = 0` identifies the organization, and its direct children are tenants.
The root customer may also contain business data and is a valid tenant context.

Platform administration (`users.blnSysAdmin`) stays separate. It is not a role an
organization can grant, and it does not implicitly bypass the new permission service.
Support impersonation needs its own explicit integration during the cutover.

## Step 1: foundation (implemented)

V26 adds role and permission catalogs, organization memberships and tenant
memberships. One user can have only one organization membership, including when
suspended. Each organization membership can have at most one assignment per tenant.
Foreign keys and checks prevent assigning tenant roles at organization level or
organization roles at tenant level. Membership states are `active` and `suspended`.
Pending invitations will be separate records, not active memberships.

`application.objAuthorization` provides `canInOrganization(userID, organizationID,
permission)` and `canInTenant(userID, customerID, permission)`, plus corresponding
permission-list methods. Callers must obtain `userID` from the authenticated session.
All decisions read current database state, so suspension, role changes, membership
removal and account/customer deactivation apply on the next check. Unknown permissions
are denied. Organization checks require the root ID; tenant checks require the exact
customer ID and validate its organization boundary, including for inherited grants.

| Role | Organization permissions | Tenant permissions |
| --- | --- | --- |
| `organization.owner` | View, members, tenants, settings, ownership transfer, deletion | All listed tenant permissions throughout the organization |
| `organization.admin` | View, members, tenants, settings | All listed tenant permissions throughout the organization |
| `organization.member` | View | Only through explicit tenant assignments |
| `tenant.admin` | None | View, content read/write, members, settings, billing view/manage |
| `tenant.editor` | None | View, content read/write |
| `tenant.viewer` | None | View, content read |

Permissions are explicit catalog entries, not wildcard grants. Editors and viewers
have no billing access. Organization-wide tenant grants cannot be narrowed by a
suspended or lower-role tenant assignment; remove the organization-wide role when
access should be limited to selected tenants. Product plans/modules remain a separate
condition for using a feature. The catalog initially contains fixed built-in roles;
custom roles and their administration are not implemented.

**Activation boundary:** V26 does not copy legacy memberships or roles. Login,
handlers, routes and UI still use the existing model. The service is available for
integration but is not yet authoritative for application requests. Re-running V26
keeps existing membership data and seeds missing built-in catalog entries. It does
not reconcile arbitrary schema drift or preserve intentional removal of built-in
permission grants. Do not add new-model memberships in production before cutover.

## Step 2: legacy audit, backfill and lifecycle

- Report duplicate assignments, missing/multiple default tenants, cross-organization
  assignments and invalid parent chains before importing anything. Do not silently
  move identities or broaden their access.
- Specify a conservative legacy-role mapping. A legacy superadmin is not automatically
  an organization owner. Confirm ambiguous owner candidates and store ownership explicitly.
- Add transactional membership operations with scope validation and grant restrictions.
  A permission to manage members must not allow an actor to grant stronger roles,
  edit platform administrators, or remove the last active owner. Lock the organization
  row when transferring ownership or changing owner memberships.
- Enforce root-only organization membership and same-family tenant assignment on writes;
  the current foreign keys do not express these cross-table hierarchy rules. Reads
  already reject invalid target hierarchies and cross-family tenant assignments.
- Separate tenant-access removal from user-account deletion. Replace the legacy
  `users.intCustomerID` deletion cascade before enabling the new lifecycle. Define
  organization deletion explicitly instead of turning children into unrelated roots.
- Apply the audited backfill and runtime cutover together. Do not maintain two
  independently editable sources of authorization between these steps.

## Step 3: application integration and UI

- Wire login, MFA, tenant switching and support impersonation to the new context.
- Replace route, handler, AJAX and menu role checks with named permissions. Map
  module operations to concrete permissions; generic content permissions alone do
  not make existing modules enforce read-only access.
- Add membership and per-tenant role management and invitation acceptance/revocation.
- Define API service-identity scopes separately from browser session membership.
- Preserve seat-limit and subscription rules, adapting the counted memberships.
- Exercise existing sessions, escalation attempts, owner transfer, tenant deletion,
  invitations and plan constraints before retiring legacy role flags and links.

## Validation

Integration specs cover effective rights, organization isolation, malformed hierarchy,
role scopes, live revocation, inactive accounts/customers, database constraints and
repeatable migration application. They run only against the dedicated test database.
The complete rollout also needs browser and handler tests at the integration stage.

```bash
bash www/tests/bin/migrate_test_db.sh
bash www/tests/bin/run_tests.sh 'reporter=mintext&bundles=tests.specs.integration.organization_authorization_spec'
```
