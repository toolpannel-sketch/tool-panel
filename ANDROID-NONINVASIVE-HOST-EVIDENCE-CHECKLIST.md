# Non-Invasive Android Host-Evidence Checklist

## Scope and Safety Boundary

This checklist is limited to **read-only, ordinary device/package inspection**. It does not require root, hooking, injection, a modified APK, a new Lua call, a license-validation request, or an attempt to force a successful network response. It does not establish the cause of `result=-1` by itself; it narrows which host-side artifact is missing.

> **Terminology:** “confirmed” means the authorized ZIP directly shows it. “inspectable” means it can normally be collected from a device or an APK without modifying the target. “unknown” means the ZIP and ordinary package metadata do not prove it.

## 1. App Version, Build, and ABI

| Question | ZIP-confirmed evidence | Normal Android-side location or method | Remaining limit |
|---|---|---|---|
| Installed package identity and app version | The ZIP does not contain a package manifest, application ID, version name, or version code. | **Settings → Apps → [target app] → App details** normally shows version information. With the owner’s device and USB debugging enabled, use `adb shell dumpsys package <package-id>`; look for `versionName`, `versionCode`, `sourceDir`, and `splitSourceDirs`. Android documents `dumpsys` as a diagnostic information tool. [1] | The version alone does not prove an identical native HTTP implementation. |
| Device ABI | Lua does not state a native ABI. | `adb shell getprop ro.product.cpu.abi` and `adb shell getprop ro.product.cpu.abilist` report device ABI properties. | Device ABI is not necessarily the ABI selected by the installed app. |
| App-native ABI / installed APK set | Lua expects host-provided native objects, including `slua_GameFrontendHUD` and its `GetHttpWrapper()` method. [4] | From `dumpsys package`, note `sourceDir` and each split. `adb shell pm path <package-id>` lists installed APK paths. If the device permits read access, copy only those APKs to a computer and inspect their `lib/<abi>/` folders in Android Studio’s **Analyze APK** view. | A packaged library name is not a guarantee that a particular bridge is enabled at runtime. |

## 2. Declared Android Network Permissions

`android.permission.INTERNET` is a normal manifest permission, not a user-facing runtime toggle. Thus the relevant evidence is the **installed package manifest**, not the Android Settings permissions screen.

| Evidence | Normal inspection method | What it can establish | What it cannot establish |
|---|---|---|---|
| Requested permissions | `adb shell dumpsys package <package-id>` and inspect the `requested permissions` section. | Whether the installed package declares `android.permission.INTERNET` and related permissions. | Whether the native `HttpWrapper` accepted, connected, or received a response. |
| APK manifest | Obtain the APK paths with `adb shell pm path <package-id>`; inspect a readable APK copy using Android Studio **Analyze APK** or `apkanalyzer manifest print <base.apk>`. | Exact manifest declarations and application attributes. | Live server policy, DNS, TLS, proxy, or native return-code meaning. |

## 3. Network-Security and Certificate Configuration

Android’s Network Security Configuration is an application-linked declarative resource. A manifest may reference it with `android:networkSecurityConfig`; it can define trust anchors, domain-specific policies, cleartext policy, certificate pinning, and debug-only overrides. [2]

| Artifact | Normal inspection method | Classification |
|---|---|---|
| Manifest `android:networkSecurityConfig` attribute | Analyze the readable base APK manifest. | **Inspectable** from the package. |
| `res/xml/network_security_config*.xml` resource | In **Analyze APK**, inspect `res/xml/`; if the resource name is found in the manifest, decode/view that resource. | **Inspectable** when it is packaged in a readable APK. |
| Target SDK and `usesCleartextTraffic` declaration | Analyze the manifest. | **Inspectable**; relevant principally to cleartext HTTP, not proof of HTTPS success. |
| System/user CA store and current user-added certificates | **Settings → Security & privacy → More security settings → Encryption & credentials** (wording differs by Android build). | **Partly inspectable** on the device. The view does not prove which stores the app trusts. |
| TLS handshake, hostname, pinning result, proxy policy, native error translation | Not exposed by the ZIP. | **Requires host/native evidence.** |

## 4. SLua and Pre-Bound Host Bindings Already Visible in the ZIP

The ZIP confirms that Lua relies on a host-provided `slua_GameFrontendHUD` singleton. The wrapper reads host utilities through `GetUtils()` and later registers Lua handlers onto host events. [4]

| Confirmed host-bound surface relevant to provenance | Evidence in authorized Lua |
|---|---|
| HTTP bridge acquisition | `slua_GameFrontendHUD:GetHttpWrapper()` is called by `http_manager.lua`. [5] |
| Generic request and response contract | `RequestForLua(url, method, head, content, priority, queueType)` is dispatched by the wrapper; `OnResponseEvent` is forwarded to `OnRawResponse(reqIndex, elapsedTime, data, content, success, result)`. [5] |
| Other host functions that can differ by native build | The archive references methods such as `GetGameInstance`, `GetUpdater`, `GetPufferDownloader`, `GetLuaEventBridge`, `GetVoiceSDKInterface`, `GetClientNetObj`, `GetUtils`, and lifecycle/update delegates. [4] |
| Runtime-visible context | The wrapper references game-status, web-view ticket, update, CDN, cloud, region, and map transitions, all delivered from host delegates or subsystems. [4] |

These names are **inspectable from the ZIP**. The methods’ implementations, native configuration, feature flags, and logging behavior are **not contained in the ZIP**.

## 5. Readable Domain and Configuration Mapping

| Candidate location | Ordinary inspection method | Evidence status |
|---|---|---|
| Supplied Lua ZIP | Search the supplied archive for static domain tables, `FuncUtil` calls, remote-config keys, region/channel selectors, and module-selection lists. The existing source audit identifies static service mapping and host-resolved configuration accessors. [6] | **Confirmed / inspectable.** |
| Installed base/split APK resources and assets | After obtaining readable APK paths with `pm path`, inspect `assets/`, `res/raw/`, `res/xml/`, and resource strings in **Analyze APK**. | **Potentially inspectable.** Only records packaged values. |
| Shared/external app files | Check only folders the app deliberately exposes, for example a visible app export folder or a readable `Android/data/<package-id>/files/` path where the device’s storage policy permits access. Do not attempt to access private `/data/user/0/<package-id>/` content. | **Conditional.** Absence proves nothing. |
| Live remote configuration, session ticket, domain overrides, cloud flags | Not serialized in the authorized ZIP. | **Requires host/device evidence** such as an app-provided diagnostics screen, an exported log, or host-owner documentation. |

## 6. Normal Host/Application Logging

Android Logcat can display messages that the host process itself emits. It can be read through Android Studio or the normal ADB command-line environment; it does not create missing native diagnostics. [3]

| Method | Exact ordinary method | Useful result | Limit |
|---|---|---|---|
| App-provided diagnostic/export screen | Inspect the app’s normal Settings, Help, Support, Update, or diagnostics UI for an existing “export log,” “network diagnostics,” or crash-report action. | Existing host logs/config snapshot. | No evidence if the app exposes no such UI. |
| Android Studio Logcat | Connect the device with USB debugging enabled; select the host process and filter for the app package or `HttpWrapper`. | Host-emitted native HTTP/TLS/DNS/response records, if any exist. | No `HttpWrapper` line means no classified native error was exposed. |
| ADB log capture | On a normal development computer, identify the process with `adb shell pidof <package-id>` and use `adb logcat --pid=<pid>`; preserve only app/host messages already emitted. | Time-correlated host log evidence. | Does not reveal a failure category if the native layer omits it. |

## Minimum Additional Artifact Required

The ZIP and ordinary package inspection **cannot distinguish** whether `success=false, result=-1` originated in native request dispatch, URL policy, DNS, TLS/certificate validation, proxy/network restriction, queue setup, or host-side filtering.

> **Minimum decisive artifact:** one normal, host-emitted `HttpWrapper` diagnostic line for the already-observed failure **that maps `result=-1` to a native failure category**, or the runtime owner’s matching `HttpWrapper` result-code documentation for that exact build.

If the app emits no host HTTP diagnostics and the runtime owner supplies no mapping, the next-best lawful package from the failing device is: **(a)** `dumpsys package` output, **(b)** the installed base/split APK manifest plus network-security resource if present, and **(c)** any app-exposed diagnostic/log export. Those can rule in or out basic manifest/policy differences, but they cannot prove the cause of `-1`.

## References

[1]: https://developer.android.com/tools/dumpsys "Android Developers — dumpsys"
[2]: https://developer.android.com/privacy-and-security/security-config "Android Developers — Network security configuration"
[3]: https://developer.android.com/studio/debug/logcat "Android Developers — View logs with Logcat"
[4]: ../authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/game_frontend_hud.lua "Authorized source — host front-end wrapper"
[5]: ../authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/http_manager.lua "Authorized source — HttpWrapper adapter"
[6]: ZIP-CLIENT-DEPLOYMENT-PROVENANCE-CHECK.md "Prior source-only provenance check"
