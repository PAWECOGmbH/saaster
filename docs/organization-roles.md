# Organization memberships and roles

## Scope

A login belongs to one main organization and can access its directly associated
tenants. Membership in unrelated organizations and nested tenant hierarchies are
outside the model. Existing `customers` IDs remain the business-data boundary:
`intCustParentID = 0` identifies the organization, and its direct children are tenants.
The root customer may also contain business data and is a valid tenant context.

Platform administration (`users.blnSysAdmin`) stays separate. It is not a role an
organization can grant, and it does not implicitly bypass the new permission service.
Support sessions use the represented membership and suppress platform privileges until the verified return to the original platform administrator.

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

**Activation boundary:** V26 only supplies the foundation. V27 adds explicit
per-organization activation and default-tenant preferences. Installing the migrations
does not activate or import any organization automatically. Unactivated organizations
retain their existing behavior. Re-running V26 preserves memberships and seeds missing
built-in catalog entries; it does not reconcile arbitrary schema drift.

## Step 2a: audit and membership operations (implemented)

`application.objMembershipMigration.audit()` returns structural issues for all
legacy organizations, or for one organization when passed its ID. It detects invalid
parent chains, incomplete/duplicate assignments, cross-organization links and invalid
default tenants. A disabled default tenant within an active organization requires
review; a disabled organization is a valid state and stays disabled.
`preview(organizationID, ownerUserID = 0)` adds role proposals,
explicit owner candidates and review items. Both methods only read legacy tables and
can run before V26. A preview with unresolved errors or review items has `ready = false`.
Even one unambiguous candidate is only suggested, never silently selected as owner.

The conservative mapping proposes organization admin only for a legacy superadmin
who already has explicit assignments to every customer in the family. Scoped
superadmins retain proposed tenant-admin assignments and need review. Legacy admins
become tenant admins in their assigned tenants, and ordinary users become editors.
Inactive users receive suspended organization memberships. Platform flags stay separate.
Ownership that would add previously unassigned tenants also requires review. Defaults
are reported for preservation during cutover, not copied or corrected by the preview.

`application.objMembership` provides these internal operations; callers must derive
`actorUserID` from the authenticated session:

| Method | Effect |
| --- | --- |
| `resendInvitation(actorUserID, organizationID, userID)` | Send a fresh activation link to an active member who has not set a password; restricted to organization managers who may manage that role |
| `saveMember(actorUserID, organizationID, userID, organization, tenants)` | Save organization role/status and tenant assignments atomically after validating every change |
| `setOrganizationMember(actorUserID, organizationID, userID, role, status)` | Add/update a same-family account's organization membership |
| `removeOrganizationMember(actorUserID, organizationID, userID)` | Remove that membership and its tenant assignments, preserving the identity |
| `transferOwnership(actorUserID, organizationID, userID)` | Promote an active member and make the former owner an organization admin atomically |
| `setTenantMember(actorUserID, customerID, userID, role, status)` | Add/update access for an existing organization member in the exact tenant |
| `removeTenantMember(actorUserID, customerID, userID)` | Remove only the requested tenant assignment |

Each write locks the root organization row in a database transaction before checking
the actor's current permissions. Role changes, suspensions, removal and ownership
transfer therefore serialize within an organization. Account rows are locked as well.
The last owner with both an active membership and active account cannot be removed,
suspended or demoted, including by two concurrent requests. Another active owner
allows an owner to leave. Ownership transfer cannot target oneself, a suspended or
unrelated member, or a platform administrator.

Only owners can manage organization admins/owners. Organization admins manage normal
members; tenant admins can assign equal or lower tenant roles only to existing
organization members in their tenant. Organization management cannot modify platform
administrator memberships. A platform administrator who is already an organization
owner may transfer their own ownership without changing their platform privileges.
Tenant operations reject members with inherited organization-wide access instead of
pretending that a tenant-specific suspension would restrict them.

## Step 3: activation and browser integration (implemented)

Open **Account settings → Members and roles** (`/account-settings/memberships`)
as an active legacy superadmin whose home is the main organization. The setup view
shows the proposed organization roles and tenant access. Select an eligible owner,
update the preview and explicitly confirm the reviewed proposal before activation.
Structural audit errors prevent activation. Scoped-superadmin and owner-access
changes are explained in the preview and covered by that confirmation.

`objMembershipMigration.activate()` rebuilds the proposal under database locks,
validates the actor again and imports memberships, assignments and defaults in one
transaction. Existing prepared memberships stop activation instead of being overwritten.
An already activated organization is not re-imported. Account home IDs move to the
root so deleting a child does not cascade-delete an identity needed in another tenant.
Legacy flags and `customer_user` rows remain as snapshots, not editable authorities.

Activation is stored in `organization_access`, independently of individual memberships.
Removing a member therefore cannot re-enable legacy access. `membership_preferences`
preserves the former default tenant. Login and MFA select an accessible default;
existing requests fail closed if access to their current tenant disappears rather
than silently switching a mutation to another tenant.

`objMembershipAccess` resolves session rights on each request. Named permissions guard
core member, company, tenant and billing actions. Compatibility flags support existing
menus and route metadata; they are derived from the current tenant's permissions.
Tenant switching rebuilds those flags and product settings immediately. Shared
`checkTenantRange()` and `getAllTenants()` also use memberships after activation.

The question-mark button at the right of the list heading opens a read-only table
explaining the six built-in roles, their scope and inherited tenant access. The help
is also available during setup, in German and English.

The management page provides organization and tenant roles, membership suspension,
removal, restoration and ownership transfer. One **Save changes** button applies the
whole edit; inherited access replaces the tenant controls when an owner/admin role is
selected. The **Action** dropdown beside **Edit** in each list row opens separate
removal/ownership confirmation dialogs that name the member and organization and
explain the effect on all its tenants. Canceling returns to the list.
For active members without a password, the menu also offers **Send activation link**.
Resending creates a fresh token valid for seven days and invalidates the previous link.
Tenant admins can manage existing organization members in their current tenant. Organization managers can create new
accounts using the existing invitation-email flow; submitted legacy privilege flags
are ignored, the account belongs to the root, and its initial tenant access is explicit.
New-account creation enforces the tenant's plan user limit on the server, including
suspended assignments in the count. Existing-member assignment changes do not add
subscription billing or a new seat-purchase flow.

Legacy profile edits preserve global account status and flags for activated accounts.
The old tenant-user deletion and platform user-deletion paths cannot delete their
identities. Tenant deletion is restricted to direct children of the current organization.
The legacy account-cancellation deletion flow is disabled for activated organizations;
it cannot safely delete the whole organization and its children.

## Remaining work

- First-class pending invitations, resend/revoke/accept states and expiry management.
  New members receive the existing seven-day account invitation link; organization
  managers can resend it from the member list.
- Organization deletion and a dedicated global account activation/deactivation flow.
  Membership suspension is available; globally disabled legacy accounts remain disabled.
- Fine-grained permissions for custom modules and project extensions. Unclassified
  handlers, non-GET requests and extension pages require `tenant.content.write`, so
  viewers cannot open extension pages until those modules define safe read routes.
- API service-identity scopes remain separate from browser memberships.
- Custom-role administration and eventual retirement of legacy snapshots.

## Manual verification

1. Apply V26/V27 and reload the application (`/index.cfm?reinit=1` as a platform admin).
2. Open Members and roles in the main organization, review the preview and activate it.
3. Give a test member `organization.member` and `tenant.viewer` in one tenant.
   In a separate browser session, verify that only that tenant is selectable and
   company, member and billing mutations are denied, including direct URLs.
4. Change the member to editor/admin and reload the existing session. Changes should
   apply immediately. Suspend or remove the membership and verify access is revoked.
5. Transfer ownership to an active member. The old owner becomes organization admin;
   attempts to remove, suspend or demote the sole active owner must fail.

## Validation

The authorization, management, migration and access integration specs exercise
organization isolation, malformed hierarchies, scope constraints, live revocation,
last-owner concurrency, migration atomicity, identity rehoming, password login,
request policy, plan limits and rendered forms. All automated writes use the dedicated
test database. `membership_probe.cfm` renders the real view and handler inside that
test application for browser checks; it only accepts fixture identities.

```bash
bash www/tests/bin/migrate_test_db.sh
bash www/tests/bin/run_tests.sh 'reporter=mintext&bundles=tests.specs.integration.organization_authorization_spec,tests.specs.integration.membership_management_spec,tests.specs.integration.membership_migration_spec,tests.specs.integration.membership_access_spec'
```
