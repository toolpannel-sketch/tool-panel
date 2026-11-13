# `Com_MsgBox_Slua_UIBP` Read-Only Package Findings

## Scope and provenance

The user supplied the matching UE4 Widget Blueprint package pair:

- `Com_MsgBox_Slua_UIBP.uasset`
- `Com_MsgBox_Slua_UIBP.uexp`

No package bytes were changed and no production Lua, backend, panel, or Android runtime flow was changed.

## Confirmed popup chain

| Layer | Evidence-backed finding |
|---|---|
| Widget Blueprint | `/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.Com_MsgBox_Slua_UIBP` |
| Controller | `client.slua.umg.common.com_msg_box_slua` |
| Switcher | `WidgetSwitcher_Font`; controller selects index `1` for `extraData.switchTextType` and index `2` for `extraData.leftAlign`; default is index `0` |
| Popup text widgets | `RichText_Content`, `RichText_ContentCentauri`, and `RichText_ContentLeft` are named in the package and controller path |
| Asset package strings | The `.uasset` contains `Roboto`, `SlateFontInfo`, `Font`, `Default__UTRichTextBlock`, `WidgetSwitcher`, and the three popup RichText widget names |
| Visual assets | Only existing popup/background/button/notice/question texture paths were recovered, including `Common_Icon_Notice_png` and `Common_Icon_Question_png`; no emoji texture or sprite was recovered |

## Current limits of the evidence

The readable name map proves a `Roboto`/`SlateFontInfo` serialization is present, but it does **not** identify which of the three RichText switcher variants uses it, nor does it expose a Composite Font/Font Face object path, fallback chain, font file payload, or emoji glyph coverage. The companion `.uexp` similarly yielded no named Font/Composite Font/FontFace/decorator/DataTable/emoji-sprite dependency.

Therefore it is not evidence-safe to switch `WidgetSwitcher_Font` blindly, claim that Roboto is the active font, or claim emoji support. A genuine fix still requires a decoded UE4 export/property table with the object references, or all Font/Composite Font/FontFace and RichText decorator dependencies exported from the matching UE project/package.

## Existing controller contract

The controller’s `SwitchText(index)` method only calls `self.UIRoot.WidgetSwitcher_Font:SetActiveWidgetIndex(index)`. It does not assign fonts. `HandleSwitchTextType()` calls `SwitchText(2)` for `leftAlign` and then `SwitchText(1)` for `switchTextType`; otherwise the default index remains `0`.

This is an existing presentation setting, not proof of an emoji-capable font or a safe shared Maintenance/Announcement rendering mechanism.

## Supplied `Roboto` configuration dependency

The separately supplied `Roboto.uasset` + `.uexp` pair now establishes that `/Engine/EngineFonts/Roboto.Roboto` is a UE Runtime Composite Font configuration. It references five Roboto FontFace assets and five additional FontFace resources: `PSLKandaProBold`, `Hortademo`, `NotoSansArabicUI-edit`, `NotoSansDevanagari-Bold`, and `NotoSansMyanmar_ExtraCondensed-SemiBold`.

That finding narrows the required asset set, but it does not change the widget conclusion: the provided Widget Blueprint package does not show which switcher index uses that font, and the provided Font package does not include the FontFace glyph data needed to prove emoji coverage. The evidence-only dependency details are recorded in `roboto-font-package-findings.md`. No switcher index or Lua call was changed.
