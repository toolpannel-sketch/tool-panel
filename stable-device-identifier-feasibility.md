# Stable Device Identifier Feasibility — V3 / Android Host

## Scope and evidence boundary

This is a **strictly read-only** assessment of the supplied V3 Lua package and previously supplied non-secret host inventories. It does not invoke a host identifier method, collect a real identifier, alter random device-ID generation, or modify the production loader, server validation, device binding/rebind, or any verified presentation flow.

The exact target is the current Android Dynamic Lua context, not an assumed Android application API. A method name visible in V3 proves only that V3 calls or expects that method; it does not, by itself, prove that the Dynamic Lua context exposes it, what backing identifier it uses, or how it survives uninstall/reinstall.

## Current loader boundary

The active Merged loader already prefers a runtime function named `getPersistentDeviceId` or `getDeviceId` when it is actually present and returns a non-empty string. The previously supplied non-secret runtime-global inventory did **not** list either global. The loader therefore falls back to a generated 32-hex-character local `.device_id`; deleting that file legitimately produces a new fallback identity.

## V3 and observed-host findings

| Candidate | Exact V3 / host evidence | What can be stated without exposing a value | Restart / reinstall stability | Android restrictions and collision risk | Server device-binding suitability |
|---|---|---|---|---|---|
| **`Client.GetPhoneDeviceID()`** | V3 calls it in `NoticesUtil.lua:952`, `data_device_os.lua:58`, `logic_login_verify.lua:303`, `login_module.lua:680`, and `webModule.lua:441`. The trusted-device path compares its result to `trusted_device_list[].deviceid`. | V3 treats the return as a non-empty string and passes it to game login/security and telemetry paths. The V3 source does not reveal its native backing source. | **Not proven** across Lua restart, app-data deletion, uninstall, or reinstall. Its repeated native-host use makes it the strongest candidate to test, not a confirmed stable replacement. | The wrapper hides any Android permission/OS behavior and gives no uniqueness guarantee. Collision probability is unknown. | **Conditional best candidate only.** It must first be proven callable on this Dynamic Lua host and shown, through a separately approved non-secret stability probe, to remain stable across restart. Reinstall/app-data persistence remains unproven. |
| **`Client.GetDeviceXID()`** | Sole V3 call found in `logic_lobby_watermark.lua:52`, where the result is embedded in a login watermark. | A string-like watermark identifier is implied; V3 supplies no source, scope, or lifecycle contract. | Not proven. | It may be analytics/anti-abuse metadata rather than a physical-device identity. No collision or permission contract is exposed. | **Not suitable** as a binding identity based on current evidence. |
| **`HisarData.DeviceId` / `HisarData.AppInstallData.GuidStr`** | `HiggsBosonComponent.lua:649–653` imports `STExtraGameInstance`, reads object fields, and sends them in a game packet. | V3 proves these fields exist in that game-instance path; it does not prove a standalone callable API or lifetime. | Not proven; the `AppInstallData` name suggests installation-scoped data, not device-scoped persistence. | No permission, reset, uniqueness, or current-host accessibility contract appears in V3. | **Not suitable** without documented source-project/host contract and separate approval. |
| **Advertising / OAID path**: `Client.GetPhoneAdvertisingID()`, `TApmHelper.GetDataFromTGPA("OAID", "")` | `data_device_os.lua:76–95`; Android advertising ID is conditional on a VNG branch, while OAID/XID is conditional on a non-BLUEHOLE branch. | These are telemetry/advertising-oriented identifiers when their optional helpers are available. The current target host has not proven either helper callable. | Advertising identifiers are user-resettable; OAID behavior is not disclosed by V3. | Android guidance limits Advertising ID to ad-related use and requires honoring reset/opt-out. It is not an appropriate durable license-binding identity.[1] | **No.** Do not use for server license binding. |
| **Firebase / Adjust identifiers**: `FirebaseHelper:GetFIRAppInstanceId()`, `IMSDKHelper:GetAdjustID()` | `data_device_os.lua:103–111`; both are imported helper calls, not current-host API proof. | The source identifies analytics/app-instance helpers only. | Firebase Installation IDs are app-install scoped and resettable; V3 gives no lifecycle for Adjust. | FIDs are intentionally app-instance scoped and only last while the app is installed.[1] | **No** for recovery after app-data deletion/reinstall. |
| **Model / make / name / ABI / install channel** | V3 calls `GetDeviceModel`, `GetDeviceMake`, `GetDeviceName`, `GetDeviceABIInfoJson`, and `GetInstallChannelID`; the target host inventory also lists several corresponding `ScriptHelperClient` functions. | These are device characteristics or distribution metadata, not unique identity contracts. | May persist, but are shared by many devices and can be changed/spoofed. | High real-world collision risk; no single-device guarantee. | **No.** A fingerprint assembled from these fields would be privacy-invasive and still unreliable. |
| **Direct Android hardware/system APIs**: `ANDROID_ID`, `Settings.Secure`, IMEI, serial, MEID, IMSI, MAC | No V3 call site or current host inventory member establishes a callable API for any of these. | None. | Not applicable: no proven V3/host route. | Android 10 restricts IMEI/serial/non-resettable IDs to privileged, carrier, or device/profile-owner contexts; MAC access is also restricted.[1] [2] | **No.** Do not invent or probe a direct Android call from Lua. |
| **`ScriptHelperClient.GetDeviceInfo()`** | Listed in the prior non-secret host-surface inventory as a function name only. No V3 call site, argument shape, return shape, or identifier contract was supplied. | The name alone is insufficient to classify the return safely. | Unknown. | Unknown. | **No.** It requires independent contract documentation; it must not be called speculatively. |

## Important evidence distinction

> The V3 package proves a **strong native-host candidate**—`Client.GetPhoneDeviceID()`—but the available evidence does **not** prove that the current Dynamic Lua entry context exposes that member or that it is stable through app-data deletion or reinstall.

The target-host inventory proves that a global `Client` table exists, and the prior folder probe separately proved the current `Client.WriteFileAtPath` member. It did not inventory `Client` members, so it cannot establish `Client.GetPhoneDeviceID` availability. The V3 member cannot be assumed callable merely because another `Client` member is callable.

## Answer to the feasibility question

**No stable replacement is proven safe enough to replace the current local random device ID today.** The best evidence-backed next candidate is `Client.GetPhoneDeviceID()`, but only as a separately approved, non-secret capability/stability investigation. The current safe behavior remains the existing provider-first, local-random fallback.

If a future approved probe proves that `Client.GetPhoneDeviceID()` is callable and stable across ordinary Lua restarts, a later production design would still need a deliberate server-side migration policy. Existing records are bound to the current random ID, so sending a new identifier would otherwise trigger the existing `device_mismatch` rule. That is a protected canonical binding-rule change and must receive separate approval; it must not silently rebind active licenses.

The narrow future probe should record only allowlisted metadata such as method availability, returned type, non-empty status, and a one-way fixed-length comparison digest. It must never persist, display, log, or transmit the raw identifier. Reinstall/app-data-deletion testing should occur only if separately approved and only on the user's own test device.

## Recommendation

Keep the current provider-first/local-random mechanism unchanged. Do **not** use advertising IDs, OAID, Firebase/Adjust IDs, model fingerprints, hardware serials, IMEI, MAC addresses, or inferred Android APIs for this server-side license binding. Request a separate approval only if the user wants the isolated `Client.GetPhoneDeviceID()` availability-and-restart-stability probe; even a pass would not authorize production migration or rebind changes.

## Returned two-run Android probe evidence

The user supplied `FIRSTRESULT.zip` and `SECONDRESULT.zip`. Only each archive's allowlisted `.phone_device_id_probe_result` file was read. The internal `.phone_device_id_probe_state` files were not opened, copied, or reported.

| Run | `api_available` | `value_present` | `restart_stable` | Evidence-bounded conclusion |
|---|---|---|---|---|
| First standalone run | `true` | `true` | `baseline_recorded` | `Client.GetPhoneDeviceID()` was callable in the current Android Dynamic Lua host and returned a non-empty string. |
| After the user closed/reopened the application and ran the same standalone probe | `true` | `true` | `true` | The second local opaque comparison token matched the first, establishing stability across this tested close/reopen cycle. |

> **Current verified result:** `Client.GetPhoneDeviceID()` is the first host-provided identity candidate proven both callable and restart-stable in this exact Android Dynamic Lua environment. No raw value, state token, key, device file, account data, or server request was inspected.

This result does **not** establish persistence through app-data deletion, uninstall/reinstall, factory reset, OS upgrade, device transfer, or a different runtime/package version. It also does not establish global collision resistance, anti-spoofing, or any Android permission/backing-source contract. The standalone probe's source and regression coverage prove it does not touch the current random `.device_id`, license validation, device binding, key/status files, Maintenance, Announcement, Telegram, or Main Lua.

### Production decision remains separate

No production identity or binding change is authorized by this probe result. A future adoption design would need to preserve the existing provider-first fallback order, decide how `Client.GetPhoneDeviceID()` is represented server-side, and explicitly migrate or safely rebind historical random-ID bindings. Sending the newly proven identifier directly into the current canonical validation request would otherwise be a protected device-binding rule change and could produce `device_mismatch` for already-bound licenses. Any such design requires separate approval, migration tests, and Android regression testing.

## References

[1]: https://developer.android.com/identity/user-data-ids "Android Developers — Best practices for unique identifiers"
[2]: https://developer.android.com/about/versions/10/privacy/changes "Android Developers — Privacy changes in Android 10"
