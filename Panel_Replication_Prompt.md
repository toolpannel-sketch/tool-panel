# Same-Behavior Lua License Control Panel — Replication Prompt

## Purpose

You are building an independent project that reproduces the behavior and visual language of an existing Cyberpunk-themed Lua License Control Panel. The result must provide the same user-visible workflows, server-side license decisions, HTTPS request/response contracts, role permissions, device-binding behavior, referral onboarding, System Announcement behavior, and optional Telegram redirect extension.

This document is a **technical implementation prompt**, not a transfer of private credentials or an instruction to copy another project’s secrets. The new project must use its own database, OAuth application, owner identity, signing secrets, deployment domain, and any third-party credentials. Never request, print, commit, or hardcode another project’s secret values.

> Important limitation: A prompt can reproduce the architecture and behavior, but an exact pixel-for-pixel and byte-for-byte clone requires the original source files, approved visual assets, exact configuration values, and a controlled comparison against the original deployment. Do not claim identical behavior until the required test matrix passes.

---

## Master Build Instruction

Build a production-ready full-stack web application named **Lua License Control Panel** using the following baseline:

| Layer | Required implementation |
|---|---|
| Frontend | React 19, TypeScript, Vite, Tailwind CSS 4, Shadcn/Radix UI, responsive cyberpunk dashboard layout |
| Backend | Node.js, Express, tRPC v11, Zod input validation |
| Database | MySQL or TiDB with Drizzle ORM and Drizzle Kit migrations |
| Authentication | The platform’s supported OAuth/session integration; do not invent a password system or expose session secrets to the browser |
| Security | Server-authoritative validation, fail-closed decisions, role-gated procedures, rate limits, hashed device identities, no client-trusted authorization |
| Testing | Vitest for server and contract regressions, TypeScript checking, Lua syntax checking, browser visual verification |
| Deployment | HTTPS production deployment with a stable public domain and environment-managed secrets |

Use a persistent cyberpunk visual system: black/deep navy background, neon cyan and magenta accents, HUD-style brackets, restrained glow, monospace or technical display typography, high contrast, responsive cards, and mobile-friendly controls. Preserve accessibility: keyboard navigation, visible focus states, readable contrast, labels for inputs, and responsive layouts.

Do not create fake reviews, testimonials, ratings, or customer activity. Do not seed fabricated production users, licenses, referrals, or device bindings.

---

## Required Product Areas

### 1. Authentication and identity

Use the supported OAuth/session flow supplied by the host platform. Every protected request must resolve the current authenticated user on the server. Store a durable internal user record containing at least:

| Field | Requirement |
|---|---|
| `id` | Internal numeric primary key |
| `openId` | Provider identity, unique and server-managed |
| `name`, `email` | Provider profile fields where available |
| `username` | Optional panel username, unique when present |
| `role` | `super_owner`, `owner`, or `admin` |
| `accessStatus` | `pending`, `active`, or `revoked` |
| `accessExpiresAt` | Optional access expiry |
| timestamps | Creation, update, and last sign-in metadata |

New accounts must not automatically receive elevated access merely because they are authenticated. Use the approved referral/onboarding flow for activation. Never use a client-provided role or account ID to authorize a request.

### 2. Role model

Implement these server-side permissions exactly:

| Capability | Super Owner | Owner | Admin |
|---|---:|---:|---:|
| View own dashboard | Yes | Yes | Yes |
| View all license keys | Yes | Yes | No; own keys only |
| Generate keys | Yes | Yes | Yes; own keys only |
| Ban/unban or change own permitted keys | Yes | Yes | Own keys only, according to existing policy |
| Delete keys | Yes | Yes | No unless explicitly approved by the application policy |
| Create referrals | Yes | Yes | No |
| Manage users/access | Yes | Yes, within owner scope | No |
| Super Owner global review | Yes | No | No |
| Configure System Announcement | Yes | No | No |
| Enable/disable Telegram extension | Yes | No | No |
| View/edit all Telegram mappings | Yes | No | No |
| Edit own Telegram link | Yes | Yes | Initial registration only; no later edit unless explicitly changed by policy |
| Edit explicitly scoped Admin Telegram links | Yes | Yes | No |

Authorization must be enforced in backend procedures, not only by hiding buttons. Preserve the distinction between **authentication** and **authorization**.

### 3. License registry and key generation

Create a canonical server-authoritative `licenses` table with:

| Field | Requirement |
|---|---|
| `id` | Primary key |
| `keyValue` | Unique license key, maximum 128 characters |
| `status` | `active`, `expired`, `revoked`, or `unused` |
| `expiresAt` | Nullable timestamp |
| `activatedAt` | Nullable timestamp |
| `durationMinutes` | Optional activation-duration configuration |
| `maxDevices` | Maximum distinct device bindings |
| `boundDeviceId` | Optional legacy first-device hash, never raw ID |
| `createdByUserId` | Creator account |
| timestamps | Creation and update metadata |

The UI must support duration and maximum-device inputs, optional custom key prefix/name subject to strict length and character validation, copy-ready JSON output such as `{"key":"ACTUAL_KEY"}`, key search, status controls, expiry display, and per-key device-binding review.

Activation-duration keys should begin timing according to the established policy: for newly generated duration-based keys, the timer starts on the first successful device activation/binding. Preserve fixed-expiry behavior for legacy records where required.

### 4. Device binding

Create a separate `device_bindings` table. Store only a server-generated keyed hash of the client device identity; do not store raw device IDs. A license may bind to multiple distinct devices up to `maxDevices`. A device must not belong to multiple licenses unless the approved policy explicitly permits it.

The dashboard must report the **grouped count of distinct device bindings per license**, not merely the first binding or a correlated single row. Show the full device usage count, for example `3 / 10`, when three distinct devices are bound to a ten-device key.

### 5. Referral onboarding

Create a `referrals` table containing:

| Field | Requirement |
|---|---|
| `id` | Primary key |
| `code` | Unique, non-guessable referral code |
| `role` | `owner` or `admin` |
| `createdByUserId` | Referring owner/super owner |
| `redeemedByUserId` | Nullable redeemer |
| `status` | `active`, `redeemed`, or `revoked` |
| `expiresAt` | Mandatory expiry |
| timestamps | Creation and redemption metadata |

The pending screen must show the signed-in identity, explain that the invited account must be used, allow referral redemption, and provide a safe sign-out/switch-account path. Do not silently attach a referral to a different authenticated account.

### 6. Audit trail

Record security-relevant actions in an `audit_logs` table, including referral creation/redeem/revoke/delete, key creation/status/delete, device bind/unbind, role/access changes, and other approved administrative actions. Mask sensitive values in audit display. Never log raw license keys, raw device IDs, ticket tokens, OAuth tokens, or secret environment values.

---

## Canonical HTTPS License Validation Contract

The released Android Merged Lua uses the canonical public HTTPS endpoint:

```text
POST /api/license/validate
Content-Type: application/json
```

Request body:

```json
{
  "key": "LICENSE_KEY",
  "device_id": "PERSISTENT_DEVICE_ID"
}
```

The endpoint must be server-authoritative. It must validate the key, status, expiry, device binding, maximum devices, and device/key ownership rules. It must not trust a client-supplied role, account ID, status, expiry, or binding count.

Successful response:

```json
{
  "ok": true,
  "licenseId": 123,
  "status": "active",
  "expiresAt": "2026-12-31T23:59:59.000Z",
  "deviceBound": true,
  "deviceCount": 1,
  "maxDevices": 3
}
```

The exact successful fields may be extended, but the existing client must continue to receive the fields it consumes. Do not change the approved response contract after the Lua loader is released without a versioned migration.

For failed validation, return an HTTP failure status and a machine-readable error. Preserve these logical errors:

| Error | Meaning |
|---|---|
| `invalid_key` | Key does not exist or request is malformed |
| `key_banned` or `key_revoked` | Key has been disabled/revoked according to the selected contract |
| `key_expired` | Key expiry has passed |
| `device_limit_reached` | New distinct device exceeds `maxDevices` |
| `device_already_bound` | Device is associated with another license under the policy |

The Lua adapter must fail closed: it may load the main feature only after a valid successful response. Transport failure, malformed JSON, missing adapter, empty response, unexpected status, or unknown validation response must stop the main Lua execution.

Also implement, where needed, the existing diagnostics without coupling them to license authorization:

```text
GET  /v1/transport-ping
POST /v1/transport-ping       body: {"test":"ping"}
POST /ping                    body: {"test":"ping"}, X-Transport-Probe-Id: safe-probe-id
GET  /ping/diagnostic/:requestId
```

Transport diagnostics must not accept or store license keys, device IDs, ticket tokens, or request bodies beyond the documented ping test.

For compatibility with earlier downloadable adapters, the application may also retain:

```text
POST /v1/validate
```

If it is part of the original client contract, preserve its request and response shape exactly. Do not merge or casually rewrite `/api/license/validate` and `/v1/validate` after production clients depend on them.

Apply rate limiting to validation and ticket endpoints. Use `Cache-Control: no-store` for sensitive or dynamic responses.

---

## Lua Loader Requirements

Provide a compile-ready Lua wrapper for the approved UE4 Dynamic Lua runtime. The wrapper must:

1. Read the configured key file, supporting the approved JSON wrapper format `{"key":"..."}`.
2. Preserve the approved identity resolver: retain an existing active legacy `.device_id` unchanged for compatibility; for a fresh enrollment without it, call guarded `Client.GetPhoneDeviceID()` before generic providers or a random local fallback. Keep the raw host value in memory only and never print, persist, or diagnose it.
3. Build JSON using the host-supported encoder.
4. Use only the documented HTTPS bridge, such as the verified `HTTP_POST(url, body) -> status, response_body` contract, or the target host’s approved equivalent.
5. POST to the configured `/v1/validate` endpoint.
6. Parse and validate the response.
7. Show clear failure messages for invalid, revoked, expired, device-limit, malformed-response, or transport errors.
8. Execute the main Lua only after successful validation.
9. Keep the login popup session-guarded so the same host session does not repeatedly show it during UI lifecycle transitions.
10. Keep V1 production loader behavior separate from any V2 mock-only demo.

Do not use undocumented native calls, process-memory reads, injected `.so` modules, bypasses, guessed device IDs, raw license keys in URLs, or client-side authorization decisions.

The loader’s host-specific adapter cannot be guessed. The friend must provide the exact runtime callback/bridge contract or test the documented host bridge. If the target runtime cannot make HTTPS POST requests, report that blocker rather than weakening validation.

---

## System Announcement Feature

Add a singleton announcement record controlled only by the Super Owner:

| Field | Requirement |
|---|---|
| `enabled` | On/off |
| `title` | Up to 80 characters |
| `message` | Up to 300 Unicode characters, including emoji |
| `startAt`, `endAt` | Optional schedule window |
| `displayMode` | `every_login` or `once_per_day` |
| `textSize` | `small`, `normal`, `large`, or `festival_large` |
| audit/timestamps | Required |

Expose a read-only active-announcement endpoint for the Lua presentation flow. The announcement is presentation-only and must never affect license validation, authorization, device binding, or whether the main Lua is allowed to run.

The Lua flow must be:

```text
successful license validation
→ if active announcement exists, show it
→ OK may continue to the isolated Telegram ticket flow
→ Cancel continues normal Main Lua flow without Telegram
→ no active announcement means no Telegram action
```

---

## Isolated Telegram Extension

Telegram must be implemented as a removable additive extension. Removing or disabling Telegram must not affect login, authentication, license validation, authorization, HTTP transport, key generation, referrals, device binding, Main Lua execution, or the System Announcement feature itself.

Use isolated tables equivalent to:

| Table | Purpose |
|---|---|
| `telegram_settings` | Singleton extension enabled/disabled flag |
| `telegram_channels` | One validated channel link per eligible account |
| `telegram_account_scopes` | Confirmed Owner → Admin management scope |
| `telegram_key_mappings` | Explicit license-to-account mapping |
| `telegram_tickets` | Short-lived, hashed, single-use, device-bound tickets |

Channel validation must accept only supported HTTPS Telegram links:

```text
https://t.me/<public_channel>
https://t.me/+<invite_hash>
https://t.me/joinchat/<invite_hash>
```

Reject arbitrary hosts, non-HTTPS schemes, `javascript:`, `data:`, `file:`, malformed paths, unsafe query/fragment variants, and unsupported path shapes. Private invite links must be stored exactly as entered after validation. Never resolve them, convert them to a public username, guess a channel, or require an `@username`.

The redirect flow must be:

```text
successful license validation
→ separate short-lived ticket request tied to key/device context
→ user presses Announcement OK
→ ticket redemption with the same device context
→ server checks single-use, expiry, device hash, explicit license mapping, and enabled channel
→ open only the stored mapped Telegram URL
```

Ticket requirements:

| Requirement | Rule |
|---|---|
| Lifetime | Short-lived, for example 60 seconds |
| Storage | Store only a cryptographic token hash |
| Replay | Atomic redemption; second use fails |
| Device binding | Ticket device hash must match redemption device hash |
| Mapping | Explicit `telegram_key_mappings` row is mandatory |
| Fallbacks | No creator fallback, username lookup, guessed channel, or client account ID |
| Failure behavior | Continue normal Main Lua flow without opening Telegram |

The panel must show an existing-user setup popup for active eligible Super Owners, Owners, or Admins who have no saved Telegram link. It must explain that both Public Channel Link and Private Invite Link are accepted. After successful save, server-backed setup state must suppress the popup on future logins.

The Super Owner UI must show each mapped account and provide an **EDIT LINK** control. Editing must target the selected account’s server-side user ID, reuse the strict validator, and preserve the private link exactly. Admins may initially register their own link; Owners may manage their own and explicitly scoped Admin links; Super Owners may view/edit all mapped links.

---

## Dashboard UI Checklist

Reproduce the following responsive sections using the cyberpunk visual system:

| Section | Required behavior |
|---|---|
| Sidebar/header | Brand, current account identity, role, navigation, sign-out/switch-account control |
| Overview | Total keys, active keys, revoked/banned keys, distinct device bindings |
| Generate Key | Duration, unit, maximum devices, optional custom key name/prefix, copy-ready result |
| License Registry | Search, status, expiry, device usage, created-by information, actions |
| Device bindings | Full grouped per-key binding count and safe unbind action |
| Referrals | Create, redeem, revoke, clear/delete according to role, expiry and audit history |
| User Roles | Access status, role-scoped management, safe account deletion/clear actions |
| API/transport | Existing configuration or diagnostics required by the deployed contract |
| System Announcement | Super Owner-only settings, schedule, display mode, emoji-safe message, text size |
| Telegram | Enable/disable, own link, mapped accounts, scope review, per-account edit for Super Owner |
| Empty/error states | Readable loading, no-data, authorization, and transport error states; never replace errors with fake zero data |

Mobile layout must preserve all controls without horizontal overflow. Long private invite links must wrap safely.

---

## Required Files and Artifacts

A complete independent implementation should contain equivalents of:

```text
client/src/App.tsx
client/src/index.css
client/src/components/DashboardLayout.tsx
client/src/components/TelegramExtensionCard.tsx
client/src/pages/Home.tsx
server/_core/context.ts
server/_core/trpc.ts
server/db.ts
server/license.ts
server/licenseRoutes.ts
server/telegram.ts
drizzle/schema.ts
drizzle/migrations/*.sql
server/*.test.ts
BRPlayerCharacterBase-Merged.lua
BRPlayerCharacterBase-Reusable.lua
README.md
todo.md
package.json
```

The exact filenames may differ, but the same responsibilities must remain clearly separated. Keep Telegram-specific schema, procedures, UI, and Lua hooks removable as a unit.

---

## Environment Values the New Project Must Supply

The friend must create and configure their own values. Do not copy secret values from the original project.

| Variable/category | Purpose |
|---|---|
| Database connection | MySQL/TiDB production database |
| Session signing secret | Secure authenticated sessions |
| OAuth application ID and portal/API URLs | Supported login flow |
| Project owner identity | Legitimate Super Owner assignment |
| Built-in storage/API values | Only if the chosen platform integration requires them |
| Application title/logo | New project branding |
| Stable HTTPS public domain | Lua and browser clients must use the deployed domain |
| Telegram bot token/owner ID | Only if a bot integration is actually used; store in secret manager |
| Runtime bridge values | Host-specific Lua HTTP adapter and file paths |

Never place database URLs, JWT secrets, OAuth secrets, Telegram bot tokens, or owner identifiers in frontend source, Lua files, screenshots, public prompts, or Git repositories. Use the platform’s secret manager.

The owner must also confirm the correct original project-owner identity for the new project. Do not “fix” ownership by adding an authorization bypass or by hardcoding an arbitrary account as Super Owner.

---

## Migration and Data Rules

Run schema-first migrations. Create tables before dependent indexes/relationships. Verify the live schema after migration. Do not seed fake business data. If migrating real data, obtain explicit authorization, map records deterministically, preserve audit history, and never copy raw secrets or raw device identifiers.

The Telegram extension must be removable by disabling its feature flag first, then removing Telegram-only procedures, UI, Lua hooks, and tables in a controlled migration. Before removal, verify that validation, announcements, authentication, referrals, keys, and Main Lua still work independently.

---

## Verification Matrix

Do not call the project same-behavior complete until all of the following pass:

| Test area | Required verification |
|---|---|
| Authentication | Login, logout, account switching, pending referral, active account |
| Authorization | Super Owner, Owner, and Admin procedure boundaries; forbidden actions return errors |
| Validation | Valid, invalid, revoked/banned, expired, unused, device-limit, duplicate-device cases |
| Database | Key creation, expiry, referral redemption, grouped device counts, audit entries |
| HTTPS | Correct method, content type, status, JSON shape, rate-limit behavior, no-store headers |
| Lua | Compile/syntax check; transport success; malformed response; fail-closed behavior; Main Lua gate |
| Host-first identity | Fresh A login, A-to-B complete `lua-license` folder copy rejection, Clear Data re-login, uninstall/reinstall re-login, and existing-legacy compatibility |
| Announcement | OFF, active window, outside window, every-login, once-per-day, Cancel, OK |
| Telegram | Public link, private `+` link, `joinchat`, invalid URLs, exact preservation, explicit mapping, ticket expiry, replay, device mismatch, no fallback |
| UI | Desktop and mobile screenshots, long private-link wrapping, loading/error/empty states, role visibility |
| Isolation | Disable/remove Telegram and confirm all protected systems still work |
| Production | HTTPS domain, OAuth callback, environment secrets, migration state, logs, rollback checkpoint |

Run at minimum:

```bash
pnpm test
pnpm exec tsc --noEmit
luac -p BRPlayerCharacterBase-Merged.lua
pnpm build
```

Also perform browser verification against the deployed HTTPS domain and a real, authorized Android Dynamic Lua host. A local test alone does not prove the UE4 runtime bridge works.

---

## What the Friend Must Send or Provide

The friend does **not** need to send the original project’s private credentials. To build their own equivalent panel, they must provide the following information in their own Manus project:

1. A clear confirmation that they want an independent panel with the same feature behavior, not access to the original project’s database or accounts.
2. Their preferred project name, title, logo, and permanent domain requirements.
3. Their own Manus/project-owner account and the correct Super Owner identity.
4. Their own database and environment configuration through the platform’s secret manager.
5. The exact Lua runtime bridge contract available in their UE4/Dynamic Lua host, especially the HTTPS POST callback signature, JSON encoder/decoder availability, file paths, and persistent device-ID strategy.
6. The approved Main Lua insertion point or a clearly labeled placeholder. The license wrapper must remain outside the protected Main Lua and must gate its execution.
7. Whether Telegram is required. If yes, they must confirm that it is the isolated optional extension and provide only their own channel-management policy; private invite links are not converted or resolved.
8. Whether they need only a fresh database or an authorized migration of their own existing users, licenses, referrals, and audit records.
9. Authorized test accounts and non-sensitive test keys for validation. They must never send production keys, raw device IDs, OAuth tokens, database passwords, JWT secrets, or Telegram bot tokens in chat.
10. A browser/device test plan and screenshots or logs from their own authorized runtime when the Lua bridge needs calibration.

The friend can paste this entire document into their own Manus request and then add the project-specific values above. The implementation agent should first inspect their newly created project, create a project TODO, scaffold the database and role model, implement the HTTPS contract, build the responsive UI, add the isolated Telegram extension, write tests, and only then publish a checkpoint.

---

## Final Acceptance Statement

The new project is acceptable only if it demonstrates the same documented behavior through evidence: the same server-authoritative license decisions, the same fail-closed Lua gate, the same role boundaries, the same device-binding counts, the same referral and announcement behavior, the same strict Telegram mapping/ticket rules, and a responsive cyberpunk dashboard. Visual similarity alone is not sufficient, and a successful browser login alone is not proof that the Android Lua HTTPS bridge or validation contract is working.

> Build an independent, secure implementation. Do not copy secrets, bypass authorization, weaken validation, expose raw device identities, or claim exact equivalence without completing the verification matrix.

---

## References

[1]: https://react.dev/ "React documentation"
[2]: https://www.typescriptlang.org/docs/ "TypeScript documentation"
[3]: https://trpc.io/docs "tRPC documentation"
[4]: https://orm.drizzle.team/docs/overview "Drizzle ORM documentation"
[5]: https://vitest.dev/guide/ "Vitest documentation"
[6]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST "MDN HTTP POST method"
[7]: https://owasp.org/www-project-application-security-verification-standard/ "OWASP Application Security Verification Standard"
