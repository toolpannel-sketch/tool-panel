# Final Authorized Network-Pattern Audit

## Scope and Boundary

This is a **static-only** review of the user-authorized Lua archive at `/home/ubuntu/authorized-lua-audit/ALL LUA DEC 4.5 BGMI`. It records only documented source behavior. No native call was added, no transport probe was changed, and no license, device, or authentication code was run.

## Evidence Collected So Far

| Source | Documented call | Method | URL construction | Headers / body | Priority / queue | Callback | Source-level success evidence |
|---|---|---|---|---|---|---|---|
| `serverlist_downloader.lua` | `http_manager:Get(url, {}, "", nil, callback, nil, 3, 0)` | GET | `FuncUtil.GetDomainByID(3366179)` plus a keyword/path, or the same domain plus `serverList_kubernetes.txt` / `server_list_in.txt` | Empty header table and empty body | priority `3`, queue `0` | `(success, data, content)` | The code treats `success` and non-nil `content` as success and saves content locally; it is a call-site handling pattern, not a captured successful runtime response. |
| `cdn_downloader.lua` | `http_manager:Get(retInfo.cdnUrl, {}, "", nil, callback, nil, 30, 0, retInfo.savePath)` | GET | `retInfo.cdnUrl`, configured elsewhere from domain-based CDN paths | Empty header table and empty body | priority `30`, queue `0`, plus a save-path parameter | `(success, data, content)` | The code saves returned content only when `success and content`; it does not include captured proof that a request succeeded in this target runtime. |

The documented calls above both use the same `http_manager` module and therefore the same underlying `HttpWrapper:RequestForLua` path already tested. Their distinct priorities, queue values, URL construction, and file-save consumers do **not** by themselves provide an alternate documented transport implementation.

| Source | Documented call | Method | URL construction | Headers / body | Priority / queue | Callback | Source-level success evidence |
|---|---|---|---|---|---|---|---|
| `LudoUtils.lua` | `http_manager:Get(url, header, "", nil, callback)` | GET | `getLudoSvrUrlPrefix()` selects a configured domain by editor/region/IMSDK environment and builds `api/status` resource paths with ticket, uid, openid, language, and region query parameters | `Content-Type: application/json`; `Accept-Encoding: gzip`; empty body | Not supplied; wrapper defaults apply | `(success, data, content, result)` at room-list call sites; some call sites use `(success, data)` | Call sites JSON-decode `data` and resolve promises only after `success=true`; no captured target-runtime completion is included. |
| `LudoUtils.lua` | `http_manager:Post(url, header, json.encode(data), nil, callback)` | POST | Same runtime-configured Ludo service prefix, including status/table paths and query parameters | Same JSON/gzip headers; JSON body such as `currentList` / `worldList` | Not supplied; wrapper defaults apply | `(success, data)` | Call sites JSON-decode `data` only after `success=true`; this documents intended successful JSON handling, not an independently verified external HTTPS result. |

`LudoUtils.getHeaders()` contains only `Content-Type: application/json` and `Accept-Encoding: gzip`. Its configured domains are selected at runtime and do not provide a standalone externally-verifiable endpoint in the authorized source. Both Ludo patterns obtain the same `http_manager` module, so they remain consumers of the already-tested `HttpWrapper:RequestForLua` bridge rather than a distinct documented transport.

## Final Classification

| Question | Evidence-based result |
|---|---|
| Is there a documented Lua transport implementation different from `http_manager` / `HttpWrapper`? | **No.** All identified downloader and Ludo call sites use `http_manager`, which forwards requests to the same documented native wrapper. |
| Does source show GET and POST usage? | **Yes.** It documents both methods, including custom headers, JSON body use, and priority/queue variations. |
| Does source include a fixed, externally-verifiable working HTTPS request for this target runtime? | **No.** URLs are runtime-configured domains, downloader inputs, or domain-ID resolution outputs. |
| Does source prove an HTTPS response actually succeeded on this target device/runtime? | **No.** It contains conditional `success` handling, not a captured runtime response or a success trace. |
| Does source map `result=-1` or expose native HTTP/TLS diagnostics? | **No.** The wrapper forwards `result` to Lua without interpreting it. |

> **Conclusion:** The authorized source provides no distinct documented working HTTPS transport beyond the already-tested `http_manager` / `HttpWrapper` bridge. It does not expose enough documented host/runtime information to diagnose the observed `result=-1`, zero-byte response further. Host/runtime-side error mapping, native request logs, or a known-working request from the target environment is required before another transport-only experiment would be evidence-based.

## Safety Boundary

No license validation, key processing, device binding, authentication logic, undocumented native calls, reverse-engineered APIs, or speculative transport changes were added or executed during this audit.
