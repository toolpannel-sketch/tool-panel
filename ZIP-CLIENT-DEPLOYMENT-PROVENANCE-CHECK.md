# Client-Deployment Provenance Check

**Author:** Manus AI  
**Scope:** Static inspection of `/home/ubuntu/authorized-lua-audit/ALL LUA DEC 4.5 BGMI/` only.  
**Excluded:** Runtime execution, probes, new requests, reverse engineering, hooks, injection, native implementation analysis, and any license-system change.

## Bounded conclusion

The archive provides credible evidence that the **same packaged Lua source can be hosted differently across two client deployments**, because key services and configuration values are supplied by host-bound objects whose implementations and values are not included in the ZIP. The most relevant external dependency for the observed `HttpWrapper` failure is the native object behind `slua_GameFrontendHUD:GetHttpWrapper()`; the ZIP declares Lua-side usage, not the native request implementation or its deployment configuration.[1]

However, the source cannot identify which missing external difference exists on either device. It does not contain the native `HttpWrapper` implementation, Android packaging/permission data, TLS/network policy, a native error-code map for `result=-1`, or the host-provided configuration tables. Therefore, it cannot prove that any particular flag, region, ticket, or module caused the working client’s result.

> **Conclusion:** The ZIP identifies several host-side variables that could make two deployments behave differently, but it does not identify the missing external difference. A lawful comparison of the host artifacts listed below is required; no additional Lua-side request path is established.

## Evidence of host-supplied behavior and configuration

| Source evidence | Host-supplied element outside the ZIP | What can vary between deployments | Relevance to the observed `HttpWrapper` failure |
|---|---|---|---|
| `http_manager.lua` obtains the wrapper from `slua_GameFrontendHUD` and delegates GET/POST through `RequestForLua`; the Lua callback receives the host-returned outcome.[1] | The `slua_GameFrontendHUD` binding and `HttpWrapper` native implementation. | Native library build, binding registration, URL policy, callback delivery, TLS/DNS handling, or availability. | **Directly relevant.** The ZIP has no implementation or diagnostic map to distinguish these possibilities. |
| `game_frontend_hud.lua` exposes host objects such as `GameFrontendHUD`, `Client`, `BusinessHelper`, and the HTTP wrapper to Lua.[2] | The game client’s pre-bound UE/SLua host services. | Different client build or runtime can expose the same method name with different native behavior. | **Directly relevant** as the boundary containing `HttpWrapper`; no native semantics are present in Lua. |
| `FuncUtil.GetDomainByID(...)` and `FuncUtil.GetKeywordByID(...)` are used to construct first-party URLs, while the resolver implementation/value table is not supplied as a Lua definition in the archive.[3] | Runtime domain/keyword mapping. | Region, environment, service-domain, or campaign-link resolution. | **Indirect.** It demonstrates host-resolved configuration, but does not provide a custom endpoint setting or an alternate transport. |
| `HDmpveRemote.HDmpveRemoteConfigGet*` reads values such as `HTTPDNS` and `HTTPDNSServerIP`.[4] | Host remote-config provider and its active configuration snapshot. | Feature flags and selected connection route configuration. | **Limited.** The documented `HTTPDNS` branch changes `Client.ConnectToURL` for game-session connection, not `HttpWrapper:RequestForLua`; the source does not show it configuring the wrapper path. |
| `Client.GetPublishRegion`, `Client.IsJaguar`, `Client.IsDevelopment`, platform/language methods, and `BusinessHelper.GetIMSDKEnv` gate behavior in Lua.[5] [6] | Build channel, publication region, device platform, environment, and SDK state. | Code branches, domains, UX, optional module selection, and session behavior. | **Contextual only.** These can prove the runtime environment differs, but source does not connect them to a wrapper success or failure. |
| `NetUtil.ConnectToURL` chooses direct/DNS-proxy game connection and invokes `Client.ConnectToURL(NetInterface, ip, timeout)`; it then uses the game packet interface.[4] | Game-session connector, `NetInterface`, and DNS proxy implementation. | Game server endpoint and session transport setup. | **Not an HTTP/JSON substitute.** The shown flow is a game-session connection path with no generic response-body callback. |
| `GameMainExtraModuleUtil` tests package-side Lua existence with `STExtraGameplayStatics.IsDSLuaFileExists`, then conditionally loads `GameLua.{Mod|ExtraModule}.<Name>.ModConfig` based on mode/map/build rules.[7] | Mounted game Lua resources, host file-existence service, and runtime-supplied mode/map inputs. | Optional gameplay module presence and selection order. | **Potential deployment difference, not a bridge.** It does not register native APIs or document a network extension mechanism. |
| Puffer/updater code mounts resources through `Client.MountPakFile`, checks package resources, and branches for cloud-version behavior.[8] | Installed/mounted PAK or on-demand resource set, cloud build status, and native mount behavior. | Resource availability, optional content, and module assets. | **Potential deployment difference.** No evidence shows a mounted resource adding a generic Lua HTTPS API. |

## Package and load-order boundary

The archive contains Lua-side module-selection logic, but it does not give Lua authority to add a native bridge. `GameMainExtraModuleUtil.GetExtraModules` selects from `GameLua.ExtraModule.ExtraModuleConfig` according to host-provided mode/map context, verifies the selected module path through `STExtraGameplayStatics.IsDSLuaFileExists`, and loads the selected module configuration through Lua `require`.[7] This establishes that two clients can have different **mounted optional Lua/module resources** or receive different game-mode inputs.

It does **not** establish that a client can load a new native networking library. The prior identification audit found no packaged plugin descriptor, compiled bridge artifact, or sanctioned native-registration mechanism. The static loader scan also found no documented `loadfile`, `dofile`, or `package.loadlib` route that would transform an external device file into an authorized native HTTPS bridge. Package differences remain a provenance lead only, not a permitted solution.[7] [8]

## What does *not* explain the custom ping from source alone

Several archive flows communicate with game-owned services, download assets, or manage first-party sessions. Their existence does not establish that an arbitrary custom endpoint can be reached differently.

| Candidate difference | Source-bounded assessment |
|---|---|
| Game login/session ticket, cookie, or account state | Some first-party flows use host-issued session context, but the harmless custom ping is intentionally unauthenticated. The ZIP does not show a game ticket being required for `HttpWrapper:RequestForLua` to deliver a response body. |
| `HTTPDNS` / `HTTPDNSServerIP` | These values select the `Client.ConnectToURL` game-session branch in `client_entry.lua`; the ZIP does not show them being passed into `HttpWrapper`.[4] |
| Extra module or PAK selection | The source can select or mount game content, but no selected module is documented as registering a generic HTTPS transport.[7] [8] |
| Web view or image downloader | These are distinct host services with different output contracts (UI navigation or texture completion), not documented arbitrary JSON response channels. They do not replace `HttpWrapper` for a custom API. [2] |
| Publication region, platform, or cloud-version branch | These values can change first-party behavior, but no source evidence ties them to a successful generic `HttpWrapper` response. [5] [6] |

## Exact host-side artifacts to compare

Because the archive cannot choose among the external possibilities, the following artifacts are the smallest useful **comparison set** between the reportedly working client and the affected device. They should be compared only where the user is authorized to access them; this report does not ask for extraction, alteration, or bypass of protected components.

| Priority | Artifact to compare | Why the ZIP identifies it as relevant | Minimum comparison fields |
|---:|---|---|---|
| 1 | **Client build identity and native SLua host identity** | Lua depends on pre-bound `slua_GameFrontendHUD`, `Client`, and `HttpWrapper`, whose implementations are absent.[1] [2] | App package name, version name/code, ABI, build/channel identifier, and the documented SLua/host binding version if exposed by the client owner. |
| 2 | **Host `HttpWrapper` configuration and authorized diagnostics** | The callback outcome is delivered by the host wrapper, and Lua contains no mapping for `result=-1`.[1] | Whether the wrapper is enabled, its documented URL/TLS/proxy policy, and any owner-provided native diagnostic for the same request class. Do not collect secrets or modify the wrapper. |
| 3 | **Network-capability packaging and device network policy** | This information is absent from the Lua ZIP but can determine whether a native Android HTTP implementation may create/deliver a response. | Manifest network capability, app network-security policy, certificate/trust policy, proxy/VPN state, and endpoint reachability as supplied by the app/runtime owner. The ZIP alone cannot verify any of these. |
| 4 | **Active host remote-configuration snapshot** | `HDmpveRemote` supplies values not stored in the archive; relevant visible keys include `HTTPDNS` and `HTTPDNSServerIP` for the game-session connector.[4] | Build/channel/region, relevant feature flags, and the two named connection keys. Treat these as contextual unless host documentation links them to `HttpWrapper`. |
| 5 | **Host domain/keyword mapping snapshot** | Lua calls `FuncUtil.GetDomainByID` and `GetKeywordByID`, yet the resolver values are not defined in the ZIP.[3] | Mapping values for the IDs used by the same first-party code paths, plus region/environment selection. This validates deployment configuration, not custom endpoint support. |
| 6 | **Mounted resource/module manifest and selection inputs** | Optional modules are selected from mounted resources using map/mode inputs and a native file-existence check.[7] [8] | Mounted PAK/on-demand resource list and hashes; `ExtraModuleConfig`/`ModConfig` versions; selected `ModID`, `ModType`, and `MapType`; cloud-version state. |
| 7 | **Host-exposed method inventory** | The Lua source calls many bound services whose native implementations are out of scope.[2] | A runtime-owner-provided list of supported Lua bindings and documented method contracts, specifically confirmation of any official transport bridge besides `HttpWrapper`. |

## Next boundary

No new ping probe is proposed in this provenance check. The source identifies the **native `HttpWrapper` implementation and deployment configuration** as the decisive missing evidence, while showing that game-session DNS settings, first-party tickets, optional modules, and mounted PAKs are only contextual differences unless the host owner documents a connection to wrapper behavior.

Until one of the comparison artifacts provides a documented discrepancy, the correct conclusion remains: the ZIP alone cannot reproduce or explain the claimed working client.

## References

[1]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/http_manager.lua "Authorized HTTP manager bridge contract"
[2]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/game_frontend_hud.lua "Authorized host-front-end Lua wrapper"
[3]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/logic_community.lua "Host-resolved community URL use"
[4]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/client_entry.lua "Game-session connection and HTTPDNS configuration use"
[5]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/PublishRegionMacros.lua "Host-provided publish-region checks"
[6]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/LudoUtils.lua "Host environment and first-party session helper use"
[7]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/GameMainExtraModuleUtil.lua "Optional module selection and host file-existence check"
[8]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/logic_puffer_downloader.lua "Host-mounted resource and download flow"
