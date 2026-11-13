# UE4 Local Lua License-Gate Playbook

## Purpose

Use this playbook when a large UE4 class-module Lua file needs the existing license gate while keeping the module's original game features, including class-bound UI such as ESP Box or `EnemyFrameUI`, operational.

This is a **copy-only method**. Never overwrite the received original file or the separately verified external/pickle production loader. Create a working copy first, retain a read-only reference copy, and operate only on the working copy.

## Critical Rule

> A UE4 class module that ends with a top-level class return, such as `combine_class.DeclareFeature(..., "BRPlayerCharacterBase")`, must keep that return as the **final top-level return** of the Lua chunk.

Putting the entire original class module inside a `run_authorized_main()` or similar license callback moves its class return inside that function. It can cause a Lua parser failure such as an `end expected` error, or let the file compile while preventing the UE4 host from receiving the class module. A common visible symptom is that class-bound features such as ESP Box disappear even though global HUD overlays still render.

## Proven Single-File Layout

| Position | Required content | Rule |
|---|---|---|
| Top | Existing license constants, key persistence, canonical validation, Maintenance, Announcement, and Telegram helpers | Preserve their approved request contracts and privacy boundaries. |
| Middle | Original UE4 class module and Main/ESP definitions | Keep the original class code and feature table intact. |
| Before the module return | Authorized callback and license-entry UI/callback | The callback must start the deferred initializer only after canonical validation and any active-maintenance gate are cleared. |
| Final line | Original UE4 module return | Return the registered UE4 class module at top level, not from the authorization callback. |

## Safe Integration Procedure

First, identify the original Main/ESP initializer—for example, `InitAllModSystems`. Do not run this initializer immediately at file load. Store its closure under a fixed internal global name only while the license is not yet authorized.

Next, preserve the original module registration. Replace an immediate class return with a local module variable assignment. Keep the full `DeclareFeature` feature list and its module name unchanged.

The authorized callback must run only after the existing canonical license validation succeeds. It must then retrieve the deferred initializer, schedule or invoke that original initializer through the existing safe timer path, continue the existing announcement flow, and return its normal callback value. It must never wrap the original UE4 module definition inside the callback.

Finally, keep the login UI/callback below the module declaration, then return the stored UE4 module value as the chunk's final statement.

## Do Not Change Without Separate Approval

The following systems are protected and must retain their existing behavior: canonical `/api/license/validate` contract, server-side device binding, host-first identity policy, key and status file formats, Maintenance, Announcement, Telegram mapping/redirect, authentication and authorization, and the external/pickle verified loader.

No raw key, device ID, host identity, token, URL, or response body may be added to diagnostics or user-facing UI.

## Required Verification

| Check | Expected result |
|---|---|
| Lua 5.3 parser | `luac5.3 -p` succeeds. |
| Normal valid key | Login succeeds and the authorized initializer starts. |
| Invalid or mismatched key | Main/ESP initializer does not start. |
| ESP Box | Box renders on characters after valid login. |
| Existing overlays | Previously working tracer, label, health, and distance visuals remain operational. |
| Maintenance | Active maintenance blocks the authorized initializer. |
| Announcement and Telegram | Existing mapped flow remains unchanged. |

## Failure Signals

An `end expected ... near return` error after inserting a license wrapper generally means a return statement has been placed before later wrapper statements in the same function block. A file that compiles but has missing class-bound UI generally indicates that the original class module was returned from the wrong scope. Revert to the preserved working copy and apply this layout; do not patch individual ESP rendering calls blindly.
