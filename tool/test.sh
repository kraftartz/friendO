#!/usr/bin/env bash
# Run the tests of every package that has any.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_packages.sh"

while read -r path sdk; do
  # `flutter test` and `dart test` both fail when the directory holds no
  # matching file, so check for one rather than for the directory.
  if ! compgen -G "$REPO_ROOT/$path/test/*_test.dart" > /dev/null; then
    echo "==> skip (no tests): $path"
    continue
  fi
  echo "==> test: $path"
  (cd "$REPO_ROOT/$path" && "$sdk" test)
done < <(each_package)
