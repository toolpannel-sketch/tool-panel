# Documented `http_manager` POST Ping Test

## Scope

This is a **transport-only** test. It does not read a license key, generate a device identifier, call either license-validation route, or load protected Lua code. It uses only the authorized `http_manager:Post` signature documented in the supplied Lua source.

| Item | Value |
|---|---|
| Endpoint | `https://luapanel-8355ybgt.manus.space/v1/transport-ping` |
| HTTP method | `POST` |
| Request body | `{"test":"ping"}` |
| Expected response body | `{"ok":true,"test":"ping"}` |
| Expected HTTP status | `200` |
| Timeout | `45` seconds |
| License side effects | None |
| Database side effects | None |

## Authorized Lua Call

The supplied probe, `BRPlayerCharacterBase-HttpManagerPostPingProbe.lua`, invokes only this documented call shape:

```lua
http_manager:Post(API_URL, headers, body, nil, callback, TIMEOUT_SECONDS, 0, 0)
```

The callback follows the authorized format:

```lua
callback(success, data, content, result)
```

It writes a sanitized status record to:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.http_manager_post_ping_status
```

No license or device identifier is written to this report.

## Success Criterion

A successful native round trip must produce the `HTTP_MANAGER_POST_PING_CALLBACK` record with all of the following values:

```text
success=true
result=<documented success result from the host>
data_matches_expected=true OR content_matches_expected=true
```

The probe also records byte counts for `data` and `content`, so a native failure with no response remains distinguishable from a response-format mismatch. A result such as `success=false`, `result=-1`, and zero bytes remains a transport failure; it does not justify integrating license validation.

## Device Test Procedure

Compile and run only `BRPlayerCharacterBase-HttpManagerPostPingProbe.lua` in the same Dynamic Execution host and network context as the intended loader. Wait at least 45 seconds after it starts. Then provide only the complete contents of `.http_manager_post_ping_status`. Do not provide a license key or device identifier.

> License validation remains disabled until this callback carries the expected response through the documented bridge.

## Observed Target-Device Result

The submitted status report contains the following documented callback result:

```text
HTTP_MANAGER_POST_PING_CALLBACK success=false result=-1 data_bytes=0 content_bytes=0 data_matches_expected=false content_matches_expected=false
```

The callback fired, but the host returned no response bytes. Therefore the public endpoint response did **not** reach Lua through this host execution path. This is a native/runtime transport failure, not a server JSON mismatch, and the license adapter remains unmodified and fail-closed.
