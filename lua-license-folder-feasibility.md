# LuaLicense Automatic Folder Creation — Read-Only Feasibility Report

**Scope:** This report evaluates only the proposed first-run directory ensure step. Emoji work remains paused. No production Lua, API route, validation/rebind rule, device-binding behavior, Maintenance, Announcement, Telegram flow, Main Lua, panel, OBB, or asset was changed.

## Executive conclusion

The desired behavior is feasible **only if the Android UE4 Lua host exposes a proven directory-create/ensure API** for the loader’s writable path. The current production loader already has safe file-read and file-write behavior, but it does **not** create its parent folder itself. No exact directory-creation API can be proven from the supplied material, so a Lua-only implementation must **not** be written yet by guessing `mkdir`, `os.execute`, `lfs`, or a new helper.

> **Current decision:** Do not change `BRPlayerCharacterBase-Merged.lua` until the matching B3 Lua package or a non-secret host capability report proves a directory-create contract that succeeds on the Android runtime.

## 1. Current writable license path

The active loader defines its storage root at line 10:

```lua
local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
```

The actual current path is lowercase `lua-license`, not the display name `LuaLicense`. Android/Linux paths are case-sensitive, so the future ensure step must use **this exact existing string**. Renaming or changing its case would split existing users’ saved state and is outside the approved scope.

## 2. Existing filesystem evidence

| Evidence source | Proven behavior | What it does **not** prove |
|---|---|---|
| Active `BRPlayerCharacterBase-Merged.lua`, lines 66–80 | `read_file(path)` uses `io.open(path, "rb")`; `write_file(path, data)` uses `io.open(path, "wb")`, returns `false, err` on failure, and otherwise writes/close the file. | It does not create a parent directory. |
| Active loader, lines 38–39 | The source explicitly states: “The existing folder must already exist; no directory-creation API is used here.” | It confirms the current limitation. |
| V3 source `file_util.lua` | Existing project helper imports `SavedFileUtil` and calls `SavedFileUtil.FindFiles(targetDir, extension, recursive)`. | It exposes discovery only; no `CreateDirectory`, `MakeDirectory`, `mkdir`, or exists/ensure method was found in that helper. |
| Current non-secret runtime capability report | No visible global `SavedFileUtil`, `FileUtil`, filesystem namespace, or directory-create function was recorded. | The report is one-level limited and cannot prove that no host API exists elsewhere. |
| B3 package availability | No archive/file named `B3` was available in the supplied upload/workspace search. | The requested B3-specific API inspection is therefore incomplete; absence of the file is not evidence that its host API does not exist. |

The package-wide V3 text scan was intentionally stopped after it became slow, rather than executing or extracting untrusted content. Targeted inspection of the known `file_util.lua` is the only existing helper evidence available. It is insufficient to invent a folder-create call.

## 3. Current persistence files in this folder

| Path under `KEY_DIR` | Current use | Creation/write point |
|---|---|---|
| `key.json` | Canonical saved key format: JSON object with string `key`. | Written only after the unchanged server-valid branch via `save_validated_key`; existing `key.txt`, `key.in`, `key.ini` are read-only legacy fallbacks. |
| `.device_id` | Fallback device identity only when a runtime persistent-ID provider is unavailable. | Written by `get_device_id`; a write failure stops with a non-secret path/error message. |
| `.license_status` | Non-secret status line. | Best-effort `write_status`, starting with `LOADER_STARTED`; current behavior silently skips if opening fails. |
| `.telegram_redirect_diagnostic` | Approved non-secret redirect stage markers. | Written only by the existing diagnostic helper. |
| `.saved_key_diagnostic` | Approved non-secret input-source/length/status trace. | Written only by the existing diagnostic helper. |
| `.announcement_seen` | Announcement display-once marker. | Written only after the existing post-validation Announcement presentation path. |
| `.runtime_globals` | Non-secret runtime capability report. | Written only when that existing report helper is used. |
| `.downloader_probe` | Disabled-by-default one-time host probe. | Written only when `ENABLE_DOWNLOADER_PROBE` is explicitly enabled. |

No individual file should be deleted, reset, renamed, or recreated merely because the directory ensure step runs.

## 4. Safe insertion point

If and only if a documented host function is proven, the directory ensure belongs **immediately after `KEY_DIR` is defined and before the first `pcall(write_status, "LOADER_STARTED")`**. This means it occurs before every existing `io.open` attempt, device fallback generation, key read/write, status write, or diagnostic write.

The future helper must be narrow:

1. Check whether the exact `KEY_DIR` already exists.
2. Create only that directory when it is absent.
3. Treat “already exists” as success and do not enumerate, delete, alter, or recreate files.
4. If the ensure fails, stop before validation and Main Lua using the existing generic `stop`/status behavior, with a non-secret error marker such as `LICENSE_STORAGE_UNAVAILABLE`. It must never log a key, device ID, token, response body, or user data.
5. On success, call no new backend/API route and continue through the **unchanged** current loader flow.

The helper must not be placed after `get_device_id`, `read_key`, or the server-valid callback, because those paths already attempt writes or reads in the directory.

## 5. Expected behavior by user state

| Scenario | Expected result after a proven ensure helper | Protected behavior |
|---|---|---|
| New user; directory absent | First run ensures exact current `KEY_DIR`; the normal key-entry UI appears. On current validation timing, the existing device fallback and status/key files are written as their current logic dictates. | Validation protocol, key JSON format, device ID format, and popup flow remain unchanged. |
| Existing user; directory exists | Existence check returns success; no file is touched by the ensure step. Existing saved-key prefill, device identity, status/diagnostic files, and read fallback order operate exactly as now. | No reset, migration, delete, rename, or rebind. |
| Existing directory; a particular file is missing | The ensure step does nothing beyond accepting the directory. Existing code’s per-file behavior remains authoritative. | No artificial file recreation. |
| Directory create/check fails | Stop before validation/Main Lua with a non-secret storage-unavailable diagnostic. Do not write partial state. | No request/response contract or validated state is changed. |

## 6. Lua-only versus host-side requirement

This can remain an isolated loader change **only** if B3/host already exposes a tested Lua-callable API such as `DirectoryExists` + `CreateDirectory`/`MakeDirectory`, with a contract that accepts this Android app-private path. That call must be confirmed by source or a deliberately approved, non-secret capability test.

If B3 exposes only `io.open` and `SavedFileUtil.FindFiles`, then it cannot ensure a missing parent folder. In that case, a **host-side capability** is required: the UE4/Android host must expose an approved directory-ensure API, or create the license storage directory before running user Lua. A Lua-only fallback based on `os.execute("mkdir...")`, `lfs.mkdir`, or arbitrary imports is not approved because none is proven available or safe in this host.

## 7. Exact next evidence needed

Provide one of the following, read-only:

1. The actual B3 Lua package/archive (or its filesystem utility module) that contains the host file APIs; or
2. A non-secret Android runtime capability report that includes the relevant filesystem object and its method names; or
3. Official host documentation for the writable-path and directory-create contract.

After that evidence identifies an exact existing API, a separate implementation approval can authorize only the small pre-storage ensure helper, followed by Lua syntax checks and controlled new/existing-user tests. Until then, no loader change is technically justified.

## Renewed V3 archive result

The user re-supplied `V3.zip` for the directory-API check. A second targeted read-only inspection confirms that its only clearly named filesystem helper is `V3/file_util.lua`. That module imports `SavedFileUtil` and exposes only this observed host call:

```lua
SavedFileUtil.FindFiles(targetDir, extension, recursive)
```

No exact `CreateDirectory`, `MakeDirectory`, `mkdir`, `DirectoryExists`, `DirExists`, `EnsureDirectory`, `CreateFolder`, or equivalent contract was recovered from that helper or from the archive’s directly identifiable filesystem modules. The archive-wide text search was stopped rather than allowed to run indefinitely; its partial/non-result is not interpreted as proof that an undocumented host method cannot exist.

The active loader was then re-read to verify the implementation boundary. `KEY_DIR` is still defined before `write_status`, and `LOADER_STARTED` is written before JSON/key reads or fallback device creation. Therefore the original insertion guidance remains correct: a future proven ensure helper belongs between the `KEY_DIR` definitions and the first status write.

> **Renewed decision:** The V3 archive does not remove the host-API blocker. It proves file discovery only, not parent-directory creation. A B3-specific host module, non-secret runtime capability report, or official host API documentation is still required before any isolated folder-ensure implementation can be approved.

## Deeper V3 static-analysis result

V3 was unpacked only to a temporary analysis copy and scanned for every filesystem/host bridge reference, including `SavedFileUtil`, `Client.*`, `ScriptHelperClient.*`, reflection-style calls, and common directory-method names. The direct host-file surface recovered was:

| Observed method | What it proves | What it does not prove |
|---|---|---|
| `SavedFileUtil.FindFiles(targetDir, extension, recursive)` | File discovery. | Folder existence or creation. |
| `Client.SaveStringToFile(contents, relativePath)` | Host-relative file writing. | Automatic creation of a missing parent directory. |
| `Client.WriteFileAtPath(fullPath, contents)` | Full-path write with a stored result value in one V3 caller. | That the exact external `KEY_DIR` is permitted or missing parents are created. |
| `Client.DeleteDirectory(...)` / `Client.DeleteFile(...)` | Delete capabilities. | A complementary directory-create or exists contract. |

No direct `CreateDirectory`, `MakeDirectory`, `DirectoryExists`, `DirExists`, `EnsureDirectory`, `mkdir`, `lfs`, or equivalent reflective method was recovered.

V3 does use nested write paths, including `SaveGames/<name>.json`, `BlockyLua/BlockyLuaPreset.json`, `/RoleInfo/RoleInfo.json`, and a full internal-path sidekick file. Those calls are **potential leads only**: the source does not prove whether their parents were precreated by the game or auto-created by the host. No caller creates a brand-new directory and verifies its result.

> **Deeper conclusion:** V3 offers plausible write primitives but still no documented, safe directory-ensure contract. It is not valid to replace the loader’s `io.open` flow or add a guessed creation call based on these examples.

The next safe gate is either B3/host documentation that explicitly states parent-directory behavior for `Client.WriteFileAtPath`/`Client.SaveStringToFile`, or separate approval for a non-secret Android capability probe. A probe would itself create a marker/state artifact and needs its own cleanup and rollback policy; it must not be merged into the verified loader without approval.

## Returned Android capability-probe evidence

The user ran the separate probe and returned its non-secret hidden result file. Its fixed result is:

```text
path_available=true
directory_exists=not_proven_no_directory_query
create_supported=available
create_result=call_completed
verify_result=marker_readable
```

The user also confirmed that the exact lowercase `lua-license` folder was absent before this probe and then appeared automatically with the probe file inside it. Combined with the successful read-back, this is direct Android-runtime evidence for the following bounded contract in this package/runtime:

```lua
Client.WriteFileAtPath(
  "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.lua_license_folder_probe",
  "LUA_LICENSE_FOLDER_PROBE_MARKER_V1"
)
```

The `Client` method was exposed, the dot-call completed, and raw `io.open(..., "rb")` read the exact marker back. Under the user-confirmed absent-folder test condition, that establishes that this host can create the missing parent path for this exact full-path writer.

| Proven | Still not proven |
|---|---|
| The exact app-scoped lowercase path can be made writable by `Client.WriteFileAtPath(fullPath, contents)`. | A direct `DirectoryExists`-style query; the probe intentionally reports this as `not_proven_no_directory_query`. |
| A missing parent folder is created by this host in the tested condition. | General behavior for any other package, root, or host/runtime version. |
| The created full path is readable afterwards through the existing raw `io.open` reader. | The method's return-value semantics; the probe relies on read-back, not a return value. |

### Implemented production insertion and Android verification

After separate approval, the production **Merged** loader added the narrow preflight immediately after `read_file`/`write_file` are available and before the first `pcall(write_status, "LOADER_STARTED")`. It writes only the fixed non-secret `.lua_license_folder_ready` marker through the Android-proven full-path writer, reads the exact marker back, and only then enters the existing loader flow. It never uses the marker call for `key.json`, `.device_id`, or `.license_status`.

The user completed the requested Android verification without supplying any sensitive value. Their reported sequence was:

| Run | Observed outcome | Evidence-bounded result |
|---|---|---|
| First direct launch with no folder | The `lua-license` folder appeared automatically and the normal key-entry UI appeared; no key was submitted. | The production preflight created/verified the path and preserved the normal missing-key prompt. |
| Reopen with the folder already present | The same key-entry UI appeared again. | The fixed marker did not block the normal existing-folder/missing-key behavior. |
| Valid key submission | Login succeeded; the expected key, device, and status persistence appeared, along with additional non-secret files. | Existing valid-key persistence and the verified license flow continued after the preflight. |

`.lua_license_folder_ready` is the expected new fixed marker file. Other dot-prefixed files may be pre-existing approved diagnostics or presentation state; this verification does not infer their names or contents. The folder preflight writes no key, device ID, token, URL, response body, or user data.

The implementation is therefore verified for the exact tested Android package/runtime and path. A direct `DirectoryExists` API and generalized behavior for other packages/runtimes remain unproven, but are not required for this approved Merged-loader flow. License validation, device binding/rebind, Maintenance, Announcement, Telegram, Main Lua, API, and persistence formats remained outside this change.
