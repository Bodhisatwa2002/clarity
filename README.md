# Clarity

A personal map of every place you've been — each pin carrying your own short
review, shared with friends as one link.

> **"Your friends' honest opinions, on a map, for any kind of place."**

iPhone-first, built in Flutter. See [`docs/feature-brief.pdf`](docs/feature-brief.pdf)
for the full product brief, and [`CLAUDE.md`](CLAUDE.md) for the developer guide.

## Getting started

```bash
export PATH="/opt/homebrew/bin:$PATH"   # Flutter installed via Homebrew
flutter pub get
open -a Simulator                       # start an iPhone simulator
flutter run                             # build and launch the app
```

## Status

Early scaffold. The 5-tab app shell (Map · Feed · Add · Friends · Profile) is in
place with placeholder screens. Features are being built one at a time — see the
build order in `CLAUDE.md`.
