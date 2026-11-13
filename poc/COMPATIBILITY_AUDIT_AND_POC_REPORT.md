# Compatibility Audit and Lifecycle POC

## Scope

This report records the approved read-only audit of the two pinned Lua references and the isolated lifecycle proof of concept. The two pinned references were not modified, overwritten, or deleted. No production loader, HTTP path, transport, server connection, canonical validation, host device identity, key/status format, Telegram, Announcement, or Maintenance implementation was imported into the POC.

## Audited references

| Reference | Observed execution shape | Compatibility implication |
|---|---|---|
| `BRPlayerCharacterBase-Merged.lua` | Canonical validation callback reaches `gate_server_maintenance`, then calls the deferred `run_authorized_main` hand-off. The changing Main Lua is placed below that function boundary. | Good fit for callback-driven authorization, but match re-entry must be provided by a lifecycle hook; the one-time validation callback alone does not create match re-entry. |
| `FailClose-NoRestriction.lua` | Original UE4 class/module body remains top-level, lifecycle methods such as `ReceiveBeginPlay` remain registered on the class, and the file preserves a final module return. Its protected feature initialization is deferred through a stored initializer. | The module body and return contract cannot be moved blindly inside a normal function. A universal adapter must keep module registration separate from authorized feature activation. |

## Callback and hand-off findings

Both references use an asynchronous validation callback and call the protected Main Lua only from the successful authorization branch after maintenance gating. The current key-entry session guard prevents repeated key-entry UI launches during a continuous host session, but it is not itself a complete match lifecycle coordinator. The POC therefore models authorization state independently from match transitions.

The Merged-style hand-off is represented by `main.initialize(session_id)` followed by `main.on_match_start(session_id, match_number)`. The Module/Fallback-style hand-off is represented by `main.register(session_id)` followed by the same match-start hook. This proves that both styles can share one lifecycle coordinator without concatenating their module bodies.

## Lifecycle and cleanup findings

The audit found that the substantial module-style Main Lua contains UE4 lifecycle registration, timers, widgets, event handlers, and deferred initialization. A production universal version must add idempotent initialization and cleanup around those resources. The POC models this with an optional `on_match_end` cleanup hook and retains authorization across match boundaries.

The POC does not claim that arbitrary future Main Lua can be lifecycle-safe without following an adapter contract. Each Main Lua must expose the appropriate initialize/register entry and a match-start hook; any timers, widgets, and event registrations created by that Main Lua must be cleaned up or invalidated in its match-end hook.

## POC behavior

The isolated harness executes the following for both modes:

1. Application start invokes the injected validation exactly once.
2. Successful authorization invokes the appropriate merged or module hand-off.
3. Match 1, Match 2, and Match 3 each invoke Main Lua again.
4. No additional validation occurs during the three matches.
5. Match cleanup runs for all three matches.
6. Application restart clears authorization state.
7. A new application start invokes validation again.

## POC files

- `poc/LuaLicense-Universal-Lifecycle-POC.lua`
- `poc/run_universal_lifecycle_poc.lua`
- `poc/COMPATIBILITY_AUDIT_AND_POC_REPORT.md`

## Boundary verification

The POC contains no production endpoint, `RequestForLua`, HTTP wrapper, transport call, server binding call, host device-ID resolver, key-file parser, Telegram flow, Announcement flow, or Maintenance flow. It is not wired into the application and cannot change production behavior by itself.

## Acceptance result

The POC is a **PASS for the modeled lifecycle contract** in both merged-style and module-style modes. It proves the coordinator behavior, not yet the Android host's real match callback names or the arbitrary Main Lua's resource cleanup. Those require the next explicitly approved integration audit/adapter step before a final universal loader is created.
