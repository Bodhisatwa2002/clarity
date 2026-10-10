#!/usr/bin/env bash
# Runs the same quality gates as CI. Used by the pre-push hook and `make check`.
#
#   scripts/check.sh          # format + analyze + test
#   scripts/check.sh --quick  # format + analyze only (no tests)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
export PATH="/opt/homebrew/bin:$PATH"
# shellcheck source=git/rules.sh
source scripts/git/rules.sh

quick=false
[[ "${1:-}" == "--quick" ]] && quick=true

step() { printf '\n\033[1m▸ %s\033[0m\n' "$*" >&2; }

step "Dependencies (lockfile must be up to date)"
flutter pub get --enforce-lockfile >/dev/null

step "Format (dart format)"
if ! dart format --output=none --set-exit-if-changed lib test; then
  red "✖ Code is not formatted. Run: dart format lib test"
  exit 1
fi

step "Static analysis (flutter analyze)"
flutter analyze --fatal-infos --fatal-warnings

if ! $quick; then
  step "Tests (flutter test)"
  flutter test
fi

green "✔ All checks passed"
