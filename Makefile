.PHONY: setup format lint test check protect run-staging db-start db-stop db-reset db-test db-diff db-drift db-link db-push db-push-seed test-integration

export PATH := /opt/homebrew/bin:$(PATH)

setup:    ## Install git hooks + fetch dependencies (run once per clone)
	@./scripts/setup.sh

format:   ## Format all Dart code
	dart format lib test

lint:     ## Static analysis, same flags as CI
	flutter analyze --fatal-infos --fatal-warnings

test:     ## Run the test suite
	flutter test

check:    ## Everything CI runs: format check, analyze, test
	@./scripts/check.sh

protect:  ## Apply GitHub branch rulesets (needs gh auth + a GitHub remote)
	@./scripts/protect-main.sh

# ── App ──────────────────────────────────────────────────────────────────────

run-staging:  ## Run the app against the staging Supabase project (config/staging.json)
	flutter run --dart-define-from-file=config/staging.json

# ── Database (Supabase) — see supabase/README.md ─────────────────────────────

# Only the four containers the app needs: db, auth, REST API, gateway.
DB_EXCLUDE := realtime,storage-api,imgproxy,mailpit,postgres-meta,studio,edge-runtime,logflare,vector,supavisor

db-start:     ## Start the local Supabase stack (db + auth + API only)
	supabase start -x $(DB_EXCLUDE)

db-stop:      ## Stop the local stack (data is kept)
	supabase stop

db-reset:     ## Recreate the local database from migrations + seed.sql
	supabase db reset --local
	@# The REST API caches the schema; tell it about any new columns.
	@psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -qc "notify pgrst, 'reload schema'"

db-test:      ## pgTAP tests: RLS and functions (local stack must be running)
	@./scripts/db/test.sh

db-diff:      ## Generate ONE migration from supabase/schemas changes: make db-diff NAME=add_trips
	@test -n "$(NAME)" || (echo "Usage: make db-diff NAME=<short_snake_case_name>" && exit 1)
	supabase db schema declarative sync --no-apply --name $(NAME)

db-drift:     ## Check migrations rebuild exactly what supabase/schemas describes
	@out="$$(supabase db schema declarative sync --no-apply --name drift_check 2>&1)"; \
	  if grep -q "No schema changes found" <<<"$$out"; then echo "✔ No drift"; \
	  else rm -f supabase/migrations/*_drift_check.sql; echo "$$out" | tail -20; echo "✖ Schema files and migrations differ"; exit 1; fi

db-link:      ## Link the CLI to the project in .env (once per machine)
	@set -a && . ./.env && set +a && supabase link --project-ref "$$SUPABASE_PROJECT_REF" -p "$$SUPABASE_DB_PASSWORD"

db-push:      ## Apply pending migrations to the linked project (prompts first)
	@set -a && . ./.env && set +a && supabase db push -p "$$SUPABASE_DB_PASSWORD"

db-push-seed: ## Same, plus seed.sql — staging only, never production
	@set -a && . ./.env && set +a && test "$$APP_ENV" = staging || (echo "Refusing: APP_ENV is not staging" && exit 1)
	@set -a && . ./.env && set +a && supabase db push --include-seed -p "$$SUPABASE_DB_PASSWORD"

test-integration: ## App ↔ Supabase end-to-end test against the local stack
	@eval "$$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|PUBLISHABLE_KEY)=')" && \
	  SUPABASE_TEST_URL="$$API_URL" SUPABASE_TEST_KEY="$$PUBLISHABLE_KEY" flutter test test/integration/
	@$(MAKE) --no-print-directory db-reset
