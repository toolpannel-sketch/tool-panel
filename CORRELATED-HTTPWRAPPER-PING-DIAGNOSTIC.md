# Correlated `HttpWrapper` Ping Diagnostic

## Scope

This diagnostic is deliberately **key-free** and has no license, device-binding, authentication, or database effect. It uses only the documented `HttpWrapper` acquisition, request, and response-event contract in the authorized Lua source. The request body is exactly `{"test":"ping"}`.

## Endpoints

| Purpose | Method and URL | Input | Output |
|---|---|---|---|
| Correlated ping | `POST https://luapanel-8355ybgt.manus.space/ping` | Body `{"test":"ping"}` and a harmless `X-Transport-Probe-Id` header | `{"ok":true,"test":"ping"}` |
| Sanitized server record | `GET https://luapanel-8355ybgt.manus.space/ping/diagnostic/<request-id>` | The correlation identifier recorded by the Lua status file | Receipt and server-response lifecycle flags only |

The correlation identifier is not an authentication value. The server retains no keys, device identifiers, tokens, IP addresses, or request body content. Records expire after 30 minutes and are capped in memory.

## Device procedure

Compile and run only `BRPlayerCharacterBase-HttpWrapperCorrelatedPingProbe.lua`. It writes one status line to:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.http_wrapper_correlated_ping_status
```

Copy that line unchanged. Its `request_id` identifies the safe server record. Open the diagnostic URL with that exact identifier, then provide both outputs. The Lua probe does not parse JSON and never changes `success` or `result`.

## Classification

| Evidence | Classification | Meaning |
|---|---|---|
| Server record exists, `responseSent=true`, Lua callback has `success=true` and response bytes | Case A | Transport completed; only then inspect application parsing, if any. |
| Server record exists, `responseSent=true`, Lua callback has zero bytes or `success=false` | Case B | Request reached the server; native host response delivery is the remaining boundary. |
| No server record for the Lua `request_id` | Case C | Failure occurred before the request reached this server; inspect only documented request construction and host/network configuration. |
| Lua callback has bytes but they do not equal the expected JSON | Case D | Compare raw byte counts and body match; response format/parsing becomes the next bounded issue. |

> `responseSent=true` means Express finished writing the response locally. It does **not** prove that the Android runtime accepted or delivered those bytes to Lua.

## Result template

```text
SERVER_REQUEST_RECEIVED = <true/false>
SERVER_RESPONSE_SENT = <true/false>
LUA_CALLBACK_RECEIVED = <true/false>
LUA_SUCCESS = <true/false>
LUA_DATA_BYTES = <number>
LUA_CONTENT_BYTES = <number>
LUA_RESULT = <value>
```
