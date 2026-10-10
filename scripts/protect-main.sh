#!/usr/bin/env bash
# Applies the GitHub rulesets in .github/rulesets/ to the repo, so GitHub itself
# rejects direct pushes to main/staging and branches with non-standard names —
# even with `git push --no-verify`. Also creates the staging branch (from main)
# if missing and makes it the default branch, so new PRs target it.
# Safe to re-run: existing rulesets are updated.
#
# Requires: gh CLI logged in with admin rights on the repo (`gh auth login`).
# Note: rulesets on *private* repos need GitHub Pro/Team; public repos are free.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
source scripts/git/rules.sh

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
echo "Applying rulesets to $repo"

# Repo settings that pair with the rulesets. Squash merges for work branches
# (feature → staging) and merge commits for releases (staging → main), both
# titled by the Conventional Commits PR title. Merged work branches are
# auto-deleted; protected branches never are.
gh api -X PATCH "repos/$repo" --silent \
  -F allow_squash_merge=true -F allow_merge_commit=true -F allow_rebase_merge=false \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -f merge_commit_title=PR_TITLE -f merge_commit_message=PR_BODY \
  -F delete_branch_on_merge=true
echo "✔ Merge settings: squash + merge commit, delete branch on merge"

for file in .github/rulesets/*.json; do
  name="$(jq -r .name "$file")"
  id="$(gh api "repos/$repo/rulesets" --jq ".[] | select(.name == \"$name\") | .id")"
  if [[ -n "$id" ]]; then
    gh api -X PUT "repos/$repo/rulesets/$id" --input "$file" --silent
    echo "✔ Updated ruleset: $name"
  else
    gh api -X POST "repos/$repo/rulesets" --input "$file" --silent
    echo "✔ Created ruleset: $name"
  fi
done

# Rulesets go first: the branch-naming ruleset must allow 'staging' before it
# can be created.
if ! gh api "repos/$repo/branches/$INTEGRATION_BRANCH" --silent 2>/dev/null; then
  sha="$(gh api "repos/$repo/git/ref/heads/$RELEASE_BRANCH" --jq .object.sha)"
  gh api -X POST "repos/$repo/git/refs" --silent \
    -f ref="refs/heads/$INTEGRATION_BRANCH" -f sha="$sha"
  echo "✔ Created branch '$INTEGRATION_BRANCH' from '$RELEASE_BRANCH'"
fi

gh api -X PATCH "repos/$repo" --silent -f default_branch="$INTEGRATION_BRANCH"
echo "✔ Default branch: $INTEGRATION_BRANCH"
