#!/usr/bin/env bash
# Read the two manifest promises out of a built release APK.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_packages.sh"
cd "$REPO_ROOT"

# ADR-0003 promises that the app cannot open a socket. ADR-0020 promises that
# the OS copies nothing off the phone. Both promises live in the merged
# manifest, which is the file a reader can check and the file a dependency can
# change without anybody noticing.
#
# The release APK is the artefact, not the debug one. The debug and profile
# manifests declare INTERNET on purpose, because the Flutter tool needs it for
# hot reload. A check that read those would fail on a clean tree, and a check
# that cries wolf gets deleted.
#
# See ADR-0023.

APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"

if [ ! -f "$APK" ]; then
  echo "manifest: no APK at $APK. Run: flutter build apk --release" >&2
  exit 1
fi

# The Android SDK ships aapt2 once per build-tools version. Take the newest.
AAPT2=""
for candidate in "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"/build-tools/*/aapt2; do
  [ -x "$candidate" ] && AAPT2="$candidate"
done
if [ -z "$AAPT2" ]; then
  # Never pass quietly. A check that cannot run has proved nothing.
  echo "manifest: aapt2 not found. Set ANDROID_HOME to an SDK with build-tools." >&2
  exit 1
fi

manifest="$("$AAPT2" dump xmltree "$APK" --file AndroidManifest.xml)"

failed=0
fail() { echo "manifest: $1" >&2; failed=1; }

# ADR-0003. Any permission that reaches the network fails the build, not only
# INTERNET, because a dependency that wants one usually asks for both.
for permission in INTERNET ACCESS_NETWORK_STATE ACCESS_WIFI_STATE; do
  if grep -q "android.permission.$permission" <<<"$manifest"; then
    fail "android.permission.$permission is in $APK"
  fi
done

# ADR-0020. aapt2 prints a false boolean as `false` or as `(type 0x12)0x0`,
# depending on its build-tools version. Accept either, and accept nothing else.
if ! grep -qE 'allowBackup\(0x[0-9a-f]+\)=(false|\(type 0x12\)0x0)' <<<"$manifest"; then
  fail "android:allowBackup is not false"
fi
grep -q 'dataExtractionRules' <<<"$manifest" ||
  fail "android:dataExtractionRules is not set"
grep -q 'fullBackupContent' <<<"$manifest" ||
  fail "android:fullBackupContent is not set"

if [ "$failed" -ne 0 ]; then
  echo "==> manifest: FAILED" >&2
  exit 1
fi
echo "==> manifest: ok ($APK)"
