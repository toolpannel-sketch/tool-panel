# `Roboto` UE4 Font Package — Read-Only Findings

## Scope and integrity

This record covers only the user-supplied `/home/ubuntu/upload/Roboto.uasset` and `/home/ubuntu/upload/Roboto.uexp` pair. Both files were read as bytes only. No APK, OBB, PAK, UE asset, Lua loader, server route, panel, database record, or Android runtime path was modified.

| Supplied artifact | Size | SHA-256 |
|---|---:|---|
| `Roboto.uasset` | 2,675 bytes | `069cc20096ab80f1c496de5dbf5c3bb80b29fa3f07eb5a1f93086729669a5c48` |
| `Roboto.uexp` | 6,877 bytes | `e7ad7b9fe3ef4b8549ce6d117c2bf4ead1e878380a680d8af061f3e5bd53b10b` |

## What the package proves

The package has one exported object, named `Roboto`, whose class is `/Script/Engine.Font`. Its serialized `FontCacheType` is `EFontCacheType::Runtime`, and it contains a `CompositeFont` property. This is a genuine UE Runtime Composite Font configuration rather than a plain text label. Epic documents Runtime fonts as Composite Fonts, consisting of a default family and optional sub-font families selected by character range. [1]

The package imports and actually references the following `FontFace` objects in its export data. The five Roboto faces are the default-family candidates; the remaining faces are additional composite-family resources. The package’s `SubTypefaces` property is also present and serialized as an array of `CompositeSubFont` data, confirming that range-based sub-font configuration exists in this asset.

| Referenced UE FontFace asset path | Direct reference observed in `Roboto.uexp` | Evidence-safe interpretation |
|---|---:|---|
| `/Engine/EngineFonts/Faces/RobotoRegular.RobotoRegular` | Yes | Default Roboto family face resource |
| `/Engine/EngineFonts/Faces/RobotoBold.RobotoBold` | Yes | Default Roboto family face resource |
| `/Engine/EngineFonts/Faces/RobotoItalic.RobotoItalic` | Yes | Default Roboto family face resource |
| `/Engine/EngineFonts/Faces/RobotoBoldItalic.RobotoBoldItalic` | Yes | Default Roboto family face resource |
| `/Engine/EngineFonts/Faces/RobotoLight.RobotoLight` | Yes | Default Roboto family face resource |
| `/Engine/EngineFonts/PSLKandaProBold.PSLKandaProBold` | Yes | Additional composite-face resource; glyph range cannot be established from this pair alone |
| `/Game/UMG/Font/Hortademo.Hortademo` | Yes | Additional composite-face resource; glyph range cannot be established from this pair alone |
| `/Game/UMG/Font/NotoSansArabicUI-edit.NotoSansArabicUI-edit` | Yes | Additional composite-face resource; glyph range cannot be established from this pair alone |
| `/Game/UMG/Font/NotoSansDevanagari-Bold.NotoSansDevanagari-Bold` | Yes | Additional composite-face resource; glyph range cannot be established from this pair alone |
| `/Game/UMG/Font/NotoSansMyanmar_ExtraCondensed-SemiBold.NotoSansMyanmar_ExtraCondensed-SemiBold` | Yes | Additional composite-face resource; glyph range cannot be established from this pair alone |

## What the package does **not** prove

The supplied package is a Composite Font *configuration*. It does not include the corresponding `FontFace` package pairs or an independently readable font payload. No `OTTO`, `ttcf`, `wOFF`, `wOF2`, or normal SFNT header was found in the supplied two files, and no `Roboto*.ubulk` companion was supplied. This prevents an actual `cmap` inspection of the referenced font faces.

Consequently, the following conclusions are **not** supportable from the supplied pair:

| Question | Result | Reason |
|---|---|---|
| Does the target popup’s active switcher child use this `Roboto` asset? | Not proven | The Widget Blueprint package proves a `Roboto` identifier, but not the object reference assigned to indices `0`, `1`, or `2`. |
| Does any referenced face contain U+1Fxxx emoji glyphs? | Not proven | The actual FontFace payloads and their `cmap` tables are absent. |
| Does the composite font map an emoji range to a particular sub-face? | Not proven | The cooked `SubTypefaces` serialization is present but cannot be fully decoded without the matching package mapping/version metadata; no aligned U+1Fxxx range value was recovered. |
| Is `Hortademo` an emoji-capable fallback? | Not proven | Its name alone is not glyph-coverage evidence. |
| Is there a UE RichText emoji decorator, sprite, texture, or DataTable fallback in this asset? | No such dependency is referenced by this supplied Font asset | A Font asset cannot establish a popup RichText decorator contract; the popup Widget Blueprint still needs separate evidence. |

> **Decision:** This package identifies a real Runtime Composite Font chain, but it does **not** prove a usable emoji-glyph fallback. It must not be selected blindly through `WidgetSwitcher_Font`, and it does not justify any Lua-only change.

## Exact next asset request

To verify glyph support instead of inferring it from names, provide the matching package pair for every imported `FontFace` listed above:

`<AssetName>.uasset` + `<AssetName>.uexp`, and `<AssetName>.ubulk` **only if it exists beside that FontFace asset**. The highest-priority files are:

1. `RobotoRegular.uasset` and `RobotoRegular.uexp`.
2. `Hortademo.uasset` and `Hortademo.uexp`.
3. `PSLKandaProBold.uasset` and `PSLKandaProBold.uexp`.
4. `NotoSansArabicUI-edit.uasset` and `NotoSansArabicUI-edit.uexp`.
5. `NotoSansDevanagari-Bold.uasset` and `NotoSansDevanagari-Bold.uexp`.
6. `NotoSansMyanmar_ExtraCondensed-SemiBold.uasset` and `NotoSansMyanmar_ExtraCondensed-SemiBold.uexp`.

The four additional Roboto face pairs are needed if the UE typeface chooses style-specific faces: `RobotoBold`, `RobotoBoldItalic`, `RobotoItalic`, and `RobotoLight`.

## Supplied `FontFace` package-pair follow-up

The requested high-priority FontFace pairs were supplied and inspected read-only. Each is a tiny `/Script/Engine.FontFace` package that preserves only its `SourceFilename` metadata. None includes an inspectable SFNT/OpenType payload, a `cmap` table, color-emoji tables (`COLR`, `CBDT`, or `sbix`), or a same-named `.ubulk` companion. Consequently, none can establish that a particular emoji codepoint exists in the actual cooked face.

| Asset | Supplied size (`.uasset` / `.uexp`) | `SourceFilename` serialized in export data | Emoji-glyph result |
|---|---:|---|---|
| `RobotoRegular` | 647 / 94 bytes | `../../Content/Slate/Fonts/Roboto-Regular.ttf` | Not testable from supplied package pair; no font payload/cmap is present. |
| `Hortademo` | 628 / 93 bytes | `C:/Users/lionelzheng/Desktop/Horta demo.ttf` | Not testable from supplied package pair; no font payload/cmap is present. |
| `PSLKandaProBold` | 645 / 95 bytes | `../../Content/EngineFonts/PSLKandaProBold.ttf` | Not testable from supplied package pair; no font payload/cmap is present. |

The exact source-file strings prove only the authoring inputs; they do **not** identify a usable Android runtime path or prove that the font bytes retained their original glyph coverage after cooking. A byte-level scan also found no `OTTO`, `ttcf`, `wOFF`, `wOF2`, `cmap`, `glyf`, `COLR`, `CBDT`, `sbix`, or normal SFNT header in any supplied pair.

> **Updated decision:** `RobotoRegular`, `Hortademo`, and `PSLKandaProBold` cannot currently be approved as a genuine emoji fallback. This is an evidence limitation—not proof that the underlying fonts lack emoji. The missing evidence is the cooked font-data payload that contains the character map.

### Exact next requirement

For each candidate, provide the matching same-name `.ubulk` file if one exists in the cooked content. If no `.ubulk` exists, provide the actual cooked embedded font-data payload or the original `.ttf` that is confirmed to be the one packaged by this Android build. The minimum next candidates are `Hortademo` and `PSLKandaProBold`, because they are the non-Roboto faces in the Composite Font that could conceivably have custom fallback coverage. The remaining three Noto face package/data sets are also still required to verify their configured ranges and glyphs.

Even if one face proves emoji coverage, an implementation remains blocked until the Widget Blueprint proves which of `WidgetSwitcher_Font` indices `0`, `1`, or `2` binds this Composite Font and the host exposes a safe, confirmed way for `Msg.Show` to select that variant. No index will be changed speculatively.

## Supplied TrueType glyph-map results

Six actual TTF files were subsequently supplied and read-only inspected using their embedded `cmap` tables. All six have **zero** mapped Unicode scalars in the modern emoji range `U+1F000`–`U+1FAFF`. None has a color/bitmap emoji table (`COLR`, `CPAL`, `CBDT`, `CBLC`, `sbix`, or `SVG`). The common Android popup test characters `U+1F600` (grinning face), `U+1F44D` (thumbs up), `U+1F525` (fire), `U+1F389` (party popper), `U+1F680` (rocket), and `U+1F4E2` (loudspeaker) are absent from every supplied font.

| Supplied file | Family reported by its TTF metadata | `U+1F000`–`U+1FAFF` cmap scalars | Color/bitmap emoji tables | Composite Font correlation | Rendering decision |
|---|---|---:|---|---|---|
| `Roboto-Regular.ttf` | Roboto Regular | 0 | None | Filename matches the `RobotoRegular` FontFace’s serialized source filename, but the cooked asset has no content hash to prove byte identity | Cannot render the required emoji. |
| `Roboto-Bold.ttf` | Roboto Bold | 0 | None | Corresponds by filename family to the imported Roboto Bold style | Cannot render the required emoji. |
| `Roboto-Light.ttf` | Roboto Light | 0 | None | Corresponds by filename family to the imported Roboto Light style | Cannot render the required emoji. |
| `DroidSansFallback.ttf` | Droid Sans Fallback | 0 | None | Not referenced by the supplied `Roboto` Composite Font | Cannot be a generic modern-emoji fallback. It has `U+2764` only as a monochrome symbol and lacks `U+FE0F`; that does not meet the requested emoji path. |
| `DroidSansMono.ttf` | Droid Sans Mono | 0 | None | Not referenced by the supplied `Roboto` Composite Font | Cannot render the required emoji. |
| `NotoNaskhArabicUI-Regular.ttf` | Noto Naskh Arabic UI | 0 | None | Not the same asset as the configured `NotoSansArabicUI-edit` FontFace | Cannot render the required emoji. |

This replaces the former glyph-coverage uncertainty for these specific files: their modern emoji coverage is now conclusively absent. It does **not** answer the still-missing `Hortademo`, `PSLKandaProBold`, `NotoSansArabicUI-edit`, `NotoSansDevanagari-Bold`, or `NotoSansMyanmar_ExtraCondensed-SemiBold` data files. None of the supplied TTFs is a genuine existing resource that can be selected to fix the popup.

> **Current decisive blocker:** the supplied actual font data proves that the available Roboto/Droid/Noto-Naskh candidates do not carry the required modern emoji glyphs. The remaining uninspected Composite Font faces must be checked by their actual matching TTF/bulk data. If they also lack the requested codepoints, the exact missing host dependency is a UE4-compatible FontFace/Runtime Composite Font containing those codepoints and assigned to the popup in the Widget Blueprint. The four-argument `Msg.Show` path still provides no verified method to select a different widget or font.

For a successful genuine emoji path, at least one provided face must yield inspectable glyph coverage for the exact test emoji, and a decoded Widget Blueprint property reference must show which RichText switcher child uses this Composite Font. If no listed face has that coverage, the required host-side addition is an already packaged or newly approved UE `FontFace`/Composite Font containing the required emoji glyphs, assigned in the Widget Blueprint—not a UTF-8 or Lua workaround. Epic’s documentation confirms that sub-font families are the asset-level range mechanism and that Font Face assets hold the reusable font data. [1]

## Current implementation status

No production change is authorized or technically justified yet. The established four-argument Android `Msg.Show(4, title, message, callback)` call still has no verified font-selection or `extraData` route, and the target popup’s active index remains unproven. Maintenance, Announcement, Telegram redirect, validation, safe rebind, device binding, and Main Lua remain untouched.

## Final available-resource disposition

The available Android font evidence is now complete: the only supplied TTF files are `Roboto-Regular`, `Roboto-Bold`, `Roboto-Light`, `DroidSansFallback`, `DroidSansMono`, and `NotoNaskhArabicUI-Regular`; no matching `.ubulk` or separate TTF data is available for the five other Composite Font references. The known actual TTF bytes have no modern emoji character-map coverage. The other five FontFace entries remain configuration names with no inspectable glyph data; their absence from the available package must not be turned into an assumption that a usable asset exists elsewhere.

Accordingly, no current, evidence-backed asset can be reused to render real modern emoji in the shared popup. The only safe path is a host-side UE4 asset/presentation addition: package a verified emoji-capable FontFace, configure it as a Composite Font fallback in the popup Widget Blueprint, and use a documented default or `Msg.Show` selection contract. This is a future recommendation only; it has not been implemented.

## References

[1] Epic Games, [Font Asset and Editor](https://dev.epicgames.com/documentation/unreal-engine/font-asset-and-editor-in-unreal-engine?lang=en-US).
