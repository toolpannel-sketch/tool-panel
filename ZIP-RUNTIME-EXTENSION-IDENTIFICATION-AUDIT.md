# Authorized ZIP Runtime and Extension-Mechanism Identification Audit

**Author:** Manus AI  
**Date:** August 14, 2026  
**Scope:** Static inspection only of `/home/ubuntu/authorized-lua-audit/ALL LUA DEC 4.5 BGMI/`. No archive code was run; no native functions were probed, inferred, or reverse engineered; and no license, device-binding, authentication, or loader behavior was changed.

## Executive conclusion

The archive is most consistently identified as a **Lua runtime embedded in a UE4-based BGMI/PUBG Mobile game client, using an SLua-style host binding layer**. The evidence is the `slua` global API, `slua_GameFrontendHUD` host singleton, UE4-labelled console calls, and `import(...)` access to host-side subsystem classes. This is an identification of the exposed scripting surface—not confirmation of an exact engine or SLua version. [1] [2] [3]

The ZIP documents two **Lua-level loading mechanisms**: ordinary `require(...)` for packaged Lua modules and a host-selected `GameLua.Mod.*` / `GameLua.ExtraModule.*` selection process. Neither mechanism registers a new compiled host API, enables a new Unreal plugin, or provides a general HTTPS bridge. [4] [5]

> **No supported extension mechanism can be established from the ZIP.**
>
> **The authorized ZIP does not expose another documented networking route; host/runtime documentation or a supported bridge is required.**

Consequently, this audit does **not** provide a safe alternative ping request. A harmless `{"test":"ping"}` probe would only be justified after the host owner exposes a documented bridge that returns remote response data to Lua.

## Identification evidence

| Identification question | Static evidence | Bounded conclusion |
|---|---|---|
| **Likely scripting runtime** | `slua.isValid`, `slua.setTickFunction`, and other `slua.*` calls are used as runtime globals; Lua code accesses an `slua_GameFrontendHUD` singleton. [1] [2] | The source targets an **SLua-style embedded Lua host**. The ZIP does not name a precise SLua release. |
| **Likely engine/framework** | `FuncUtil.UE4ExecuteConsoleCommand(...)` strings and host-style calls such as `USubsystemBlueprintLibrary.GetWorldSubsystem(...)` occur in the source. [3] [6] | The host is **UE4-oriented**. The archive alone does not establish a precise UE4 point version. |
| **Likely application context** | Source identifiers include `BGMI`, `GameLua`, `BlueHole`, and game-specific HUD, lobby, map, and gameplay modules. [1] [4] | The content is structured for a BGMI/PUBG Mobile family game-client environment. This is a source-name/context identification only. |
| **Exact runtime version** | The ZIP filename contains `4.5`, but the archive contains no `.uproject`, `.uplugin`, build descriptor, or version manifest. A bundled debugger mentions multiple Lua versions for compatibility, rather than declaring the runtime’s active version. [7] | **No exact UE4, SLua, or Lua runtime version is established.** The archive filename is not version metadata. |

## Documented host-application APIs exposed to Lua

The following APIs are evidence of a pre-existing **host-to-Lua binding boundary**. They are not Lua-side facilities for adding new native code.

| Source file and function | Exposed host/application surface | What the source actually demonstrates | Does it let Lua add an HTTPS bridge? |
|---|---|---|---|
| `game_frontend_hud.lua`: `GetInstance()` (line 16), listener registration (lines 316–359) | `slua_GameFrontendHUD` singleton, UI utilities, lifecycle, webview, update, device, login, and tick event delegates. [1] | Lua can subscribe to host-declared delegates and call already-bound host methods. The `OnAddLuaLogicManagerEvent` / `OnRemoveLuaLogicManagerEvent` handlers only receive a Lua filename and validate/log it. [1] | **No.** No function in this wrapper registers a host class, native library, plugin, or new delegate. |
| `AIStateInfoSubSystem.lua`: `import(...)`, `GetMLAICppSubSystem()` (lines 145–150) | Imported host/UE classes and a world subsystem obtained through `USubsystemBlueprintLibrary`. [6] | Existing C++/Blueprint-like subsystem methods are callable only because the host has already exposed them to the Lua runtime. [6] | **No.** It consumes pre-bound APIs; it does not bind new ones. |
| `GameMainExtraModuleUtil.lua`: `CanInjectExtraModule()` (lines 24–213), `GetExtraModules()` (lines 225–255) | A host-aware check `STExtraGameplayStatics.IsDSLuaFileExists`, followed by `require("GameLua.Mod...ModConfig")` or `require("GameLua.ExtraModule...ModConfig")`. [4] | The host can select from **already packaged Lua modules** according to configuration and mode/map predicates. [4] | **No.** This is Lua module selection; it does not compile, register, or attach native code. |
| `ModuleManager.lua`: module lookup/initialization | The app’s Lua module framework resolves registered symbolic entries to packaged Lua modules. [5] | Normal in-archive module organization and lifecycle management. [5] | **No.** No plugin descriptor, binary loader, or host-binding registration contract is documented. |

## Module, plugin, and package metadata findings

The archive-wide static inventory did **not** find UE project/plugin descriptors (`.uproject`, `.uplugin`, or `*.Build.cs`) or native library artifacts (`.so`, `.dll`, `.dylib`, or `.a`). Therefore, the ZIP supplies no plugin name, compiled module, build target, engine version manifest, or installation contract from which a new host bridge could be legitimately built or enabled.

The module naming convention is Lua-package based: `GameLua.Mod.*`, `GameLua.ExtraModule.*`, `client.slua.*`, and `client.logic.*`. `GameMainExtraModuleUtil` requires a pre-existing `ModConfig` file only after a host-exposed existence query succeeds. This is meaningful evidence of a **content/module selection mechanism**, but not of a plugin-development or native-extension-installation mechanism. [4] [5]

| Candidate mechanism | Exact source evidence | Scope shown by source | Audit classification |
|---|---|---|---|
| Packaged Lua module import | `require(...)` throughout the archive; `ModuleManager` registry and `GameMainExtraModuleUtil` configuration lookups. [4] [5] | Loads Lua code already discoverable by the runtime. | **Documented, Lua-only.** |
| Host-recognized extra module selection | `STExtraGameplayStatics.IsDSLuaFileExists(Path)`; `CanInjectExtraModule`; `GetExtraModules`. [4] | Selects existing `GameLua.Mod` / `GameLua.ExtraModule` content based on config. | **Documented, Lua-content selection only.** |
| Host-class bridge consumption | `import("MLAISubSystem")`, `USubsystemBlueprintLibrary.GetWorldSubsystem`, `slua_GameFrontendHUD`. [1] [6] | Uses classes/functions that were pre-bound by the native host. | **Documented consumer-side bridge use.** |
| Debugger-only native-library attempt | `LuaPanda.tryRequireClib("libpdebug", libPath)` temporarily appends to `package.cpath`, then calls `require(libName)`. [7] | Targets a debugger hook library named `libpdebug`; the ZIP contains no matching binary or HTTP adapter. [7] | **Not evidence of a supported production extension route.** |
| Debugger socket fallback | `LuaPanda.reGetSock()` tries `lua_extension.luasocket().tcp()`, then `require("socket.core").tcp()`, then a custom debugger socket callback. [8] | Debugger communication only; it is neither an HTTPS API nor a general remote JSON contract. [8] | **Not an HTTPS bridge.** |
| Lua source compilation/reload | `loadstring(...)`, `package.searchers`, and reload helpers. [9] | Evaluates/reloads Lua chunks and locates Lua modules. | **Not native binding registration.** |

## Why the debugger references do not establish a supported HTTPS extension path

`LuaPanda.lua` contains a narrowly scoped helper that temporarily adds a local path to `package.cpath` and attempts `require("libpdebug")`. Its own call sites name only `libpdebug`; the same file labels its socket logic as debugger operation and tries `lua_extension.luasocket()` or `socket.core` only for that debugger connection. [7] [8]

This is **not** a documented production plugin interface for the target game runtime. The archive provides neither the referenced debug native binary nor a declared way to ship, sign, load, or authorize a new native library. It also contains no TLS/HTTPS wrapper, URL request contract, or remote JSON response callback associated with this code. Treating it as permission to load a different native library would exceed the evidence in the ZIP and is outside this audit’s constraints.

## Required legitimate bridge boundary

The source shows that a legitimate HTTP(S) integration would have to be supplied **by the host/runtime owner before Lua runs**. Based on the observed design, such a bridge would need to be pre-bound into the SLua environment in one of the existing host-exposed forms—for example, as an imported host class/subsystem or a host singleton method with an explicit Lua callback/event contract. Lua-side `require(...)` or `GameMainExtraModuleUtil` could then load or select a wrapper around that already-authorized capability, but neither can create the capability themselves. [1] [4] [6]

No source file demonstrates a supported authoring workflow, plugin manifest, compiled bridge module, registration macro/API, or app-approved installation path for such a capability. Therefore, the legitimate next artifact would need to come from the runtime/application owner: **documented bridge API details, a pre-exposed host subsystem, or a supported plugin/SDK extension process**. This report intentionally does not infer the implementation of any absent native method.

## Constraints and non-findings

This audit did not execute Lua code, call a host method, connect to any URL, or evaluate a candidate transport. It did not attempt to access hidden globals, inspect native memory, alter package paths, add loaders, or use the debugger helpers. It makes no claim that a missing API is impossible; it concludes only that a supported method **cannot be established from this authorized ZIP alone**.

## References

[1]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/game_frontend_hud.lua "game_frontend_hud.lua — slua_GameFrontendHUD wrapper and host delegates"
[2]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/SLuaCommonTool.lua "SLuaCommonTool.lua — slua validity checks"
[3]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/login_module.lua "login_module.lua — UE4 console-command references"
[4]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/GameMainExtraModuleUtil.lua "GameMainExtraModuleUtil.lua — extra-module discovery and configuration selection"
[5]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/ModuleManager.lua "ModuleManager.lua — packaged Lua module framework"
[6]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/AIStateInfoSubSystem.lua "AIStateInfoSubSystem.lua — import-based host subsystem consumption"
[7]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/LuaPanda.lua "LuaPanda.lua — debugger-specific libpdebug loader and Lua-version compatibility checks"
[8]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/LuaPanda.lua "LuaPanda.lua — debugger socket acquisition fallbacks"
[9]: file:///home/ubuntu/authorized-lua-audit/ALL%20LUA%20DEC%204.5%20BGMI/reload.lua "reload.lua — package.searchers-based Lua module reload helper"
