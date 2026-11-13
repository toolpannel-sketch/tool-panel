# `Client.GetPhoneDeviceID()` Restart Probe Protocol

## Scope

This standalone artifact tests only whether the V3-observed `Client.GetPhoneDeviceID()` member is available in the current Android Dynamic Lua host, returns a non-empty string, and compares the return across a **single approved close/reopen test**. It does not run the production Merged loader and does not interact with validation, device binding, key persistence, Maintenance, Announcement, Telegram, or Main Lua.

The probe never writes the raw returned value. Its public result contains only these fixed fields:

```text
api_available=true|false
value_present=true|false
restart_stable=baseline_recorded|true|false|not_tested|baseline_not_saved
```

The internal `.phone_device_id_probe_state` holds only an opaque fixed-length comparison token. It is not printed, returned, transmitted, or added to any license request. It is not a cryptographic identity proof; it exists solely because a restart comparison requires a prior-run reference without retaining the raw value.

## Android procedure

| Step | Action | Expected non-secret outcome |
|---|---|---|
| 1 | Do not run the production Merged loader. Copy and run `PhoneDeviceIdRestartProbe.lua` alone. | `api_available` and `value_present` classify the exposed V3 member; a successful baseline records `restart_stable=baseline_recorded`. |
| 2 | Fully close the target application, reopen it, and run the **same standalone probe** once more. Do not clear app data, reinstall, or delete `.device_id`. | `restart_stable=true` means the two local comparison tokens matched; `false` means they differed. |
| 3 | Return only the three result lines from `.phone_device_id_probe_result` or the visible console output. | No raw identifier, token, screenshot of the value, key, device file, status, or account data is needed. |

The two probe-only files are:

```text
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.phone_device_id_probe_result
/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.phone_device_id_probe_state
```

They do not replace, alter, delete, or read `.device_id`, `key.json`, or `.license_status`. The result file can be checked after each run; the state file should remain untouched between the two runs. This protocol deliberately does **not** test app-data deletion or reinstall.

## Interpretation boundary

`api_available=true` means only that the member was callable in this runtime. `restart_stable=true` means only that the two-run local comparison matched. Neither result authorizes a production identity change, server migration, or automatic rebind. Those would require separate approval and a protected canonical device-binding design review.
