# LuaLicense Folder Capability Probe — Android Test Protocol

**Scope:** This is a separate one-time Android capability test. It does not replace, import, or alter `BRPlayerCharacterBase-Merged.lua`. It must never be pasted into the production loader or the main Lua.

## What the probe uses

The probe uses only the exact full-path writer shape statically observed in V3:

```lua
Client.WriteFileAtPath(fullPath, contents)
```

It does not assume any return-value meaning, parent-directory behavior, directory-query API, or Android permission. It writes only one fixed marker and then (only after reading back the same marker) overwrites that single probe file with five allowlisted, non-secret results.

| Item | Exact value |
|---|---|
| Fixed target directory | `/storage/emulated/0/Android/data/com.pubg.imobile/lua-license` |
| Probe-only file | `.lua_license_folder_probe` |
| Network/API calls | None |
| License/device/status file access | None |
| Permitted persisted content | Five fixed capability labels only |

## Mandatory Android test conditions

Run `LuaLicenseFolderCapabilityProbe.lua` **by itself** in the same Android package/runtime as the production loader, but on a clean test profile/device where the target `lua-license` directory is absent before execution. Do **not** remove an active user's live folder, key file, device file, diagnostics, or any production state to create this condition.

The probe must not be merged with the loader and must not be followed by the production/main Lua in the same execution. After it ends, capture either the visible fixed print report or the content of `.lua_license_folder_probe` if that file was created. Do not add raw stack traces, function return values, filesystem errors, paths, or user values to the result report.

## Result format

The report contains exactly these keys and fixed-value categories:

```text
path_available=true
directory_exists=confirmed_by_existing_probe_file | not_proven_no_directory_query
create_supported=available | unavailable
create_result=call_completed | call_error | not_attempted
verify_result=marker_readable | marker_not_readable | not_attempted
```

`directory_exists=not_proven_no_directory_query` is deliberate. V3 did not expose a proven direct directory-existence function, and the probe must not invent one. An existing probe file is the only indirect existence proof it reports.

## Decision matrix

| Android observation on a clean absent-folder test | Evidence-bounded conclusion | Next action |
|---|---|---|
| `create_supported=unavailable` | This runtime does not expose the observed V3 writer under the `Client` global. | Stop; provide the report. No workaround or production change. |
| `create_result=call_error` | The observed writer is callable but rejected this exact path/call in this runtime. | Stop; provide the fixed labels only. No workaround or production change. |
| `verify_result=marker_not_readable` | A successful Lua call alone does not prove a writable folder or parent creation. | Stop; provide the fixed labels only. No workaround or production change. |
| Clean test is confirmed folder-absent before run; `verify_result=marker_readable` after run | Strong runtime evidence that `Client.WriteFileAtPath(fullPath, contents)` can make/read the exact target probe path in this host. The result itself still does not establish a general directory-query API. | Request separate approval before designing any production folder-ensure helper. |

## Future production boundary

Even a positive probe result does not authorize a production change. If separately approved after Android evidence, the safest future helper would remain immediately after `KEY_DIR` and before the first `write_status("LOADER_STARTED")`. It must use the exact lowercase path, accept an existing folder without touching files, remain fail-closed on unsuccessful verification, and preserve every existing validation, device-binding, Maintenance, Announcement, Telegram, and Main Lua path.
