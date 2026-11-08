# Organization memberships and roles

## Scope

A login can belong to multiple independent main organizations, with independent
roles, status and direct tenant assignments in each. Nested tenant hierarchies remain
outside the model. Existing `customers` IDs remain the business-data boundary:
`intCustParentID = 0` identifies the organization, and its direct children are tenants.
The root customer may also contain business data and is a valid tenant context.

Platform administration (`users.blnSysAdmin`) stays separate. It is not a role an
organization can grant, and it does not implicitly bypass the new permission service.
Support sessions use the represented membership, stay within the organization selected at support login, and suppress platform privileges until the verified return to the original platform administrator.

## Step 1: foundation (implemented)

V26 adds role and permission catalogs, organization memberships and tenant
memberships. V29 changes V26's original one-organization constraint to one membership
per (user, organization) pair. Each membership can have at most one assignment per tenant.
Foreign keys and checks prevent assigning tenant roles at organization level or
organization roles at tenant level. Membership states are `active` and `suspended`.
V30 stores invitations separately; they grant no membership before acceptance.

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
Tenant admins can manage existing organization members in their current tenant.
Organization managers invite new or existing identities through the invitation dialog.
Old account-creation bookmarks redirect to memberships for activated organizations.
The older activation-link action remains available for pre-existing passwordless members.
Invitation tenant assignments enforce plan user limits again on acceptance, including
suspended assignments in the count. Existing-member assignment changes do not add
subscription billing or a new seat-purchase flow.

Legacy profile edits preserve global account status and flags for activated accounts.
The old tenant-user deletion and platform user-deletion paths cannot delete their
identities. Tenant deletion is restricted to direct children of the current organization.
The legacy account-cancellation deletion flow is disabled for activated organizations;
it cannot safely delete the whole organization and its children.

## Multiple organizations and identity (V29)

User IDs stay stable. `users.intCustomerID` is a nullable legacy home reference, not an
authorization boundary. Its foreign key now uses SET NULL rather than deleting an
identity with the customer. Membership removal, suspension, role changes and ownership
transfer always constrain the exact organization. `membership_identities` remembers
managed identities after their last membership disappears and prevents legacy fallback.
Existing IDs, assignments, flags and business-data boundaries are preserved.

The tenant picker includes destinations across accessible organizations and labels
them with the organization name. Login/MFA choose an accessible default; an existing
request never silently moves to a fallback tenant. Derived administrator flags are
rebuilt for the selected context. A legacy home organization remains usable until its
own explicit activation even when the identity joins an activated organization.

Forms and action links carry a context token through the existing CSRF helpers. AJAX
sends the same context via a header. An old form cannot apply to another tenant after
a tab changes context. The dispatcher serializes requests sharing a session while
executing them. See [extension integration](extension-permissions.md) for custom clients.

## Invitation lifecycle (V30)

`objOrganizationInvitation` exposes `invite`, `resend`, `revoke`, `inspect`,
`listForOrganization` and `accept`. Management calls require the authenticated actor
and an explicit organization. Acceptance takes an authenticated recipient ID, or a new
password for a previously unregistered/passwordless recipient proven by the mail token.
HTTP callers cannot submit the authenticated recipient ID themselves.

Invitations store the organization, recipient, proposed organization role, explicit
tenant assignments, inviter, expiry and status (`pending`, `accepted`, `revoked`,
`expired`). Tokens have 256 bits of random input; only SHA-256 hashes are stored.
Links last seven days. Resending replaces the token; old, revoked, expired and used
links cannot be accepted. Expiry is enforced on every lookup and displayed even if the
stored pending row has not yet been marked expired by a subsequent management action.

Acceptance locks the organization and invitation, rechecks the inviter's current
permission to grant the proposal, validates active tenants and identity, and creates
memberships atomically. Existing memberships are never overwritten or reactivated by
an invitation. Duplicate/paralleled acceptance has one success and subsequent rejection.
Email locks shared by registration, legacy account creation and invitation acceptance
prevent concurrent account duplication. Existing ambiguous email identities are not
merged automatically; inviting/accepting them is rejected for review.

Existing password-protected identities must sign in; the existing MFA flow remains in
force. Invitation-only authentication does not create an application access session.
This also allows an identity with no current memberships to accept a new invitation.
A new identity is created only at acceptance, with no organization privilege flags.
The existing mail layout and translation system serve both themes.

## Deployment and compatibility

Apply V29 and V30 after V26–V28, then reload the application. Existing activated
organizations retain their memberships and grants. No unactivated organization is
imported or activated by these migrations. New application permissions require an
explicit manifest and explicit role grants; there are no wildcard grants.

Applications should migrate from home-customer/global-flag checks to the public
membership/authorization services and adopt the context-bearing CSRF helpers. See
[the integration guide](extension-permissions.md) for a neutral example. Direct SQL
that assumes deleting a customer also deletes its users must be reviewed; identity
cleanup is an explicit lifecycle operation now. Demo seeding explicitly removes its
reserved demo identities before rebuilding customers.

## Remaining work outside this scope

- Organization deletion and dedicated global account activation/deactivation workflows.
- Object-specific access rules remain the responsibility of each application/module.
- API service-identity scopes remain separate from browser memberships.
- Custom-role administration and eventual retirement of legacy snapshots.

## Manual verification

1. Apply V26–V30 and reload the application (`/index.cfm?reinit=1` as a platform admin).
2. Open Members and roles in the main organization, review the preview and activate it.
3. Give a test member `organization.member` and `tenant.viewer` in one tenant.
   In a separate browser session, verify that only that tenant is selectable and
   company, member and billing mutations are denied, including direct URLs.
4. Change the member to editor/admin and reload the existing session. Changes should
   apply immediately. Suspend or remove the membership and verify access is revoked.
5. Transfer ownership to an active member. The old owner becomes organization admin;
   attempts to remove, suspend or demote the sole active owner must fail.

6. Invite an existing identity into a second activated organization as a viewer. Sign
   in with that identity, accept, and switch between the original and new organization.
   Verify separate roles, settings and tenant access. Suspend/remove only one membership.
7. Invite a new email, verify that no user/membership exists before acceptance, and
   accept using the mail link. Resend/revoke another invitation and try its old link.
8. Keep a management form open in tab A, switch context in tab B, then submit tab A.
   Even when both destinations allow management, the old form must be rejected.
9. Exercise a manifest's GET read route as a viewer and its POST handler as an editor;
   direct template requests, wrong methods and missing tokens must follow the same rules.

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

Additional integration suites cover `access_registry_spec`, `extension_http_spec`,
`multiple_organizations_spec`, `organization_invitation_spec` and `organization_upgrade_spec`.
The upgrade spec executes V29 against isolated pre-upgrade tables inside the dedicated
test database, checking retained IDs/roles and explicit activation boundaries. Invitation
specs use the real mail layout and local Inbucket service, including concurrent acceptance.
