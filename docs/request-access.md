# Shared browser request access

`application.objRequestAccess` owns browser access decisions. `Application.cfc`
keeps session locking, session refresh, request setup and response rendering. The
policy does not emit redirects, alerts or HTTP responses, so its permission checks
can also be used by views. Named role permissions remain in `objAuthorization`,
and core action classification remains in `objMembershipAccess.allowRequest()`.

## Dispatch order

1. `resolve(targetPage, sefString, method)` resolves the route and returns `content`
   plus a `decision`. Direct registered templates require exactly one canonical
   mapping; unregistered mapped handlers remain inaccessible by direct URL.
2. `checkContext(content, method, submitted, queryString, headers)` checks current
   membership/action permissions and the context token. Denials retain HTTP 403
   for missing permissions and HTTP 409 for stale forms. This runs before language
   changes or rendering, inside the existing session lock.
3. `checkPage(content, method, queryString)` checks the route's product access and
   mapping flags, or returns the existing anonymous login/registration/invoice-print
   redirect. Explicit extension policies replace legacy admin/superadmin mapping
   restrictions only for activated organizations; platform-only restrictions remain.
4. `checkCsrf(content, method, queryString, headers)` applies the existing CSRF
   verification. Invalid AJAX requests receive HTTP 403; other requests retain the
   login/dashboard redirect and alert. The dispatcher logs rejected CSRF requests.

Every decision contains `access`. A denied decision also provides a `reason` and
either a relative `redirect` or an HTTP `statusCode`/`statusText`, optionally with a
translated message/alert key. These descriptions are applied by the dispatcher
before invoking application hooks or including the target template. Do not use an
individual stage as a replacement for the complete request checks.

## Action visibility

Use `canAccess(content, method = "GET", submitted = {}, queryString = {})` with
trusted route metadata from `objGlobal.getSEF()` to check an action for the current
authenticated session. It combines membership/action permissions, product access,
mapping flags and login requirements. Pass the intended method and action keys,
not the method of the page displaying the button. For example, with `targetRoute`
resolved for an application's edit handler:

```cfml
application.objRequestAccess.canAccess(targetRoute, "POST", {edit_record: 1})
```

The check itself does not change session alerts, emit responses, or require a CSRF
token: a page must be able to decide whether to show a form before it is submitted.
Keep the normal token helpers in that form. A visible action never authorizes its
later submission; the dispatcher and handler still check it again. Resolve fresh
metadata in the current context, do not accept a route struct from the client or
cache permission results across users or context changes. `getSEF()` retains its
existing language/slug preparation behavior.

For a named permission without a route, use `objAuthorization.canInTenant()` or
`canInOrganization()`. Object-specific tenant filtering remains the application's
responsibility. This service does not define API service-identity permissions.

## Positive route metadata and compatibility

`objGlobal.getSEF()` now exposes `access` instead of `noaccess`. Internal consumers
use the positive value consistently; there is no duplicate negative flag. Custom
code reading `route.noaccess` must use `not route.access`, and code setting a denial
must set `route.access = false`.

`moduleAccess(moduleID)` preserves the existing module-booking decision and delegates
the date check to `bookingAccess(status, at)`: free bookings, or bookings whose
inclusive start/end dates contain today, retain access. Canceled bookings retain
access until their end date. The existing platform-admin exception is preserved;
support sessions do not gain it. Role permissions do not grant product access.

This refactor deliberately retains `getModuleStatus()` as the source of route-level
module entitlement. That existing method reads direct module bookings, not modules
included only through a plan. Aligning that behavior with plan-included modules is
a separate follow-up, not a change introduced by this refactor.

No database migration is required. Reload the application after deploying so that
the new service is initialized. Existing organization activation boundaries remain
unchanged.

## Validation

`request_access_spec` covers anonymous entry points, legacy mapping roles, current
membership checks, support separation, context-token handling and booking dates.
`extension_http_spec` exercises real routed and direct template requests, including
product/platform restrictions, missing or ambiguous mappings, CSRF, stale forms and
unregistered HTTP methods. Existing membership, scheduler and security suites remain
applicable.
