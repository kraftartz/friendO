# ADR-0023: Check the stated guarantees in CI

**Status:** Accepted
**Date:** 2026-09-08

## Context

This project turns a rule into a build error wherever it can, and says why:

> A folder cannot fail to compile. "Widgets hold no BLoC" would stay a review convention, and
> review conventions decay. — [ADR-0018](0018-ui-package-and-widgetbook.md)

It then states three guarantees that nothing checks.

**The INTERNET permission.** [ADR-0003](0003-offline-only-no-internet-permission.md) already asked
for the check and it was never written:

> Add a check to CI that fails the build if the INTERNET permission appears in the merged manifest.
> A transitive dependency can add that permission without anyone noticing.

The risk is live. `drift`, `flutter_local_notifications`, `flutter_secure_storage` and
`path_provider` are declared and not yet wired in. Each brings a manifest.

**The backup attributes.** [ADR-0020](0020-no-os-level-backup.md) adds three attributes to the same
manifest, and an unset attribute there means "back everything up".

**The package boundaries.** ADR-0004 and ADR-0018 both claim the compiler holds the line, and both
are right today. But the whole guarantee lives in three `pubspec.yaml` files, and nothing watches
those files. Add `flutter` to `packages/friendo_domain/pubspec.yaml` and CI stays green. The
compiler proves that the code written today compiles. It does not prove that the boundary still
exists.

There is a trap in writing the manifest check. `android/app/src/debug/AndroidManifest.xml` and the
profile one both declare INTERNET, correctly, because the Flutter tool needs it for hot reload. CI
builds only `--debug` today. A naive grep would fail on a clean tree, and a check that cries wolf
gets deleted.

## Decision

Two scripts in `tool/`, both callable by hand and both called by CI.

### `tool/manifest_guard.sh`

Read the promises out of a built **release** APK, which is the artefact the promises are about.

```bash
flutter build apk --release
./tool/manifest_guard.sh
```

It fails when any of these is true:

- `INTERNET`, `ACCESS_NETWORK_STATE` or `ACCESS_WIFI_STATE` appears in the packaged manifest. All
  three, because a dependency that wants one usually asks for two.
- `android:allowBackup` is not false.
- `android:dataExtractionRules` or `android:fullBackupContent` is missing.

It reads the manifest with `aapt2 dump xmltree`. **It fails when `aapt2` cannot be found.** A check
that cannot run has proved nothing, and a check that passes quietly in that state is worse than no
check.

Release signs with the debug key today. That is enough to read a manifest, and it must never reach
a store.

### `tool/boundaries.sh`

Called from `tool/lint.sh`, so it runs in the pre-commit hook as well as in CI. It reads the three
package files and fails when a package declares something its boundary forbids.

Each package gets an **allowlist**, not a denylist:

| Package | May declare |
|---|---|
| `friendo_domain` | `equatable`, `lints`, `test` |
| `friendo_ui` | `flutter`, `flutter_lints`, `flutter_test` |
| `friendo_ui_book` | `flutter`, `flutter_lints`, `flutter_test`, `friendo_ui`, `widgetbook`, `cupertino_icons` |

A new dependency then fails until somebody edits the list, which is the moment to decide whether it
belongs. A denylist only catches the names somebody thought of in advance.

Two more checks sit in the same script:

- `friendo_domain` must not name `flutter` under `environment:`. That key alone puts Flutter into
  the package config and turns a compile error into a lint.
- `packages/friendo_domain/.dart_tool/package_config.json` must hold no `flutter` entry. This is
  the strongest form of the same question and the only one that sees Flutter arriving through
  another dependency. It runs after `pub get` has written the file.

## Consequences

### Positive

- Three prose rules become three build errors, which is the standard this project sets elsewhere.
- The release APK is now built on every run, so the artefact that carries the promises is the
  artefact that gets read.
- The boundary check runs in the pre-commit hook, so it fails on the machine that broke it.
- The allowlist turns "should I add this dependency?" into a diff somebody has to approve.

### Negative

- CI gets slower. A release build is the longest step in the run.
- `tool/boundaries.sh` reads YAML with `awk`. It is fine for three hand-written files and it would
  not survive a generated pubspec or an unusual layout.
- The allowlist needs editing for every legitimate new dependency. That is the point, and it will
  still feel like friction at the time.
- The manifest check needs an Android SDK. It cannot run on a machine that only has Dart.
- Nothing here checks iOS. `Info.plist` and the Keychain classes from ADR-0020 stay unguarded,
  because iOS is not built in CI at all.

## Alternatives Considered

### Grep the source manifests instead of the built APK

**Why rejected:** The debug and profile manifests declare INTERNET on purpose. A grep over the
source tree fails on a clean checkout, and a check that always fails gets deleted or ignored.

### Read the merged manifest that Gradle writes under `build/`

**Why rejected:** Its path moves between Android Gradle Plugin versions. A check that silently
stops finding its input is the worst kind.

### A custom lint rule for the package boundaries

**Why rejected:** ADR-0004 already rejected a lint for this job: a lint can be turned off, and it
watches code rather than the pubspec where the boundary actually lives.

### Trust `dart analyze` to catch a broken boundary

**Why rejected:** It catches an import that exists. It cannot see a dependency added today for code
written next month, which is exactly when the boundary is lost.
