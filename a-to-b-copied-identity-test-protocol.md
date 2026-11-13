# A-to-B Copied Local Identity Test Protocol

## Scope

This isolated test answers one question only: whether the existing canonical validation path accepts A's copied `key.json` **and** A's copied local `.device_id` when the standalone test Lua is run on physical Device B.

It does not modify the production loader, server binding rule, host identity method, random-ID mechanism, normal B key/device/status files, Maintenance, Announcement, Telegram, or Main Lua. It reports only a final non-secret accepted/rejected/undetermined marker.

## Device A preparation

Use the already verified production Merged loader to complete a fresh valid test-license login on A. Confirm `A_BINDING=PASS` with the existing standalone baseline diagnostic. Keep a temporary local test copy of only these two A files:

| A source file | B special test destination | Purpose |
|---|---|---|
| `key.json` | `.a_to_b_test_key.json` | Supplies the identical A license state to the isolated test. |
| `.device_id` | `.a_to_b_test_device_id` | Supplies the identical A local identity only to the isolated test payload. |

Do not send either file to this project. Do not copy `.license_status`, folder markers, diagnostics, or any other file.

## Device B isolated run

Use a different physical Android device and the same approved external pickle/vehicle method. Place the two A test copies under the exact hidden B filenames above. Do **not** replace B's normal `key.json`, `.device_id`, or `.license_status`; the diagnostic reads only its special test filenames and never writes those normal files.

Run only `AtoBCopiedIdentityDiagnostic.lua`. It submits the copied key and copied local identity to the existing canonical validation endpoint, then writes:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.a_to_b_copied_identity_diagnostic
```

| Result | Meaning | Required action |
|---|---|---|
| `B_COPIED_IDENTITY=REJECTED` | The existing validation refused the copied local identity from B. | Expected secure result; stop and report only this marker. |
| `B_COPIED_IDENTITY=ACCEPTED` | The existing validation accepted the copied key plus copied local identity. | Security finding; stop. Do not implement a fix without separate approval. |
| `B_COPIED_IDENTITY=UNDETERMINED` | The diagnostic could not obtain a usable canonical result. | Stop and report only this marker; do not infer accepted/rejected. |

Afterward, delete only the two special B test files and `.a_to_b_copied_identity_diagnostic` if desired. Leave B's normal license/device/status files untouched.
