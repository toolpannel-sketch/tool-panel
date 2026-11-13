# Direct HttpWrapper POST Ping Diagnostic

## Scope

This probe is deliberately limited to the user-authorized `HttpWrapper` interface. It sends exactly one side-effect-free HTTPS request to the public ping endpoint and never reads a license key, device identifier, or protected Lua content.

| Item | Value |
|---|---|
| Endpoint | `https://luapanel-8355ybgt.manus.space/v1/transport-ping` |
| HTTP method | `POST` |
| Request body | `{"test":"ping"}` |
| Expected response | `{"ok":true,"test":"ping"}` |
| Status file | `lua-license/.http_wrapper_direct_post_ping_status` |
| Contract used | `GetHttpWrapper` → `OnResponseEvent:Add` → `RequestForLua` |

> The authorized source forwards `OnResponseEvent` as `(reqIndex, elapsedTime, data, content, success, result)`. It does not document native numeric meanings for `result`; therefore `result=-1` must not be labeled as TLS, certificate, URL, queue, or timeout failure without additional host documentation.

## Status Interpretation

| Status prefix | What it proves | What it does not prove |
|---|---|---|
| `FAILED stage=hud_missing` through `OnResponseEvent_Add_failed` | A documented Lua-side setup stage was unavailable or threw an error. | Network/TLS reachability. |
| `FAILED stage=request_not_accepted` | `RequestForLua` did not return a usable request index. | Why the native layer rejected it. |
| `REQUEST_ACCEPTED ... awaiting_callback` after 60 seconds | The documented direct request call returned an index, but no matching response event was delivered while the test remained active. | Whether the failure was DNS, TLS, a queue, connectivity, or a native timeout. |
| `CALLBACK success=false result=-1 data_bytes=0 content_bytes=0` | A matching native callback arrived without an HTTP body. | A specific native error category; the authorized Lua contract does not map `-1`. |
| `CALLBACK success=true ... data_matches_expected=true` | The documented direct bridge delivered the expected panel response. | License validation; that remains a separate future task. |

## Device Procedure

Compile and run `BRPlayerCharacterBase-HttpWrapperDirectPostPingProbe.lua` with **no** key file required. Keep the test context open for **60 seconds**, then submit the complete status-file content. Do not run a license loader during this test.

If the callback still has `success=false`, `result=-1`, and zero bytes, the correct conclusion is only that the documented native bridge did not deliver the response. A specific root cause requires host/runtime diagnostics that the authorized Lua API does not expose.

## Submitted Device Result

The direct probe returned a matching callback for `request_index=1` after approximately `2.80` seconds with `success=false`, `result=-1`, `data_bytes=0`, and `content_bytes=0`. This proves that the documented direct request setup, event registration, request-index correlation, and native callback delivery all occurred; no server response body was delivered to Lua.

The same public endpoint was independently verified to return HTTP `200` with `application/json` from outside the device. Therefore, the panel request/response contract is healthy, while the target runtime's documented native transport reports an unmapped failure before Lua receives HTTP data. The authorized Lua contract does not expose enough information to distinguish URL resolution, TLS/certificate validation, network policy, queue, or native timeout as the cause of `result=-1`.
