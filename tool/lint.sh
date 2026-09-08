#!/usr/bin/env bash
# Check formatting and analyse the whole repository.
#
# The pre-commit hook and CI both call this, so "clean" means one thing in both
# places. Tests are not run here: a slow hook is a bypassed hook.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_packages.sh"
cd "$REPO_ROOT"

echo "==> format"
dart format --output=none --set-exit-if-changed .

# One run covers all four packages. The analyzer resolves every file against
# its own enclosing package, so a `package:flutter` import inside friendo_domain
# still fails here, and that package's own analysis_options.yaml still applies.
# Verified by probe on 2026-09-08.
echo "==> analyze"
flutter analyze

echo "==> boundaries"
"$REPO_ROOT/tool/boundaries.sh"
