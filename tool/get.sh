#!/usr/bin/env bash
# Fetch dependencies for every package.
#
# The packages resolve independently, each with its own lockfile. That is what
# keeps `package:flutter` unresolvable inside friendo_domain, so it is worth the
# extra calls this script makes.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_packages.sh"

while read -r path sdk; do
  echo "==> pub get: $path"
  (cd "$REPO_ROOT/$path" && "$sdk" pub get)
done < <(each_package)
