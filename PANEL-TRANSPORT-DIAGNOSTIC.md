# Panel Transport Diagnostic

## Purpose

The existing `/v1/validate` endpoint correctly returns HTTP `403` for an invalid key. The earlier key-free POST intentionally used an invalid key, so its native `result=-1` callback could not by itself distinguish a non-success validation decision from a failure to reach the panel.

The panel now provides a minimal, key-free diagnostic endpoint:

| Method | URL | Response | Side effects |
|---|---|---|---|
| GET | `/v1/transport-ping` | HTTP 200 and `{"ok":true,"service":"lua-license-panel"}` | None |
| POST | `/v1/transport-ping` | HTTP 200 and `{"ok":true,"service":"lua-license-panel"}` | None |

Neither route reads a license key, binds a device, queries the database, or changes license state.

## Matching probes

`BRPlayerCharacterBase-HttpManagerGetProbe.lua` tests basic GET response delivery. `BRPlayerCharacterBase-HttpManagerPostPingProbe.lua` tests a successful JSON POST response delivery using the same documented `http_manager:Post` signature as validation.

Run one probe at a time, without any key file, wait 60 seconds, and submit the corresponding status file. A usable result requires all of the following:

```text
success=true
data_bytes>0 or content_bytes>0
panel_ok=true
```

If GET succeeds but POST fails, the native bridge has a POST-specific limitation. If both fail with `result=-1` and zero bytes, the native host cannot deliver even the panel’s minimal 200 response and the production license loader must remain fail-closed. If POST succeeds, the next test can use a valid license key with the production adapter.

## Submitted POST result

The target runtime returned:

```text
HTTP_MANAGER_POST_PING_CALLBACK success=false result=-1 data_bytes=0 content_bytes=0 panel_ok=false
```

The live panel was independently verified to return HTTP `200` with the expected 41-byte JSON body for the identical POST request. Therefore, `panel_ok=false` does **not** identify a panel JSON or route issue: the target native HTTP layer supplied no response body to Lua. The production online license gate remains fail-closed pending a host response event with `success=true` and a non-empty body.
