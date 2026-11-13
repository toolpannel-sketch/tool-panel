# Lua License Control Panel — A-to-Z Replication Handoff

## Purpose

This handoff is for creating a **new, independent Lua License Control Panel** that reproduces the current panel’s documented workflows and security boundaries as closely as possible. The supplied current source archive is the primary implementation reference; this guide is the scope, configuration, and acceptance contract.

> **Security boundary:** The new panel must use its own database, owner identity, OAuth application, domain, and managed secret values. Do not transfer production credentials, session cookies, raw device identifiers, raw license keys, Telegram tokens, or private user data in chat, source control, screenshots, or public files.

## What to attach to a new build request

Send the following files to the new project task, in this order if files must be sent one at a time.

| Order | File | Why it is needed |
|---|---|---|
| 1 | `A_TO_Z_PANEL_REPLICATION_HANDOFF.md` | The exact scope, configuration boundary, and acceptance requirements. |
| 2 | `Panel_Replication_Prompt.md` | Detailed implementation rules, database responsibilities, role model, HTTP behavior, UI rules, and test matrix. |
| 3 | `lua-license-panel-current-source.tar.gz` | Sanitized current source tree. Treat it as the authoritative implementation reference when it differs from prose. |
| 4, optional | A separately authorized data migration export | Only when the new owner is authorized to migrate their own users, keys, bindings, announcements, referrals, and Telegram mappings. |

The source archive must be copied into a **new project**, never over the running production project. It contains source code and tests only; it does not carry over a live database, secret manager values, OAuth state, hosting domain, or Manus-owned configuration.

## Copy-paste instruction for the new build task

```text
Build a new independent Manus WebDev project from the attached sanitized source archive and replication documents. Reproduce the current Lua License Control Panel’s behavior, UX, role rules, canonical HTTP contracts, database schema, tests, Android Merged Lua integration, System Announcement, and isolated Telegram mapping/ticket extension.

Treat the archive as the source of truth. Do not invent alternate authorization paths, relaxed validation, fallback Telegram mappings, client-trusted device binding, or mock production data. Use a new database, new managed secrets, a new OAuth application/project owner binding, and a new HTTPS domain. Apply migrations before importing any separately authorized data. Preserve the existing API and Lua file contracts unless a deliberate versioned migration is approved.

Before publishing, run the documented automated tests, type-check, browser checks, and the Android verification matrix. Do not claim exact equivalence until those checks pass.
```

## Current behavior that must be reproduced

| Area | Required behavior |
|---|---|
| Authentication and roles | Supported OAuth/session flow; server-enforced Super Owner, Owner, and Admin permissions; referral onboarding; no client-side role trust. |
| Key management | Server-generated keys, duration/fixed-expiry handling, status controls, creator scoping, search, copy-ready key JSON, per-key device usage, unbind controls, and protected delete actions. |
| Canonical binding | Server hashes the submitted device identity and keeps raw values out of the database. Device ownership and limits remain server-authoritative. |
| Safe replacement | A device binding can move to a new key only when its old source key is revoked or expired; active-key rebind remains rejected. |
| Canonical validation | Preserve the released `POST /api/license/validate` request/response contract used by the Android loader. Keep compatibility endpoints only where they are already part of the released source. |
| Lua folder setup | The Merged Lua uses the proven `Client.WriteFileAtPath` marker write/read-back preflight before normal license persistence, without overwriting keys, identities, or status files. |
| Saved-key flow | Store a validated key only after canonical success; preserve existing data on invalid, expired, revoked, or transport-failure results. |
| Maintenance | A valid license remains valid, but active Maintenance presents its configured message and blocks Main Lua after validation. |
| Announcement | After validation and when Maintenance is inactive, show the configured announcement. Cancel continues Main Lua; OK may execute the isolated Telegram flow and then continue Main Lua. |
| Telegram extension | Isolated and removable. Use strict Telegram URL validation, explicit server-side license-to-account mapping, short-lived hashed single-use device-bound tickets, and no fallback channel resolution. |
| UI | Responsive cyberpunk dashboard with the same management areas, server-backed empty/error states, and no fabricated users, keys, reviews, or telemetry. |
| Audit and privacy | Audit security-relevant administrative actions with masked values. Never log raw keys, raw device IDs, ticket values, OAuth tokens, database credentials, or secret environment values. |

## Canonical server and Lua contracts

The new project must preserve the released contract rather than substituting a browser-only or local-only implementation.

| Contract | Required rule |
|---|---|
| Validation request | `POST /api/license/validate` with JSON `{ "key": string, "device_id": string }`. |
| Validation decision | Server validates registration, status, expiry, device ownership, safe replacement conditions, and device capacity inside the existing transactional binding flow. |
| Validation outcome vocabulary | Preserve the client-consumed success/status/message fields and logical outcomes for valid, not registered, revoked/invalid, expired, device mismatch, and maximum device limit. |
| Device hash | Hash on the server using an application secret. Never store the raw `device_id`. |
| Main Lua gate | Main Lua must run only after canonical success and the approved post-validation presentation sequence. Network, malformed, unknown, or missing callback outcomes must fail closed. |
| `key.json` | Continue using the released JSON wrapper format `{"key":"..."}`. |
| `.license_status` | Keep it diagnostic-only and non-secret. Do not place raw keys or host identities in it. |

## Current Android Merged Lua behavior

The file `BRPlayerCharacterBase-Merged.lua` is the exact production artifact to start from. The new project must retain its tested order rather than rebuilding it from memory.

```text
folder marker write/read-back preflight
→ resolve device identity
→ canonical validation
→ active Maintenance blocks Main Lua
→ active Announcement presentation
→ Announcement OK: optional mapped Telegram ticket/redeem/open flow
→ Main Lua continuation
```

### Host-first anti-cloning policy

The current approved policy is intentionally **Option A**, not a forced migration:

| User state | Resolver behavior |
|---|---|
| Existing active legacy `.device_id` exists | Preserve the legacy local value so existing active bindings are not silently broken, migrated, rebound, or invalidated. |
| Fresh enrollment with no legacy local ID | Safely call `Client.GetPhoneDeviceID()` before generic providers or the random local fallback. Keep this raw host value in memory only. |
| Host value unavailable | Keep the released generic-provider and random-local compatibility fallback. This path is not a complete anti-cloning guarantee. |

The new project must not claim device hardware attestation. The tested mechanism blocks normal complete-folder copying in the unmodified runtime; a modified client able to choose arbitrary payload values requires a separate server-verifiable host-attestation design.

## Current Android evidence to reproduce

The new project should repeat these tests with its own authorized key and devices before relying on the release.

| Test | Required result |
|---|---|
| Fresh A host-first login | Valid login and Main Lua execution; no newly written local `.device_id` is required for the host-first path. |
| A → B complete `lua-license` folder copy | B is rejected as bound to a different device; B must not execute Main Lua. |
| Same A after Clear Data | Same existing valid key logs in successfully. |
| Same A after uninstall/reinstall of the same build | Same existing valid key logs in successfully. |
| Existing legacy user | Remains on the existing legacy identity without automatic rebind or deletion. |
| Telegram mapping | Announcement OK opens only the explicit mapped channel after valid ticket checks; Cancel and missing mapping continue Main Lua without opening Telegram. |

## Required new-project configuration

The project owner must configure their own managed values. Values from the original deployment must never be copied.

| Category | New-project requirement |
|---|---|
| Database | Separate MySQL/TiDB database or schema. Apply migrations before any authorized data import. |
| Auth and owner | New OAuth application/project identity and the correct platform-managed owner binding. Do not hardcode or bypass owner authorization. |
| Secrets | New `JWT_SECRET`, database connection, OAuth values, and required platform keys through the managed secret interface. |
| Domain | New stable HTTPS domain. Update client-facing Lua/API configuration only through the approved release process. |
| Branding | New project title and logo as required. |
| Telegram | New owner’s mappings and channel links. Do not import mappings or ticket data without explicit authorization. |
| Android host | Verify the exact UE4/Dynamic Lua HTTP bridge, JSON support, allowed storage path, `Client.WriteFileAtPath`, and `Client.GetPhoneDeviceID()` contracts in the new runtime/build. |

## Data migration rule

A code-equivalent panel can start with a blank database. An operationally equivalent panel with existing users and keys requires a separate, explicit data-migration approval.

> Do not migrate raw device identities, credentials, OAuth tokens, or unreviewed data. Existing device-binding hashes are only meaningful with the appropriate server-side hashing secret and migration plan. A clone using fresh secrets should normally start with fresh bindings unless an authorized migration design proves continuity safely.

## Acceptance standard

The new project is not “same to same” merely because it looks similar. It is accepted only after the source builds, migrations apply, all existing automated tests pass, canonical HTTP behavior is preserved, role boundaries are tested, Telegram mapping/ticket isolation is tested, and the Android matrix above passes on the authorized target runtime.

The full detailed implementation requirements and verification matrix are in `Panel_Replication_Prompt.md`.
