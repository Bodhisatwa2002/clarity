#!/usr/bin/env bash
# Single source of truth for the repo's git rules. Sourced by the local hooks
# in .githooks/ and by the CI workflows, so both enforce exactly the same thing.
#
# Branch flow:
#   feature/… fix/… ──PR (squash)──▶ staging ──PR (merge commit)──▶ main
#   hotfix/…        ──PR (squash)──▶ main, then main ──PR──▶ staging (back-merge)

# Production and integration branches.
RELEASE_BRANCH="main"
INTEGRATION_BRANCH="staging"

# Branches nobody may commit or push to directly. Changes land via pull request.
PROTECTED_BRANCHES=("$RELEASE_BRANCH" "$INTEGRATION_BRANCH" "master" "develop")

# Allowed branch prefixes: <type>/<short-kebab-description>
BRANCH_TYPES="feature|fix|hotfix|bugfix|chore|docs|refactor|test|ci|perf|build|style|release"
BRANCH_PATTERN="^(${BRANCH_TYPES})/[a-z0-9]+([._-][a-z0-9]+)*$"

# Branches opened by bots (Dependabot) keep their own naming.
BOT_BRANCH_PATTERN="^dependabot/"

# Conventional Commits: <type>(<optional scope>)!: <subject>
COMMIT_TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
COMMIT_PATTERN="^(${COMMIT_TYPES})(\([a-z0-9._/-]+\))?!?: [^ ].{0,98}$"

red() { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[32m%s\033[0m\n' "$*" >&2; }
dim() { printf '\033[2m%s\033[0m\n' "$*" >&2; }

is_protected_branch() {
  local branch="$1" p
  for p in "${PROTECTED_BRANCHES[@]}"; do
    [[ "$branch" == "$p" ]] && return 0
  done
  return 1
}

# Usage: check_branch_name <name>  → exit 0 if valid, prints help otherwise.
check_branch_name() {
  local branch="$1"
  if [[ "$branch" =~ $BRANCH_PATTERN || "$branch" =~ $BOT_BRANCH_PATTERN ]]; then
    return 0
  fi
  red "✖ Invalid branch name: '$branch'"
  dim "  Branch names must look like <type>/<short-description>, lowercase kebab-case."
  dim "  Allowed types: ${BRANCH_TYPES//|/, }"
  dim "  Examples: feature/contact-sync, fix/otp-timeout, chore/bump-flutter"
  dim "  Rename with: git branch -m <type>/<description>"
  return 1
}

# Usage: check_pr_flow <base branch> <head branch>
# Enforces which branch may be merged into which (see the flow at the top).
check_pr_flow() {
  local base="$1" head="$2"

  case "$base" in
    "$RELEASE_BRANCH")
      [[ "$head" == "$INTEGRATION_BRANCH" ]] && return 0
      [[ "$head" == hotfix/* ]] && { check_branch_name "$head"; return; }
      red "✖ '$head' cannot be merged into '$RELEASE_BRANCH'."
      dim "  Only '$INTEGRATION_BRANCH' (a release) or a hotfix/… branch may target '$RELEASE_BRANCH'."
      dim "  Change this PR's base branch to '$INTEGRATION_BRANCH'."
      return 1
      ;;
    "$INTEGRATION_BRANCH")
      # Back-merge after a hotfix keeps staging in sync with production.
      [[ "$head" == "$RELEASE_BRANCH" ]] && return 0
      if is_protected_branch "$head"; then
        red "✖ '$head' cannot be merged into '$INTEGRATION_BRANCH'."
        return 1
      fi
      check_branch_name "$head"
      ;;
    *)
      # Stacked PRs into another working branch.
      check_branch_name "$head"
      ;;
  esac
}

# Usage: check_commit_subject <first line of message>
check_commit_subject() {
  local subject="$1"
  # Git-generated messages are allowed as-is.
  if [[ "$subject" =~ ^(Merge|Revert\ \"|fixup!|squash!|amend!) ]]; then
    return 0
  fi
  if [[ "$subject" =~ $COMMIT_PATTERN ]]; then
    return 0
  fi
  red "✖ Commit message does not follow Conventional Commits:"
  red "    $subject"
  dim "  Format: <type>(<optional-scope>): <subject>   (max 100 chars)"
  dim "  Types:  ${COMMIT_TYPES//|/, }"
  dim "  Examples: feat(map): cluster nearby pins"
  dim "            fix(auth): retry OTP after timeout"
  dim "            chore!: drop iOS 15 support"
  return 1
}
