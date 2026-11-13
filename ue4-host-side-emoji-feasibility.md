# UE4 Shared Popup Emoji Rendering — Host-Side Feasibility Assessment

**Status:** Read-only feasibility assessment. No production Lua, UE asset, OBB, APK, backend, panel, or verified Android behavior has been modified.

## Executive recommendation

It is **technically feasible** to make both shared `Msg.Show` popups render real emoji, but only through an authorized **UE4 host-project presentation-layer build**. The safest approach is to add an emoji-capable `FontFace` to a Runtime Composite Font and configure it as a fallback/sub-font range in the shared popup’s existing `RichTextBlock` style. This preserves the already verified Lua calls and passes the panel’s Unicode message through unchanged.

Reusing the existing chat-emoji sprites is technically possible only after creating and binding a RichText image-decorator and its image DataTable, then defining a markup/token contract. The inspected popup does not currently contain that contract. Because the existing popup receives literal Unicode text, this route would additionally need a safe character-to-markup transformation. It is therefore the higher-risk alternative and is **not recommended** for the first isolated fix.

> **Decision:** Prefer a dedicated emoji-capable Composite Font fallback that becomes the default font presentation of the existing shared popup. Do not modify the `Msg.Show(4, title, message, callback)` call, any Lua flow, or server/panel logic.

## What the verified build evidence establishes

The shared Android popup is `/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.Com_MsgBox_Slua_UIBP`. It contains `RichText_Content`, `RichText_ContentCentauri`, `RichText_ContentLeft`, and a `WidgetSwitcher_Font`. Both Maintenance and Announcement already travel through this one presentation surface.

The fully extracted OBB confirms that the actual popup package does not import the available `ChatEmojiUI` sprite resources, a RichText image decorator, or a decorator DataTable. It also confirms that the six actual TTF files packaged for the relevant font path have no `U+1F000`–`U+1FAFF` character-map entries and no color/bitmap emoji table. A Lua-only text-encoding change therefore cannot create glyphs or safely bind the separate chat sprites.

## Feasibility answers

| User question | Evidence-bounded answer |
|---|---|
| Can `Com_MsgBox_Slua_UIBP` be edited at Widget Blueprint level? | **Yes, in principle**, if the authorized owner has the matching UE4 project, its source assets, the same engine/game build toolchain, and Android packaging access. The safe operation is an asset-level change to the shared widget and its referenced font assets—not an extracted-OBB edit. |
| Is a dedicated emoji font safer than chat sprites? | **Yes.** A Composite Font fallback works on the literal Unicode message already assigned by the controller, needs no Lua transformation, and applies to all three RichText variants if configured as their default presentation. |
| Would one shared presentation fix cover Maintenance and Announcement? | **Yes**, provided the affected active RichText widget(s) all point to the updated default style/font. The existing Maintenance and Announcement code already calls the same shared `Msg.Show` widget path. |
| Must assets be repackaged? | **Yes.** UE assets are cooked for Android and then staged/packaged into deployment artifacts. A Widget Blueprint, FontFace, Font asset, and any DataTable/decorator change requires a matching UE4 cook/package cycle; extracted archives must not be manually patched. [1] |
| Can verified license/runtime systems remain untouched? | **Yes.** The recommended font fallback is a visual asset assignment. It does not require changes to validation, authorization, device binding, HTTP transport, Maintenance/Announcement state logic, Telegram redirect, or Main Lua continuation. |
| Is a Lua-only workaround possible if host editing is unavailable? | **No, not for genuine emoji.** The packaged popup has neither the required glyphs nor a proven inline-sprite decorator contract. Literal UTF-8 text cannot add missing font glyphs. |

## Safest implementation design: Composite Font fallback

Unreal Runtime Font assets are Composite Fonts. A Font asset has a default font family and may add sub-font families for specified character ranges; a `FontFace` stores reusable font data. [2] This model is a direct match for an emoji fallback.

The host owner should import a license-approved, Android-compatible emoji font as a `FontFace`, create or update a Runtime Composite Font, and map **only the explicitly supported emoji ranges** to that face. The desired modern range normally includes `U+1F000`–`U+1FAFF`. Any supporting symbols, variation selectors, zero-width joiner behavior, regional-indicator pairs, and skin-tone modifiers must be included only when the chosen font and UE4 Android renderer have been tested with those exact sequences.

The updated Composite Font must then be assigned to the default Text Style/Font property of every active `RichText_Content*` presentation used by the popup. The preferred first version uses the existing default switcher mode, because the current four-argument `Msg.Show` facade has no verified way to select `WidgetSwitcher_Font` index `1` or `2`. This avoids changing the Lua call contract.

| Required asset or capability | Why it is required | Acceptance check |
|---|---|---|
| Matching licensed UE4 project and build source | Only the project/editor can safely edit the Widget Blueprint and cook compatible Android content. | The original widget opens and recompiles without redirecting missing dependencies. |
| Exact UE4 version, game modules, Android SDK/NDK, signing/release workflow | Cooked assets and deployment must match the Android build’s compatibility rules. | A clean Development Android package launches before emoji testing. |
| License-approved emoji-capable font file | Supplies real glyph coverage missing from current packaged fonts. | Direct `cmap` inspection confirms all chosen test scalars. |
| New `FontFace` and Runtime Composite Font assets | Lets UE4 load and select the fallback at rendering time. | Font Editor preview renders the test matrix using the intended fallback. |
| Updated `Com_MsgBox_Slua_UIBP` default RichText font/style | Makes the fix shared without changing `Msg.Show`. | Default `Msg.Show` uses actual glyphs in each active RichText variant. |
| Android device test build | Desktop Editor preview cannot prove Android glyph/rendering behavior. | Maintenance and Announcement show the same emoji test matrix on target Android hardware. |

### Important color-emoji qualification

Glyph coverage is necessary but not enough to guarantee **color** emoji. Some emoji fonts depend on color/bitmap tables that a particular UE4 Android renderer may not support in the target game build. The first build must validate the selected font’s actual rendering on device. If the target renderer does not render its color tables, a font with acceptable monochrome glyphs can still meet a text-glyph requirement, but it does not meet a color-emoji requirement. Do not claim color support before the Android result is observed.

## Higher-risk alternative: chat-sprite RichText decorator

UMG `RichTextBlock` can render inline images through a DataTable and decorator class. Epic’s documented example uses `RichTextBlockImageDecorator`, a `Rich Image Row` DataTable, a decorator assigned to the widget’s `Decorator Classes` array, and markup such as `<img id="RowName"/>`. [3]

The available chat sprites could theoretically become rows in such a DataTable, but the existing `Msg.Show` popup contains none of those bindings. This route requires the host project to add the decorator, DataTable, correctly sized rows, widget binding, and a strict mapping from every permitted input emoji to sprite-row names. Literal Unicode input would also need presentation-only conversion to markup with escaping and a defined unsupported-character policy. A custom decorator may require C++ support in the game project. [3]

| Dimension | Composite Font fallback | Chat-sprite decorator |
|---|---|---|
| Works with current literal Unicode message | Yes | No; requires token/markup mapping. |
| Requires Lua contract change | No, if made default style | Usually yes unless the host converts text internally. |
| Supports arbitrary supported emoji set | Yes, based on font coverage | Only rows explicitly mapped to sprites. |
| Widget/asset complexity | FontFace + Composite Font + style binding | Decorator class + DataTable + sprite rows + widget decorator binding + mapping policy. |
| Risk to 300-character Unicode behavior | Low after on-device test | Higher: markup expansion, escaping, wrapping, and unexpected tags. |
| Recommended for this popup | **Yes** | No, unless font rendering fails and the host explicitly chooses a limited emoji catalog. |

## Required packaging and rollout process

The safe operation is to modify only the source UE project, then compile/cook/stage/package an Android test build. Cooking converts assets such as Blueprints and fonts into target-specific runtime content; packaging bundles cooked content into deployment artifacts such as PAK files. [1] The existing extracted OBB must remain evidence-only and must never be edited or recompressed as a distribution method.

The minimal rollout is a separate test branch/build containing only the new FontFace, Composite Font update, and `Com_MsgBox_Slua_UIBP` presentation assignment. No Lua source, HTTP endpoint, license code, database schema, or panel code should be included in that build diff. The host owner must verify that all new assets are referenced so the cook does not strip them; Unreal packaging removes unreferenced content. [1]

## Risks, controls, and rollback

| Risk | Control before release | Rollback |
|---|---|---|
| Font lacks a required emoji or sequence | Verify `cmap` and test an agreed Android emoji matrix, including allowed sequences. | Restore the prior Composite Font/Widget Blueprint and repackage the prior known-good build. |
| Color glyphs show monochrome, boxes, or `?` | Test the target font on the actual Android build before claiming color capability. | Return to the prior widget/font; do not alter Lua. |
| Text clipping, altered line height, or performance hitch | Test short/long messages, 300-character Unicode text, wrapping, and cold-show performance. Set loading policy deliberately. FontFace loading policies have different I/O and memory trade-offs. [2] | Reissue the known-good package; retain the previous signed build and asset source revision. |
| Inactive switcher variant is modified | Update the default active presentation only unless the host documents a switcher selection contract. | Revert only the Widget Blueprint/font asset change. |
| Chat sprites appear to work in chat but not the popup | Do not reuse without a bound decorator/DataTable and a tested markup contract. | No effect if the sprite route is not attempted. |
| Existing functional flows regress | Test strictly after normal valid login: Maintenance ON/OFF, Announcement ON/OFF, OK redirect, Cancel continuation, safe key replacement, and Main Lua. | Install/release the previous known-good Android package; server/panel state remains unchanged. |

Rollback is asset-build rollback, not a Lua rollback. Keep the current working source revision and signed Android artifact intact; build the presentation change on a separate branch/tag; retain manifest/version metadata; and distribute the new packaged artifact only after the visual and regression matrix passes. If any failure occurs, restore the original Widget Blueprint and Font asset references in source, recook/repackage, and reissue the prior known-good package. Do not edit a live OBB in place.

## Approval gate before implementation

Implementation should begin only after the owner confirms all of the following:

1. The matching UE4 project and Android packaging authority are available.
2. The chosen emoji font’s license permits embedding and redistribution.
3. The desired outcome accepts verified monochrome glyphs or explicitly requires color emoji.
4. The allowed emoji test matrix is defined.
5. The host owner approves an isolated source-asset change limited to the FontFace/Composite Font and `Com_MsgBox_Slua_UIBP` style assignment.
6. The prior working Android build is retained for rollback.

## References

[1] Epic Games, [Packaging Unreal Engine Projects](https://dev.epicgames.com/documentation/unreal-engine/packaging-your-project?lang=en-US).

[2] Epic Games, [Font Asset and Editor](https://dev.epicgames.com/documentation/unreal-engine/font-asset-and-editor-in-unreal-engine?lang=en-US).

[3] Epic Games, [UMG Rich Text Block — UE 4.27](https://dev.epicgames.com/documentation/unreal-engine/umg-rich-text-block?application_version=4.27).
