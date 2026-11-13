# PLUBICV1 Transport and License-Validation Audit

**Scope.** This is a read-only, defensive review of the supplied `PLUBICV1.lua`, the adjacent `Features.lua`, and the panel's `/v1/validate` contract. It does not add an undocumented bridge, bypass server validation, suppress anti-cheat behavior, or execute remote code.

## Executive classification

`PLUBICV1.lua` does not contain a contract-backed HTTP client for license validation. Its only clearly identifiable HTTPS operation is a WebView call that opens `https://t.me/ALEXALORD`; opening a URL in a host WebView is not evidence that Lua can perform an arbitrary HTTPS POST and receive a response body.

The adjacent `Features.lua` contains a LuaSocket-style `socket.http` request, but it uses a placeholder HTTP URL, sends the key and device identifier in the query string, has no explicit timeout or TLS configuration, and is not suitable for the target runtime because the supplied inventory already showed that `socket.http` is unavailable there.

## Checklist matrix

| Area | Observed evidence | Classification | Safe requirement |
|---|---|---|---|
| HTTPS and TLS | `PLUBICV1.lua` opens a Telegram HTTPS URL through a WebView. `Features.lua` uses `http://YOUR_SERVER_IP:5000/...`. | No API TLS transport is present in `PLUBICV1.lua`; `Features.lua` is plaintext and uses a placeholder. | The authorized transport must use the panel's HTTPS URL, validate certificates through the host networking layer, and reject certificate or hostname failures. |
| Asynchronous behavior | The WebView operation is host UI behavior. The LuaSocket example calls `http.request` directly. | No verified non-blocking license request exists. | A host bridge should provide a callback/future contract or a bounded worker operation so the game loop is not blocked. |
| HTTP method | Panel route is `POST /v1/validate`. `Features.lua` uses the default request behavior and puts data in a URL. | Method and transport do not match the panel contract. | Use POST only. |
| Headers | Panel expects JSON input. `Features.lua` does not set an explicit JSON content type. | Header contract is incomplete. | Send `Content-Type: application/json` and an appropriate `Accept: application/json`; do not put the license key in headers unless the server contract explicitly requires it. |
| Payload | Panel reads JSON fields `key` and `device_id`. `Features.lua` sends `key` and `device_id` in the URL query string and expects a different `data.keys` file shape. | Payload format is incompatible and leaks secrets into URLs/logs/history. | Send a JSON body such as `{ "key": "...", "device_id": "..." }`; keep it out of the URL. |
| Timeout | No timeout is configured in the supplied Lua request. | A hung request could block or leave the loader in an undefined state. | Require a short, explicit connect/read/total timeout and fail closed on expiry. |
| Status codes | The panel returns `200` for success and `403` for malformed or rejected validation. `Features.lua` checks only `code == 200`. | Basic status checking exists only in the incompatible sample; failure reasons are not parsed. | Accept only HTTP 200 with a valid success JSON object; treat all other statuses and malformed responses as denial. |
| Response body | Panel success includes `ok: true` and `expiresAt`; rejection includes one of the documented error codes. `Features.lua` does not decode the response body. | The sample cannot distinguish invalid, banned, expired, or device-binding failures. | Parse JSON defensively and map only the known error codes; never execute the response as Lua. |
| Memory and file handling | `Features.lua` closes opened files and collects a response table, but has no response-size bound. | Basic file cleanup is present; network-body limits are absent. | Bound response size, release buffers after parsing, and close every file/socket on every path. |
| Logging | `PLUBICV1.lua` displays promotional status text. `Features.lua` prints generic outcomes. | No structured, privacy-safe transport logging exists; URL-based keys may leak through logs. | Log only sanitized stage, status, and error category; never log keys, device IDs, tokens, or full URLs containing secrets. |
| URL validation | Telegram URL is fixed. API URL in `Features.lua` is a placeholder and not validated. | No license API URL validation is present in the supplied code. | Pin the configured HTTPS origin/path and reject unexpected schemes, hosts, redirects, or user-controlled URLs. |
| DNS and connectivity | A safe malformed POST to the deployed panel returned HTTP 403 over HTTP/2, with HSTS and `x-content-type-options: nosniff`, showing that the endpoint is reachable. | Panel availability is verified from the sandbox, not from the restricted Android Lua host. | The host bridge must expose bounded DNS/connectivity errors without retry storms. |
| Server behavior | The panel route reads JSON `key` and `device_id`, validates them server-side, and returns documented error codes. | Server contract is authoritative and suitable for fail-closed validation. | Preserve the server's key, expiry, ban, and one-device-one-key checks; do not replace them with local expiry or bypass logic. |

## Security findings

The `PLUBICV1.lua` content contains code that replaces or suppresses network, anti-cheat, reporting, and exception-handling functions. That is not a license transport and must not be repurposed as one. Adding a hidden file or forcing those functions would create an unauthorized bypass rather than a reliable API integration.

The `Features.lua` sample also has three independent correctness problems: it requires unavailable LuaSocket modules in the target runtime; it uses a placeholder plaintext URL; and it places both the key and device identifier in the query string. That pattern should not be copied into the production loader.

## Safe implementation gate

No Lua-side transport adapter should be added until an authorized host surface provides all of the following: HTTPS certificate verification performed by the host, POST support, JSON request-body transmission, a bounded timeout, an asynchronous callback or equivalent non-blocking contract, the numeric status code, the response body, and a documented error path. Until then, the reusable loader must remain fail-closed. The safe fallback is an offline signed-license design or an authorized host/companion bridge—not a bypass or hidden extraction method.
