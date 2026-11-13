# Complete Single-File Universal Lua

## Scope

`LuaLicense-Universal-Complete.lua` is a new, separate Universal Lua file. The two pinned references remain unchanged and are not overwritten, deleted, or imported at runtime.

The file preserves the copied canonical validation flow in the new file: key input, existing API URL, `RequestForLua`, response handling, host-first device identity, device binding/status decisions, Announcement, and Server Maintenance handling. The lifecycle bridge is connected only after the existing successful authorization path.

## Exact one insertion point

Inside `LuaLicense-Universal-Complete.lua`, search for this unique marker:

```lua
MAIN LUA — PASTE FULL CODE HERE
```

Paste the **complete Main Lua exactly once** between these two comments:

```lua
-- BEGIN MAIN LUA
-- [PASTE YOUR COMPLETE MAIN LUA HERE]
-- END MAIN LUA
```

Do not paste any part of the Main Lua anywhere else. Do not create another callback file, module file, `loadfile()` call, or second copy.

## Final usage

1. Open `LuaLicense-Universal-Complete.lua`.
2. Find the one `MAIN LUA — PASTE FULL CODE HERE` marker.
3. Replace the placeholder between `BEGIN MAIN LUA` and `END MAIN LUA` with the complete Main Lua.
4. Save the same file.
5. Run that single file through the existing host environment.

The canonical key-entry and validation flow remains in the Universal file. The Main Lua is reached only from the existing authorized success path.

## Lifecycle contract

The Universal file maintains runtime-only authorization state. The expected behavior is:

| Event | Behavior |
|---|---|
| Application start | Existing key input and canonical validation execute once. |
| Valid response | Authorization becomes active and the pasted Main Lua runs. |
| Match 1 | Main Lua runs for Match 1. |
| Match 2 | Main Lua re-enters without another license validation. |
| Match 3 | Main Lua re-enters without another license validation. |
| Duplicate callback | Same match number is ignored after its first dispatch. |
| Match end | Registered match cleanup handlers run once. |
| Application restart | Runtime authorization state is reset; a fresh validation is required. |
| Invalid, expired, revoked, device-mismatch, or device-limit response | Main Lua does not execute. |

Match-specific timers, widgets, event handles, actor references, and cached match state should be created by the pasted Main Lua through its normal existing code and released through the Universal cleanup boundary when applicable. The Universal bridge does not invent a second copy of the Main Lua.

## Merged-style and module/fallback compatibility

The canonical validation and authorization path is preserved in the new file. The pasted Main Lua executes inside the authorized runner, so deferred Merged-style code can run after validation. Module/Fallback-style code can retain its class registration and module-return statements inside the one pasted block; the block is not split into another file or manually registered by the user.

If a specific host requires a host-defined match-start or match-end callback, the existing host callback must call the exported lifecycle hooks already present in the Universal file. That is host lifecycle wiring, not a second Main Lua insertion point.

## Protected boundaries

The following are preserved and are not rewritten, replaced, or refactored: HTTP, HTTP watchers, transport, server connection, API request/response shape, canonical validation semantics, host-first device identity, device binding policy, key format, status format, Telegram mapping, Announcement behavior, Server Maintenance behavior, authentication flow, and the two old reference files.

## Verification

The separate regression checks verify Lua syntax, exactly one Main Lua insertion marker, canonical validation markers, lifecycle bridge markers, negative-path guards, and byte-for-byte hashes of the two pinned references. The deterministic lifecycle harness verifies one validation per runtime, Match 1/2/3 re-entry, duplicate callback guards, fail-closed invalid validation, and fresh validation after application restart.

## Compiler-boundary correction for top-level-return Main Lua

If the pasted Main Lua ends with a module/class return such as `return require("combine_class").DeclareFeature(...)`, do not place `fetch_active_announcement(validated_key)` or any Universal wrapper line immediately after that return inside the pasted block. Lua parses the entire enclosing `run_authorized_main_once` function as one scope; the following wrapper statement leaves that enclosing function without its required closing `end`. This produces the reported error at the wrapper line: `'end' expected (to close 'function' at line 889) near 'fetch_active_announcement'`.

The corrected artifact `LuaLicense-Universal-Complete-ChunkFix.lua` fixes this only on the integration side. It stores the complete pasted Main Lua as one source chunk, compiles and executes that chunk after authorization, and invokes the existing Announcement hand-off only after the Main Lua chunk returns. The user Main Lua remains unchanged. In the corrected file, paste only the Main Lua body; do not paste `fetch_active_announcement`, `return LICENSE_SESSION`, or any Universal lifecycle code.

The uploaded reproduction confirmed that the original user Main Lua body compiles by itself once the wrapper-only `fetch_active_announcement(validated_key)` line is excluded. The corrected complete file also passes `luac5.3 -p` and the deterministic Merged/Module lifecycle regressions.
