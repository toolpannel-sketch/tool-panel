# Prioritized Host-Configuration Evidence Matrix

> **Scope.** This is a source-and-documentation assessment only. It does not execute Lua, invoke a native API, inspect a native binary, modify the license system, or recommend interception, hooking, injection, certificate bypass, or any undocumented call.

## Assessment boundary

The authorized ZIP establishes that the Lua layer is embedded in a host application and that `HttpWrapper` is a host-provided object. It does **not** contain the implementation of `RequestForLua()`, the Android manifest, an Android Network Security Configuration, certificate material, an `HttpWrapper` error-code mapping, or a host network log. Therefore, a Lua-only result of `success=false, result=-1` cannot identify the underlying cause.

The claimed same-ZIP working client makes a **deployment or host-state difference plausible**, but it does not identify which difference is present. The table below keeps that distinction explicit.

| Priority | Area | Confirmed from the ZIP | Requires host/device evidence | Unknown from the ZIP |
|---|---|---|---|---|
| 1 | Host / SLua identity | Lua calls `slua_GameFrontendHUD:GetHttpWrapper()` and then `HttpWrapper:RequestForLua(...)`; the result event is delivered through `HttpWrapper.OnResponseEvent`. | Exact app package, version code, ABI, engine build, SLua build, and the exported binding inventory for the installed host. | Exact Unreal/SLua version, native class implementation, binding registration, and whether two deployments export identical Lua bindings. |
| 2 | `HttpWrapper` configuration | `http_manager.lua` forwards URL, method, headers, body, priority, and queue type to `RequestForLua`; it forwards the native `success` and `result` values unchanged. | Host HTTP initialization, request policy, accepted URL schemes/domains, TLS stack, proxy/VPN policy, DNS policy, queue configuration, and native error/log mapping. | What `result=-1` means, whether the request reached DNS/TLS/HTTP, and whether a host policy rejected it before dispatch. |
| 3 | Android network configuration | No Android manifest, network-security XML, certificate bundle, or host HTTP source is contained in the ZIP. | Installed app manifest/network-security declaration, active app network permission state, device Android/API level, time, trusted CAs, and any host-provided network diagnostic. | Whether the host declares normal network permissions, pins certificates, limits trust anchors, blocks domains, or uses a custom TLS stack. |
| 4 | Remote-config / domain mapping | Lua repeatedly obtains endpoint fragments through host-bound accessors such as `FuncUtil.GetDomainByID`, `FuncUtil.GetKeywordByID`, `Client.GetConfig*`, `Client.HDmpveRemoteConfigGet*`, `Client.GetPublishRegion`, and `DolphinConfig:GetStrConfigFromIni`. | The active runtime values for those host-provided selectors and the host’s configuration snapshot for the same build/channel/region. | The literal values behind the referenced IDs, their update source, and whether they influence the custom panel URL. |

## 1. Host / SLua identity

### Confirmed from the ZIP

The source uses an SLua-style bridge and expects objects already registered by the native game host. The relevant contract is distributed across `SLuaGlobalDefine.lua`, `game_frontend_hud.lua`, and `http_manager.lua`. The following bindings are relevant to a network-capability comparison.

| Pre-bound binding or service | Source evidence | Role in the Lua layer | Status |
|---|---|---|---|
| `slua_GameFrontendHUD:GetHttpWrapper()` | `http_manager.lua`; `game_frontend_hud.lua` | Retrieves the host-owned HTTP bridge. | Confirmed bridge acquisition only. |
| `HttpWrapper:RequestForLua(url, method, head, content, priority, queueType)` | `http_manager.lua` | Queues a native request and returns a request index. | Native implementation absent. |
| `HttpWrapper.OnResponseEvent:Add(...)` | `http_manager.lua` | Delivers host event data to Lua. | Native event semantics absent beyond forwarded values. |
| `Client` | Numerous call sites, including `Client.GetPublishRegion`, `GetLoginChannel`, `GetWebViewTicket`, and `HDmpveRemoteConfigGet*` | Host/game state, session metadata, and remote-config access. | Native implementation and values absent. |
| `DolphinConfig` | `app_update.lua` and configuration call sites | Host initialization, INI-backed string configuration, channel, and app-store URL access. | Actual INI files/values absent. |
| `FuncUtil` | `LudoConst.lua` and many webview/CDN call sites | Resolves domain and keyword IDs into runtime values. | ID registry and value source absent. |
| `logic_moment_helper` / `LogicMomentHelper` | UGC and content call sites | Produces domain, picture, and video values for first-party content. | Native/configuration backend absent. |

The ZIP also contains a Lua `ModuleManager` and `GameMainExtraModuleUtil`, but their source shows host-selected packaged Lua module/file selection; it does not show Lua registration of a new compiled binding or native plugin. [1][2]

### Requires host/device evidence

For both deployments, compare the **user-visible** app name, package identifier, version name/code, architecture/ABI if shown by the distribution, game build number, and any official runtime/build information page. A host owner’s binding inventory or runtime documentation is the authoritative way to determine whether the two `slua_GameFrontendHUD` objects actually export the same native surface.

### Unknown

The ZIP cannot establish the exact SLua or UE4 version, whether `HttpWrapper` is compiled identically, whether it is feature-flagged, or whether the working client has a different native host build.

## 2. `HttpWrapper` configuration and initialization dependencies

### Confirmed from the ZIP

`http_manager.lua` performs Lua-level wrapper initialization: it acquires the host object, subscribes to `OnResponseEvent`, associates request indices with callbacks, and forwards the following caller-controlled values.

| Request field | Lua source behavior | Can differ by caller? | Can explain `result=-1` from ZIP alone? |
|---|---|---:|---:|
| URL | Passed unchanged to `RequestForLua`. | Yes | No; source has no error mapping. |
| Method | Existing wrappers show GET and POST. | Yes | No. |
| Headers | Passed as the `head` argument. | Yes | No. |
| Body | Passed as the `content` argument. | Yes | No. |
| Priority / queue type | Passed through to the host bridge. | Yes | No; no native queue documentation is present. |
| Response `success` / `result` | Forwarded from the host callback without a Lua translation table. | No | No; `-1` is undefined in the ZIP. |

This establishes a **host configuration dependency**, not a specific cause. The manager does not expose a Lua setting for certificate validation, proxy selection, DNS, allowed domains, native timeout, Android permission, or error translation. [3]

### Requires host/device evidence

The minimum decisive evidence is one of the following, in priority order:

1. A **host-supported diagnostic/export** from the Android device that records the `HttpWrapper` failure category or native error associated with the already-observed request. This must come from a documented UI/log facility supplied by the host; no instrumentation is requested.
2. The host/runtime owner’s documented `HttpWrapper` result-code mapping and configuration contract for the installed build.
3. A documented host configuration summary showing whether HTTP is enabled, which URL schemes/domains are allowed, the active proxy/VPN/DNS policy, and any TLS/certificate policy.

### Unknown

The ZIP cannot distinguish request construction, native queue policy, DNS resolution, route reachability, TLS trust, certificate hostname matching, server rejection, or a general host feature disablement. `result=-1` is simply an unclassified native value at the Lua boundary.

## 3. Android HTTPS configuration

### Confirmed from the ZIP

The ZIP does not include `AndroidManifest.xml`, `res/xml/network_security_config.xml`, an APK/AAB, a certificate store, a CA bundle, a pin set, or a native network client. Therefore it proves none of the Android-side settings.

### Requires host/device evidence

Android’s official guidance says applications performing network operations must declare `android.permission.INTERNET` and `android.permission.ACCESS_NETWORK_STATE`; these are normal install-time permissions. [4] Android also supports an app-declared Network Security Configuration referenced from the manifest. That configuration can impose domain-specific trust anchors, debug overrides, cleartext rules, certificate transparency, and certificate pinning. [5]

Android validates HTTPS certificate chains and hostnames through its network stack; an unknown CA, self-signed certificate, or missing intermediate can produce a TLS handshake failure. [6] These are **possible categories**, not a diagnosis of this host.

| Lawful device-side observation | What it can distinguish | What it cannot prove |
|---|---|---|
| Android Settings → App info screenshot: app identity/version and Mobile data/Wi‑Fi access state | Whether the installed package/build and user-facing network access differ from the reported working deployment. | Native `HttpWrapper` error cause, manifest permissions, or TLS policy. |
| Android Settings → date/time and active network/VPN/proxy status (if visible) | Whether basic time or network context differs. | Whether the host uses that network path or a custom TLS policy. |
| Official host diagnostics/export, if the host provides it | Native failure category and possibly resolved endpoint/TLS message. | Only what the documented host log actually reports. |
| Official app package/build/configuration manifest supplied by the owner | Permissions, package identity, target SDK, and Network Security Configuration. | Runtime-only switches or server-side policy not represented there. |

Do **not** install a custom CA, disable certificate checks, change certificate pinning, add a proxy, alter the APK, or change system protections to test this. Those actions would not be a legitimate comparison of the target host configuration.

### Unknown

The source cannot establish whether the installed application declares the required permissions, configures `networkSecurityConfig`, pins CAs, uses a custom native TLS library, or is subject to a domain allow-list.

## 4. Remote-config and domain mapping before a request

### Confirmed from the ZIP

The source contains several runtime-resolved endpoint mechanisms. They prove that endpoint values can vary by host configuration or state, but they do not expose a generic custom-URL override.

| Mechanism | Source evidence | Inputs resolved outside the ZIP | Relationship to custom validation URL |
|---|---|---|---|
| `FuncUtil.GetDomainByID(id)` | `LudoConst.lua` lines 226–265 and widespread webview/content call sites | Host mapping for numeric domain IDs. | No evidence it accepts or overrides a custom panel domain. |
| `FuncUtil.GetKeywordByID(id)` | Webview/guide URL assembly | Host mapping for numeric keyword IDs. | No evidence it supplies custom request headers or an arbitrary endpoint. |
| `Client.HDmpveRemoteConfigGetBool/Int/String` | Static call sites across UI/game logic | Host remote-config snapshot and feature keys. | No evidence it configures `HttpWrapper` or custom validation. |
| `Client.GetConfigInt/GetConfigString` | Static configuration call sites | Host config table values. | No evidence of HTTP bridge policy exposure. |
| `Client.GetPublishRegion/GetIPRegion/GetLoginChannel/GetIMSDKEnv` | Region/channel/session branches | Host-selected runtime state. | May select first-party services; no custom URL route shown. |
| `DolphinConfig:GetStrConfigFromIni/GetDolphinChannelId` | App/configuration utilities | Host-supplied INI and channel state. | No custom generic transport configuration shown. |
| `logic_moment_helper.GetDomain` | UGC/CDN content assembly | First-party content/domain configuration. | Existing downloads still converge on `HttpWrapper`. |

The complete static identifier set used by `FuncUtil.GetDomainByID` is:

```text
3366005,3366013,3366015,3366017,3366018,3366028,3366036,3366039,3366040,3366041,3366046,3366047,3366048,3366049,3366050,3366052,3366053,3366054,3366055,3366057,3366058,3366060,3366067,3366072,3366077,3366078,3366079,3366080,3366081,3366082,3366083,3366089,3366092,3366093,3366099,3366100,3366101,3366102,3366103,3366113,3366114,3366115,3366172,3366173,3366174,3366175,3366177,3366178,3366179,3366180,3366181,3366182,3366183,3366185,3366186,3366187,3366188,3366189,3366190,3366192,3366193,3366195,3366198,3366199,3366200,3366201,3366202,3366203,3366204,3366205,3366207,3366210,3366211,3366212,3366213,3366214,3366215,3366216,3366217,3366218,3366220,3366221,3366222,3366223,3366224,3366228,3366232,3366233,3366234,3366235,3366236,3366241,3366242,3366243,3366246,3366247,3366248,3366251
```

The complete static identifier set used by `FuncUtil.GetKeywordByID` is:

```text
3377002,3377003,3377004,3377005,3377006,3377007,3377008,3377009,3377010,3377011
```

`LudoConst.lua` confirms that several domain IDs are selected by game type and front/server role, but the actual strings remain host-resolved. [7]

### Requires host/device evidence

To compare this category, the only useful evidence is a **documented host configuration snapshot** for the same build, publish region, login channel, and active environment, or an official runtime screen that displays those values. The ZIP cannot resolve any ID itself.

### Unknown

The actual domains/keywords, the host’s remote-config update source, how often values refresh, and whether any item controls `HttpWrapper` are not present in the authorized source.

## Minimum additional information from the Android device

The smallest lawful evidence package that can start separating the categories is:

1. **One user-visible App info capture** for the installed client: application identity, version/build, and Mobile data/Wi‑Fi access state.
2. **One user-visible runtime/build or settings capture**, if the host exposes it: publish region, login channel, environment, and any network/remote-config status. Do not invoke hidden/debug-only pages.
3. **One host-supported error report/log export** that includes the already-observed `HttpWrapper` failure, or the official meaning of native `result=-1` for that exact host build.

Item 3 is the **minimum decisive artifact**. Without either a host-supported native error category or the runtime owner’s result-code documentation, the ZIP cannot distinguish native dispatch failure from DNS, TLS, certificate policy, or other host-side rejection. Items 1–2 can establish that two deployments are comparable, but cannot determine the cause alone.

## Bounded conclusion

It remains reasonable to compare legitimate host state because the ZIP demonstrably relies on host-provided bindings, domain resolution, session/context values, and configuration services. However, the ZIP does not expose an editable `HttpWrapper` policy, an Android permission/security declaration, a certificate control, or a custom endpoint override. **The next legitimate comparison is host/device evidence—not another Lua transport probe.**

## References

[1]: ../authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/ModuleManager.lua "Authorized ZIP — ModuleManager"
[2]: ../authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/GameMainExtraModuleUtil.lua "Authorized ZIP — GameMainExtraModuleUtil"
[3]: ../authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/http_manager.lua "Authorized ZIP — http_manager"
[4]: https://developer.android.com/develop/connectivity/network-ops/connecting "Android Developers — Connect to the network"
[5]: https://developer.android.com/privacy-and-security/security-config "Android Developers — Network security configuration"
[6]: https://developer.android.com/privacy-and-security/security-ssl "Android Developers — Security with network protocols"
[7]: ../authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/LudoConst.lua "Authorized ZIP — LudoConst"
