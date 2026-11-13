# Authorized Lua HTTP Contract Audit

## Scope and boundary

The user confirmed authorization to review the supplied `ALLLUADEC4.5BGMI.rar` archive. The archive was inspected statically only: its contents were **not executed**. The audit was restricted to documented Lua-level HTTP request paths relevant to the panel’s online validation request. It did not extract credentials, inspect hidden runtime state, invoke undocumented native functions, or execute downloaded/returned code.

## Inventory and result

The archive contains **21,112 Lua files** and extracted to approximately **212 MB** in an isolated audit directory. Static review found no occurrences of the previously tested standard transports: `HTTP_POST`, `http_post`, `socket.http`, `ssl.https`, `ltn12`, `http.request`, `WebRequest`, or `SimpleHttp`.

One project-provided, documented request path was found in `http_manager.lua`:

| Item | Verified source behavior |
|---|---|
| Manager access | `ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)` |
| Initialization | The manager obtains `slua_GameFrontendHUD:GetHttpWrapper()` when that host object is available. |
| POST call | `http_manager:Post(url, headers, body, ueObj, callback, timeout, priority, queueType)` |
| Native wrapper call | `HttpWrapper:RequestForLua(url, "POST", headers, body, priority, queueType)` |
| Callback data | `callback(success, data, content, result)` |
| Request handle | A non-zero request index indicates that the manager accepted the request. |

> The source establishes a public, concrete request contract. It does **not** establish that the restricted Dynamic Execution host running the existing license wrapper exposes `ModuleManager`, initializes `http_manager`, or delivers its asynchronous callback.

## Added bounded probe

`BRPlayerCharacterBase-HttpManagerProbe.lua` is a key-free probe for that exact documented contract. It makes one POST to the panel’s validation endpoint using a fixed invalid probe identity. It cannot bind a real license key and reports only sanitized status metadata in:

```text
lua-license/.http_manager_probe_status
```

The final status will be one of the following:

| Status | Meaning |
|---|---|
| `HTTP_MANAGER_PROBE_FAILED ModuleManager_missing` | The target host does not expose the documented manager access point. |
| `HTTP_MANAGER_PROBE_FAILED CommonModuleConfig_http_manager_missing` | The module config is not available in the target host. |
| `HTTP_MANAGER_PROBE_FAILED http_manager_Post_unavailable` | The configured manager cannot provide the documented POST method. |
| `HTTP_MANAGER_REQUEST_ACCEPTED ... awaiting_callback` | The request was queued; wait at least 10 seconds, then retrieve the file again to check whether the callback replaced this status. |
| `HTTP_MANAGER_CALLBACK success=... result=... data_bytes=... content_bytes=...` | The host delivered a response callback; this establishes a usable asynchronous transport candidate. |

## Required next evidence

Run only `BRPlayerCharacterBase-HttpManagerProbe.lua` in the same Dynamic Execution host where the production wrapper runs. Do not add a real key file for this probe. After waiting 10 seconds, submit the resulting `lua-license/.http_manager_probe_status` file.

If the result is `HTTP_MANAGER_CALLBACK`, the next implementation step is an **asynchronous** license gate that starts the protected feature entry point only from a successful validated callback. The current synchronous production loader must not be changed until callback delivery is demonstrated; blocking or guessing an event-loop mechanism would not be reliable.

## First probe result and follow-up

The target host returned:

```text
HTTP_MANAGER_CALLBACK success=false result=nil data_bytes=0 content_bytes=0
```

The authorized source defines this exact empty callback shape as its local timeout path: after the configured timeout, it calls `callback(false, "", nil)` without a fourth `result` value. The first probe used an 8-second timeout; therefore it proves that the manager was initialized and accepted the request, but **does not** prove a server response or a usable online transport.

`BRPlayerCharacterBase-HttpManagerLongTimeoutProbe.lua` is the only justified follow-up. It uses the same documented API, no real key, and a bounded 45-second timeout. If it yields `HTTP_MANAGER_LONG_CALLBACK` with non-empty response metadata, the asynchronous adapter can proceed. If it writes `HTTP_MANAGER_LONG_TIMEOUT`, the target host cannot obtain a panel response through this path and the production loader must remain fail-closed.

## 45-second follow-up result

The target host returned:

```text
HTTP_MANAGER_LONG_CALLBACK success=false result=-1 data_bytes=0 content_bytes=0
```

This is a native response event rather than the manager’s local 45-second timeout, because the callback included `result=-1`. However, it still contains no response bytes and reports `success=false`; therefore the host did not deliver an HTTP response from the panel to Lua. The documented callback mechanism exists, but the native request failed before a usable server response was available. The response code `-1` is host-defined and the supplied source does not document a further Lua-level remedy.

The production license gate must remain fail-closed. It must not authorize any key from callback delivery alone, from a request index, or from a `success=false` event. A future online adapter is justified only if the host can produce `success=true` and a parseable panel JSON response body.
