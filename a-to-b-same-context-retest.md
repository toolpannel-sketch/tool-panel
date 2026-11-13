# A-to-B Copied-State Test — Same Execution Context Retest

## Returned evidence boundary

The user reported that Device A ran the baseline diagnostic through an external **pickle/vehicle** method, while Device B ran the copied-state diagnostic as a compiled file. A returned `A_BINDING=PASS`; B returned `B_COPIED_STATE=UNDETERMINED`.

These are **not comparable A-to-B security results**. The standalone diagnostic depends on the execution context for local path access, B's pre-existing identity, the JSON adapter, `slua_GameFrontendHUD`, the HTTP wrapper, and asynchronous callback delivery. A PASS in one loader context does not establish that all of those dependencies are equivalent in a different compiled-file context.

| Diagnostic dependency | Why execution method can matter | Effect on the prior B result |
|---|---|---|
| Explicit `lua-license` file paths | The launching context can have a different mounted-storage or file-permission view. | B may not have read the copied test key or its own identity. |
| Existing `.device_id` / provider | The diagnostic deliberately refuses to generate an identity. | A fresh or differently scoped B environment yields `UNDETERMINED`. |
| JSON global/module | The external and compiled contexts can expose a different Lua module/global surface. | Missing JSON prevents the canonical request. |
| `slua_GameFrontendHUD` / HttpWrapper / response event | These are host-bound globals and callbacks, not self-contained Lua libraries. | A different context can prevent request dispatch or callback reception. |

> **Conclusion:** `B_COPIED_STATE=UNDETERMINED` must be treated only as a context/precondition failure. It does not prove copied-state acceptance or rejection.

## Required comparable retest

Both A and B must use the **same latest standalone diagnostic file through the same external pickle/vehicle method**. Do not compile one device's test file while externally loading the other. Both devices must use the same latest Android build.

### Device A

First use the verified production Merged loader for an ordinary valid test-license login on A. Then run the unchanged A-to-B standalone diagnostic through the external pickle/vehicle method. Require:

```text
TEST_MODE=A
A_BINDING=PASS
```

Do not continue to B if A is rejected or indeterminate.

### Device B

Before testing, B must have its own already-existing identity in the **same external pickle/vehicle execution context**. Never copy A's `.device_id`, provider value, status, or diagnostic files. Copy only A's `key.json` bytes to B under the separate test filename:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.a_to_b_test_key.json
```

Keep B's normal `key.json` unchanged. First run the B-stage diagnostic through the same pickle/vehicle method. If it identifies a local stage failure, stop and provide only `B_STAGE=...`. If it reaches `CANONICAL_REJECTED` or `CANONICAL_ACCEPTED`, stop; that stage itself is the security outcome.

If the stage result is ready for the original test, run the unchanged A-to-B standalone diagnostic through the same pickle/vehicle method. Interpret only:

| Result | Interpretation |
|---|---|
| `B_COPIED_STATE=REJECTED` | Expected secure outcome: B's own identity did not satisfy the existing A-bound license state. |
| `B_COPIED_STATE=ACCEPTED` | Unexpected outcome: stop; no fix or binding change is authorized. |
| `B_COPIED_STATE=UNDETERMINED` | Still inconclusive; use only the B-stage diagnostic result to locate the precondition. |

## Restrictions preserved

The retest does not change production Lua, server binding, random device-ID generation, `Client.GetPhoneDeviceID`, key JSON structure, `.license_status`, Maintenance, Announcement, Telegram, Main Lua, or authentication. Do not send key contents, device files, raw identifiers, tokens, URLs, response data, or screenshots of sensitive files. Provide only the resulting fixed marker.
