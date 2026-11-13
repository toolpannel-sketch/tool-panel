# Second Authorized Lua HTTP Audit

## Scope

This second review statically examined the user-authorized source archive for an exact Lua-level remedy to the target runtime result:

```text
HTTP_MANAGER_LONG_CALLBACK success=false result=-1 data_bytes=0 content_bytes=0
```

No Lua file was executed. The review considered only documented wrapper access, callback wiring, request construction, JSON parsing, and host configuration references. It did not inspect credentials, invoke native functions outside the verified probe, or attempt hidden transport discovery.

## Verified findings

| Area | Static finding | Relevance to the probe |
|---|---|---|
| Wrapper lifecycle | `http_manager:OnInitialize()` calls `slua_GameFrontendHUD:GetHttpWrapper()` and registers `HttpWrapper.OnResponseEvent:Add(...)`. | The target callback proves this initialization path is already active. |
| POST request | `http_manager:Post(...)` calls `HttpWrapper:RequestForLua(url, "POST", headers, body, priority, queueType)`. | The probe used this exact public method, with the documented default priority and queue type of `0`. |
| Response dispatch | `OnRawResponse(reqIndex, elapsedTime, data, content, success, result)` invokes the original callback with `success, data, content, result`. | The `result=-1` was forwarded from the native wrapper; it is not produced by JSON parsing or the manager timeout. |
| Timeout behavior | The manager’s own timeout calls `callback(false, "", nil)` and does not provide `result`. | The 45-second callback containing `result=-1` was a native event, not the Lua manager timeout. |
| Fire-and-forget method | `SimplePostForLua` has no documented response callback. | It cannot securely validate a license because it cannot return the panel decision to Lua. |
| JSON helper | `json_util.lua` provides `cjson` decoding with a `dkjson` fallback. | JSON parsing can occur after a response arrives; it cannot resolve a zero-byte native response. |
| Other wrapper consumers | The only other consumers found use `GetHttpWrapper()` to cancel queues or manage image downloads. | They provide no additional request headers, host allowlist, TLS configuration, or response-body contract. |
| Result-code mapping | No Lua source mapping for HTTP-wrapper `result=-1` was found. | A Lua-only change cannot assign a reliable recovery action to this host-defined failure. |

## Decision

The supplied source establishes the same documented request path already probed; it does not contain an additional Lua-level transport, callback registration requirement, JSON requirement, or host configuration that would convert `result=-1` into a successful API response. Therefore, changing the BR Character would be speculative and would weaken the fail-closed design.

The remaining technical requirement is outside the Lua source: the native host must permit the request and deliver a response body through `OnResponseEvent`. A production asynchronous license gate should be added only after a probe shows `success=true` and non-zero response bytes containing parseable panel JSON.
