# B-Side A-to-B Stage Diagnostic Protocol

## Purpose and safety boundary

Use `AtoBCopiedStateBStageDiagnostic.lua` **only on Device B** after the original A-to-B diagnostic produced `B_COPIED_STATE=UNDETERMINED`. It identifies the one non-secret precondition or transport stage that prevented the canonical copied-state test from reaching an accepted/rejected outcome.

It does not change the production loader, server binding, key JSON, `.device_id`, `.license_status`, host identity, Maintenance, Announcement, Telegram, or Main Lua. It reads only B's existing identity source and the already-copied hidden test key file. It writes only:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.a_to_b_b_stage_diagnostic
```

## Preparation

Keep the existing B file exactly here, in normal JSON key-file structure:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.a_to_b_test_key.json
```

Do not replace B's normal `key.json`. Do not add, remove, or copy `.device_id`. Do not run production Merged Lua or a normal license login during this retest.

## Allowed output and interpretation

| `B_STAGE` value | Meaning | Safe next action |
|---|---|---|
| `COPIED_TEST_KEY_UNAVAILABLE` | The special B test-key file was not readable at its exact path. | Correct the filename/path only; do not expose its content. |
| `COPIED_TEST_KEY_FORMAT_INVALID` | The test file was readable but was not the normal JSON key-file structure. | Re-copy only A's original `key.json` bytes. |
| `B_OWN_IDENTITY_UNAVAILABLE` | B has no readable pre-existing identity provider or `.device_id`. | Stop. This test cannot establish security until B has its own pre-existing identity; do not copy A's identity. |
| `JSON_ADAPTER_UNAVAILABLE`, `HTTP_HOST_UNAVAILABLE`, `HTTP_WRAPPER_UNAVAILABLE`, `RESPONSE_EVENT_UNAVAILABLE`, `CALLBACK_REGISTER_FAILED`, `REQUEST_DISPATCH_FAILED` | A local standalone-runtime precondition prevented canonical validation. | Stop and send only the stage value. |
| `REQUEST_DISPATCHED` | Request was accepted for dispatch. Wait for callback result to replace it. | If it remains unchanged after the normal runtime wait, send only this stage. |
| `TRANSPORT_RESPONSE_UNUSABLE` or `CANONICAL_RESPONSE_INVALID` | Canonical request did not produce a usable result for this diagnostic. | Stop and send only the stage. |
| `CANONICAL_REJECTED` | The copied key was rejected under B's own identity. | This is the expected secure result; stop. |
| `CANONICAL_ACCEPTED` | The copied key was accepted under B's own identity. | Stop; do not implement any fix without separate approval. |

Never send the copied key file, device file, response body, key, device ID, token, URL, or screenshot beyond the single `B_STAGE=` marker.
