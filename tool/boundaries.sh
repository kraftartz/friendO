#!/usr/bin/env bash
# Fail when a package declares a dependency that its boundary forbids.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_packages.sh"
cd "$REPO_ROOT"

# ADR-0004 and ADR-0018 both say the compiler holds these lines, and both are
# right. The compiler proves that the code written today compiles. It cannot
# prove that the boundary still exists, because the boundary lives in three
# pubspec files and one added line removes it silently. This script watches
# those files. See ADR-0023.
#
# Each package gets an allowlist and not a denylist. A new dependency then
# fails until somebody edits this file, which is the moment to decide whether
# it belongs.

DOMAIN_ALLOWED="equatable lints test"
UI_ALLOWED="flutter flutter_lints flutter_test"
BOOK_ALLOWED="flutter flutter_lints flutter_test friendo_ui widgetbook cupertino_icons"

failed=0

# Print the key of every entry under `dependencies:` and `dev_dependencies:`.
declared() {
  awk '
    /^[a-z_]+:/            { section = $0; sub(/:.*/, "", section) }
    /^  [a-z_][a-z_0-9]*:/ {
      if (section == "dependencies" || section == "dev_dependencies") {
        key = $1; sub(/:$/, "", key); print key
      }
    }
  ' "$1"
}

check() {
  local package="$1" pubspec="packages/$1/pubspec.yaml" allowed=" $2 " name
  while read -r name; do
    [ -z "$name" ] && continue
    case "$allowed" in
      *" $name "*) ;;
      *)
        echo "boundary: $package must not depend on '$name'" >&2
        failed=1
        ;;
    esac
  done < <(declared "$pubspec")
}

check friendo_domain "$DOMAIN_ALLOWED"
check friendo_ui "$UI_ALLOWED"
check friendo_ui_book "$BOOK_ALLOWED"

# The domain must not name Flutter in `environment:` either. That key alone
# puts Flutter into the package config and turns a compile error into a lint.
if awk '/^environment:/ { in_env = 1; next } /^[a-z_]+:/ { in_env = 0 }
        in_env && /^  flutter:/ { found = 1 } END { exit !found }' \
        packages/friendo_domain/pubspec.yaml; then
  echo "boundary: friendo_domain must not name flutter in environment:" >&2
  failed=1
fi

# The strongest form of the same check, and the only one that sees a dependency
# pulled in by another dependency. `pub get` writes this file, so it runs only
# when the file is there.
config="packages/friendo_domain/.dart_tool/package_config.json"
if [ -f "$config" ] && grep -q '"name": *"flutter"' "$config"; then
  echo "boundary: Flutter resolved into friendo_domain's package config" >&2
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  echo "==> boundaries: FAILED" >&2
  exit 1
fi
echo "==> boundaries: ok"
