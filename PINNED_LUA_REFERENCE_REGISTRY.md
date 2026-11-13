# Pinned Lua Reference Registry

The following files are intentionally retained as **separate, immutable reference artifacts**. They must never be merged into each other or overwritten in place. Any future fix starts from a new working copy of the reference that matches the reported runtime behavior.

| Pinned artifact | Intended use | Boundary |
|---|---|---|
| `BRPlayerCharacterBase-Merged.lua` | Normal/previously verified merged-loader reference for the established external/pickle-style runtime flow. | Preserve the approved host-first identity rollout and all verified presentation flows. |
| `FailClose-NoRestriction.lua` | Local single-file reference for cases requiring no editable feature-settings persistence and custom runtime startup only after canonical authorization. | Preserves the UE4 module return while preventing the custom `FastTick/MainLoop` path from starting before authorization. |

Both pinned copies have been checked with Lua 5.3 syntax validation. The fail-closed local reference still requires its dedicated Android invalid-key, valid-key, and session-settings-reset checks before its runtime security behavior is treated as Android-verified.

## Future Workflow

First identify which reference matches the reported runtime method. Create a writable copy of that one artifact, preserve the original reference, and make the smallest evidence-backed change. Do not expose or embed raw keys, device identifiers, tokens, URLs, or response bodies in future diagnostics.
