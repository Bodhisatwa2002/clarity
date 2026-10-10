# Clarity — Places Review App

> A personal map of every place you've been, each pin carrying your own short
> review, shared with friends as one link. **"Your friends' honest opinions, on
> a map, for any kind of place."**

This file orients Claude Code (and any AI assistant) working in this repo. The
full product thinking is in `docs/feature-brief.pdf` — read it when you need
product context.

## What this app is

- A **friends-first, personal map** you build and share. Not a public reviews site.
- Positioning: **any place** (not just food), **friends** (not strangers),
  **proof you were there** (not just a wishlist).
- Core hook: **contact sync** — sign up with a phone number, find which of your
  contacts are already on the app, open their map.
- Platform: **iPhone first** (this repo). Android is Phase 3 from the same
  Flutter codebase. A small web share page comes later.

## Tech stack (decided)

| Layer            | Choice                                              |
| ---------------- | --------------------------------------------------- |
| App framework    | **Flutter** (Dart)                                  |
| Build            | Xcode (iOS), macOS only                             |
| Backend          | **Supabase** (Postgres + Auth + Storage) — not yet wired |
| Auth             | Phone number + OTP, plus Sign in with Apple         |
| Geo              | PostGIS in Supabase; "places within 2 km", clustering |
| Map display      | Google Maps SDK for iOS (`google_maps_flutter`) — free in a native app |
| Place search     | Google Places API, called from backend              |
| Contacts         | `flutter_contacts` (iOS Contacts framework)         |
| Location         | Core Location — "I'm here" + verified visits        |
| AI search (later)| pgvector in Supabase                                |

Nothing beyond Flutter (+ `flutter_svg`) is wired up yet — the app runs
entirely on dummy data (`lib/core/data/mock_data.dart`) held in one
`AppState`. Add backend pieces one feature at a time.

## Project structure

```
lib/
  main.dart                       # runApp(ClarityApp)
  app/
    clarity_app.dart              # MaterialApp + AppScope (state)
    routes.dart                   # Routes.* names + onGenerateRoute
  core/
    theme/                        # AppColors, AppGradients, AppShadows, AppText, AppTheme
    icons/app_icons.dart          # AppIcon (the design's SVG line icons) + AppIconView
    models/                       # Place, Visit (kept separate!), Person, PlaceCategory, social.dart
    data/mock_data.dart           # Dummy people, places, visits, feed, notifications
    state/app_state.dart          # AppState (ChangeNotifier) + AppScope / context.app
    utils/                        # Fmt (formatters), Layout (design → device offsets)
  features/
    onboarding/                   # 01–06, 21: splash, welcome, phone, OTP, profile, permissions, consent
    map/                          # 07 map, 08 list, 23a empty map (tab 1)
    add_place/                    # 09 add a place (search / I'm here / drop a pin)
    review/                       # 11 write / edit review
    place/                        # 10 place detail, 23c no reviews
    feed/                         # 12 feed, 24b error, 24c loading (tab 2)
    friends/                      # 13 find friends, 14 friends & requests, 15 friend profile, 23b (tab 3)
    search/                       # 16 search
    share/                        # 17 share sheet (showShareSheet)
    lists/                        # 18 collaborative list
    profile/                      # 19 my profile (tab 4), 20 settings
    notifications/                # 22 notifications
    system/                       # 24a offline, hidden "Design states" sheet
    shared/widgets/               # Reusable components (see below) + app_shell.dart
assets/fonts/                     # Manrope + Newsreader (OFL), bundled
docs/feature-brief.pdf            # Full product brief
```

**Convention:** one folder per feature under `lib/features/`, screen-specific
widgets in that feature's `widgets/`. Anything used by two features goes in
`lib/features/shared/widgets/`. Cross-cutting non-UI code goes in `lib/core/`.

**Reusable components** (`lib/features/shared/widgets/`): `SheetScaffold`
(blue header + white sheet — most screens), `SkyScaffold` (full gradient),
`HeaderBar`, `AccentTitle` (bold + italic serif headline), `PrimaryButton`,
`DashedButton`, `PillButton`, `TextLinkButton`, `TagChip`, `StatusPill`,
`CategoryFilterBar`, `GlassIconButton`, `GlassOrb`, `ProgressRing`,
`GlassStatTile`, `GlassTag`, `InitialsAvatar`, `AvatarStack`, `SegmentedTabs`,
`GlassTabs`, `AppSwitch`, `SearchField`, `BareTextField`, `RatingBadge`,
`StarRow`, `DashedBorder`, `Pressable`, `MapArtView`/`MapPinMarker`,
`FloatingNavBar`. Build new UI from these before writing new widgets; take
colors and type only from `AppColors` / `AppText`.

**Design source:** `Clarity App Design.html` (390×844 artboards). Offsets in
the design include a 60pt status-bar area — use `Layout.y()` / `SheetScaffold`'s
`sheetTop` with the design's numbers rather than hand-tuning.

**Dev shortcuts:** `flutter run --route=/home` skips onboarding. Long-press
"Clarity · version 1.0" in Settings for the hidden *Design states* sheet
(offline, feed loading/error, place with no reviews, new-user empty states).

## Screens to build (MVP)

Current state: every screen in the design is built as UI with dummy data and
a working interactive flow (sign-up → map → add place → review → place →
share / lists; feed, friends, search, notifications, settings). The map is an
illustration until Google Maps is wired. Original build order:

1. **My Map** — map with your pins, color-coded by category; list view + filters
2. **Add a place** — Google Places search / "I'm here" GPS / drop a pin
3. **Write a review** — rating, text, up to 5 photos, date, tags, status
4. **Place detail** — photos, your review, who's been here
5. **Auth** — phone OTP + Sign in with Apple, create profile
6. **Contact sync** — the core hook
7. **Friends, feed, sharing**

Full screen list (24 screens) is in the chat history / feature brief.

## Commands

```bash
# Always ensure Flutter is on PATH (installed via Homebrew):
export PATH="/opt/homebrew/bin:$PATH"

flutter run                 # Run on the default device (pick simulator if asked)
flutter run -d "iPhone 16"  # Run on a specific iOS simulator
flutter analyze             # Static analysis — run before committing
flutter test                # Run tests
flutter pub add <package>   # Add a dependency
flutter pub get             # Fetch dependencies
```

To launch an iOS simulator manually: `open -a Simulator`.

## Working agreements

- **Build incrementally.** Add one screen/feature, run it, confirm it works,
  then move on. Keep the app runnable at every step.
- **Run `flutter analyze` before finishing** any change. Keep it at zero issues.
- **Don't add the backend prematurely.** Keep costs at ₹0 until there are real
  users. Supabase/Google APIs get wired only when a feature needs them.
- **Privacy is a first-class requirement** (India DPDP Act + Apple rules):
  never store non-users' contact numbers; match and delete. Ask for contacts
  permission at the moment the user taps "Find friends," not on launch.
- **Keep `place` and `visit` as separate concepts** from day one — it's what
  makes verified visits, revisits, and trips possible later.

## Naming note

The app's working name is **Clarity** (matches the folder). The real product
name is still an open question in the brief ("something short that works as a
verb"). The Dart package is `clarity`; iOS bundle org is `ai.thinkbyte`.
Rename later if the brand changes.
