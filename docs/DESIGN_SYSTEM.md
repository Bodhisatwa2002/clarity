# Clarity — Design System

| | |
| --- | --- |
| **Source of truth** | [Clarity design system](https://claude.ai/artifact/8hxtY8V5jf9jemD3diWiav) (live previews of every component) |
| **Built from** | The Clarity screen designs (`Clarity App Design.html`, 390×844) and the landing page |
| **In this repo** | [`design-system/tokens.json`](./design-system/tokens.json) (snapshot of the tokens) · [`design-system/clarity-mark.svg`](./design-system/clarity-mark.svg) (logo) |
| **In code** | `lib/core/theme/` (`AppColors`, `AppGradients`, `AppShadows`, `AppText`) · `lib/features/shared/widgets/` |
| **Last synced** | 2026-10-10 |
| **Related** | [`PRD.md`](./PRD.md) · [`ARCHITECTURE.md`](./ARCHITECTURE.md) · [`../AGENTS.md`](../AGENTS.md) §5 |

When the design system changes, update the live system first, then refresh
`design-system/tokens.json`, this file and the Flutter tokens in the same PR.

---

## 1. Brand

**Clarity — honest places, from people you trust.** An iPhone app (Android
later) where you log every place you've been with a short review, sync your
contacts, and open your friends' maps. This system covers the app screens and
the marketing site.

## 2. Content fundamentals

Write like a friend giving a tip, not like a listings site.

| Rule | Do | Don't |
| --- | --- | --- |
| Plain and short | "Go before 4pm." | "Visitors are advised to arrive early." |
| Second person, present tense | "Your map starts with one place." · "12 of your contacts are here." | "The user's map is empty." |
| Name real things | Place names, first names, categories | "Lorem", "User 1" |
| Buttons say exactly what happens | Send code · Verify & continue · Add to a list · Post review | Submit · OK |
| Errors say what to do next | "Still no connection. We'll keep trying in the background." | Apologies, bare error codes |
| Privacy in plain words | "Numbers are matched, then deleted." | Legalese on product screens |
| Indian context is the default | +91 first, ₹ budgets (₹ to ₹₹₹₹), dhabas, momo stalls, homestays | US-first examples |

**Key phrases to reuse:** *Who's been here?* · *One thing to know* · *Want to
go* · *Visited* · *Not recommended* · *Friends' rating* · *Taste match*.

## 3. Visual foundations

Four moves make a screen look like Clarity. Use all four; add nothing else.

1. **Blue gradient ground.** `gradient-screen` for full-screen moments
   (onboarding, Add a place, Offline). `gradient-header` behind tab screens,
   with a white sheet (`surface`, top corners `radius-lg`) rising over it.
2. **Glass circles.** One per screen at most: a disc filled with
   `gradient-glass`, a 1px white border at 65%, `shadow-glass`, and often a
   `mint` progress ring. They hold the logo, a rating (`stat` style) or a single
   icon.
3. **Dashed pills.** Chips, tags and secondary buttons use a 1.5px **dashed**
   border on `radius-pill`. Selected chips turn solid `ink` with white text.
   Highlighted chips use `blue-100` fill with a `blue-500` dashed border.
4. **Black pill actions.** The one primary action per screen is a full-width
   `ink` pill, `button-h` tall. The bottom nav bar is the same black pill.

### Headline pattern

Sans headline (Manrope 700, tight tracking) with **one** italic serif phrase
(Newsreader): "Your friends' *honest opinions,* on a map." · "Make it *yours*" ·
"No pins *yet*". One italic phrase per headline, never two. In Flutter:
`AccentTitle`.

### Colour rules

- Text on `blue-600`: white, or `on-blue-muted` for subtitles. Over the lower
  third of `gradient-screen`, switch to `navy-900`.
- `mint` is decoration only: rings, dots. It fails as text on white.
- Category colours appear only as map pins and 8px dots next to a label. Never
  as text, never as fills behind text. Food and Café differ in lightness so they
  read apart.
- State: `success` / `success-bg` for verified and saved; `danger` /
  `danger-bg` for delete and errors.

### Layout

- App screens are `screen-w` (390px) wide. Side gutter `space-5` on blue,
  `space-4` inside the sheet.
- Headers start `space-7` from the top (in Flutter: `Layout.y()` / `Layout.top()`
  adjust this for each device's status bar).
- Cards: `surface-2`, `radius-md`, padding `space-4`, gap `space-2` between
  cards. No shadows on cards inside the sheet; `shadow-card` only for things
  floating over a map.
- The bottom nav floats `space-4` from the sides and 26px from the bottom.
  Leave about 120px of bottom padding in any scrolling sheet
  (`Layout.navClearance`).
- Touch targets are at least `tap-min` (44px).

## 4. Tokens

The full machine-readable set is in
[`design-system/tokens.json`](./design-system/tokens.json). The tables below add
the Flutter name each token maps to. Only **light** theme exists; there is no
dark mode yet.

### 4.1 Colour

| Token | Value | Flutter | Usage |
| --- | --- | --- | --- |
| `blue-600` | `#2A66CF` | `AppColors.blue` | Primary brand blue. Top of every gradient, links, active icons. White text passes 4.5:1. |
| `blue-500` | `#4C8BE3` | `AppColors.blueLight` | Middle gradient stop. White text only at 24px+ (3.4:1). |
| `blue-300` | `#9DC0F0` | `AppColors.blueSky` | Lower gradient stop. Text over it switches to `navy-900`. |
| `blue-200` | `#C3DAF7` | `AppColors.blueMist` | Bottom gradient stop, photo placeholders. |
| `blue-100` | `#DDEAFB` | `AppColors.tintStrong` | Highlighted chips, avatar grounds, list icons. |
| `blue-50` | `#EEF5FE` | `AppColors.tint` | "One thing to know" field, unread rows, ask cards. |
| `navy-900` | `#10264D` | `AppColors.navy` | Text/icons on the light part of the gradient and on `blue-100`. |
| `on-blue-muted` | `#F2F7FF` | `AppColors.onBlueSoft` ⚠️ | Secondary text on `blue-600`. Never on white. |
| `ink` | `#111111` | `AppColors.ink` | Primary buttons, nav bar, selected chips, headings on white. |
| `ink-2` | `#1A1A1A` | `AppColors.text` | Body and review text. |
| `slate-700` | `#3F4857` | `AppColors.slate` | Secondary text, uppercase section labels. |
| `slate-600` | `#5B6577` | `AppColors.muted` | Meta text. Lightest text colour allowed on white (5.9:1). |
| `slate-400` | `#8A94A6` | `AppColors.subtle` | Dashed outlines, placeholders, chevrons. Not for text that must be read. |
| `line` | `#D5DCE6` | `AppColors.fieldBorder` ⚠️ | Hairlines, dividers, sheet handle. |
| `surface` | `#FFFFFF` | `AppColors.white` | The white sheet, inputs, default ground. |
| `surface-2` | `#F4F6FA` | `AppColors.card` | Cards and list rows on the sheet. |
| `surface-3` | `#F1F4F9` | `AppColors.segment` | Segmented tracks, search fields. |
| `mint` | `#7FE3C4` | `AppColors.mint` | Rings, unread dots on blue. Decorative only. |
| `success` | `#11694E` | `AppColors.success` | Verified visit, "Available", high taste match, Saved. |
| `success-bg` | `#DDF6EC` | `AppColors.successBg` | Ground behind success text. |
| `danger` | `#B42318` | `AppColors.danger` | Delete account, errors, required star. |
| `danger-bg` | `#FEF1EF` | `AppColors.dangerBg` | Error and delete-confirm panels. |

**Category colours** — map pins and category dots only (`PlaceCategory.color`):

| Token | Value | `PlaceCategory` |
| --- | --- | --- |
| `cat-food` | `#E8590C` | `food` |
| `cat-cafe` | `#7A4A1E` | `cafe` |
| `cat-stay` | `#7048E8` | `stay` |
| `cat-trek` | `#2B8A3E` | `trek` |
| `cat-view` | `#1971C2` | `viewpoint` |
| `cat-temple` | `#C2255C` | `temple` |
| `cat-beach` | `#0B7285` | `beach` |
| `cat-other` | = `slate-600` | `other` (and Shop) |

**Supporting colours used by components** (not tokens yet): disabled button
`#C9CED6` (`AppColors.disabled`), inactive nav icon `#9AA3B2`
(`AppColors.navIdle`), "Taken" pill `#FDE7DF` / `#9A3412`
(`AppColors.takenBg` / `takenFg`), tip box `#F1F5FB` (`AppColors.tipBox`),
overlay scrim `rgba(8,18,40,0.5)` (`AppColors.scrim`), map land `#EEF3F9`,
water `#D4E5F8`, parks `#DCEEE2`.

### 4.2 Typography

Two typefaces, both bundled in `assets/fonts/` (OFL):

- **Manrope** (`AppText.sans`) — the app's voice: UI, headlines, labels,
  buttons, numbers.
- **Newsreader** (`AppText.serif`) — the human voice: place names, reviews,
  chip text, and the italic accent.

| Style | Family | Size / line | Weight | Tracking | Usage | Flutter |
| --- | --- | --- | --- | --- | --- | --- |
| `display-xl` | Manrope | 46 / 0.98 | 700 | −1.8 | Welcome and landing headlines | `AppText.sans(46, …)` in `AccentTitle` |
| `title-lg` | Manrope | 30 / 33 | 700 | −0.8 | Screen titles in the blue header | `AppText.screenTitle()` |
| `title-md` | Manrope | 22 / 28 | 700 | −0.4 | Section titles on the sheet | `AppText.sans(22, …)` |
| `serif-accent` | Newsreader italic | 52 / 1.0 | 400 | −1 | The one italic phrase (~1.12× the sans next to it) | `AccentTitle` |
| `serif-place` | Newsreader | 23 / 27 | 400 | — | Place, list and friend names | `AppText.placeName()` ⚠️ |
| `serif-review` | Newsreader | 17 / 24 | 400 | — | Review text, friends' quotes | `AppText.serif(17, …)` |
| `serif-chip` | Newsreader | 18 / 22 | 400 | — | Text inside dashed pills | `TagChip` |
| `body` | Manrope | 15 / 22 | 500 | — | Default UI text, subtitles | `AppText.sans(15)` |
| `body-strong` | Manrope | 15 / 22 | 700 | — | Names in rows, settings labels | `AppText.sans(15, weight: w700)` |
| `button` | Manrope | 17 / 24 | 700 | — | Primary pill buttons | `AppText.button()` |
| `meta` | Manrope | 12 / 16 | 600 | — | Dates, counts, small chip text | `AppText.meta()` ⚠️ |
| `label` | Manrope | 12 / 16 | 800 | +0.5 | Uppercase section labels | `AppText.sectionLabel()` ⚠️ |
| `stat` | Manrope | 34 / 1.0 | 800 | −1 | Number inside a glass circle | `GlassOrb` / `GlassStatTile` |

### 4.3 Spacing

| Token | Value | Usage |
| --- | --- | --- |
| `space-1` | 4 | Icon-to-text in tight chips, segmented track padding |
| `space-2` | 8 | Between chips and stacked cards |
| `space-3` | 12 | Inside cards and rows (avatar to text) |
| `space-4` | 16 | Card padding; sheet side padding; nav inset |
| `space-5` | 22 | Screen gutter on blue headers and gradient screens |
| `space-6` | 32 | Between major groups on onboarding |
| `space-7` | 60 | Top padding of every header (includes the status bar) |

### 4.4 Radius

| Token | Value | Usage |
| --- | --- | --- |
| `radius-sm` | 14 | Photo thumbs, icon squares, small inset boxes |
| `radius-md` | 22 | Cards and list rows on the sheet |
| `radius-lg` | 32 | Top corners of the white sheet; large panels |
| `radius-pill` | 999 | Buttons, chips, inputs, nav bar — the default shape |
| `radius-device` | 44 | Phone frame corners in mockups and marketing |

### 4.5 Shadows

| Token | Value | Flutter | Usage |
| --- | --- | --- | --- |
| `shadow-card` | `0 14px 34px rgba(16,38,77,0.18)` | `AppShadows.card` | Floating cards over the map |
| `shadow-field` | `0 10px 30px rgba(16,38,77,0.15)` | `AppShadows.soft` ⚠️ | White inputs on the blue gradient |
| `shadow-glass` | `0 14px 34px rgba(20,60,140,0.22)` | `AppShadows.orb` | Under glass circles |

### 4.6 Gradients

Part of the brand. Use them only as screen and header grounds — never on
buttons or chips.

| Token | Value | Flutter |
| --- | --- | --- |
| `gradient-screen` | `#2A66CF 0% → #4C8BE3 42% → #9DC0F0 78% → #C3DAF7 100%` (top to bottom) | `AppGradients.sky` |
| `gradient-header` | `#2A66CF → #4C8BE3` | `AppGradients.header` |
| `gradient-glass` | Radial at 32%/26%: white 60% → 18% → 8%, plus 1px `rgba(255,255,255,0.65)` border | `AppGradients.glass()` |

### 4.7 Sizes

| Token | Value | Usage |
| --- | --- | --- |
| `tap-min` | 44 | Smallest tappable size |
| `button-h` | 60 | Primary pill button |
| `field-h` | 58 | Text input |
| `chip-h` | 38 | Filter and tag chips (onboarding hero chips: 52) |
| `nav-h` | 66 | Bottom nav bar, floating 26px above the bottom |
| `screen-w` | 390 | Design width (iPhone 14/15) |

## 5. Iconography

- Inline SVG line icons on a 24 grid, stroke 1.8–2.4, round caps and joins, no
  fill. Colour comes from the text they sit with. In Flutter: `AppIcon` +
  `AppIconView` (`lib/core/icons/app_icons.dart`).
- Core set: map (folded map), feed (card with lines), plus, friends (two
  people), profile (one person), pin, search, bell, share (arrow out of tray),
  link, lock, shield-check, star (filled for ratings), heart, bookmark.
- Icon-only buttons are 44px circles: on blue, `rgba(255,255,255,0.18)` fill
  with a white 50% border (`GlassIconButton`); on white, `surface-3`.
- **No emoji anywhere.** No WhatsApp or Instagram logos — use generic chat and
  camera glyphs with text labels.

## 6. Logo

![Clarity mark](./design-system/clarity-mark.svg)

- The mark is a white map pin inside a `blue-600` disc with a faint inner ring —
  the same shape as the app's glass circles.
- Use it at 40px or larger, with clear space of a quarter of its width on every
  side. Don't recolour the disc or add a shadow inside the mark.
- On blue grounds, show the pin in white inside a glass circle (`GlassOrb`)
  rather than the solid disc.
- Wordmark: "Clarity" in Manrope 800, −0.6px tracking. There is no custom
  logotype yet (the product name is still open — see `PRD.md` §17).

## 7. Components

Each component has a live preview in the
[source system](https://claude.ai/artifact/8hxtY8V5jf9jemD3diWiav). The right
column names the Flutter widget that implements it.

| Component | Rules | Flutter |
| --- | --- | --- |
| **Button** | **Primary:** `ink` fill, white `button` text, `button-h` tall, full width at the bottom; one per screen. **Disabled:** `#C9CED6` fill, `slate-700` text; the label can say what's missing ("Add a rating and one tip to post"). **Secondary:** white fill, 1.5px dashed `ink` border, 56px. **Text link:** no fill, 48px, centred under the primary. **Icon button:** 44px circle, always labelled. Labels name the action. | `PrimaryButton`, `DashedButton`, `PillButton`, `TextLinkButton`, `GlassIconButton` |
| **Chip** | **Plain:** white, 1.5px dashed `slate-400`, `serif-chip` in `ink-2`, `chip-h`. **Highlighted:** `blue-100` fill, dashed `blue-500`, `navy-900` text — featured words, not selection. **Selected:** solid `ink`, white text. **Category filter:** sans 13px with an 8px category dot; "All" uses a `mint` dot. **Hero:** 52px, 18px serif, rows can bleed off-screen. On blue: white 90% dashed border, white text. One to three words. | `TagChip`, `StatusPill`, `CategoryFilterChip`, `CategoryFilterBar` |
| **TextField** | **Default:** `surface`, `field-h`, pill, `shadow-field` on blue, 17px Manrope 600 in `#0F1E3A`, placeholder `slate-400`. **Label:** 13px bold above, indented 18px. **Country code:** dashed translucent pill, +91 default. **Inline status:** "Available" (`success-bg`/`success`) or "Taken" (`#FDE7DF`). **Tip field:** `blue-50`, dashed `blue-500`, radius 18, live character count. **Search:** `surface-3`, no border, magnifier in `slate-600`. Show limits as counts ("24/90"). | `WhitePillField`, `BareTextField`, `SearchField` |
| **OtpInput** | Six 50×62 boxes, radius 18, 8px apart, on blue only. Filled: white, 26px Manrope 700. Active: translucent white, 2px white border, caret. Empty: faint fill, dashed white border. One hidden `inputmode=numeric`, `autocomplete=one-time-code` field under the boxes so paste and iOS autofill work. "Resend code in 0:30" becomes a dashed "Resend code" button. | `_CodeBoxes` in `onboarding/otp_screen.dart` |
| **GlassCircle** | `gradient-glass`, 1px white 65% border, `shadow-glass`. Optional 2px white-30% track with a 3–3.5px `mint` arc (4.6 rating ≈ 92%). Holds a white icon (~40% of the disc) or a `stat` number with an uppercase `on-blue-muted` caption. Sizes 150 (splash), 120–128 (rating, onboarding), 96–100 (counts, avatars), 40 (header logo). One per screen, blue grounds only. A dashed white ring means empty or offline. | `GlassOrb`, `ProgressRing`, `GlassStatTile` |
| **PlaceCard** | **List row:** `surface-2`, `radius-md`, padding 14×16; category dot + label + status (12px, `slate-700`), name in `serif-place`, meta in `slate-600`, the tip in quotes on one line; rating top-right with a filled star. **Floating map card:** white, radius 26, `shadow-card`, category as a dashed pill, 23px serif name, "One thing to know" box on `#F1F5FB`. Whole card links to Place detail. Never show a rating for Want to go. | `place_list_view.dart`, `place_preview_card.dart`, `CategoryLine`, `RatingBadge` |
| **BottomNav** | Black pill, `nav-h`, radius 33, inset `space-4` and 26px from the bottom. Icons 22px; active is white with a 4px dot below and `aria-current`; inactive `#9AA3B2`. Add is a 48px white disc with a black plus — always opens Add a place. No text labels. Hidden on full-screen flows. | `FloatingNavBar` |
| **Segmented** | **On blue** (Map / List, Friends / Requests): translucent white track, 40% white border; selected is a white pill with `navy-900` text. **On white** (status, visibility, share kind): `surface-3` track, full width, equal segments; selected is an `ink` pill. Segments 36–40px, 4px track padding, radius 18. Two or three options only. | `GlassTabs` (on blue), `SegmentedTabs` (on white) |
| **Toggle** | Track 52×32: `ink` on, `#C9CED6` off; white 26px knob. Row at least `tap-min`, label 15px semibold, optional 12px `slate-600` explanation, 56px min row, hairline dividers. Only for changes that apply immediately. | `AppSwitch` |
| **Avatar** | Two initials, Manrope 800. Sizes 26, 38 (stacks), 42–46 (rows), 88 (profile, as a glass circle on blue). Tint pairs: `blue-100`/`#1D4E9E`, `#FFE3CC`/`#9A3412`, `success-bg`/`success`, `#EDE5FF`/`#5B3CC4`, `#FDE2EC`/`#A61E4D` — stable per person. **Not on Clarity yet:** no fill, dashed `slate-400` border, Invite button. **Stacks:** overlap 10px, 2px border. **Taste match:** 75%+ `success`, 55–74% `#1D4E9E`, lower `slate-600`. | `InitialsAvatar`, `AvatarStack` |
| **MapPin** | Teardrop 30×36, 2.2px white outline, white centre dot, 44×44 tap target. Selected: 52×60, 3px outline. Colours from `cat-*`; accessible name is the place name. **You are here:** 16px `blue-600` dot, 3px white ring, 44px 16% blue halo. Map style: land `#EEF3F9`, water `#D4E5F8`, parks `#DCEEE2`, white roads. Empty map: a dashed `blue-600` pin outline in a white disc. | `MapPinMarker`, `MapArtView` (→ Google Maps custom markers + map style later) |
| **ScreenShell** | **Full gradient** (`gradient-screen`): onboarding, Add a place, Offline, permission primers; controls at the top, white centred title, optional glass circle, black primary pinned to the bottom. **Header + sheet** (`gradient-header`): tab screens and detail pages; 30px title, `on-blue-muted` subtitle, up to two 44px icon buttons; white sheet with `radius-lg` top corners starting 130–390px down. **Overlays:** `rgba(8,18,40,0.5)` scrim, sheet with a 40×5 handle. | `SkyScaffold`, `SheetScaffold`, `showShareSheet` |

## 8. Accessibility

- Body text 4.5:1 minimum. `slate-600` is the lightest text colour on white.
  White on `blue-500` only at 24px+.
- Every control is a real button/link/field with a label; icon-only buttons
  carry a semantic label (`Semantics(label:)` / `tooltip` in Flutter).
- Toggles expose switch semantics with their checked state; segmented controls
  act as tabs (switching views) or radios (setting a value).
- Respect reduced motion: skeleton pulses stop (`MediaQuery.disableAnimations`).
- Touch targets ≥ 44px. Category colour is never the only signal — pins and
  dots always sit next to a label.

## 9. Code vs design system — differences to resolve

The Flutter theme predates this design system. These are the known mismatches
(⚠️ in the tables above). Fix them in a dedicated `refactor(theme)` PR so the
code uses the design system's names and values.

| # | Design system | Code today | Proposed fix |
| --- | --- | --- | --- |
| 1 | `line` = `#D5DCE6` | `AppColors.line` = `#E6EAF0`; `#D5DCE6` is `AppColors.fieldBorder` | Rename so `line` matches the token; keep `#E6EAF0` as a separate lighter divider if screens need it |
| 2 | `on-blue-muted` = `#F2F7FF` | That value is `AppColors.onBlueSoft`; `AppColors.onBlueMuted` is `#EAF2FF` | Align names with the token |
| 3 | `serif-place` = 23px / 27 | `AppText.placeName()` defaults to 20px, height 1.2 | Default to 23 / 27; pass smaller sizes explicitly where the design uses them |
| 4 | `meta` = 12px weight 600 | `AppText.meta()` uses weight 500 | Use 600 |
| 5 | `label` = 12px, weight 800, +0.5 | `AppText.sectionLabel()` is 13px, +0.4 | Use the token values |
| 6 | `shadow-field` alpha 0.15 | `AppShadows.field` uses 0.18 (0.15 is `AppShadows.soft`) | Make `field` match the token |
| 7 | Spacing, radius and size tokens | Literal numbers in widgets | Add `AppSpacing`, `AppRadius`, `AppSizes` constants named after the tokens |
| 8 | Avatar tint pairs, map style colours | Partly in `MockData` / `AppColors` | Move the tint pairs into `AppColors` |
| 9 | Source mentions 28 screens | The PRD lists 24 (23a–c and 24a–c counted as states) | Same screens; no change needed |

Until that PR lands, existing code stays as it is — screens were tuned against
the design and render tests guard their layout.
