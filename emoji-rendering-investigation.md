# UE4 Android Emoji Rendering Investigation

## Scope

This record concerns only genuine emoji glyph rendering in the existing Android `Msg.Show` presentation path. It does not propose changes to validation, device binding, transport, maintenance/announcement decisions, Telegram, authentication, authorization, Super Owner controls, or Main Lua continuation.

## Current runtime boundary

The active Android Merged loader calls `Msg.Show(4, title, message, callback)` for both the Maintenance and Announcement popups. That documented-in-project call provides no font, fallback-font, rich-text style, inline icon, or asset argument. The loader's separate `RichText_Content` fallback is reached only when `Msg.Show` is unavailable, so it cannot correct the observed glyph replacement in the normal Android path.

No packaged `.ttf`, `.otf`, `.ttc`, UE asset, image/sprite asset, popup font selector, or runtime font-loading API is present in this project. Therefore, no genuine app-side emoji asset route has yet been identified.

## Newly traced host-controller path

An extracted host Lua source package is available outside this web project. It establishes the default path as follows:

1. `CommonMsgBoxMgr.Show` selects the default UI key `com_msg_box_slua` unless a caller provides an alternative `extraData.showUIKey`.
2. `CommonMsgBoxMgr.ShowNextMsgBox` invokes `UIManager.ShowUI(UIManager.UI_Config.com_msg_box_slua, msgData, ParamTable)`.
3. The controller source is `client.slua.umg.common.com_msg_box_slua` (`com_msg_box_slua.lua`). It writes the title to a `Title` TextBlock and the message to `RichText_Content`, `RichText_ContentCentauri`, and `RichText_ContentLeft` through `SetText`.
4. The controller contains `WidgetSwitcher_Font`. It defaults to widget index `0`; its only exposed controller operation is `SwitchText(index)`, which changes the active child widget. No `SetFont`, Font Face, Composite Font, fallback, or image-decorator API is exposed by the available controller source.

This confirms that the real font is preconfigured inside the `com_msg_box_slua` UE Widget Blueprint and/or its nested Text/RichText widgets. The supplied V3 archive adds the UI registry entry and establishes the exact default Widget Blueprint path as `/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.Com_MsgBox_Slua_UIBP`. It also shows that `extraData.switchTextType` selects index `1` and `extraData.leftAlign` selects index `2`. Those are preconfigured child-widget selectors only: neither identifies nor assigns a font. The current Android loader's four-argument `Msg.Show` facade has no verified route for sending `extraData`; the underlying `CommonMsgBoxMgr.Show` optional `extraData` is an eighth parameter.

The V3 archive inventory contains 21,112 Lua files and one extensionless file; it contains no `.uasset`, `.uexp`, `.ubulk`, `.pak`, `.ttf`, `.otf`, `.ttc`, texture, sprite, or other rendering binary. Its exact active font asset, fallback chain, and the glyph coverage of `WidgetSwitcher_Font` child widgets therefore cannot be truthfully identified from the supplied archive alone.

## Matching OBB container inventory

The supplied matching OBB is a 1,334,965,297-byte stored ZIP container. Its UE content resides in five PAK chunks, not as individually addressable Widget Blueprint or font files: `mini_obb.pak` (988,997,333 bytes), `mini_obb0_obb.pak` (612,121 bytes), `mini_obbzsdic_obb.pak` (87,636,505 bytes), `res_cachesyspkgdiffmini_obb.pak` (248,878,464 bytes), and `res_tempmini_obb.pak` (105,321 bytes). No file names within the outer OBB identify the message-box Widget Blueprint or font because those names, if present, are held by the PAK indexes.

The direct popup target remains `/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.Com_MsgBox_Slua_UIBP`. Further read-only work must inspect the appropriate PAK index and determine whether it is readable or encrypted before any widget/font resource can be identified.

## OBB PAK readability result

The main 988,997,333-byte PAK footer does not expose the normal readable UE PAK footer signature or a clear-text package index in the inspected tail bytes. Read-only byte searches across the OBB do not reveal `Com_MsgBox_Slua_UIBP`, `RichText_Content`, or the concrete `/Game/UMG/UI_BP/Common` path. The only generic `Roboto` string is visible at an OBB-level offset but cannot be associated with the popup widget or treated as evidence of the widget's configured font.

Consequently, the supplied OBB confirms the exact binary package location but does not provide a safely readable asset index or font chain for the target Widget Blueprint. The remaining trustworthy route is a matching unencrypted/extracted Widget Blueprint and its dependent font resources, or a UE project asset set that exposes the configured Composite Font and glyph fallback chain.

## Standard PAK index verification

An OBB-wide, read-only search found no standard UE PAK footer signature (`0x5A6F12E1`, little-endian `E1 12 6F 5A`) in any of the five contained PAK files. The target `Com_MsgBox_Slua_UIBP` package name is also absent from the readable OBB bytes. This rules out selective extraction with a normal unkeyed UE PAK reader from this attachment and provides no evidence of the actual `RichText_Content` font, `WidgetSwitcher_Font` variant fonts, Composite Font fallback, RichText decorator, texture, sprite, or DataTable dependencies.

The required missing host-side input is therefore either: (1) the matching package encryption/decryption configuration and approved readable asset export path, or (2) an unencrypted extract of the target Widget Blueprint plus all referenced font and presentation resources. No production Lua was changed during this inspection.

Epic's UMG documentation independently confirms this boundary: a Text widget selects its font in the Widget Blueprint's Appearance details, and UMG custom fonts use packaged Runtime Composite Font assets. The Font Editor documentation further confirms that Runtime fonts are Composite Fonts and Font Face data must be available in an asset for runtime loading. This supports the source finding that the missing Widget Blueprint/font package—not Lua text encoding—is the required next artifact. [1] [2]

## Official UE requirements

Epic documents that UMG custom fonts are selected through packaged Font/Font Face assets and, for UMG, Runtime Composite Font assets. Composite Fonts can assign sub-font families by character range, which is the correct asset-level mechanism for glyph fallback. RichText inline images additionally require a configured RichTextBlock, Data Table assets, and a decorator class in the UE project; they are not created by text markup alone. [1] [2] [3]

## Required host-side input before a genuine fix

One of the following must be supplied or exposed by the UE4 Android host:

1. The `Msg.Show` Widget Blueprint asset path plus a packaged Composite Font whose fallback family contains the required emoji glyphs; or
2. A supported runtime API that assigns a packaged Font asset to the `Msg.Show` title/message widgets; or
3. An already packaged RichText/image decorator and emoji sprite Data Table, with its asset paths and safe invocation contract.

Without one of these host-side capabilities, changing UTF-8/Lua strings cannot add absent emoji glyphs and would not be a genuine fix.

## Supplied `Com_MsgBox_Slua_UIBP` package-pair findings

The supplied `Com_MsgBox_Slua_UIBP.uasset` and matching `.uexp` are readable package artifacts. Read-only string and package-header inspection confirms that the package contains the concrete default Widget Blueprint path `/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP`, the text-related widget names `RichText_Content`, `RichText_ContentCentauri`, `RichText_UrlTips`, and `WidgetSwitcher_Font`, plus UE property/type names `Font`, `SlateFontInfo`, `TypefaceFontName`, and `UTRichTextBlock`.

The only readable candidate family name is `Roboto`. This is not yet proof that every `WidgetSwitcher_Font` child uses Roboto, nor that Roboto is an external packaged Font asset: it may be a serialized inline/default `FSlateFontInfo` family name. No readable `/Game/...` Font, Composite Font, FontFace, RichText decorator, emoji texture/sprite, or DataTable asset path is embedded in the currently recovered reference strings. `RichText_ContentLeft` is not visible in the direct readable strings of this specific package pair, although it remains present in the verified Lua controller contract.

The `.uexp` payload contains no clear-text `SlateFontInfo` token, so the actual per-widget serialized property values cannot be safely attributed from raw text alone. A UE package parser compatible with this build's custom package format, or the referenced font/dependency packages themselves, is still required to prove the active font and any emoji fallback coverage. No inference about emoji support has been made from the generic `Roboto` name.

An additional read-only parser route is available for the supplied package pair: [pyUE4Parse](https://github.com/MinshuG/pyUE4Parse) documents support for `.uasset`, `.uexp`, and `.ubulk` parsing, including JSON conversion. Its output still depends on selecting a compatible UE version and, for unversioned or ambiguous cooked properties, may require the matching mapping metadata. The [UAssetAPI documentation](https://atenfyr.github.io/UAssetAPI/) similarly identifies readable UE 4.13+ package support and optional `.usmap` mapping input for ambiguous/unversioned properties. These tools can inspect but will not modify the supplied package artifacts.

## Supplied `Roboto` Font package-pair findings

The supplied `Roboto.uasset` and `Roboto.uexp` pair is a real `/Script/Engine.Font` export named `Roboto`, using `EFontCacheType::Runtime` with a `CompositeFont` property. It directly references the five standard Roboto FontFace assets and the additional `PSLKandaProBold`, `Hortademo`, `NotoSansArabicUI-edit`, `NotoSansDevanagari-Bold`, and `NotoSansMyanmar_ExtraCondensed-SemiBold` FontFace assets. This proves a configured Runtime Composite Font chain, but does not prove that the shared popup’s active RichText switcher variant uses it.

No matching FontFace asset pair, font payload, or `Roboto*.ubulk` companion was supplied. The pair contains no independently inspectable TrueType/OpenType payload or glyph `cmap`; therefore emoji support cannot be inferred from `Roboto`, `Noto`, or `Hortademo` names. No aligned serialized U+1Fxxx emoji-range assignment was recovered. The evidence-safe result is that this is a promising font configuration dependency, but **not yet a proven emoji fallback**. The exact dependency list and next asset request are retained in `roboto-font-package-findings.md`.

No production Lua or verified flow was changed. The remaining requirements are: the actual FontFace package data to inspect glyph coverage, a decoded Widget Blueprint reference that connects a specific `WidgetSwitcher_Font` child to this Composite Font, and a verified host contract to choose that child if it is not the existing default.

## Follow-up `FontFace` pair inspection

The supplied `RobotoRegular`, `Hortademo`, and `PSLKandaProBold` package pairs each resolve to a `/Script/Engine.FontFace` with a serialized source filename, respectively `Roboto-Regular.ttf`, `Horta demo.ttf`, and `PSLKandaProBold.ttf`. Each pair is only 628–647 bytes for `.uasset` and 93–95 bytes for `.uexp`; none contains an inspectable SFNT/OpenType payload, `cmap`, color-emoji table signature, or same-name `.ubulk` companion. The package metadata therefore cannot prove an emoji glyph, a Unicode range, a cooking/loading policy, or a runtime path.

The conclusion remains deliberately narrow: the supplied FontFace *metadata* does not rule emoji glyphs out, but it cannot establish them either. The actual matching font data is still required, together with the existing Widget Blueprint switcher binding and safe `Msg.Show` invocation proof. A Lua workaround or blind font-switcher change remains prohibited. Full hashes, source metadata, and the exact next artifact request are preserved in `roboto-font-package-findings.md`.

## Supplied TrueType glyph evidence

Six actual TTFs have now been inspected directly. `Roboto-Regular`, `Roboto-Bold`, `Roboto-Light`, `DroidSansFallback`, `DroidSansMono`, and `NotoNaskhArabicUI-Regular` each expose **zero** `cmap` mappings in `U+1F000`–`U+1FAFF`; none contains a color/bitmap emoji table. This is conclusive for the supplied bytes: none contains the common popup emoji scalars tested, including grinning face, thumbs up, fire, party popper, rocket, or loudspeaker.

The `Roboto-Regular.ttf` filename corresponds to the serialized authoring filename of the supplied `RobotoRegular` FontFace, but that cooked FontFace does not retain a hash that proves the uploaded TTF is byte-identical. The evidence is nevertheless sufficient for the current decision: even if it is the exact font, it cannot render modern emoji. `DroidSansFallback.ttf` has some monochrome dingbat coverage—including `U+2764`—but no modern emoji mappings or variation selector `U+FE0F`; it is neither referenced by the supplied Composite Font nor a genuine generic emoji fallback.

The still-uninspected Composite Font faces are `Hortademo`, `PSLKandaProBold`, `NotoSansArabicUI-edit`, `NotoSansDevanagari-Bold`, and `NotoSansMyanmar_ExtraCondensed-SemiBold`. Their exact matching TTF/bulk data is required for the final glyph check. The separate existing blocker remains: no decoded binding proves which popup switcher child uses this Composite Font and no safe `Msg.Show` font/widget-selection contract has been found. No implementation change is authorized.

## Final available-resource conclusion

The user confirmed that the complete available TTF set is limited to the six supplied files and that no matching `.ubulk` files or separate TTFs exist for the other referenced FontFace names. This is now treated as an **availability boundary**, not as evidence that undisclosed resources must exist.

| Question | Evidence-bounded answer |
|---|---|
| Which faces are configured in the supplied `Roboto` Runtime Composite Font? | The configuration directly references the five Roboto style faces—Regular, Bold, Italic, Bold Italic, Light—and the five additional faces `PSLKandaProBold`, `Hortademo`, `NotoSansArabicUI-edit`, `NotoSansDevanagari-Bold`, and `NotoSansMyanmar_ExtraCondensed-SemiBold`. `SubTypefaces` is serialized, so range-based selection exists in the asset. |
| Which face is assigned to each popup `WidgetSwitcher_Font` index? | **Not established.** The supplied Widget Blueprint identifies the switcher and three RichText widgets, but does not decode a per-index font assignment. The controller sets text only and the active four-argument `Msg.Show` facade has no verified presentation-data contract. |
| Does any available actual font byte resource carry modern emoji? | **No.** Every available TTF has zero `cmap` values in `U+1F000`–`U+1FAFF` and no color/bitmap emoji table. |
| Can a hidden/unextractable PAK payload be declared absent? | **No.** Read-only inspection cannot prove a negative about inaccessible package content. It also cannot provide a safe resource to reuse. |
| Can genuine modern emoji be delivered now using the known current popup resources? | **No.** No named, inspectable, emoji-capable FontFace/fallback is available and no safe font/widget selection route is proven. A Lua-only change would be speculative and is prohibited. |

> **Final engineering decision:** From the complete set of *available and inspectable* packaged resources, genuine modern emoji rendering in the Android `Msg.Show` popup is **not currently implementable safely**. The existing `?` result is consistent with missing glyph coverage in every available candidate. This does not alter any verified feature.

### Safe non-implementation alternative

The safe future alternative is a **host-side UE4 presentation change**, isolated from all license and runtime logic. The host owner would package a UE4-compatible FontFace with verified coverage for the allowed popup emoji set, add it as a Runtime Composite Font sub-family over the intended Unicode ranges (`U+1F000`–`U+1FAFF`, and any explicitly supported symbol/variation-selector ranges), and bind that Composite Font to the actual popup RichText widget(s) in `Com_MsgBox_Slua_UIBP`. If color emoji is required, the target UE4 Android renderer must separately demonstrate support for that font’s color-glyph technology; monochrome glyph coverage alone is not a color-emoji guarantee.

That host change must also either make the emoji-capable style the existing default popup presentation or expose a documented `Msg.Show` presentation argument. Only after those two host facts are verified should an isolated Android test use Maintenance and Announcement messages with a small documented emoji test matrix. No license validation, key replacement, device binding, Maintenance scheduling, Announcement behavior, Telegram flow, transport, or Main Lua changes are needed for that asset-level path.

## Extracted OBB archive confirmation

The user subsequently provided read-only extracted-OBB ZIP archives: `mini_obbzsdic_obb.zip` (129 MB, SHA-256 `3cddd43ed5157bafbff647d98189a606d09e727c6676138f237f74a7d1ac4536`) and `mini_obb.zip` (1,000 MB, SHA-256 `64d4d4e72982b4fa1afdb31a75192361a43d373e58b1997ecae5e71450523447`). This removes the prior PAK-index uncertainty for the assets present in those archives, but it does not change the emoji conclusion.

The exact Widget Blueprint pair at `ShadowTrackerExtra/Content/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.uasset` and `.uexp` hash-matches the previously supplied package pair. It therefore confirms that all earlier widget findings apply to this extracted Android build: `UTRichTextBlock`, `RichText_Content`, `RichText_ContentCentauri`, `WidgetSwitcher_Font`, and the serialized `Roboto` identifier are present; no per-index font choice is decoded. There is no same-name `.ubulk` companion.

| Extracted evidence | Read-only result | Emoji consequence |
|---|---|---|
| `Roboto` Composite Font and ten FontFace references | Same exact `Roboto`, `RobotoRegular`, `Hortademo`, and `PSLKandaProBold` package bytes as previously inspected; the other configured FontFace metadata is present under the expected paths. | Confirms the prior Composite Font chain, but does not supply a new emoji-capable face. |
| Actual font files in the extracted archive | Exactly six font files exist: `DroidSansFallback.ttf`, `DroidSansMono.ttf`, `NotoNaskhArabicUI-Regular.ttf`, `Roboto-Bold.ttf`, `Roboto-Light.ttf`, and `Roboto-Regular.ttf`. Each hash-matches the TTF supplied and inspected earlier. | The prior direct `cmap` conclusion now applies to this extracted Android build: all six have zero `U+1F000`–`U+1FAFF` mappings and no color/bitmap emoji table. |
| Remaining configured FontFace source records | `Hortademo`, `PSLKandaProBold`, `NotoSansArabicUI-edit`, `NotoSansDevanagari-Bold`, and `NotoSansMyanmar_ExtraCondensed-SemiBold` retain only their serialized source-file metadata; no matching named font file or same-name bulk file exists in the supplied extracted archive. | No glyph coverage can be claimed for those configuration names, and no usable resource may be assumed to exist. |
| Bulk resources | The archives contain unrelated `.ubulk` entries globally, but none with the popup or configured-font candidate names. | No target widget/font bulk payload is available to inspect or reuse. |
| Existing emoji sprites | The archive contains 248 emoji-named entries and 128 `ChatEmojiUI/Frames` assets, including `EmojiAtlas`. | These are separate sprite/texture assets, not a verified text fallback. |
| Popup widget dependencies | The exact popup import table includes only its non-emoji background/button/notice/question PaperSprite assets and the default `UTRichTextBlock` class. It has no `ChatEmojiUI`, emoji texture, RichText image-decorator, or DataTable dependency. | The shared popup has no evidence-backed route to render those separate sprite assets inline. |

The string `Decorator` remains a generic serialized identifier in the popup package; it is **not** an imported decorator resource or a safe sprite contract. Archive filename discovery found no explicit RichText emoji-decorator asset, and the available chat-emoji Lua files are compiled bytecode that cannot be read by the available Lua decoder due to an incompatible bytecode version. That failed decoding is not treated as proof of an API. More importantly, the target popup itself does not reference the chat sprite assets.

> **Updated final conclusion:** The fully extracted archives confirm rather than overturn the earlier result. They contain genuine chat emoji sprites, but the verified `Msg.Show` popup neither imports those assets nor exposes a documented RichText/decorator or font-selection invocation route. The actual TTF set in the same Android build lacks modern emoji glyphs. Therefore no existing packaged resource can be safely reused for Maintenance or Announcement popup emoji rendering without a host-side Widget Blueprint/decorator/font change. No Lua or verified system was modified.

## References

[1] Epic Games, [Font Asset and Editor](https://dev.epicgames.com/documentation/unreal-engine/font-asset-and-editor-in-unreal-engine?lang=en-US).

[2] Epic Games, [Using Fonts with UMG (UE 4.27)](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-fonts-with-umg?application_version=4.27).

[3] Epic Games, [UMG Rich Text Blocks](https://dev.epicgames.com/documentation/en-us/unreal-engine/umg-rich-text-blocks-in-unreal-engine).
