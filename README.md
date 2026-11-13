
## Permanent Production Website

The permanent public website for this project is:

> https://luapanel-8355ybgt.manus.space

This Manus-hosted domain is the production access URL for the Lua License Control Panel. Use this URL directly on desktop or mobile; do not reuse an old OAuth chooser URL or a localhost/127.0.0.1 link saved in browser history.

### OAuth callback

The login flow starts from the published website and keeps the callback on the same production host:

`https://luapanel-8355ybgt.manus.space/api/oauth/callback`

The browser portal URL and OAuth API base are intentionally separate. If the Manus domain changes, the OAuth callback configuration and the deployed application must be updated together before users sign in again.

### Domain management

The current setup intentionally uses the Manus domain and does not require DNS configuration. If a custom domain is added later through the project domain settings, users should switch to that new HTTPS URL and the OAuth callback must be changed to the matching `/api/oauth/callback` address. Old login tabs containing `redirect_uri=127.0.0.1` should be closed before retrying sign-in.

### Mobile sign-in recovery

Always open the published URL directly: `https://luapanel-8355ybgt.manus.space/`. If an old OAuth error mentions `127.0.0.1`, close the old OAuth/account-chooser tab completely and start again from the published URL. Do not reuse an old `/app-auth` link because its `redirectUri` is embedded in the URL. The current login flow starts at `/api/oauth/start`, uses the published callback `/api/oauth/callback`, and always redirects through the Manus browser portal. After signing out, use the published URL again for a different account.

## Referral onboarding recovery

If a newly invited user signs in with the wrong account, use **Sign out** or **Sign in with another account**, then reopen `https://luapanel-8355ybgt.manus.space/` and sign in with the email that received the referral. The pending-access screen will show the signed-in email and referral redemption instructions. Paste the referral code created by the owner and redeem it; access remains blocked until redemption succeeds. Referral expiry and the `Expires on` date are enforced by the server.

## Reusable BR Character Login Wrapper

`BRPlayerCharacterBase-Reusable.lua` is a copy-paste license gate for changing local Lua scripts. It calls the canonical endpoint `https://luapanel-8355ybgt.manus.space/api/license/validate` through the verified documented host sequence: `slua_GameFrontendHUD:GetHttpWrapper()`, `OnResponseEvent:Add(...)`, and `RequestForLua(..., "POST", ...)`. It prefers the key at `/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/key.json`. For Android hosts that handle alternate extensions more reliably, it also accepts `key.txt`, then `key.in`, and finally `key.ini` in the same folder. The wrapper prefers a runtime-provided persistent identity when the Android Lua host exposes one and otherwise maintains a device identity in the dot-prefixed `.device_id` file. The hidden filename is intended to reduce casual discovery in ordinary file managers; it is not encryption or tamper protection.

To update a BR character feature, keep the wrapper at the top of the Lua file, replace only the code inside `run_authorized_main` below `PASTE YOUR CHANGING MAIN LUA CODE BELOW THIS LINE`, and recompile or package the resulting file. Keep only one license file in the folder when testing so it is clear which file is being read; `key.json` is preferred, followed by `key.txt`, `key.in`, and finally `key.ini`. JSON format remains `{"key":"ACTUAL-KEY"}`, while a plain key string is also accepted. Do not add an external `main_features.lua` loader call. The host request is asynchronous: the loader writes `VALIDATING ... awaiting_callback`, exits its initial chunk, and invokes the protected code only from a `success=true`, HTTP-200, `{ "success": true, "status": "valid" }` callback. It deliberately does not busy-wait, because blocking the Lua event loop could prevent the documented response event from arriving. If the callback reports `success=false`, the loader stops with `license server unreachable`; if no callback arrives, the protected code remains blocked. The canonical statuses `expired`, `not_registered`, `invalid`, `device_mismatch`, and `device_max_reached` each stop with their own non-secret message.


## Runtime HTTP bridge boundary

The project ships the web license panel, validation API, and reusable Lua wrapper. It does not build, inject, or distribute game-process `.so` modules, memory hooks, or an injector runtime. The production wrapper now uses only the demonstrated `slua_GameFrontendHUD`/`HttpWrapper` POST callback contract; it does not fall back to `HTTP_POST`, LuaSocket, LuaSec, hidden transport discovery, or undocumented native calls. The harmless correlated ping demonstrated `success=true`, HTTP result `200`, and a complete response body through this same contract before license validation was integrated.

The loader remains fail-closed at every stage. A missing wrapper, request-dispatch failure, unsuccessful callback, non-200 result, empty body, invalid JSON, unexpected response shape, or any non-`valid` canonical status prevents protected Lua code from running. The `.license_status` file contains only timestamped non-secret stages such as `VALIDATING`, `ACCESS_GRANTED`, `TRANSPORT_FAILED`, or `VALIDATION_FAILED`; it never contains the license key or device identity.

## Runtime capability diagnostic

When Dynamic Execution hides console output, the wrapper also writes a non-secret global capability report to:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.runtime_globals
```

The report lists only global names and Lua types. Inspect candidates such as `HTTP_POST`, `httpPost`, `request`, `fetch`, `http`, `gg`, `UE`, and `Android`. The wrapper also performs a bounded, names-and-types-only inspection of the `Net`, `NetUtil`, and `UnrealNet` tables (one nested level) and records entries such as `Net.SomeFunction [function]` when those members are exposed. It never calls discovered functions during diagnosis. A discovered name is not automatically compatible: the host developer or runtime documentation must define its arguments and return values before it can be mapped to the license adapter. In one supplied report, the runtime exposed `Net.Connect`, `Net.SendPacket`, `NetUtil.ConnectToURL`, `NetUtil.ConnectToURLDirectly`, `NetUtil.ConnectToURLWithDNSProxy`, and `NetUtil.SendPkg`, but the report did not establish that any of them accepts arbitrary HTTPS JSON POST data or returns an HTTP status plus response body. The wrapper therefore does not call them speculatively. It also records descriptive `debug.getinfo` metadata when the runtime exposes that API, such as whether a candidate is a Lua or native function and any reported source/parameter metadata. The latest diagnostic additionally lists bounded metatable keys and types for `Net`, `NetUtil`, and `UnrealNet` without invoking metamethods or candidate functions. This metadata does not reveal a reliable argument or return contract for native functions, so it cannot by itself justify an adapter. The report never stores the license key or device identity.

## Device-binding security note

If the Android Lua host does not show console, error, or toast output, inspect the hidden `/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.license_status` file after a run. It contains only a timestamp and a non-secret stage such as `KEY_FILE`, `VALIDATING`, `ACCESS_GRANTED`, `VALIDATION_FAILED`, or `ERROR`; it never stores the license key or device identifier. Delete this diagnostic file before a later test only if you want a clean result. The validation API stores a server-side hash of the device identifier supplied by the Lua runtime. The reusable loader prefers a runtime-provided persistent identifier and falls back to its app-specific `.device_id` file. A ZIP/archive or another hidden filename would only make casual inspection harder; it would not create a stronger identity because the Lua process still needs read/write access. The current practical hardening is therefore: use the host's app-private/native persistent identifier when available, use the hidden file only as a fallback, and keep the server-side one-device binding. This prevents ordinary key sharing, but a plain Lua client cannot provide unforgeable hardware attestation: a determined user who can modify the runtime or copy the identifier can impersonate it. Stronger guarantees require a native Android component using platform-backed hardware attestation and a server-issued challenge. The panel therefore treats the current binding as an access-control layer, not as absolute hardware proof.

The owner panel now exposes only `BRPlayerCharacterBase-Reusable.lua` as a downloadable Lua wrapper; the legacy `features.lua`, old `BRPlayerCharacterBase.lua`, and `bot.py` download routes are removed from the panel.


### Final bridge inventory test

Because the target runtime reported `DOWNLOADER_PROBE_UNAVAILABLE import_failed`, the next and final Lua-side diagnostic is `BRPlayerCharacterBase-BridgeInventory-Test.lua`. It does not call `Downloader`, `NetUtil`, packet functions, HTTP, or game APIs. It writes only names/types and safe `import("...")` availability results to `/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.bridge_inventory`. Run it once, then send the complete `.bridge_inventory` text. If it shows a documented callable HTTP request bridge with a known response contract, that bridge can be added as an optional fail-closed adapter. If it shows only failed/nil imports or undocumented functions, rewriting Lua cannot create network access; the viable choices are an approved host/companion bridge or an offline signed-license design.

### Downloader capability probe

The reusable wrapper includes a disabled-by-default `ENABLE_DOWNLOADER_PROBE` flag. When explicitly set to `true for one test run`, it imports the host-provided `Downloader` object and downloads only the fixed public file `/downloader-probe.txt` to the isolated `.downloader_probe` path. The probe records a sanitized status such as `DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE`, `DOWNLOADER_PROBE_CALL_FAILED`, or `DOWNLOADER_PROBE_NO_VERIFIED_FILE`; it never includes a license key, device identity, game packet, or main Lua code.

The temporary file `BRPlayerCharacterBase-DownloaderProbe-Test.lua` is probe-only: after `run_downloader_probe()` it returns immediately, so normal `validate_license()`, HTTP POST fallback, and changing main Lua code cannot overwrite `.license_status` or execute during this test. Run this temporary copy only after deleting old `.downloader_probe` and `.license_status` files; then inspect those two files. `DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE` means the fixed HTTPS GET completed and the downloaded body matched the public fixture. `DOWNLOADER_PROBE_NO_VERIFIED_FILE` means the call returned without a verified file, while `DOWNLOADER_PROBE_CALL_FAILED` means the bridge invocation raised or failed. `DOWNLOADER_PROBE_UNAVAILABLE ...` means the import or method is absent. A successful probe proves only that this host can perform the demonstrated HTTPS GET/file-write operation. It does not prove that `Downloader` supports POST, custom headers, response callbacks, or arbitrary JSON request bodies. The probe must remain disabled in production unless a documented, server-side validation contract has been verified. A public client-downloaded key list is not an acceptable replacement for server validation because client-side JSON can be modified.

The supplied target-runtime `.bridge_inventory` report was inspected on 2026-08-13. It exposes an `import` function and global tables named `Net`, `NetUtil`, and `UnrealNet`, but safe imports for `Downloader`, `NetUtil`, `Net`, `UnrealNet`, `Http`, `HTTP`, `Network`, `Request`, `UE`, and `Android` all returned `failed`. The report therefore does not provide a callable, documented HTTP contract. No Lua-only rewrite can create the missing network capability. Online panel validation remains blocked until an approved host bridge or working host-side example is supplied; otherwise the supported fallback is offline signed-license verification with explicit replay/expiry limitations.

The follow-up `BRPlayerCharacterBase-HostSurfaceInventory-Test.lua` is also diagnostic-only. It records selected names/types for `ScriptHelperNetInterface`, `ScriptHelperClient`, callback/delegate structures, file/cache surfaces, and network tables, then records safe import availability. It does not invoke any discovered method, callback, delegate, network function, downloader, or packet API. Run it alone in the license folder and send `.host_surface_inventory`. A candidate can be integrated only after its host-side request arguments, callback/return shape, and response semantics are documented; a name or table alone is not enough.


### Host contract-shape diagnostic

`BRPlayerCharacterBase-HostContractShape-Test.lua` is a one-time, non-invasive diagnostic for the target Dynamic Execution runtime. It inspects only the type, bounded debug metadata, and bounded metatable keys of `ScriptHelperNetInterface.Connect`, `ScriptHelperNetInterface.Disconnect`, and selected `ScriptHelperClient` members such as `OpenURLInSDK`, file/cache helpers, and H5 helpers. It never invokes a candidate, callback, delegate, URL, download, packet, or game API. Run it alone and inspect `.host_contract_shape`.

The report can show whether a candidate is a native function or userdata and whether Lua metadata is exposed, but metadata does not establish arguments, callback registration, response payloads, or error semantics. A production license adapter may be added only after the host developer or runtime documentation supplies that request/response contract and the adapter preserves server-side key, expiry, ban, device binding, and fail-closed behavior.


The supplied `.host_contract_shape` report was inspected on 2026-08-13. It exposes native C functions `ScriptHelperNetInterface.Connect`, `ScriptHelperNetInterface.Disconnect`, and several `ScriptHelperClient` functions including `GameMasterGetWebUIUrl`, `GetFileDirPath`, `LoadFileToStringByFullPath`, `LoadH5FromCache`, `LoadSavedFileToStringArray`, `OpenURLInSDK`, `SaveStringToIntermediateFile`, `StopH5Downloading`, `DeleteFile`, and `IsFileExistsWithPakCheckMatchExt`. Each reports `what = C`, `source = [C]`, and `nparams = 0` with `isvararg = true`; both inspected metatables are unavailable. These fields are native metadata only and do not reveal whether `Connect` is synchronous or asynchronous, its arguments, callback registration, response body, HTTP status, or error behavior. No production adapter is justified by this report. The next required evidence is an official signature or a working host-side example that demonstrates a real request and server response.


Any future host transport adapter must preserve the existing `/v1/validate` decision path: the server remains authoritative for key validity, ban state, expiry, and device binding. The adapter must treat malformed responses, transport errors, timeouts, and missing callbacks as failures and must never turn local files or cached state into an approval. Because the contract-shape report did not provide a callable request/response contract, the current loader remains fail-closed and no undocumented native method is invoked.


### Getter-return contract discovery

`BRPlayerCharacterBase-GetterReturn-Test.lua` is a one-time diagnostic for selected zero-argument getters only: `ScriptHelperClient.GameMasterGetWebUIUrl` and `ScriptHelperClient.GetFileDirPath`. It runs each candidate inside `pcall` and records only sanitized return types/values in `.getter_return_probe`. It does not call `Connect`, `Disconnect`, `OpenURLInSDK`, downloads, callbacks, packets, license validation, or main Lua. A return value can reveal a local/UI helper result, but it does not establish an HTTP request/response contract. A usable license adapter still requires an official signature or a working host example that returns the panel response to Lua.


#### Getter-return probe decision table

| Observed result | Meaning | License-system decision |
|---|---|---|
| `.getter_return_probe` is created and contains `call_ok` with a sanitized primitive value | A selected zero-argument getter returned a local/UI value | Record it as a getter result only; do not treat it as an HTTP response or license approval |
| `.getter_return_probe` is created and contains `call_ok [nil]` or only type values | The getter ran but returned no usable value | Do not infer network support; continue fail-closed |
| `.getter_return_probe` is created and contains `call_error` | Lua protected-call error occurred while invoking the selected getter | Treat the candidate as unsupported for this test; do not retry with different arguments |
| No `.getter_return_probe` is created and the Lua host remains alive | The report path is not writable or the script did not reach the writer | Treat the test as inconclusive; do not infer success or network support |
| The host closes, crashes, or silently stops during the test | The selected host call may be unsafe or incompatible even though `pcall` was used | Stop probing that candidate; obtain an official signature or working host example; never use it in production |

`pcall` can contain ordinary Lua errors but cannot guarantee recovery from a native host crash. None of these outcomes authorizes a license approval; only the existing server validation response can do that.

### Observed getter-return probe result

The target runtime completed `BRPlayerCharacterBase-GetterReturn-Test.lua` without a crash, but both selected zero-argument calls rejected the missing argument before returning a value: `ScriptHelperClient.GameMasterGetWebUIUrl` reported that a number was expected, and `ScriptHelperClient.GetFileDirPath` reported that a string was expected. This establishes only that these functions require arguments; it does not establish their argument semantics, callback behavior, URL capability, or any HTTP response path. No license or device data was touched. The next safe step is to obtain an official signature or a working host-side example rather than guessing arguments.

### Friend-code HTTP module inventory

The supplied friend login code references `Http`, `WebRequest`, and `SimpleHttp` as possible host modules. `BRPlayerCharacterBase-HttpModuleInventory-Test.lua` checks only whether those modules can be imported and what names/types they expose; it does not make a request, open a URL, invoke a callback, download a file, or run license code. A module name alone is not a request contract.

Before any adapter integration, the friend code must be hardened: it exposes the key in a URL/log, and its remote response is evaluated with `loadstring`, which is unsafe for untrusted server content. The production adapter must send the key through the panel's authenticated validation path, parse a strict data response, verify the server decision, and fail closed on malformed data, errors, timeouts, or missing callbacks. No embedded secret or local success flag may authorize the main Lua.


### Current runtime closure

The latest target-runtime probe recorded `DOWNLOADER_PROBE_UNAVAILABLE import_failed`. Together with the earlier bridge, host-surface, contract-shape, getter, and HTTP-module reports, this means that no verified Lua-callable HTTP POST transport is available in the supplied runtime. The remaining prerequisite is an **authorized official host API or developer-provided bridge contract** that specifies the request method, URL/body/headers, timeout behavior, callback or return shape, numeric status, response body, and error path. Until that prerequisite exists, the production loader remains fail-closed; no undocumented native call, third-party file extraction, or validation bypass is supported.


### Online-only limitation

The target Dynamic Execution runtime has been tested for the available Lua-side transport surfaces. The supplied evidence does not show a callable, authorized HTTPS JSON POST mechanism that returns a status code and response body. A Telegram/WebView URL opener or a fixed Downloader GET capability is not equivalent to license validation transport. Therefore the online loader remains fail-closed until an authorized host contract becomes available. The project does not add undocumented bridge extraction, unauthorized file access, unsafe remote execution, or a validation bypass to compensate for that missing capability.


### Server discovery boundary

The panel validation endpoint is already configured and documented; the unresolved issue is the target runtime's client transport, not discovery of the server URL. The project does not include a Lua file that scans folders, captures hidden server addresses, extracts proprietary bridge code, or intercepts undocumented runtime methods. Any future diagnostic remains limited to non-invasive names/types reporting within the user's own authorized runtime.


### No-developer online-only constraint

The requested online-only mode cannot be implemented by adding a Lua file that discovers or captures an undocumented HTTP/JSON transport. The completed diagnostics were not wasted: they established that key-file reading works, while the target runtime lacks the client-side request/response surface required to reach the known panel endpoint. Until an authorized transport is exposed, the reusable loader must fail closed rather than guessing native calls or intercepting hidden components.


### Hidden transport extraction boundary

File-chain scanning, interception, undocumented native-call probing, and capture of another component's transport are not supported implementation paths. The authorized diagnostics already completed—global/module inventory, host-surface inspection, contract-shape metadata, getter probing, HTTP-module inventory, and Downloader testing—did not expose a verified HTTPS JSON POST contract. Contract-dependent adapter work therefore remains blocked until an approved request/response interface exists.


### Key-validation scope boundary

Key validation authorizes checks against this project’s panel; it does not authorize entering external sites, extracting hidden server/runtime components, or probing undocumented bridges. Any future Lua adapter must use an explicitly authorized and documented request/response contract, while the current loader remains fail-closed.

### Supported completion options
The current blocker is a missing authorized client transport inside the target Dynamic Execution host, not a missing panel endpoint. There are two supported completion paths. The first is to pause the Lua online client until the host developer supplies a documented bridge contract covering request arguments, callback or return values, HTTP status, response body, timeout, and error semantics. The second is to switch deliberately to an offline signed-license architecture in which the panel signs a short-lived license payload and the Lua host verifies it locally using a vetted cryptographic implementation; cached approval must still fail closed on invalid signature, expiry, or device mismatch, and offline revocation cannot be instantaneous.

The project will not implement proprietary transport extraction, runtime interception, undocumented native invocation, external-file harvesting, or server-validation bypass. Until one of the two supported paths is selected and its prerequisites are available, the online loader remains fail-closed.

### Online-only requirement and implementation boundary
Online server validation remains the required product goal. The limitation is at the client-runtime transport layer: the panel endpoint exists, but the target Dynamic Execution environment has not exposed a verified Lua-callable request/response API. The next implementation evidence must therefore be either an authorized host transport contract or a user-owned companion bridge that accepts the key/device payload and returns the panel's status and response body. File extraction, traffic interception, undocumented native invocation, and validation bypass are excluded because they do not establish a reliable or authorized transport.
