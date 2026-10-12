#!/usr/bin/env bash
# Runs the pgTAP database tests (RLS, functions) against the local stack.
# Everything runs in a rolled-back transaction, so the seed is untouched.
#   make db-test
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
export PATH="/opt/homebrew/bin:$PATH"

DB_URL="${LOCAL_DB_URL:-postgresql://postgres:postgres@127.0.0.1:54322/postgres}"
status=0
for file in supabase/tests/database/*.test.sql; do
  echo "▸ $file"
  out="$(psql "$DB_URL" -v ON_ERROR_STOP=1 -q -tA -f "$file" 2>&1)" || status=1
  grep -E '^(not )?ok|^#|ERROR' <<<"$out" || true
  grep -qE '^not ok|ERROR' <<<"$out" && status=1
done
[[ $status -eq 0 ]] && echo "✔ Database tests passed" || echo "✖ Database tests failed" >&2
exit $status
