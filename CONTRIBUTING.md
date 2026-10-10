# Contributing to Clarity

## First-time setup

```bash
make setup        # installs git hooks (core.hooksPath=.githooks) + flutter pub get
```

Every clone needs this once — the hooks are what block bad commits/pushes locally.

## Workflow

Two long-lived branches, both protected — **nobody commits or pushes to either
directly**; every change goes through a pull request.

| Branch    | Role                                   | Receives PRs from               |
| --------- | -------------------------------------- | ------------------------------- |
| `staging` | Integration / testing (default branch) | work branches, `main` (back-merge) |
| `main`    | Production — what ships                | `staging` (release), `hotfix/…` |

```
feature/… ─┐
fix/…     ─┼─ PR, Squash and merge ──▶ staging ── PR, Create a merge commit ──▶ main
chore/…   ─┘                              ▲                                     │
                                          └──── PR (back-merge) ◀── hotfix/… ──┘
```

**Day to day — feature → staging**

```bash
git switch staging && git pull --ff-only
git switch -c feature/contact-sync          # 1. branch from staging
# ...work...
git commit -m "feat(friends): match contacts against users"   # 2. commit
git push -u origin feature/contact-sync     # 3. push (runs all checks first)
gh pr create --base staging --fill          # 4. PR → CI → "Squash and merge"
```

**Release — staging → main** (when staging has been tested and you're happy)

```bash
gh pr create --base main --head staging --title "chore(release): 1.1.0" --body "…"
```

Merge it with **"Create a merge commit"** — *never squash* staging into main.
A squash rewrites staging's commits into one new commit, so staging and main
stop sharing history and every later release PR conflicts.

**Hotfix — urgent production fix**

```bash
git switch main && git pull --ff-only
git switch -c hotfix/crash-on-launch
# ...fix, commit, push...
gh pr create --base main --fill             # squash-merge into main
gh pr create --base staging --head main --title "chore: back-merge main into staging"
```

Always do the back-merge (with a merge commit) so staging has the fix too.

CI rejects any PR into `main` whose source isn't `staging` or `hotfix/…`.

### Branch names

`<type>/<short-description>` — lowercase, kebab-case.

| Type        | Use for                                  | Example                     |
| ----------- | ---------------------------------------- | --------------------------- |
| `feature/`  | New functionality                        | `feature/place-search`      |
| `fix/`      | Bug fix                                  | `fix/otp-timeout`           |
| `hotfix/`   | Urgent production fix                    | `hotfix/crash-on-launch`    |
| `bugfix/`   | Alias of `fix/`                          | `bugfix/map-pin-offset`     |
| `refactor/` | Code change with no behaviour change     | `refactor/app-state-split`  |
| `perf/`     | Performance                              | `perf/map-clustering`       |
| `test/`     | Tests only                               | `test/review-screen`        |
| `docs/`     | Documentation                            | `docs/supabase-setup`       |
| `chore/`    | Tooling, deps, housekeeping              | `chore/bump-flutter`        |
| `build/`    | Build system, Xcode, packaging           | `build/ios-signing`         |
| `ci/`       | CI/CD config                             | `ci/add-testflight`         |
| `style/`    | Formatting only                          | `style/format-feed`         |
| `release/`  | Release preparation                      | `release/1.1.0`             |

### Commit messages — [Conventional Commits](https://www.conventionalcommits.org)

```
<type>(<optional-scope>): <subject>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`,
`ci`, `chore`, `revert`. Add `!` for a breaking change (`feat(api)!: …`).
Max 100 characters on the subject line. The **PR title** must follow the same
format, because it becomes the squash or merge commit on `staging` / `main`.

## What gets checked, where

| Check                                 | pre-commit | commit-msg | pre-push | CI (PR) | GitHub ruleset |
| ------------------------------------- | :--------: | :--------: | :------: | :-----: | :------------: |
| No commits/pushes to `main`/`staging` | ✔          |            | ✔        |         | ✔              |
| PR direction (work → staging → main)  |            |            |          | ✔       |                |
| Branch name format (bots exempt)      | warn¹      |            | ✔        | ✔       | ✔              |
| Conventional commit message           |            | ✔          |          | ✔ (all commits + PR title) |   |
| `dart format` (staged files / all)    | ✔          |            | ✔        | ✔       |                |
| `flutter analyze` (fatal infos)       |            |            | ✔        | ✔       |                |
| `flutter test`                        |            |            | ✔        | ✔ + coverage |           |
| `pubspec.lock` committed & current    |            |            | ✔        | ✔       |                |
| iOS release build (no codesign)       |            |            |          | ✔       |                |
| PR required, CI green, no force-push  |            |            |          |         | ✔              |

¹ `post-checkout` warns when you switch to a badly named branch.

Run the CI checks yourself any time: `make check` (or `scripts/check.sh --quick`
to skip tests).

Local hooks can be skipped with `--no-verify`; CI and the GitHub rulesets can't,
so that's for emergencies only.

## Turning on GitHub protection (once, after creating the GitHub repo)

```bash
git remote add origin git@github.com:<owner>/clarity.git
git push --no-verify origin main   # one-time bootstrap: GitHub needs main to exist
gh auth login
make protect      # rulesets + merge settings; creates staging and makes it the default
```

This makes GitHub itself reject direct pushes to `main` and `staging` (no
bypass, admins included), require a PR with the `CI passed` check green
(and, for `staging`, up to date), and reject branch names that don't match the
prefixes above.
Rulesets on private repos need GitHub Pro/Team; public repos get them free.
Without them, the `Guard protected branches` workflow still flags any direct
push to `main` or `staging` in red.

The rule definitions live in one place — `scripts/git/rules.sh` — shared by the
hooks and CI. Change a rule there (and in `.github/rulesets/branch-names.json`
for branch prefixes).
