#!/usr/bin/env bash
# One-time setup for a fresh clone: installs the git hooks and fetches deps.
#   ./scripts/setup.sh   (or: make setup)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
export PATH="/opt/homebrew/bin:$PATH"

git config core.hooksPath .githooks
chmod +x .githooks/* scripts/*.sh scripts/git/*.sh
echo "✔ Git hooks installed (core.hooksPath=.githooks)"

flutter pub get
echo "✔ Dependencies fetched"
