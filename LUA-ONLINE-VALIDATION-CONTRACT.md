# Lua Online Validation Contract

## Purpose

The project-owned API endpoint is:

```text
POST https://luapanel-8355ybgt.manus.space/v1/validate
Content-Type: application/json
```

The Lua client sends a JSON object containing `key` and `device_id`.

```json
{"key":"LUA-EXAMPLE","device_id":"persistent-app-scoped-id"}
```

A successful response has HTTP status `200` and a JSON body containing `ok: true` and `expiresAt`. A rejected request has HTTP status `403` and one of the documented error codes: `invalid_key`, `key_banned`, `key_expired`, `device_limit_reached`, or `device_already_bound`.

## Transport options

The preferred host contract is a synchronous Lua global:

```lua
local status, response_body = HTTP_POST(url, json_body)
```

The adapter accepts the result only when `status` is numeric and `response_body` is a string. Any bridge exception or malformed result fails closed before the feature code runs. Callback signatures are not guessed.

If the host provides standard modules, the adapter requires `ltn12` plus `ssl.https` for an `https://` URL. `socket.http` is not treated as an HTTPS/TLS implementation. Plain HTTP is supported only for non-HTTPS URLs and is not used by the production API URL.

## Runtime gate

The target runtime must expose either the documented `HTTP_POST` function or the standard LuaSec modules. The reusable wrapper does not scan hidden files, inspect proprietary implementations, intercept traffic, invoke undocumented native functions, or bypass server validation. If neither transport is available, it stops with an error and does not execute the protected Lua feature.

## Device binding note

The server hashes the client-provided `device_id` before storing it. A file-backed random identifier is a continuity fallback, not cryptographic hardware attestation. A host-provided persistent app-scoped identity is preferred.

## References

[1]: https://lunarmodules.github.io/luasocket/http.html "LuaSocket HTTP documentation"
[2]: https://github.com/lunarmodules/luasec "LuaSec source and documentation"
