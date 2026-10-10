.PHONY: setup format lint test check protect

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
