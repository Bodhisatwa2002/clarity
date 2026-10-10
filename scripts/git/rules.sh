#!/usr/bin/env bash
# Single source of truth for the repo's git rules. Sourced by the local hooks
# in .githooks/ and by the CI workflows, so both enforce exactly the same thing.

# Branches nobody may commit or push to directly. Changes land via pull request.
PROTECTED_BRANCHES=("main" "master" "develop")

# Allowed branch prefixes: <type>/<short-kebab-description>
BRANCH_TYPES="feature|fix|hotfix|bugfix|chore|docs|refactor|test|ci|perf|build|style|release"
BRANCH_PATTERN="^(${BRANCH_TYPES})/[a-z0-9]+([._-][a-z0-9]+)*$"

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
  if [[ "$branch" =~ $BRANCH_PATTERN ]]; then
    return 0
  fi
  red "✖ Invalid branch name: '$branch'"
  dim "  Branch names must look like <type>/<short-description>, lowercase kebab-case."
  dim "  Allowed types: ${BRANCH_TYPES//|/, }"
  dim "  Examples: feature/contact-sync, fix/otp-timeout, chore/bump-flutter"
  dim "  Rename with: git branch -m <type>/<description>"
  return 1
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
