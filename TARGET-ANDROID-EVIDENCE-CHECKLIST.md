# Target Android Evidence Checklist

This checklist is for the user's own authorized Dynamic Execution runtime. It does not call undocumented network functions, inspect third-party files, bypass validation, or execute downloaded code.

## 1. Key filename behavior

Create only one file at a time in:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/
```

Use the exact content below for each run:

```text
key.json: {"key":"YOUR_PANEL_KEY"}
key.txt:  YOUR_PANEL_KEY
key.in:   YOUR_PANEL_KEY
key.ini:  YOUR_PANEL_KEY
```

Before each run, remove the other three key files and remove `.license_status` only if a clean timestamp is desired. Run order is `key.json`, `key.txt`, `key.in`, then `key.ini`. Run the production reusable wrapper and record only the final non-secret stage from `.license_status`. Do not send the key itself. Possible useful stages are `KEY_FILE`, `VALIDATING`, `ACCESS_GRANTED`, `VALIDATION_FAILED`, or `ERROR: HTTP adapter unavailable`.

A `KEY_FILE` result shows a file was selected. `ERROR: HTTP adapter unavailable` means the filename was read successfully but the host has no usable POST transport. A validation error after `VALIDATING` means the request path was reached; it does not prove that the key was accepted.

## 2. Downloader probe

Use only `BRPlayerCharacterBase-DownloaderProbe-Test.lua`, never the production wrapper with the probe flag enabled. Remove old `.downloader_probe` and `.license_status`, run once, then record the sanitized contents of both files. Expected classifications are:

```text
DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE
DOWNLOADER_PROBE_CALL_FAILED
DOWNLOADER_PROBE_NO_VERIFIED_FILE
DOWNLOADER_PROBE_UNAVAILABLE ...
```

A successful result proves only fixed public HTTPS GET and file-write capability. It does not prove POST, JSON bodies, custom headers, callbacks, HTTP status access, or response-body access. Do not point the probe at the panel validation endpoint or at any key-bearing URL.

## 3. Existing bridge reports

The following reports already supplied by the user are sufficient for the current classification and do not need to be regenerated unless the runtime changes:

```text
.bridge_inventory
.host_surface_inventory
.host_contract_shape
.getter_return_probe
.http_module_inventory
```

A future candidate can be considered only if an authorized runtime report or documentation demonstrates all of these fields: request method, URL argument, JSON body argument, headers, timeout behavior, asynchronous callback or equivalent, numeric HTTP status, response body, and a failure/error path.

## 4. Decision rules

| Evidence | Decision |
|---|---|
| Only WebView/URL opening | Not a license API transport; do not adapt it |
| Fixed HTTPS GET and file write | Keep as diagnostic only; do not use for online validation |
| Native function name or `debug.getinfo` metadata only | Do not invoke or adapt it |
| POST plus status/body/callback contract | Candidate for a bounded optional adapter, pending local verification |
| No documented POST contract | Keep loader fail-closed; use an authorized host bridge or offline signed-license design |

Never include keys, device IDs, tokens, private URLs, or third-party source files in a report. Screenshots should show only sanitized stage names and error categories.


## Latest observed result

The supplied target-runtime report recorded `DOWNLOADER_PROBE_UNAVAILABLE import_failed`. This establishes that the isolated Downloader probe cannot be used for the next architecture in this runtime. It does not establish POST support, response parsing, or a license-validation transport. The production loader therefore remains fail-closed and no Downloader adapter is enabled.
