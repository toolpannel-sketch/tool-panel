# Authorized ZIP: Remote-Communication Differential Investigation

**Author:** Manus AI  
**Scope:** Static analysis only of the user-authorized archive at `/home/ubuntu/authorized-lua-audit/ALL LUA DEC 4.5 BGMI/`. No Lua was executed. No transport probe, credential, endpoint, license, device-binding, authentication, or application behavior was changed.

## Question and method

This investigation asks a narrow question: whether the authorized ZIP itself documents an existing remote-communication path or host-supplied configuration that could explain a separately working client. It does **not** infer native APIs, repurpose game credentials, or treat a source-level success branch as proof that the target Android runtime successfully delivered an HTTPS response.

The archive contains **21,112 Lua files**. A recursive literal scan identified **52 distinct `http://`/`https://` strings across 42 Lua files**. The review then traced concrete outbound-style calls, URL constructors, dynamic headers, file/asset download callbacks, remote-loading paths, and success-state handlers.

## Executive conclusion

The archive contains several legitimate, game-owned HTTP consumers, but **every documented general request route converges on `slua_GameFrontendHUD:GetHttpWrapper()` through `http_manager`**. The same native bridge underlies ordinary JSON GET/POST, server-list downloads, CDN-file downloads, and image downloads.[1]

The ZIP does show that its original game environment was designed to handle successful requests: it contains callbacks that parse JSON, update UI/game state, save server-list data, save CDN bytes, and decode downloaded textures. Those branches are **implementation intent**, not a captured successful response from the target Android dynamic-execution environment. The authorized source includes neither runtime logs nor a documented successful HTTPS result for this target.

Therefore, the ZIP alone provides **no separate, documented communication path or externally configurable generic endpoint that can reproduce the reported working client**. The claimed client may have used an environment difference, a host-supported configuration, or game-issued service data that is not included in this Lua archive; that cannot be established statically from this ZIP.

## Endpoint and URL inventory

| Category | Exact source evidence | Static finding | JSON-capable generic client? |
|---|---|---|---|
| Game service domains | `serverlist_downloader.lua`, `cdn_downloader.lua`, `logic_community.lua`, `LudoConst.lua` | Most non-public service roots are obtained with `FuncUtil.GetDomainByID(<numeric id>)`, sometimes combined with `FuncUtil.GetKeywordByID`. Their concrete values are not supplied by the Lua source. [2] [3] [4] [5] | No. The caller still uses `http_manager` / `HttpWrapper`. |
| Community endpoints | `logic_community.lua:GetVersionUrl()` and its `Post` call sites | The release/CE/test domain is selected using host/game environment state, and request headers include game-issued values such as `openid` and a web-view ticket. [4] | No. It is a game-owned endpoint contract on the same bridge. |
| Ludo/web-game service endpoints | `LudoConst.lua`, `LudoUtils.lua` | Per-game server domains are selected from environment-specific `GetDomainByID` entries. The code adds game-issued `sTicket`, `openid`, and `uid` values to requests. [5] [6] | No. It is an application-specific game service contract. |
| Server-list files | `serverlist_downloader.lua` | Builds two text-file URLs from host-resolved domain/keyword values; on `success` it writes returned byte arrays to local files. [2] | No distinct transport; it is `http_manager:Get`. |
| CDN files / PAK assets | `cdn_downloader.lua` | Builds a region/platform/release CDN directory, downloads bytes through `http_manager:Get`, writes them to a local file, and may mount a PAK through a host API. [3] | No distinct transport and no source evidence of downloaded Lua being executed. |
| Image assets | `image_download_mgr.lua` | Uses `http_manager:ImageDownloadRequest`; response bytes are decoded into a texture and the public success callback receives `(texture, url)`. [7] | No. This is an image-content contract, not a documented JSON loader. |
| Public web links | Numerous UI and policy files; `logic_webview_sdk.lua` | Privacy, policy, community, and sharing links are passed to the host web-view/open-URL surface. The documented wrapper opens a URL; it does not return page bytes to Lua. [8] | No. |
| Local MCP examples | `MCPServerExample.lua`, `CreativeMCPUtility.lua` | The shown `127.0.0.1:10086` URLs are printed example calls to a local MCP server exposed by the game tooling. They do not document an outbound arbitrary HTTP client. [9] | No. |

The literal scan also found public policy pages, social-avatar image URLs, CDN image URLs, and placeholder URLs. These are data or web-view targets, not alternate client APIs. Numeric dotted strings in the archive were not accepted as an alternative path because the static review did not find a hard-coded public IP used by a documented generic outbound JSON request.

## Exact documented transport comparison

| Source pattern | URL source and scheme | Headers / body | Timeout / priority / queue | Callback and success behavior | Differential result |
|---|---|---|---|---|---|
| `http_manager:Get` | Caller supplies URL; `RequestForLua(url, "GET", ...)` | Caller-supplied header table and string content | Defaults priority `0`, queue `0`; optional Lua timer | `callback(success, data, content, result)` via `OnResponseEvent` | Canonical bridge. [1] |
| `http_manager:Post` | Caller supplies URL; `RequestForLua(url, "POST", ...)` | Caller-supplied headers and string body | Same defaults and optional timer | `callback(success, data, content, result)` | Canonical bridge. [1] |
| `http_manager:SimplePost` | Caller supplies URL | Content only | Native arguments fixed at `0, 0` | No Lua callback exposed by this wrapper | Same `HttpWrapper`; not usable for receiving validation JSON. [1] |
| `http_manager:ImageDownloadRequest` | Caller supplies image URL; native method is `ImageDownloadRequestForLua(..., "GET", ...)` | Caller-supplied headers and empty/string content | Priority only; no queue parameter in documented call | `OnImageDownloadResponseEvent` is forwarded as data/content, then image manager decodes bytes to texture | A different **content mode**, not a different bridge or documented JSON API. [1] [7] |
| `serverlist_downloader:DownloadServerList` | Host-resolved domain plus known server-list paths | `{}`, `""` | `timeout=nil`, priority `3`, queue `0` | `success` and `content` cause `SaveArrayToFile`, then completion callback | Evidence of an intended successful file-download branch on the same GET route. [2] |
| `cdn_downloader.download` | Host-resolved CDN directory plus caller path | `{}`, `""` | `timeout=nil`, priority `30`, queue `0` | `success` and `content` cause `SaveArrayToFile`; later code may mount a PAK | Intended asset/file flow only; no loader chain from downloaded bytes to Lua execution appears in the archive. [3] |
| `logic_community` JSON POST | Game-owned environment-selected service URL | Game-issued `openid`, web-view `ticket`, region, language, JSON headers, JSON body | Wrapper defaults used | Parses `data` with `json.decode`, updates caches/events only after response checks | Same POST route with privileged game-service inputs; not a reusable custom endpoint configuration. [4] |
| `LudoUtils` JSON GET/POST | Host-resolved Ludo domain and game type | JSON/gzip headers; game-issued ticket / identity in URL parameters | Wrapper defaults used | Parses JSON; resolves/rejects `Promise` based on `success` and body fields | Same route, designed for game services, with no target-runtime success evidence. [6] |

## Authentication, token, cookie, and certificate findings

The source contains normal game-session concepts—`openid`, web-view tickets, account regions, language, JWT-related game handlers, and social/community state—but the relevant HTTP flows obtain them from host-provided interfaces such as `BusinessHelper.GetOpenId()` and `Client.GetWebViewTicket(NetInterface)`.[4] [6] These values are part of the game's own session model. They are neither a documented custom-license authentication API nor an external configuration mechanism.

No source-defined generic cookie jar, certificate-pinning control, TLS toggle, proxy configuration, or caller-provided endpoint registry was found for `http_manager`. The documented request methods accept a URL, headers, content, optional timeout, priority, and queue only; they do not expose certificate or transport-policy options.[1]

`LudoUtils.getTicket()` contains an **editor-only fallback string** behind `IsEditor`. Its literal value is deliberately not reproduced in this report. It is not evidence of a usable Android-device credential and is not a safe basis for an unrelated communication test.[6]

## Remote data, update, and module-loading review

The source supports remote **data and assets**, not remote Lua code loading:

| Mechanism | What source documents | Why it does not explain an arbitrary custom JSON client |
|---|---|---|
| Server-list downloader | Retrieves text bytes over `http_manager:Get` and saves them locally. [2] | Still relies on the already-tested native wrapper and has no alternate transport. |
| CDN downloader | Retrieves CDN bytes, writes a file, and may ask the host to mount a PAK. [3] | The archive does not show a downloaded file being passed to `load`, `loadfile`, `dofile`, or `package.loadlib`. PAK mounting is a host asset operation, not a documented Lua HTTPS extension installer. |
| Image downloader | Retrieves bytes through `ImageDownloadRequestForLua`, converts them into a texture, and invokes a texture callback. [7] | The contract is image decoding/caching; it does not document response text or JSON delivery to arbitrary callers. |
| Module manager / `require` | Selects and loads packaged Lua modules, including the registered `http_manager` module. [10] | No `require("http://...")`, remote module resolver, or documented downloaded-module execution path was found. |
| Web view and sharing | Opens web pages or invokes host sharing/social interfaces. [8] | No returned remote resource body is documented for Lua consumption. |
| Game protocol services | Many modules call game-provided network/protocol managers for first-party features. | They are application protocol surfaces, not a documented caller-selected HTTP/JSON client. |

## Known-success code paths versus actual evidence

The source includes success branches that would change game state *if* the native host delivers a response: community calls cache membership/status and emit events; Ludo calls resolve promises after JSON parsing; server-list and CDN modules write received bytes; and the image manager creates textures from received bytes.[2] [3] [4] [6] [7]

> These branches show expected application behavior, not an observed successful response from this Android dynamic-execution environment. The ZIP contains no captured `success=true` HTTPS response for the target runtime, and the earlier documented probes against the separate harmless endpoint returned no bytes.

## Bounded answer to the claimed working client

The ZIP can explain how an **official game build/environment** is intended to communicate: its host provides game-selected domains, session-derived headers/tickets, and the `HttpWrapper` transport used by first-party features. It cannot establish how another client achieved custom remote login, because the relevant runtime configuration, native implementation, transport policy, and any successful runtime evidence are not included in the authorized Lua source.

**No harmless test is proposed yet.** The only concrete download/JSON flows found are still routed through the already-tested `HttpWrapper`, or require game-issued first-party session context, or return non-JSON assets. Testing them with arbitrary URLs would not be a documented route for a custom license service and could create unintended requests to game-owned services.

> **Conclusion:** The authorized ZIP alone cannot reproduce the claimed working client. It documents game-owned remote communication through the same `HttpWrapper` bridge, but no independent, documented, externally configurable custom-login transport path.

## References

[1]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/http_manager.lua "http_manager.lua — RequestForLua, SimplePostForLua, and ImageDownloadRequestForLua bridge"
[2]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/serverlist_downloader.lua "serverlist_downloader.lua — host-configured server-list GET flow"
[3]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/cdn_downloader.lua "cdn_downloader.lua — CDN file download and host PAK mount flow"
[4]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/logic_community.lua "logic_community.lua — game session headers and JSON responses"
[5]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/LudoConst.lua "LudoConst.lua — host-resolved web-game service domain mapping"
[6]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/LudoUtils.lua "LudoUtils.lua — game-owned JSON GET/POST helpers"
[7]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/image_download_mgr.lua "image_download_mgr.lua — texture-specific image download flow"
[8]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/logic_webview_sdk.lua "logic_webview_sdk.lua — host web-view URL opening wrapper"
[9]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/MCPServerExample.lua "MCPServerExample.lua — local MCP server example URLs"
[10]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/ModuleManager.lua "ModuleManager.lua — packaged Lua module resolution"
