# Live Admin Verification

**Verified on:** 2026-08-13 (UTC)

The deployed control panel loaded with an authenticated **Owner** session. The registry displayed the canonical lifecycle status labels, expiry timestamps, one-device capacity, and the status/expiry management action. Two existing records were shown as **unused** with zero device bindings.

No record was created, bound, revoked, or deleted during this inspection. Existing production keys are intentionally not repurposed for end-to-end testing without the owner's explicit authorization because binding is server-authoritative and has a real lifecycle effect.

The published API endpoint independently returned the canonical JSON contract for an unknown key. The valid, expired, same-device, and different-device branches are covered by the automated service regression suite.

## Owner-Authorized Live Matrix

The owner authorized a temporary, one-day production test license on 2026-08-13 (UTC). The issuance request was submitted through the authenticated live owner panel. The temporary key value is treated as sensitive operational data and will not be recorded in this document or user-facing report.

After the request remained in its pending UI state, a live-panel refresh showed an empty registry. The requested validation matrix and any cleanup action are paused while this data-visibility anomaly is investigated; no assumption is being made about whether the temporary record was created.

## Multi-device capacity verification

Using the owner-authorized temporary test license in the authenticated project environment, the updated endpoint accepted **five distinct devices**, accepted a repeat request from the first device without consuming capacity, and returned `device_max_reached` for a sixth distinct device. The key value is intentionally omitted. The temporary record and its test bindings were removed through the owner panel after verification; the normal audit trail remains.

## Published endpoint verification in progress

An isolated temporary one-device license was generated through the authenticated owner control panel for the final public API matrix. The published endpoint returned **valid** for the first device and a repeat request from that device, **device_mismatch** for a different device, and **not_registered** for an unrelated synthetic test key. The temporary key is retained only for the expiry response check and will be deleted immediately afterward; its value is intentionally omitted from this record.

The status was then changed to **expired** through the owner management dialog. The published endpoint returned the expected `expired` JSON status. The temporary license remains pending immediate owner-authorized deletion.

Cleanup is complete. The temporary license and its device binding were deleted through the authenticated owner panel. A server-side verification confirmed zero remaining matching license rows and zero associated binding rows. The standard audit log remains as the only intended record of this verification.
