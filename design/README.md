# noScroll — Design

Single source of truth for noScroll's brand and UI tokens. Both apps mirror these values; when a
token changes here, update the platform themes to match.

## Files

| File | What it is |
|---|---|
| [`tokens.json`](tokens.json) | Palette, semantic light/dark colors, radius, spacing, typography. The canonical token set. |
| [`logo-mark.svg`](logo-mark.svg) | The bare mark — feed lines cut by a hard slash. |
| [`app-icon.svg`](app-icon.svg) | App icon (ink rounded tile, white feed lines, baby-blue slash). |
| [`brand-identity.html`](brand-identity.html) | Brand board: wordmark, palette, taglines, personality. |

## Palette

| Token | Hex | Role |
|---|---|---|
| Ink | `#0B1120` | dark base / anchor / dark surfaces |
| Slate | `#55606B` | secondary / muted text |
| **Pop Blue** | `#1F6BFF` | **primary accent** — CTAs, the slash |
| Deep Blue | `#1650D6` | pressed state |
| Baby Blue | `#9FD8F5` | signature accent / light highlight |
| Cloud | `#F2FAFF` | light surface / background |
| White | `#FFFFFF` | surfaces / negative space |

> Note on the name: pure baby-blue-and-white reads soft on its own, so Ink carries the contrast
> and Pop Blue carries the punch — Baby Blue stays the signature color without being asked to
> do all the work alone.

## Brand ethos

Blunt, tough, no wasted motion — the anti-doomscroll app, not a wellness spa. Raw and honest ·
no paywall on the basics · built in the open · anti-corporate · no dark patterns. The product UI
should feel the same: direct, fast, no manipulation, no guilt loops.

## Where these tokens live in code

- **iOS:** `ios-app/Packages/FlintCore/Sources/FlintCore/FlintBrand.swift` — hex values mirrored here; symbol names still say `Flint*` pending the code-identifier rename.
- **Android:** `android-app/core/core-common/.../theme/FlintTheme.kt` + `android-app/app/src/main/res/values/colors.xml` — hex values mirrored here; symbol/resource names still say `Flint*`/`flint_*` pending the code-identifier rename.

> No codegen for v1 — tokens are mirrored by hand. If the set grows, add a generator that emits
> a Swift `Color` extension and a Kotlin `Color` file from `tokens.json`.
