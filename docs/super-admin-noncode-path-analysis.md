# Super Admin Non-Code Path Analysis

## Scope

This is a **read-only analysis**. No application code, database row, environment variable, API contract, authorization rule, endpoint, transport component, Lua artifact, or dashboard implementation was changed.

## Unchanged Authorization Condition

The existing `superOwnerProcedure` grants the global-reporting procedures only when all three conditions are true:

| Required condition | Current evidence |
|---|---|
| The session is active | The published `auth.me` result reports the account as active. |
| The persisted role is `super_owner` | The published `auth.me` and `dashboard.users` results report `super_owner`. |
| The authenticated Open ID equals built-in `OWNER_OPEN_ID` | This condition is false: the unchanged `superOwner.*` procedures return HTTP 403. |

The application obtains the authenticated user from the existing request-authentication context. There is no supported panel setting, dashboard action, or local client state that can make one signed-in account assume another account’s Open ID.

## Supported Non-Code Possibilities

| Option | Security impact | Can the current Super Admin account use it? | Result |
|---|---|---|---|
| Sign in with the original project-owner account whose Open ID already equals `OWNER_OPEN_ID` | None; this uses the current security model unchanged. | Only if that exact Manus account is available. | Existing global procedures should authorize normally. |
| Correct the platform-managed `OWNER_OPEN_ID` to the current Super Admin Open ID | None to application code; restores the intended existing identity match. | Yes, after a platform-level correction. | Existing global procedures should authorize normally. |
| Refresh/retry the dashboard | None. | No. | Cannot convert a deterministic 403 into an authorization grant. |
| Change only the database role | Unsafe and ineffective. | No. | The current account already has `super_owner`; the separate Open ID equality condition still fails. |

## Excluded Approaches

The following would change or bypass the protected security model and are therefore not supported under the approved scope: replacing the Open ID in the user row, fabricating an authenticated session, weakening the existing procedure predicate, creating a bypass procedure, proxying the global queries through another account, or changing API/request behavior.

## Exact Conclusion

There is **one supported application-side, non-code path**: sign into the panel using the Manus account that already owns the immutable `OWNER_OPEN_ID` value. If that account is unavailable, there is **no supported non-code way** for the current Super Admin account to satisfy the unchanged `superOwner.*` procedures. A platform-level correction of `OWNER_OPEN_ID` remains necessary for the current account to use the existing global reporting page.
