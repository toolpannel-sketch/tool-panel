# License Display Verification Notes

- The production database confirms the activated three-minute license has one persisted binding, an activation timestamp of `2026-08-14 14:32:53`, and expiry at `2026-08-14 14:35:53` UTC.
- The live panel screenshot supplied by the owner showed activation and expiry correctly localized to 8:02 PM and 8:05 PM, while the old device column remained stale at `0 / 1`.
- The updated registry now polls every 15 seconds, refreshes through query invalidation, and uses the non-sensitive authoritative first-bound-device marker as a minimum display fallback.
- The unauthenticated sandbox preview remains on its normal boot screen, so the final active-session visual confirmation must be performed from the owner’s signed-in panel after publication.
