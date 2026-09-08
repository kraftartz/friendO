# The four packages, and the SDK that drives each one.
#
# friendo_domain is pure Dart, so it uses `dart`. It has no flutter_test and no
# package_config entry for Flutter, so `flutter test` cannot run it.
#
# Sourced by the other scripts. Not runnable on its own.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PACKAGES=(
  ".:flutter"
  "packages/friendo_domain:dart"
  "packages/friendo_ui:flutter"
  "packages/friendo_ui_book:flutter"
)

# Print "path sdk" for each package, so callers can read both with one `read`.
each_package() {
  local entry
  for entry in "${PACKAGES[@]}"; do
    echo "${entry%%:*} ${entry##*:}"
  done
}
