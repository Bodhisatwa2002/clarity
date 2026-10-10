#!/usr/bin/env bash
# Applies the GitHub rulesets in .github/rulesets/ to the repo, so GitHub itself
# rejects direct pushes to main and branches with non-standard names — even
# with `git push --no-verify`. Safe to re-run: existing rulesets are updated.
#
# Requires: gh CLI logged in with admin rights on the repo (`gh auth login`).
# Note: rulesets on *private* repos need GitHub Pro/Team; public repos are free.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
echo "Applying rulesets to $repo"

# Repo settings that pair with the rulesets: squash-only merges whose commit
# title is the (Conventional Commits) PR title, and auto-delete merged branches.
gh api -X PATCH "repos/$repo" --silent \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -F delete_branch_on_merge=true
echo "✔ Merge settings: squash only, delete branch on merge"

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
