# Anti-Cloning Remediation Plan — Host Identity First

## Status and security objective

The approved **Option A safe rollout** is implemented in the production Merged loader and verified on two physical Android devices. The canonical validation route, database schema, device-binding rule, key format, status format, Maintenance, Announcement, Telegram, and Main Lua behavior were not changed for this rollout.

The target issue was local-state cloning: the legacy resolver could trust the copyable `.device_id` file, and the server could not distinguish a copied value from the original device when both clients submitted the same raw value. The server securely stores only a salt-hash of the submitted identity; it is not device attestation.

> **Goal:** Copying A's `key.json`, `.device_id`, and other Lua-license files to B must not make B's production loader submit A's effective binding identity when the host can provide a B-specific value.

## Evidence already available

| Evidence | Current conclusion | Boundary |
|---|---|---|
| `Client.GetPhoneDeviceID()` standalone probe | Callable, non-empty, and stable through the tested close/reopen cycle. | App-data deletion, uninstall/reinstall, collision resistance, and native backing source are not proven. |
| A key copied to B while B keeps its own identity | Canonically rejected. | This proves ordinary one-key/one-identity binding, not copied-local-ID resistance. |
| Current Merged resolver after Option A | Existing legacy `.device_id` remains first for compatibility. When no legacy local ID exists, guarded `Client.GetPhoneDeviceID()` is evaluated before generic providers and the random local fallback. | Legacy active bindings remain copyable and are deliberately not migrated or rebound. |
| Canonical server binding | Hashes the submitted identity and binds/rejects based on the hash. | It treats the client-submitted value as input; it is not app/device attestation. |
| Fresh A → B full-folder-copy Android test | A completed a fresh host-first login without a local `.device_id`; B received the full A `lua-license` folder and was canonically rejected as bound to a different device. | This validates ordinary full-folder-copy resistance only for fresh host-first enrollment in the unmodified tested runtime. |

The new standalone `B_COPIED_IDENTITY` test remains the required direct evidence for the current local-ID clone case. It must be completed before claiming the live system is resistant or vulnerable to a full folder copy.

## Required production design

### Identity resolver order

For the approved **Option A** release, the resolver selects the host value before every copyable local identity source **for fresh enrollments**. An already-present legacy `.device_id` is intentionally preserved first for existing active-binding compatibility:

| Priority | Condition | Identity used | Clone resistance effect |
|---|---|---|---|
| 1 | Existing legacy `.device_id` is present | Legacy local value | Compatibility path only; still copyable and therefore **not anti-cloning secure**. |
| 2 | No existing legacy ID and `Client.GetPhoneDeviceID()` is safely callable with a non-empty normalized string | Host-provided phone/device value | A copied `key.json` or `.device_id` cannot override B's own host result through normal Lua-file copying. |
| 3 | No usable host identity and a generic provider returns a usable value | Existing generic-provider value | Compatibility path; its host contract is not treated as cryptographic attestation. |
| 4 | No usable host or generic-provider identity exists | Existing random local fallback | Preserves compatibility but cannot satisfy the full anti-cloning guarantee. |

Every host call must be enclosed in `pcall`; empty, non-string, whitespace-only, or unavailable results must never be sent to validation. The raw host value must remain in memory only for the existing canonical payload. It must never appear in status files, diagnostics, popups, UI, audit text, logs, or test output.

### New-user behavior

For a new protected activation on a host where `Client.GetPhoneDeviceID()` is available, the loader sends the host value in the unchanged canonical `device_id` payload. The server hashes it using the existing server secret and binds the resulting hash. `key.json` remains exactly `{"key":"..."}`; `.license_status` format remains unchanged; copying those files to B has no normal effect because B's resolver obtains B's host value first.

If host identity is unavailable, there is an unavoidable trade-off. The approved Option A behavior preserves the existing generic-provider and random-local fallback, which maintains login compatibility but remains cloneable. That fallback must never be described as a complete clone fix. A future strict new-activation policy would require separate approval because it would change the established fallback behavior.

### Existing-user behavior and migration

Existing active licenses may already be bound to hashes of legacy random `.device_id` values. Switching an existing client directly to the host value would correctly produce the protected `device_mismatch` outcome. Therefore the resolver must **not silently replace** existing legacy identity and the server must **not silently rebind** an active license.

There is also no safe automatic legacy-to-host migration using only the copied legacy file plus the new host value. A B attacker possessing A's entire local folder could present A's legacy value and request migration to B's host value before A does. That would move the security problem rather than fix it.

The safe staged policy is:

1. **New enrollments:** Host-first identity only when the host value is available.
2. **Existing legacy bindings:** Continue using the legacy path temporarily and label them legacy; do not claim full clone resistance.
3. **Hardening migration:** Require an out-of-band owner-controlled action, such as owner-reviewed unbind/reissue or another separately designed proof from a trusted account/channel. The old random value alone is not sufficient migration proof.
4. **No automatic active-license rebind:** Preserve the current expired/revoked-only cross-license replacement rule exactly.

If the owner resets a legacy binding after an approved recovery procedure, the legitimate device revalidates using the host value and becomes host-bound. This is deliberately a controlled operation, not a transparent client migration.

## Server compatibility and schema plan

The first new-user host-first release can retain the existing `device_id` request field and the existing server-side hashing/limit transaction. To make protection status auditable, a later separately approved schema change should add an identity provenance field to `deviceBindings`, for example `legacy_local` or `host_phone`, without storing raw identifiers.

| Change | Why it is needed | Approval requirement |
|---|---|---|
| Host-first resolver in Merged Lua | Prevents normal local folder copies from choosing A's `.device_id` when B has a host value. | Production Lua approval. |
| Binding provenance column and audit event | Lets the panel distinguish legacy cloneable bindings from host-first bindings. | Schema/server approval and migration. |
| Manual legacy reset/reissue flow | Allows hardening old bindings without trusting copied legacy state as migration proof. | Separate authorization/recovery design approval. |
| Cryptographic host attestation | Needed to defend against a modified client that can arbitrarily replay a chosen value. | Requires an authorized host/app API; not available from current Lua evidence. |

## Important limitation

`Client.GetPhoneDeviceID()` can mitigate **ordinary file copying** only if the host supplies B's own value at runtime and the Lua code has not been modified. It is not proven hardware attestation. A determined modified client may still attempt to control the submitted payload. Strong resistance to modified-client replay requires a host-signed attestation or equivalent server-verifiable token, which the current Dynamic Lua evidence does not expose.

## Rollback plan

For new host-bound users, a rollback cannot simply restore a random-only loader: the random fallback would send a different value and trigger `device_mismatch`. The rollback release must keep the host-first resolver active for all host-bound bindings, while disabling only unrelated code. Legacy users remain on their legacy resolver until a separately approved hardening procedure.

No rollback may mass-unbind devices, overwrite `.device_id`, rewrite `key.json`, alter `.license_status`, weaken max-device limits, or change the expired/revoked-only safe replacement rule.

## Required verification matrix and completed Android evidence

| Scenario | Expected result |
|---|---|
| New A host identity login | Canonical valid login; host-derived binding created; no raw value persisted by the new resolver. | **PASS:** A logged in successfully and executed Main Lua with no local `.device_id` present. |
| B copies A `key.json` only | Canonical rejection using B host identity. |
| B copies A entire Lua-license folder, including `.device_id` | Canonical rejection because B host identity takes precedence over copied local state. | **PASS:** B showed the canonical `.license_status` outcome `ERROR: key is bound to a different device`; login and Main Lua did not execute. |
| A reopens normally | Valid login using the same host identity. |
| Host call unavailable before a new protected activation | Use the approved generic-provider, then random-local fallback; the resulting binding carries the known legacy clone limitation. |
| Existing active legacy user | Legacy identity remains unchanged; no automatic rebind or key/device/status rewrite. |
| Maintenance, Announcement, Telegram, Main Lua | Existing verified behavior remains unchanged after successful canonical validation. |

## Approval boundary after Option A completion

The staged host-first implementation is complete for fresh enrollments, and the required full-folder-copy Android test has passed. The actual approved policy is host-first when no legacy local ID exists, followed by the pre-existing generic-provider and random fallback; active legacy bindings remain unchanged. A separate approval remains required for any schema/server provenance change, legacy reset/reissue mechanism, strict no-host policy, or host-attestation integration.

## Confirmed copied-local-identity vulnerability

The isolated two-device test is now complete. Device A first established a valid binding. On Device B, the test placed only specially named copies of A's `key.json` and A's `.device_id` into the existing B Lua-license folder; B's normal files remained untouched. The standalone diagnostic then used the existing canonical validation endpoint with those copied values and returned only:

```text
TEST_MODE=B_COPIED_IDENTITY
B_COPIED_IDENTITY=ACCEPTED
```

> **Confirmed finding:** In the current production architecture, copying A's local key and local `.device_id` is sufficient to reproduce the same canonical identity input from a different physical device. The server accepts the copied pair because its current binding decision receives the same client-supplied identity value and therefore the same stored device hash.

This is not a server-side max-device-limit bypass through a second identity. It is a **local identity replay**: the B client presents the same local identifier as A. The current local random identifier is therefore a persistence convenience, not proof of the originating physical device.

### Required production acceptance criterion

The production change must meet this exact Android test after implementation:

| Scenario | Required outcome |
|---|---|
| A validly logs in, then B copies only A's `key.json` | Reject. |
| A validly logs in, then B copies A's entire Lua-license folder, including `.device_id` and status/diagnostic files | Reject. B's own host identity must take precedence over every copied local identity file. |
| A reopens with its original device | Accept. |
| New B user logs in with B's own assigned key | Accept without a helper or manual device-file operation. |
| Host identity unavailable for a new enrollment | Follow the retained generic-provider, then random-local fallback; document the legacy clone limitation. |
| Existing active legacy binding | Preserve without automatic replacement or weakening the canonical `device_mismatch` protection. |

The earlier plan's host-first design is now no longer only preventative guidance; it is the minimum client-side remediation for ordinary copied-folder replay in the tested host. It still does not constitute hardware attestation against a modified client that can deliberately submit arbitrary values. That stronger threat model requires an authorized server-verifiable host attestation mechanism, which remains unproven in the current environment.

### Confirmed Option A Android outcome

The final Android verification used the latest production Merged loader on both devices. Device A performed a fresh successful login and then supplied its complete `lua-license` folder to Device B. Device B opened the copied state and attempted the same normal login path. The generic popup reported an authentication failure, and the non-secret `.license_status` marker provided the decisive canonical classification: `ERROR: key is bound to a different device`.

> **Confirmed result:** A copied `key.json`, copied legacy `.device_id`, copied status files, and other copied folder contents did not make physical Device B authenticate as fresh host-bound Device A. B's runtime host value took precedence and the unchanged server rule rejected the already A-bound key.

The result must remain evidence-bounded. It does not protect existing active legacy users whose local `.device_id` pre-dates this rollout, and it is not hardware cryptographic attestation against a modified client capable of choosing an arbitrary validation payload. No automatic migration, rebind, unbind, invalidation, server-rule change, or local file-format change is authorized by this outcome.

### Clear Data persistence evidence

On the same physical Device A, the approved isolated Clear Data test was then completed after a normal successful host-first login. The app data was cleared, the latest Merged loader was opened again, and the same valid test key completed normal login successfully. The user-reported non-secret outcome is:

```text
CLEAR_DATA=PASS
```

This establishes that the tested `Client.GetPhoneDeviceID()` value remained compatible with the existing fresh host-first server binding across the tested Android Clear Data operation. It does not expose or persist the identifier, prove uninstall/reinstall persistence, or change production Lua, server binding, legacy-user behavior, or any validation/presentation flow. Uninstall/reinstall remains a separate pending test.

### Uninstall and reinstall persistence evidence

The separate same-device Android uninstall/reinstall test is complete. Physical Device A uninstalled the app, reinstalled the same latest build and Merged loader, completed its normal initial setup, and then submitted the same old valid test key. Login succeeded without restoring or manually copying any former app data. The user-reported non-secret result is:

```text
REINSTALL=PASS
```

Together with the Clear Data result, this proves that the tested host-provided identity remained compatible with the original fresh host-first binding across the requested Clear Data and uninstall/reinstall scenarios on that physical device. It does not reveal the identifier, establish native implementation details, establish collision resistance across devices, or provide cryptographic attestation against a modified client. No production Lua, canonical server-binding rule, existing legacy binding, file format, or verified post-validation flow was changed.
