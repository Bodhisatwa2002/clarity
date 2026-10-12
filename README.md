# Clarity

A personal map of every place you've been — each pin carrying your own short
review, shared with friends as one link.

> **"Your friends' honest opinions, on a map, for any kind of place."**

iPhone-first, built in Flutter.

| Doc | What's in it |
| --- | --- |
| [`docs/PRD.md`](docs/PRD.md) | Product requirements: users, features, phases, privacy, metrics |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System design: app layers, Supabase data model, flows, secrets, CI/CD |
| [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md) | Design system: tokens, components, copy and accessibility rules |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Branch flow (feature → staging → main), commits, checks |
| [`AGENTS.md`](AGENTS.md) | Rules for AI coding agents (imported by `CLAUDE.md`) |
| [`docs/feature-brief.pdf`](docs/feature-brief.pdf) | Original product brainstorm |

## Getting started

```bash
export PATH="/opt/homebrew/bin:$PATH"   # Flutter installed via Homebrew
make setup                              # git hooks + flutter pub get
open -a Simulator                       # start an iPhone simulator
flutter run --route=/home               # launch, skipping onboarding
make check                              # format, analyze, test — same as CI
```

## Status

All 24 MVP screens are built and run on mock data. Backend integration
(Supabase, Google Maps/Places, contact sync) is next — see the roadmap in
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#12-integration-roadmap).
