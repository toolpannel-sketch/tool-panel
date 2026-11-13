# Standalone Key-Entry Experiment

## Scope

`BRPlayerCharacterBase-KeyEntry-Experiment.lua` is a separate experiment. It does not import, replace, or alter either verified production loader artifact. On every experimental run, it opens an editable `ENTER YOUR KEY` popup prefilled from the current `key.json`, if present. It uses the same server endpoint and documented callback contract only after the user presses **OK**.

The experiment saves a replacement only after the server returns `valid`. Cancelling, an invalid/revoked/expired result, a device rejection, or a transport failure leaves the previously saved key untouched.

## On-device test

1. Keep the existing verified production loader unchanged and retain its current `key.json` file.
2. Confirm that `/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/` already exists. The authorized source did not establish a documented directory-creation API, so this experiment cannot create a missing directory automatically. This is the one requested behavior not implemented; it remains a safe, explicit test prerequisite.
3. Run only `BRPlayerCharacterBase-KeyEntry-Experiment.lua` in the same environment where the verified loader's HTTP callback is known to work.
4. If the `ENTER YOUR KEY` input dialog appears, verify that any saved key is prefilled. Replace it with one active test key and press **OK**. Pressing **Cancel** must close the experiment without validation or file changes.
5. On **KEY VALID / KEY SAVED**, close the experiment and run the unchanged verified production loader normally. The existing loader should read the newly saved `key.json` and execute its usual validation flow.

The field accepts either a raw license key, such as `ALEXA-LORD-7K4M-92XD`, or a complete pasted `key.json` value, such as `{"key":"ALEXA-LORD-7K4M-92XD"}`. In the second case, the experiment immediately replaces the displayed JSON with its raw key value so **OK** can become available.

## Expected safe outcomes

| Result | Meaning | Production impact |
|---|---|---|
| `KEY VALID / KEY SAVED` | The server accepted the key and the experiment wrote `key.json`. | None; run the original loader afterward. |
| Rejected key or transport failure | The server did not authorize the submitted replacement. | None; the prior `key.json` is retained. |
| `KEY ENTRY UI UNAVAILABLE` | The host could not open the existing authorized input widget through the documented UI manager. | None; original manual `key.json` flow remains available. |
| `CONNECTION ERROR` | The experimental request did not complete. | None; the prior key and original verified loader are unchanged. |
| `KEY FOLDER UNAVAILABLE` | The expected directory did not already exist or could not be written. | None; create/use the normal key folder, then retry only the experiment. |

## Rollback

Do not replace either production loader. Simply stop using the experiment. The verified originals are unchanged and were confirmed byte-for-byte equal to the backup copies in:

`/home/ubuntu/lua-license-panel-backups/verified-before-key-entry-20260814/`
