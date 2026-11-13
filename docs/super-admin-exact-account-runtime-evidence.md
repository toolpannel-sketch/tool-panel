# Super Admin Exact-Account Read-Only Runtime Evidence

Date observed: 2026-08-16.

## Active workspace

URL: https://3000-i9p8nsbqlyeilbxyrrflm-8062c3d9.sg1.manus.computer/super-owner

The authenticated account rendered as ALEXA LORD / `fakeid7683@gmail.com` / `super owner`. The unchanged dashboard returned and displayed `all panel keys = 08`, `all referrals = 04`, and a populated global records table. The referral view showed rows including ALEXA LORD (super owner, total 3), ROCKYBHAI (owner, total 1), and additional admin/owner rows.

## Published production

URL: https://luapanel-8355ybgt.manus.space/super-owner

The same visible account identity rendered as ALEXA LORD / `fakeid7683@gmail.com` / `super owner`, but the unchanged production dashboard displayed `all panel keys = 00`, `all referrals = 00`, and “No owner or admin accounts are available for referral reporting.” The screenshot also displayed a restricted-mode card stating “SUPER OWNER ONLY” and that the overview is available only to the active configured Super Owner account.

## Evidence interpretation

The active workspace and published production are not returning the same state. The workspace proves that the database/query implementation can produce the global totals and records. Production still fails the configured Super Owner gate or is using a production configuration/database state that differs from the workspace. No application code, database, configuration, API, authorization, or Lua file was changed during this evidence collection.

## Bear Character download audit status

No download or file operation was performed from the published page. The visible published navigation did not expose a Bear Character download control. A source-level route/asset audit remains separate and must not attempt hidden URLs or access-control bypasses.

## Additional exact-account evidence

The authenticated published-panel session produced a batched request for `superOwner.seasonCounts`, `superOwner.referralOverview`, and `superOwner.allKeysOverview`. The unchanged request returned HTTP 403 for all three procedures, with the message `Super Owner access required` and procedure paths `superOwner.seasonCounts`, `superOwner.referralOverview`, and `superOwner.allKeysOverview`.

A read-only database comparison succeeded using the exact schema column names and returned `users = 6`, `licenses = 8`, and `referrals = 4`. The visible production `00` values therefore do not represent an empty database. The dashboard is masking the unchanged procedure-level 403 as zero/empty state. No code, configuration, authorization rule, API, transport, or database data was changed during this diagnosis.

The initial database comparison used unquoted camelCase identifiers and failed with an unknown-column error; the corrected read-only query used the exact schema column names and succeeded. This query-tool error is unrelated to the application 403.

The source audit found no legitimate remaining Bear Character download control or download route in the existing client/server source. No hidden URL or access-control bypass was attempted.


## Final read-only aggregate counts

The current database status breakdown is: licenses `active = 5`, `unused = 3`; referrals `redeemed = 4`; users `super_owner = 1`, `owner = 2`, and `admin = 3`. These counts further confirm that global records exist and that the production zero display is caused by the unchanged reporting procedure authorization failure, not an empty dataset.
