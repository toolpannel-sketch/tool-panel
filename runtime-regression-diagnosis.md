# Runtime Regression Diagnosis Notes

## Read-only snapshot — 2026-08-20 21:41 UTC

The published `GET /api/maintenance/active` and `GET /api/announcement/active` endpoints each returned `{ "active": false }` at the time of inspection.

The persisted Maintenance record was enabled, but its UTC window was `2026-08-20T21:30:00Z` through `2026-08-20T21:35:00Z`; database UTC was `2026-08-20 21:41:13`, so the endpoint correctly returned inactive at inspection time. The persisted Announcement record was disabled and had an earlier UTC window ending at `2026-08-20T21:27:00Z`.

The active downloadable `BRPlayerCharacterBase-Reusable.lua` defines and calls the Maintenance endpoint after a valid license response, but does not define, fetch, or invoke the Announcement endpoint, presentation flow, ticket request, or redirect flow. This is a delivery/runtime gap distinct from the public endpoint state.

The merged reference carries an Announcement fetcher, but invokes it as `fetch_active_announcement(LICENSE_SESSION.key)` even though the canonical validation response intentionally returns no raw key. Its ticket request therefore receives no key and cannot obtain a redirect ticket. The isolated correction must retain the locally submitted, already validated key only in Lua memory and pass it to the presentation-only Announcement ticket request; the canonical validation endpoint and its response contract must remain unchanged.

Local browser regression check: Home and Global Overview loaded under the configured Super Owner session, including Season Counts, Referral Overview, and All Keys. Subsequent direct visits to System Control and Announcement Control resolved as a different browser identity and correctly displayed their existing restricted-page state rather than exposing controls. No settings were saved and no key-management action was invoked. This browser identity change is outside the Lua delivery correction; focused authorization, maintenance, announcement, and Telegram test coverage remains green.

## Confirmed Android Maintenance failure — 2026-08-20 22:07 UTC

The user ran the Android Lua host at 03:35 local time during a saved enabled Maintenance window and received only the valid-authorization popup; Main Lua continued instead of showing the configured Maintenance popup. Read-only database inspection at 22:06:52 UTC confirmed `enabled = 1`, `start_at = 2026-08-20 22:00:00`, `end_at = 2026-08-20 22:30:00`, and version `2`. At 22:07 UTC the live public endpoint at `https://luapanel-8355ybgt.manus.space/api/maintenance/active` returned `{"active":true,"version":2,"title":"SERVER MAINTENANCE","message":"SERVER UNDER MAINTENANCE 🧑‍🔧","endAt":"2026-08-20T22:30:00.000Z"}`. Therefore configuration persistence, UTC scheduling, and the public endpoint are correct; the remaining fault is in the delivered Lua Maintenance GET callback/response handling or its authorized continuation sequencing.

## Android diagnostic outcome and isolated correction — 2026-08-21

The approved non-secret Android status capture recorded `success=true`, `result=500`, and `body=present` for the isolated Maintenance `GET` request. The public endpoint separately returned a normal inactive JSON response, so this excludes the protected canonical validation route, its callback, and the Android bridge's basic request delivery from the fault domain. The failure is isolated to the Android bridge's handling of this GET-style Maintenance status call.

The permitted correction replaces only the post-validation Maintenance query in `BRPlayerCharacterBase-Merged.lua` with the bridge's documented POST request form and a fixed key-free `{}` body. A matching read-only POST handler was added solely to `/api/maintenance/active`; it does not consume request data, use the canonical validation limiter, or participate in license, authentication, authorization, device-binding, referral, or key-generation decisions. The former diagnostic fields were removed after the cause was captured.

The expired saved-key report was traced to the Android key-entry control potentially rendering its pasted text before Lua receives `OnTextChanged`. The key-entry confirmation now reads the text control once at submit time and passes that normalized live value into the existing unmodified canonical validation call. The existing valid-response-only `key.json` write remains unchanged: a rejected or failed validation cannot overwrite the previous saved key.

Non-destructive browser regression check under the configured Super Owner session confirmed that Home retained its creator-scoped key registry and that Global Overview exposed all-panel key/referral totals, Referral and All Keys views, Season Visibility, and the confirmation-gated deletion controls. No save, deletion, or other state-changing operation was performed.

The existing System Control page loaded its Maintenance switch, title, schedule, Unicode message, and Save Maintenance controls under the verified Super Owner session. Announcement Control continued to resolve its existing guarded-page behavior; due the browser account identity changing during navigation, no Announcement save was attempted. No panel-side procedure, authorization check, data value, or key-management state was changed during these visual checks.

## User real-device verification — 2026-08-22

The user reports that the corrected Maintenance sequence passes on Android: with Maintenance OFF and Announcement OFF, a valid login continues to Main Lua; with Maintenance ON, valid authorization succeeds, the configured Maintenance popup appears, and Main Lua does not execute. The existing Maintenance gate is therefore a fixed baseline for subsequent investigation and must not be rewritten or refactored.

With Maintenance OFF and Announcement ON, the Announcement popup now appears and Main Lua executes, but its OK action does not open the current key's mapped Telegram channel. This narrows the remaining Announcement fault to the existing post-OK ticket/mapping/redirect sequence, not the Maintenance or active-Announcement presentation queries.

The user also reports emoji rendered as `?` by both Maintenance and Announcement game popups, despite the panel accepting and preserving those characters. This is consistent with a shared host-popup font glyph limitation; backend-to-Lua preservation and available Android/UE4 font or icon support remain to be confirmed read-only.

The attempted revoked-old-key replacement recorded `key is bound to a different device` rather than a successful new-key validation. This status is a device-binding result and cannot by itself prove that the saved key replaced the newly typed key. The approved key-free trace values (`input_source`, `input_length`, and `validation_status`) are required from a single clean repro before any change is considered.

### Diagnostic evidence received after the approved trace build

The Android saved-key trace now reports `input_source=live`, `input_length=35`, and `validation_status=device_mismatch`. This proves the newly entered key was captured from the live Android control and reached canonical validation; it was rejected by the existing device-binding policy. `key.json` correctly remains unchanged because the existing persistence rule writes only after canonical `valid` status. This is not a stale saved-key submission.

The Android Telegram trace reports `OK_CALLBACK` followed by `TICKET_MISSING` (and a second `TICKET_MISSING` after the action). The existing Announcement OK handler ran but received no eligible ticket, so it never attempted ticket redemption or host OpenURL. Read-only source analysis is required to identify the exact existing ticket-eligibility condition before any mapping change is considered.

## Approved narrow correction scope — 2026-08-22

The visible Telegram setup UI is account-level: it persists one current channel per account and presents Owner/Super Owner scope management; it has no per-license mapping control. The ticket service had nevertheless required an invisible `telegram_key_mappings` record for the validated license, creating the confirmed `TICKET_MISSING` mismatch. The approved correction resolves the validated license through `createdByUserId` and that creator's current enabled channel, including historical creator-owned keys. Ticket lifetime, single redemption, device binding, the Announcement-OK-only trigger, referral-scoped channel edits, and the global Telegram enable switch remain unchanged. Missing or disabled creator channels are exposed only as allowlisted non-secret diagnostic states.

The approved saved-key correction keeps canonical validation and its public response contract intact. Inside the existing validation transaction, a device hash may move to the newly validated license only when the source license is revoked or expired by status/date. A source license that remains active or unused continues to return the existing device-mismatch result. The binding row is locked and ownership is updated atomically; no raw device ID, key, ticket, URL, token, response body, or user data is written to diagnostics.

### Emoji rendering feasibility result

The active Lua popup can adjust only the existing `RichText_Content.Font` size. No packaged UE4 font (`.ttf`, `.otf`, `.ttc`, or `.uasset`), emoji sprite, Rich Text image-data table, decorator, or documented runtime font-loading API is present in the supplied project/runtime artifact. The UE4 Rich Text documentation requires configured font assets for text styles and packaged Data Table/decorator assets for inline images. Therefore there is no supported Lua-only route to render genuine emoji in the current Android host. The shared Maintenance/Announcement text is preserved unchanged; an approved packaged UE4 font asset with required glyphs or an existing host-supported sprite/icon API is required before an emoji rendering change can be made.
