# Premium Lua System UI Rollback Guide

## Purpose

The Premium Lua System redesign is a **frontend-only, reversible visual layer**. It does not alter the license API, HTTP/transport, authentication, server validation, device binding, Telegram mapping, Announcement, Maintenance, key format, status format, or Android Lua behavior.

## Pre-redesign baseline

The exact pre-redesign restore point is checkpoint **`89cb430c`**. It preserves the working panel immediately before the premium visual layer was added, including the approved Maximum Devices 10,000 limit and optional exact-name custom-key mode.

## RGB enhancement baseline

Checkpoint **`1da526f7`** is the exact published Premium Lua System UI state before the later RGB accent and second animated-overview enhancement. Restore this checkpoint to keep the first premium redesign while removing only the later visual enhancement.

## Holographic rebuild rollback path

Checkpoint **`f2a8c902`** is the exact RGB dashboard state immediately before the approved name-free holographic rebuild. Checkpoint **`d20450ff`** is the completed holographic **PREMIUM LUA SYSTEM** visual state with asymmetric glass modules, the central PL core, and emerald/amber/crimson/violet grading. Restore **`f2a8c902`** to undo only this latest holographic visual change while retaining the earlier Control Spectrum design; restore **`89cb430c`** to return to the original pre-premium panel.

## Controlled neon rollback path

Checkpoint **`876fec32`** is the exact holographic dashboard state immediately before the approved controlled-neon enhancement. Checkpoint **`185cabbd`** is the completed neon visual state, with restrained lighting on Home priority controls and setup panels plus shared visual emphasis for Super Owner Review, Announcement Control, and Server Maintenance. Restore **`876fec32`** to remove only the latest neon layer while retaining the holographic dashboard composition.

## Combined title-and-perimeter neon rollback path

Checkpoint **`c6d03fe5`** is the exact published dashboard state before the approved combined neon treatment. Checkpoint **`1c5c0934`** is the completed visual-only release: existing cards use thin full-perimeter neon rails with stronger corner and side bloom; Global Overview, Announcement Control/System Announcement, System Control/Server Maintenance, and ordinary labels receive readable semantic glow. Restore **`c6d03fe5`** to remove only this combined neon layer while preserving all earlier holographic and controlled-neon work.

## UI-only files changed or added

| File | Role in the redesign |
|---|---|
| `client/src/components/DashboardLayout.tsx` | Premium brand shell, sidebar, and top status strip. |
| `client/src/pages/Home.tsx` | Mounts only the visual overview and in-page navigation helper; existing tRPC mutations and controls remain in place. |
| `client/src/index.css` | Premium purple/cyan HUD, responsive layout, holographic system-view styling, and motion rules. |
| `client/src/components/PremiumSystemOverview.tsx` | Display-only overview constructed from already-loaded dashboard values. |
| `client/src/components/PremiumHologramConsole.tsx` | Display-only holographic command-center composition using the same already-loaded dashboard values. |
| `client/src/components/PremiumSpectrumOverview.tsx` | Preserved earlier RGB overview component; no longer required by the holographic composition. |
| `client/src/components/PremiumSectionAnchors.tsx` | Client-side scroll helper for existing Home panels; no data or network communication. |
| `server/premiumUiIsolation.test.ts` | Regression test that confirms the new visual components introduce no request mechanism and that protected server/Lua files contain no premium UI marker. |
| `todo.md` | Redesign progress history only. |

## Exact rollback procedure

> **Recommended:** Restore checkpoint `89cb430c` from the project version history. This is the complete, tested rollback and returns every tracked file to the exact pre-redesign panel state.

1. Open the project’s **Version history**.
2. Select checkpoint **`89cb430c`**, labelled *Rollback baseline before the approved reversible Premium Lua System cyberpunk UI redesign*.
3. Choose **Rollback** and confirm the restoration.
4. Confirm the preview loads the original panel layout.
5. Run `pnpm test -- --run` and `pnpm exec tsc --noEmit` if a local verification is required.

### Roll back only the latest holographic appearance

1. Open **Version history**.
2. Select checkpoint **`f2a8c902`**, labelled *Rollback baseline before the approved name-free PREMIUM LUA SYSTEM glass/holographic RGB visual rebuild*.
3. Choose **Rollback** and confirm the restoration.
4. The earlier RGB Control Spectrum panel returns; HTTP, transport, authentication, validation, bindings, Telegram, Announcement, Maintenance, and Lua behavior are unchanged by this restoration.

## File-level rollback alternative

If a future change must retain other post-baseline work, restore only the six UI files listed above from checkpoint `89cb430c`, then remove the two isolated premium components and the premium UI isolation test. Do **not** edit or restore any protected service, router, device-binding, or Lua file for a visual rollback.

## Protected paths

The following protected paths were intentionally not changed by this redesign and must remain untouched for both rollout and rollback:

- `server/routers.ts`
- `server/license.ts`
- `BRPlayerCharacterBase-Merged.lua`
- Maintenance, Announcement, Telegram mapping, device-binding, and canonical validation contracts
