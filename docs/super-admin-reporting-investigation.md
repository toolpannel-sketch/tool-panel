# Super Admin Reporting Investigation

## Read-Only Evidence

On the current workspace preview route `/super-owner`, the configured Super Admin account rendered the existing dashboard with **05** panel keys and **03** referrals. The existing referral overview table also rendered five account rows and attributed all three redeemed referrals to `ALEXA LORD`.

The same workspace database returned **5** license rows, **3** referral rows, and **5** user rows through read-only aggregate queries. The configured account is stored as an active `super_owner`.

## Implication

The screenshot’s zero/empty state is not reproducible in the active workspace browser session. The current dashboard implementation silently renders `0` and empty tables when any query data is unavailable, which masks request failures or stale/cached results. The reporting-only correction should make loading/error/stale states explicit and add an automatic fresh-data refresh when the Super Admin dashboard becomes active, without changing protected server, authorization, API, transport, or Lua behavior.

## Published-Panel Evidence

On the published `/super-owner` route, the existing batched `superOwner.seasonCounts`, `superOwner.referralOverview`, and `superOwner.allKeysOverview` request returned HTTP `403` for all three procedures with `Super Owner access required`. The current client fallback then rendered `00` and empty-table text, exactly matching the supplied screenshot.

The same published session's existing `auth.me` response and `dashboard.users` response identify the signed-in account as an active persisted `super_owner`. Consequently, the screenshot does not represent zero real records: it represents an existing protected-procedure authorization denial being silently masked by the dashboard. No protected code or contract has been modified during the investigation.
