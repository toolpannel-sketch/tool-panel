# Production Implementation Plan — Stable Device ID Adoption

## Status and decision boundary

This is a **planning-only** document. It does not alter the Merged loader, server, database, validation route, device-binding rule, key files, status files, or any presentation flow.

The isolated target-host probe established that `Client.GetPhoneDeviceID()` is callable, non-empty, and stable across one tested app close/reopen cycle. It does **not** establish app-data-reset or uninstall/reinstall persistence, global uniqueness, anti-spoofing, or a general Android hardware-ID contract. The production design therefore must continue to treat the server as authoritative and retain the existing random local fallback.

> **Key distinction:** adopting the host value for a *new, unbound user* is technically compatible with the current server. Automatically changing an *already-bound user* from the legacy random identity to the host identity is a separate server-side binding migration and is **not** safe to do silently.

## Current contract that must remain protected

| Layer | Current behavior | Planning constraint |
|---|---|---|
| Android loader | `getPersistentDeviceId` / `getDeviceId` is preferred if present; otherwise `.device_id` is read; only then is a 32-hex local value generated. | Add `Client.GetPhoneDeviceID()` only under a guarded, non-empty native-host branch. |
| Local files | `key.json` stores only the license key. The legacy random identity is in `.device_id`; `.license_status` is diagnostic-only. | Do not rewrite `key.json` or `.license_status`. Never delete, overwrite, or reinterpret an existing `.device_id` automatically. |
| Server request | The loader submits `{ key, device_id }` to the canonical validation endpoint. The server hashes `device_id` before storage. | Keep the endpoint, request shape, server hashing, status vocabulary, authorization, and rate limit unchanged for initial adoption. |
| Binding rule | An active single-device license whose stored hash differs from the submitted hash returns `device_mismatch`. Multi-device limits are counted server-side. | Do not auto-rebind an active license by changing only client identity resolution. |
| Existing safe rebind | A device binding may move between licenses only when the source license is expired/revoked under existing atomic rules. | Do not reuse or broaden this rule for same-license identity migration without a separate server design and approval. |

## Proposed staged design

### Stage 1 — New-user host identity adoption

The initial implementation should only change the resolver used before an identity has ever been bound for this loader.

| Resolver order | Condition | Returned identity | Existing files affected |
|---|---|---|---|
| 1 | Documented global provider exists and returns a non-empty string | Existing provider value | None. |
| 2 | An existing non-empty `.device_id` is present | Existing legacy random value | None. |
| 3 | No legacy file exists; `Client.GetPhoneDeviceID()` is available, protected by `pcall`, and returns a non-empty trimmed string | Host-provided value | None in the privacy-first design. |
| 4 | The host method is absent, errors, returns a non-string, or returns empty/whitespace | Existing random-generation fallback | Create `.device_id` exactly as today. |

This order deliberately keeps all existing users on the exact same legacy identity. A brand-new user with no `.device_id` uses the proven host identity when available. The existing canonical validation call hashes whichever identity was selected, binds it transactionally, and continues unchanged.

The resolver must not display, log, write to diagnostics, add to popup text, or send the raw host value anywhere except the existing in-memory canonical validation payload. The current server already receives a device identity for validation; it stores only its secret-salted hash.

### Stage 2 — Existing-user migration is not automatic

An existing user normally has `key.json` plus a separate `.device_id`. **`key.json` does not contain an old random device ID.** Under Stage 1, the loader intentionally continues to use the existing `.device_id`, so the server binding and normal login remain unchanged.

If the resolver instead sends `Client.GetPhoneDeviceID()` for that user, the server hashes a different input and the current active-license rule correctly returns `device_mismatch`. This is why deleting `.device_id` or silently preferring the host value for existing installs must not be treated as migration.

A future explicit migration, if separately approved, requires a dedicated server transaction with all of these conditions:

1. The client proves possession of the current legacy identity through the normal canonical validation flow; it must not expose either raw identity in logs or UI.
2. The server verifies that the legacy hash is already bound to the **same** license and that the new host-derived hash is not bound to another license.
3. The server atomically replaces or aliases only that binding, preserves max-device enforcement, and writes an auditable migration event without raw identities.
4. The migration is rate-limited, idempotent, and never uses the existing expired/revoked cross-license replacement exception.
5. A failed migration preserves the existing legacy binding and falls back to the legacy resolver, rather than producing a partial state.

This would change the protected canonical binding rule and requires a separate approval, schema/route review, regression suite, and Android verification. It is expressly outside the initial client-only Stage 1 change.

## Failure and fallback behavior

| Situation | Required behavior | Forbidden behavior |
|---|---|---|
| `Client` is missing or inaccessible | Continue to legacy file/random resolver. | Throwing a new startup error or blocking login. |
| `GetPhoneDeviceID` member is missing, errors, returns non-string, empty, or whitespace | Continue to legacy file/random resolver. | Writing an empty `.device_id`, emitting raw error text, or sending an empty `device_id`. |
| Existing `.device_id` exists | Use it unchanged during Stage 1. | Replacing it with the host value or deleting it. |
| Existing active binding differs from a host-derived value | Keep legacy identity; do not attempt automatic conversion. | Calling rebind logic, unbinding, or weakening `device_mismatch`. |
| Folder/storage preflight fails | Preserve the existing fail-closed folder error path. | Writing device/key/status data before the preflight succeeds. |

## Compatibility decisions required before implementation

The user-facing UI remains unchanged in every option; no raw identifier should be shown. The unresolved choice is local backward-compatibility strategy for **new** host-identity users.

| Option | New user local storage | Old-loader rollback compatibility | Privacy / integrity trade-off | Recommendation |
|---|---|---|---|---|
| **A. Privacy-first** | Do not mirror the host value into `.device_id`. | An older loader that lacks the host branch would generate a new random identity and receive a server mismatch. | Minimizes local exposure of the host value, but does not provide a code-only rollback. | Safest identity handling; use only with a forward-compatible rollback release policy. |
| **B. Compatibility mirror** | After a successful host-based validation, mirror the raw host value into the existing hidden `.device_id`. | Older loader keeps submitting the same value. | Preserves local compatibility but stores the host value in external app storage, where the current random value is also stored. | Only with explicit privacy approval; never overwrite an existing legacy file. |
| **C. Server alias/migration record** | No raw host mirror is needed. | Server accepts a controlled legacy-to-host alias under an approved migration protocol. | Most robust for rollback/migration, but requires schema and canonical server-rule changes. | Future option; not part of initial adoption. |

## Rollback plan

There is no safe “replace code and forget” rollback if new users are bound only with a host identity and an older loader knows only the random fallback. The rollout must therefore select an explicit rollback strategy before deployment.

For the recommended privacy-first option, rollback means deploying a forward-compatible hotfix that **retains the same host-resolution branch** while disabling only unrelated new behavior. It must not revert to the old random-only resolver for users whose server binding was created from the host value. For the compatibility-mirror option, an older resolver remains compatible because it reads the mirrored local value. For a server-alias option, rollback depends on the approved alias records and transaction design.

In all cases, a rollback must preserve key JSON, `.license_status`, existing random `.device_id`, current folder behavior, validation payload contract, device limits, and audit history. No rollback may mass-unbind devices or reset active licenses.

## Required implementation sequence after separate approval

| Step | Change boundary | Required validation |
|---|---|---|
| 1 | Add a guarded host resolver branch in the Merged loader, with legacy file before host identity for existing users. | Lua syntax; targeted resolver test; no raw-ID diagnostics. |
| 2 | Add tests for missing/malformed host response, existing `.device_id`, new host identity, and random fallback. | Full server/Lua suite; TypeScript check. |
| 3 | Verify current API payload and canonical server hashing remain unchanged for new host-identity users. | Local route and transaction regression tests. |
| 4 | Android test new-user host branch, existing legacy user, host API unavailable fallback, valid login, Maintenance, Announcement, Telegram, and Main Lua. | User-provided non-secret outcomes only. |
| 5 | Keep legacy-to-host migration disabled. | Confirm no existing device binding has changed automatically. |

Separate approval would still be required for any Stage 2 server migration, `.device_id` compatibility mirror, database migration, validation-route change, or identity rollback change.

## Recommendation

Approve only **Stage 1** if the goal is safer identity selection for future clean installs while preserving all existing users. Use the privacy-first option unless the user explicitly accepts mirroring the raw host value into `.device_id` for backward-version rollback. Do not replace existing random identity, migrate device bindings, or modify canonical server rules until the separate Stage 2 migration design is approved.
