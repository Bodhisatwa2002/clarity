# AGENTS.md — Clarity

Instructions for AI coding agents (Claude Code, Codex, Cursor, Copilot, Gemini,
Aider, …) working in this repo. This is the **single source of truth** for how
to work here; `CLAUDE.md` imports it. Humans: see `README.md` and
`CONTRIBUTING.md`.

**Your role:** a senior Flutter engineer on a small, iPhone-first product team.
You ship small, tested, design-accurate changes on a feature branch, through a
pull request, without breaking the app or the CI gates.

---

## 1. Commands (run these, don't guess)

```bash
export PATH="/opt/homebrew/bin:$PATH"    # Flutter is installed via Homebrew — needed in every shell

make setup                               # once per clone: installs git hooks + flutter pub get
make check                               # EXACTLY what CI runs: lockfile, format, analyze, test
scripts/check.sh --quick                 # same, without tests (fast inner loop)

dart format lib test                     # format (page width 120, from analysis_options.yaml)
flutter analyze --fatal-infos --fatal-warnings   # must report "No issues found!"
flutter test                             # all tests
flutter test test/screens_render_test.dart --plain-name "renders settings"   # one test

flutter run --route=/home                # run, skipping onboarding
flutter run -d "iPhone 16"               # specific simulator (open -a Simulator first)
flutter build ios --release --no-codesign   # what the CI iOS job builds
flutter pub add <package>                # add a dependency (ask first — see §3)
```

**Definition of done** for any change: `make check` passes, the changed screen
was exercised (test or simulator), and the work is committed on a correctly
named branch. Don't report a task finished while any of these fail — say what
failed instead.

---

## 2. Project in brief

**Clarity** — a personal map of every place you've been, each pin carrying your
own short review, shared with friends as one link. *"Your friends' honest
opinions, on a map, for any kind of place."*

- Friends-first, not a public reviews site. **Any** place, not just food.
  **Proof you were there**, not just a wishlist.
- Core hook: **contact sync** — sign up with a phone number, see which contacts
  are on the app, open their map.
- iPhone first. Android later from the same codebase; small web share page later.
- Full product thinking: `docs/feature-brief.pdf` — read it when product
  context matters (naming, flows, priorities).

**Current state:** every MVP screen in the design is built as UI on dummy data
with a working interactive flow (sign-up → map → add place → review → place →
share / lists; feed, friends, search, notifications, settings). **No backend
yet.** The map is an illustration (`MapArtView`) until Google Maps is wired.

### Stack

| Layer          | Choice                                             | Status       |
| -------------- | -------------------------------------------------- | ------------ |
| App            | Flutter 3.47.7 / Dart 3.13 (pinned in CI)          | ✅ in use    |
| Packages       | `flutter_svg`, `cupertino_icons`, `flutter_lints`  | ✅ in use    |
| State          | One `AppState` (`ChangeNotifier`) via `AppScope`   | ✅ in use    |
| Backend        | Supabase (Postgres + Auth + Storage), PostGIS      | ⏳ not wired |
| Auth           | Phone OTP + Sign in with Apple                     | ⏳ not wired |
| Map / Places   | `google_maps_flutter`; Places API **via backend**  | ⏳ not wired |
| Contacts       | `flutter_contacts`                                 | ⏳ not wired |
| Location       | Core Location ("I'm here", verified visits)        | ⏳ not wired |
| AI search      | pgvector in Supabase                               | ⏳ later     |

---

## 3. Boundaries

### ✅ Always
- Work on a branch named `<type>/<kebab-case>` (see §7). Create it **before** the first commit.
- Run `make check` before declaring done; keep `flutter analyze` at **zero issues** (infos included).
- Build UI from the shared widgets in `lib/features/shared/widgets/` and the
  tokens in `AppColors` / `AppText` / `AppGradients` / `AppShadows`.
- Add or update a test for every new screen or behaviour (§6).
- Keep `Place` and `Visit` as separate models (§5).
- Match the code around you: naming, comment density, file layout.
- Leave the app runnable after every change — build incrementally, one feature at a time.

### ⚠️ Ask first
- Adding a dependency (`flutter pub add`), or upgrading Flutter/Dart.
- Wiring any backend or paid API (Supabase, Google Maps/Places) — the project
  stays at ₹0 running cost until there are real users.
- Requesting a new iOS permission or editing `ios/Runner/Info.plist`,
  entitlements, signing, or `project.pbxproj` beyond what a package requires.
- Changing CI (`.github/`), git hooks (`.githooks/`), `scripts/`, or
  `analysis_options.yaml` lint rules.
- Deleting files, renaming public classes/routes, or large refactors across features.
- Pushing, opening PRs, or anything else that talks to GitHub.

### 🚫 Never
- Commit or push to `main` or `staging` (or `master` / `develop`). Hooks and GitHub rulesets reject it.
- Open a PR into `main` from anything but `staging` or a `hotfix/…` branch, or squash-merge `staging` into `main`.
- Use `--no-verify`, force-push shared branches, or skip/disable tests or lints to get green.
- Hardcode colors, font families or text styles in widgets.
- Store or upload contact numbers of people who aren't users (§8).
- Ask for contacts/location permission at launch — only at the moment of use.
- Commit secrets: API keys, `.env`, `GoogleService-Info.plist`, signing certificates.
  Google Places is called **from the backend**, so no Places key ships in the app.
- Edit generated/platform files by hand: `build/`, `.dart_tool/`,
  `ios/Flutter/Generated.xcconfig`, `ios/Pods/`, `pubspec.lock` (let `pub` write it).

---

## 4. Code map

```
lib/
  main.dart                    # runApp(ClarityApp)
  app/
    clarity_app.dart           # MaterialApp + AppScope
    routes.dart                # Routes.* names + onGenerateRoute (every full-screen page)
  core/                        # cross-cutting, no feature UI
    theme/                     # AppColors, AppGradients, AppShadows, AppText, AppTheme
    icons/app_icons.dart       # AppIcon (the design's SVG line icons) + AppIconView
    models/                    # Place, Visit, Person, PlaceCategory, social.dart
    data/mock_data.dart        # all dummy people, places, visits, feed, notifications
    state/app_state.dart       # AppState + AppScope + context.app / context.appRead
    utils/                     # Fmt (formatters.dart), Layout (design → device offsets)
  features/<feature>/          # one folder per feature
    <name>_screen.dart         # the screen(s)
    widgets/                   # widgets used only by this feature
  features/shared/widgets/     # anything used by 2+ features, + app_shell.dart
test/
  flutter_test_config.dart     # loads the real fonts so test layout matches the device
  screens_render_test.dart     # renders every route at 390×844, fails on overflow
  widget_test.dart
assets/fonts/                  # Manrope + Newsreader (OFL), bundled
docs/feature-brief.pdf         # product brief
```

Features: `onboarding` (splash, welcome, phone, OTP, profile, permissions,
consent) · `map` (tab 1: map, list, empty) · `add_place` · `review` · `place` ·
`feed` (tab 2) · `friends` (tab 3: find, requests, friend profile) · `search` ·
`share` (`showShareSheet`) · `lists` · `profile` (tab 4 + settings) ·
`notifications` · `system` (offline, hidden *Design states* sheet).

**Where does new code go?**
- Used by one feature → `lib/features/<feature>/widgets/`.
- Used by two or more → `lib/features/shared/widgets/` (move it there when the second use appears).
- Not UI (models, services, formatters, repositories) → `lib/core/`.
- New full-screen page → a `Routes.*` constant + a case in `onGenerateRoute` +
  an entry in `test/screens_render_test.dart`.

---

## 5. Code style & patterns

The formatter and analyzer are the authority (`dart format`, page width **120**,
`flutter_lints`). Beyond that:

**State.** Read with `context.app` in `build` (subscribes and rebuilds); use
`context.appRead` in callbacks (no subscription). Anything the user can change
lives in `AppState` and is changed through an `AppState` method that calls
`notifyListeners()`. Widgets may read static demo content from `MockData`, but
never keep their own copy of mutable app data.

```dart
// ✅
final visits = context.app.myVisits;
onPressed: () => context.appRead.toggleSaved(place.id),

// ❌ subscribing inside a callback; mutating state outside AppState
onPressed: () => context.app.toggleSaved(place.id),
onPressed: () => MockData.visits.add(visit),
```

When the backend arrives, `MockData` reads become repository calls behind
`AppState` — keep that seam clean.

**Navigation.** Named routes only; pass ids (or the small `*Args` classes), not whole objects.

```dart
Navigator.pushNamed(context, Routes.place, arguments: place.id);
Navigator.pushNamed(context, Routes.review, arguments: const ReviewArgs('neermahal', editing: true));
```

**Layout from the design.** The design (`Clarity App Design.html`) uses 390×844
artboards whose y-offsets include a 60pt status-bar area. Use the design's
numbers through `Layout.y(context, designY)` or `SheetScaffold(sheetTop: …)` —
never hand-tune offsets for one device. Scrolling content under the floating
nav gets `Layout.navClearance` bottom padding.

**Theme.** Colors only from `AppColors`/`AppGradients`, shadows from `AppShadows`,
type only from `AppText`, icons from `AppIcon`. Headlines with a serif italic
accent use `AccentTitle`.

**Reuse before you write.** Shared components: `SheetScaffold` (blue header +
white sheet — most screens), `SkyScaffold`, `HeaderBar`, `AccentTitle`,
`PrimaryButton`, `DashedButton`, `PillButton`, `TextLinkButton`, `TagChip`,
`StatusPill`, `CategoryFilterBar`, `GlassIconButton`, `GlassOrb`,
`ProgressRing`, `GlassStatTile`, `GlassTag`, `InitialsAvatar`, `AvatarStack`,
`SegmentedTabs`, `GlassTabs`, `AppSwitch`, `SearchField`, `BareTextField`,
`RatingBadge`, `StarRow`, `DashedBorder`, `Pressable`, `MapArtView` /
`MapPinMarker`, `FloatingNavBar`.

**Domain model — keep `Place` and `Visit` separate.** A `Place` is the location
(name, category, coordinates). A `Visit` is one person's experience of it
(`placeId`, `authorId`, `date`, `status`, `rating`, `tip`, photos, `verified`).
Many visits per place is what makes friends' reviews, revisits, verified visits
and trips possible. Never put rating or review fields on `Place`.

**General Dart.** `const` constructors wherever possible; `final` fields;
`abstract final class` for static-only namespaces (`Routes`, `Layout`);
`///` doc comments on public classes and non-obvious members, explaining *why*;
no `print` (the lint enforces it).

---

## 6. Testing

- `test/screens_render_test.dart` renders every route on a 390×844 @3x view and
  fails on overflow, unbounded constraints or bad route arguments. **Every new
  route gets an entry in its `screens` map.**
- `test/flutter_test_config.dart` loads the bundled fonts — don't remove it;
  layout tests depend on real glyph widths.
- New behaviour in `AppState` → a unit test that calls the method and asserts state.
- New interactive UI → a widget test that taps through it (`tester.tap`, `pumpAndSettle`).
- Tests must pass without network, simulators or permissions. A failing test is
  fixed, never deleted or skipped to make CI green.

---

## 7. Git, branches, commits, PRs

Two protected long-lived branches; every change lands through a PR with green
CI. Full human guide: `CONTRIBUTING.md`. The rules are defined once in
`scripts/git/rules.sh` and shared by the hooks and CI.

| Branch    | Role                                   | PRs come from                       | Merge with              |
| --------- | -------------------------------------- | ----------------------------------- | ----------------------- |
| `staging` | integration/testing — **default branch** | work branches; `main` (back-merge)  | **Squash and merge**    |
| `main`    | production                             | `staging` (release); `hotfix/…`     | **Create a merge commit** (staging); squash (hotfix) |

```
feature/… fix/… ──squash──▶ staging ──merge commit──▶ main
hotfix/… ──squash──▶ main ──back-merge PR──▶ staging
```

Never squash `staging` into `main`: it rewrites history and every later release
PR conflicts. After any hotfix, open the `main → staging` back-merge PR.

**Branches** — `<type>/<lowercase-kebab-description>`:
`feature/` · `fix/` · `hotfix/` · `bugfix/` · `chore/` · `docs/` · `refactor/` ·
`test/` · `ci/` · `perf/` · `build/` · `style/` · `release/` (bots' `dependabot/…` branches are exempt)

```bash
git switch staging && git pull --ff-only
git switch -c feature/contact-sync      # ✅ always branch from staging (hotfix/… from main)
gh pr create --base staging --fill
# ❌ main · staging · my-branch · Feature/Contact_Sync · feature/ContactSync
```

**Commits** — [Conventional Commits](https://www.conventionalcommits.org),
subject ≤ 100 chars, imperative mood:

```
feat(map): cluster pins within 2 km
fix(auth): retry OTP after timeout
refactor(state): split session out of AppState
test(review): cover half-star ratings
chore(deps): bump flutter_svg to 2.4.0
feat(visit)!: rename tip to note        # ! marks a breaking change
```

Types: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore`
`revert`. The scope is usually the feature folder (`map`, `feed`, `friends`,
`auth`, `ui`, `state`, `deps`, `ci`). One logical change per commit.

**What blocks you, and where:**

| Gate                            | Rule                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| `pre-commit` hook               | no commits on `main`/`staging`; staged `.dart` files must be formatted |
| `commit-msg` hook               | Conventional Commits subject                                 |
| `pre-push` hook                 | no push to `main`/`staging`; valid branch name; full `make check` |
| CI (`.github/workflows/ci.yml`) | PR direction (work → staging → main), branch name, PR title, every commit message, lockfile, format, analyze, tests + coverage, iOS no-codesign build → one `CI passed` check |
| GitHub rulesets                 | PR required on `main` and `staging`, `CI passed` green (staging: also up to date), no force-push or deletion, branch-name prefixes |

If a hook rejects you, **fix the cause**: rename the branch
(`git branch -m feature/…`), reword the commit (`git commit --amend`), or run
`dart format lib test`. Never bypass.

**Pull requests** — the title is a Conventional Commit (it becomes the squash
or merge commit). Release PRs are titled `chore(release): <version>`. Fill in `.github/pull_request_template.md`: what and why,
screenshots for UI changes, the checklist. Keep each PR to one feature or fix.

---

## 8. Privacy & security (India DPDP Act + App Store rules)

- **Contacts:** match phone numbers against existing users and discard the
  rest. Never persist, log or upload non-users' numbers or names.
- **Permissions** (contacts, location, photos) are requested at the moment of
  use — contacts when the user taps "Find friends", location on "I'm here" —
  after the in-app explainer screen. Never on launch.
- Every new permission needs a clear `NS…UsageDescription` string in `Info.plist` (ask first).
- No analytics or tracking SDKs without asking. No PII in logs or crash reports.
- Secrets never go in the repo. Client keys that must ship (e.g. the Maps SDK
  key) are restricted to bundle id `ai.thinkbyte.clarity` and come from build
  config, not source.

---

## 9. Gotchas

- `flutter: command not found` → you forgot `export PATH="/opt/homebrew/bin:$PATH"`.
- Hook scripts must stay bash 3.2 compatible (macOS `/bin/bash`): no `mapfile`,
  `declare -A` or `${var,,}`.
- `flutter pub get --enforce-lockfile` fails in CI if `pubspec.yaml` changed
  without committing the updated `pubspec.lock`.
- Render tests fail on overflow at 390×844 — fix the layout (flex, scroll,
  ellipsis), don't shrink the test view.
- The design file `Clarity App Design.html` isn't in the repo; ask for it when
  you need exact offsets.
- Dev shortcuts: `--route=/home` skips onboarding; long-press "Clarity · version
  1.0" in Settings opens the hidden *Design states* sheet (offline, feed
  loading/error, place without reviews, new-user empty states).

---

## 10. Naming

Working name **Clarity** (Dart package `clarity`, bundle id `ai.thinkbyte.clarity`).
The final brand is still open ("something short that works as a verb") — don't
spread "Clarity" into new user-facing copy beyond what the design shows.

## Keeping this file current

Update AGENTS.md **in the same PR** whenever commands, structure, conventions or
CI rules change. If something here is wrong or stale, fix it rather than working
around it.
