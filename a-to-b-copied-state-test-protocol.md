# A-to-B Copied-License-State Diagnostic Protocol

## Scope

This protocol uses the standalone `AtoBCopiedLicenseStateDiagnostic.lua`. It does **not** modify the production loader, server binding rule, random device-ID mechanism, host identity method, `key.json`, `.license_status`, Maintenance, Announcement, Telegram, or Main Lua.

The diagnostic dispatches the existing canonical validation request only. It reports a fixed non-secret outcome in:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.a_to_b_copied_state_diagnostic
```

The file contains only `TEST_MODE=A` or `TEST_MODE=B` and one result marker. It never records a key, device ID, token, URL, or response body.

## File boundary

| Device | Read by diagnostic | Written by diagnostic | Manually copied by tester |
|---|---|---|---|
| A | Its normal `key.json` and existing identity source. | Its own `.a_to_b_copied_state_diagnostic`. | Nothing. |
| B | Its own existing identity source and, only if present, `.a_to_b_test_key.json`. | Its own `.a_to_b_copied_state_diagnostic`. | Copy A's **`key.json` bytes only** to B as `.a_to_b_test_key.json`. |

Do **not** copy `.device_id`, `.license_status`, `.lua_license_folder_ready`, diagnostics, or any other file from A to B. Do not replace B's normal `key.json`; the B-specific hidden test-key filename preserves it. The copied test file must use the normal existing JSON structure, `{"key":"..."}`, but its content must not be sent back to this project or shown in screenshots.

## Device A baseline

Use a dedicated valid test license and the latest already-verified Android build. First run the normal production loader on A once and confirm its normal login succeeds. Then run **only** the standalone diagnostic. Do not run the diagnostic together with Main Lua.

Expected result:

```text
TEST_MODE=A
A_BINDING=PASS
```

If the result is `A_BINDING=REJECTED` or `A_BINDING=UNDETERMINED`, stop. Do not copy anything to B, and report only the marker.

## Device B copied-state test

Use a different physical device with its own existing identity, established either by the verified build or the separately approved key-free B-only identity initializer. Copy only A's test-license `key.json` to this exact B path:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.a_to_b_test_key.json
```

Do not run B's production loader for this test. Run the standalone diagnostic alone.

| Result | Meaning | Next action |
|---|---|---|
| `B_COPIED_STATE=REJECTED` | The existing canonical server-side binding rejected the copied key state using B's own identity. This is the expected secure result. | Stop; send only this marker. |
| `B_COPIED_STATE=ACCEPTED` | The canonical validation accepted the copied key state. | Stop; send only this marker. Do not implement a fix without separate approval. |
| `B_COPIED_STATE=UNDETERMINED` | The test did not establish an authoritative result; likely file, identity, JSON, or transport precondition. | Stop; send only this marker. |

After recording the B result, manually remove only `.a_to_b_test_key.json` and `.a_to_b_copied_state_diagnostic` from B if desired. Do not remove or alter any normal license/device/status file.

## Verified Android result

The user completed the comparable B-stage run after B's own identity became available through the approved key-free preparation path. The submitted non-secret result was:

```text
TEST_MODE=B_STAGE
B_STAGE=CANONICAL_REJECTED
```

Together with the earlier `A_BINDING=PASS`, this verifies that the tested A license state was accepted on its bound A identity and rejected when only its `key.json` bytes were copied to B while B retained its own identity. The copied key JSON alone did not grant B a valid login.

> The B-stage diagnostic deliberately reports only the canonical accepted/rejected category. It does not expose the raw server response or claim an unrecorded exact status label such as `device_mismatch`.

No production loader, server binding rule, random/host device-identity behavior, key format, status format, Maintenance, Announcement, Telegram, or Main Lua behavior was changed for this test.
