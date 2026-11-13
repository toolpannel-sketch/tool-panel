# License Validation API

The production validation endpoint is:

```text
POST https://luapanel-8355ybgt.manus.space/api/license/validate
```

It accepts a JSON object containing a license key and a caller-supplied persistent device identifier.

```json
{
  "key": "LUA-EXAMPLE-KEY",
  "device_id": "your-persistent-device-id"
}
```

Every response is JSON with the following shape:

```json
{
  "success": true,
  "status": "valid",
  "message": "License is valid for this device."
}
```

## Behavior

| Condition | `success` | `status` | Meaning |
|---|---:|---|---|
| An unbound, unexpired license is first used | `true` | `valid` | The server hashes and binds that device ID to the license. |
| An already-bound device revalidates | `true` | `valid` | The same server-authoritative binding remains valid without consuming capacity. |
| A new device is within the configured capacity | `true` | `valid` | The server records that distinct device binding. |
| The key does not exist | `false` | `not_registered` | No license record exists for the provided key. |
| The license is revoked | `false` | `invalid` | Revoked licenses cannot validate. |
| The license is expired or has passed its expiry timestamp | `false` | `expired` | Expired licenses cannot validate. |
| A different device uses a legacy one-device license | `false` | `device_mismatch` | Existing licenses retain their one-device policy unless an administrator raises their capacity. |
| A new device exceeds configured capacity | `false` | `device_max_reached` | All available device slots for the license have already been used. |

## Example request

```bash
curl --request POST 'https://luapanel-8355ybgt.manus.space/api/license/validate' \
  --header 'Content-Type: application/json' \
  --data '{"key":"LUA-EXAMPLE-KEY","device_id":"your-persistent-device-id"}'
```

## Example responses

```json
{"success":true,"status":"valid","message":"License is valid for this device."}
```

```json
{"success":false,"status":"expired","message":"License key has expired."}
```

```json
{"success":false,"status":"not_registered","message":"License key is not registered."}
```

```json
{"success":false,"status":"device_mismatch","message":"License key is bound to a different device."}
```

```json
{"success":false,"status":"device_max_reached","message":"Maximum device limit reached for this license."}
```

## Operational controls

The endpoint validates request types and lengths, uses a `no-store` cache policy, and allows **20 validation attempts per IP address per minute**. A rate-limited request receives HTTP `429` with a JSON response using the same response shape. During key generation, an administrator selects a capacity from **1 to 100 devices**; the same limit may be changed later from **Manage** but never below the currently bound-device count. Existing licenses default to one device. The database stores only a server-keyed SHA-256 representation of submitted device values; it does not persist raw `device_id` values.
