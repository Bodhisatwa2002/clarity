# AGENTS.md — Clarity

Guidance for any AI coding agent working in this repository. The detailed,
authoritative version lives in **[CLAUDE.md](./CLAUDE.md)** — read that first.
This file is the short, tool-agnostic summary and stays in sync with it.

## The project in one line

**Clarity** — a personal map of every place you've been, each pin with your own
short review, shared with friends. iPhone-first, built in **Flutter**. Full
product brief: `docs/feature-brief.pdf`.

## Setup

```bash
export PATH="/opt/homebrew/bin:$PATH"   # Flutter was installed via Homebrew
flutter pub get
```

Requires: macOS, Xcode, Flutter (`flutter doctor` should be green for iOS).

## Build, run, test

```bash
flutter run            # run on a connected device / simulator
flutter analyze        # static analysis — must be clean before you finish
flutter test           # run the test suite
```

Launch a simulator with `open -a Simulator` if none is running.

## Code layout

- `lib/main.dart` — entry point (`ClarityApp` → `AppShell`).
- `lib/core/` — theme, constants, and later services/models (cross-cutting).
- `lib/features/<feature>/` — one folder per feature (map, feed, add_place,
  friends, profile). Shared widgets in `lib/features/shared/`.

## Conventions

- One folder per feature under `lib/features/`.
- Material 3; colors and theme come from `lib/core/theme/app_theme.dart`
  (`AppColors`, `AppTheme`) — don't hardcode colors in widgets.
- Keep the app runnable at every step; build features incrementally.

## Rules that matter

- **Run `flutter analyze` and keep it at zero issues** before completing a task.
- **Don't wire up the backend (Supabase/Google APIs) until a feature needs it** —
  keep running costs at zero until there are real users.
- **Privacy first** (India DPDP Act + Apple review): never store contact numbers
  of people who aren't users (match and delete); request contacts permission
  only when the user taps "Find friends."
- Keep **`place`** and **`visit`** as distinct models from the start.

## Commits

- Write clear, present-tense commit messages describing the change.
- Run `flutter analyze` and `flutter test` before committing.
