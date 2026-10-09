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

Nothing beyond Flutter is wired up yet — the app currently runs entirely
locally with placeholder screens. Add backend pieces one feature at a time.

## Project structure

```
lib/
  main.dart                         # App entry → ClarityApp → AppShell
  core/
    theme/app_theme.dart            # Colors + ThemeData (AppColors, AppTheme)
    constants/                      # (empty) app-wide constants
  features/
    map/map_screen.dart             # Tab 1 — My Map (home)
    feed/feed_screen.dart           # Tab 2 — Friends feed
    add_place/add_place_screen.dart # Tab 3 — Add a place + review
    friends/friends_screen.dart     # Tab 4 — Contact sync / friends
    profile/profile_screen.dart     # Tab 5 — Profile + settings
    shared/widgets/
      app_shell.dart                # 5-tab bottom navigation
      placeholder_screen.dart       # Reusable "coming soon" screen
docs/
  feature-brief.pdf                 # Full product brief
```

**Convention:** one folder per feature under `lib/features/`. Shared widgets go
in `lib/features/shared/`. Core/cross-cutting things (theme, constants, later:
services, models) go in `lib/core/`.

## Screens to build (MVP)

Current state: the 5-tab shell exists; each tab is a placeholder. Build order:

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
