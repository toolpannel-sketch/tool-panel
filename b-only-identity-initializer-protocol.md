# B-Only Identity Initializer Protocol

## Purpose

`BOnlyIdentityInitializer.lua` is an approved **standalone** preparation helper for the pure A-to-B copied-state test. It creates B's own local random `.device_id` only when B has neither an approved runtime provider nor an existing `.device_id`.

It never reads a key, key JSON, status file, A-device file, or server response. It never sends a request, validates a license, starts a login, runs Main Lua, or changes production Lua/server binding.

## Run on Device B only

Use the same approved external pickle/vehicle method as the later B diagnostics. Run the helper once. Read only this hidden result file:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.b_identity_initializer
```

| `B_IDENTITY` result | Meaning | Next action |
|---|---|---|
| `CREATED` | B's own 32-character random `.device_id` was created. | Run the B-stage diagnostic next. |
| `EXISTING` | B already had its own local device identity; it was not changed. | Run the B-stage diagnostic next. |
| `PROVIDER_READY` | B has an available runtime identity provider; no local identity was created. | Run the B-stage diagnostic next. |
| `STORAGE_UNAVAILABLE` or `WRITE_FAILED` | The helper could not establish B's own identity. | Stop and report only this marker. |

After `CREATED`, `EXISTING`, or `PROVIDER_READY`, keep B's resulting identity in place. Copy only A's `key.json` bytes to B as `.a_to_b_test_key.json`, never as B's normal `key.json`, and never copy A's `.device_id`. Then run `AtoBCopiedStateBStageDiagnostic.lua` through the same external pickle/vehicle method.

Only share fixed result markers. Do not share key files, device files, raw identity values, server responses, tokens, or URLs.
