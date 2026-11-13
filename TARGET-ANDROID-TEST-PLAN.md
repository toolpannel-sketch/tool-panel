# Ordered Android Runtime Test Plan

This plan is for the user's own authorized Dynamic Execution host. Run one test at a time. Do not combine tests, do not enable the production Downloader flag, and do not include keys, device IDs, tokens, private URLs, or third-party source files in reports.

## Test 1 — Key-file readability

Use the existing production reusable wrapper. In the license folder, keep exactly one of these files for each separate run: `key.json` containing `{"key":"YOUR_PANEL_KEY"}`, `key.txt` containing the raw key, or `key.in` containing the raw key, or `key.ini` containing the raw key. Remove the other three files before each run. Run order is `key.json`, `key.txt`, `key.in`, then `key.ini`. Remove `.license_status` only when a clean timestamp is needed.

After running, report only the sanitized final line or stage from `.license_status`. The useful outcomes are `KEY_FILE`, `VALIDATING`, `ACCESS_GRANTED`, `VALIDATION_FAILED`, or `ERROR: HTTP adapter unavailable`. A `KEY_FILE` stage proves file selection; an HTTP-adapter error after key selection proves the filename was readable but the runtime lacks the required transport. Do not treat a missing visible message as a success.

**Gate:** If at least one filename reaches `KEY_FILE` or `VALIDATING`, proceed to Test 2. If none is readable, fix only the local path/filename issue first; do not change the network adapter.

## Test 2 — Safe Downloader capability probe

Use only `BRPlayerCharacterBase-DownloaderProbe-Test.lua`. Do not use the production wrapper with a probe flag changed. Delete old `.downloader_probe` and `.license_status`, run once, and inspect the two sanitized files.

Acceptable probe results are `DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE`, `DOWNLOADER_PROBE_CALL_FAILED`, `DOWNLOADER_PROBE_NO_VERIFIED_FILE`, or `DOWNLOADER_PROBE_UNAVAILABLE ...`. The probe uses a fixed public fixture only. Never point it at `/v1/validate`, a key-bearing URL, or a downloaded script.

**Gate:** A success proves only fixed HTTPS GET and file writing. It does not prove POST, JSON request bodies, custom headers, callbacks, HTTP status access, or response-body access. Therefore, even a success does not justify mapping Downloader to license validation.

## Test 3 — Existing non-invasive capability reports

Do not regenerate reports already supplied unless the runtime version changed. The existing `.bridge_inventory`, `.host_surface_inventory`, `.host_contract_shape`, `.getter_return_probe`, and `.http_module_inventory` reports are sufficient to classify names and metadata. They do not authorize invoking native functions.

**Gate:** A candidate advances only if an authorized document or host example explicitly demonstrates URL, POST method, JSON body, headers, timeout, callback/return shape, numeric HTTP status, response body, and error behavior. Names, tables, `debug.getinfo`, C-function metadata, metatables, or WebView URL opening do not satisfy this gate.

### Recorded Test 3A — Candidate `http_post` availability probe

The submitted no-network probe was recovered and read on 2026-08-13. Its entire sanitized result was:

```text
HTTP_POST_PROBE_STARTED
http_post = missing
callback_contract = not_invoked
HTTP_POST_PROBE_COMPLETE
```

This establishes that the proposed lowercase callback bridge, `http_post(url, body, headers, callback)`, is **not exposed** by this target runtime. Since the function is absent, no callback can be tested and no request should be attempted. Do not modify the production wrapper to call this name unless a future runtime update or a documented host bridge first exposes it.

## Test 4 — Standard Lua HTTPS module availability

Use a separate diagnostic copy, not the production wrapper, and perform only protected module imports. For each module, record a boolean result from `pcall(require, module_name)` without printing module values or enumerating tables. Test these names independently: `socket`, `socket.http`, `ltn12`, `ssl.core`, and `ssl.https`.

A usable standard HTTPS path requires all of `socket.http`, `ltn12`, and `ssl.https` to load. `socket.http` without `ssl.https` is not sufficient for the production HTTPS endpoint. If any required module is unavailable, stop the standard-library path and report `STANDARD_HTTPS_UNAVAILABLE`; do not install files into the game runtime or guess alternate native calls.

**Gate:** Proceed to Test 5 only when the required modules load and the adapter can return both a numeric status and a string response body. Module availability alone does not prove that DNS, TLS, POST, headers, or response handling work.

## Test 5 — Contract-backed panel request, only if Test 3 or Test 4 passes

This test must not be attempted with guessed arguments. If and only if an authorized host contract exists, use the panel endpoint `https://luapanel-8355ybgt.manus.space/v1/validate` with a non-secret test key or deliberately invalid placeholder in a JSON body. The expected request is `POST` with `Content-Type: application/json` and fields `key` and `device_id`. The response must expose a numeric status and JSON body to Lua without logging secrets.

The loader must accept only a valid `200` response with `ok == true`; all other statuses, malformed JSON, timeout, DNS errors, missing callbacks, empty bodies, or certificate failures must deny access. The server remains authoritative for validity, bans, expiry, and one-device-one-key binding.

## Sanitized evidence format

Send only a small text report in this shape:

```text
TEST=KEY_FILE
RESULT=KEY_FILE|VALIDATING|ACCESS_GRANTED|VALIDATION_FAILED|HTTP_ADAPTER_UNAVAILABLE|NO_VISIBLE_STATUS

TEST=DOWNLOADER_PROBE
RESULT=DOWNLOADER_PROBE_SUCCESS_GET_FILE_WRITE|DOWNLOADER_PROBE_CALL_FAILED|DOWNLOADER_PROBE_NO_VERIFIED_FILE|DOWNLOADER_PROBE_UNAVAILABLE

TEST=CONTRACT
RESULT=NOT_ATTEMPTED|CONTRACT_AVAILABLE|STATUS_AND_BODY_RETURNED|CONTRACT_MISSING

TEST=STANDARD_HTTPS
RESULT=NOT_ATTEMPTED|MODULES_AVAILABLE|STANDARD_HTTPS_UNAVAILABLE|STATUS_AND_BODY_RETURNED
```

Do not send actual key contents, device identifiers, authentication tokens, full logs, or private source files. If a run crashes, report only `CRASH_AT=KEY_FILE|PROBE|CONTRACT` and whether `.license_status` was written.

## Final decision rules

If Test 1 succeeds but Test 2, Test 3, Test 3A, and Test 4 do not establish a transport, the issue is not the key format; online validation is blocked by the host transport. If Test 2 succeeds without a POST/status/body contract, retain the probe as diagnostic-only. If Test 4 loads the required modules and a bounded request returns status plus body, the adapter can use the standard LuaSec path while preserving fail-closed behavior. If a verified host contract exists, a bridge such as `HTTP_POST(url, body) -> status, response_body` or `http_post(url, body, headers, callback)` may be used only after its exact callback/return behavior is validated. The current lowercase `http_post` probe is missing. If neither path is available, do not add a guessed adapter; online-only deployments must wait for an authorized documented host bridge.
