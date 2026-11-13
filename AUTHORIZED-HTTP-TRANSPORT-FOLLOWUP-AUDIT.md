# Authorized HTTP Transport Follow-up Audit

## Scope and Boundary

This audit reviewed only the user-authorized Lua source located under `ALL LUA DEC 4.5 BGMI`. It did not execute source code, inspect native binaries, invoke native functions, discover hidden APIs, or perform any authentication or license-validation work.

## Documented Transport Contract

The authorized `http_manager.lua` source implements the following public wrapper behavior:

```lua
local index = HttpWrapper:RequestForLua(url, "POST", head, content, priority, queueType)
pairMap[index] = {callback = callback}
```

For responses, it forwards the native callback without translating the result code:

```lua
function http_manager:OnRawResponse(reqIndex, elapsedTime, data, content, success, result)
  ...
  tb.callback(success, data, content, result)
end
```

The source also exposes `Get` through the same `RequestForLua` bridge and `SimplePostForLua` as a fire-and-forget helper. The wrapper’s own optional timeout calls `callback(false, "", nil)` and **does not supply a `result` value**.

> **Finding:** No Lua-level mapping, enum, comment, conditional branch, or diagnostic string defines the meaning of `result = -1`.

## Existing Request Examples

The authorized source contains multiple normal application call sites using `http_manager:Get(...)` and `http_manager:Post(...)`. Examples include the Ludo utilities and UGC community code. Those call sites demonstrate the expected request and callback shape, for example:

```lua
http_manager:Post(url, header, jsonStr, nil, function(success, data)
  local tb = json.decode(data)
  ...
end)
```

The Ludo code additionally uses the four-field callback signature and logs the unmodified `result`:

```lua
http_manager:Get(url, header, "", nil, function(success, data, content, result)
  printf("... result:%s data:%s", result, data)
end)
```

However, its server URLs are built from runtime configuration:

```lua
local domain = LudoConst.WebgameSvrUrlDomain[eGameType]
url = FuncUtil.GetDomainByID(...)
```

The reviewed source does not provide a concrete, runnable HTTPS URL together with a recorded successful target-runtime response. A `http://localhost:8000/` literal appears only as a local test reference in the manager source; it is neither HTTPS nor evidence that the target Android runtime can reach an external server.

> **Finding:** The source demonstrates intended normal usage of the documented bridge, but contains **no documented working external HTTPS request outcome for this runtime/environment**.

## Evidence-Based Classification of the Submitted Probe

The direct `HttpWrapper:RequestForLua` probe received a callback for its returned request index after approximately 2.80 seconds with:

| Field | Observed value |
|---|---|
| `success` | `false` |
| `result` | `-1` |
| `data_bytes` | `0` |
| `content_bytes` | `0` |

The harmless public POST endpoint was independently verified to return HTTP 200 JSON outside the device. This establishes only that the public endpoint is healthy and that the documented native transport delivered no response bytes to Lua.

The authorized Lua source does not expose enough information to distinguish DNS/URL resolution, TLS or certificate handling, runtime network policy, queueing, or a native timeout as the cause of `result = -1`.

## Conclusion

There is no documented error-code mapping, native HTTP/TLS diagnostic log, or documented successful external HTTPS example in the authorized Lua source sufficient to diagnose `result = -1` further. The correct boundary is to keep the transport test isolated and the license loader fail-closed until target-host documentation or native logs are supplied by an authorized maintainer.
