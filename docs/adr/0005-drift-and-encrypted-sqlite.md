# ADR-0005: Store data in drift over an encrypted SQLite

**Status:** Accepted
**Date:** 2026-09-07. Encryption mechanism revised 2026-09-08.

## Context

The app stores friends, meetings, and notes. The shape is relational. One friend has many
meetings. One friend has many notes. Queries join across them.

The data must be encrypted on disk. See [ADR-0006](0006-keystore-dek-with-pin-gate.md).

The data set is small. About 100 friends, each with a handful of notes. Everything fits in memory.
Query speed is not a concern at this size.

Two things do matter. First, backups must survive schema changes, so migrations must be reliable.
Second, repository tests must be fast and real, not mocked.

The author has not built an encrypted database before, so the setup should be well documented and
widely used.

## Decision

Use **drift** as the database layer. Encrypt the file with **SQLite3MultipleCiphers**.

`package:sqlite3` already bundles a SQLite build with the app through a Dart build hook. Choosing
an encrypted build is a matter of naming a different source in `pubspec.yaml`. There is no extra
dependency:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
```

Encryption is transparent. Open the database, set `pragma key`, and the SQL does not change. Every
page is encrypted on write and decrypted on read. The default cipher is ChaCha20-Poly1305.

Use drift's in-memory driver for repository tests. Tests then run real SQL against a real engine.

## Verification

Measured on an Android 33 emulator on 2026-09-08, with a database created, closed, and reopened:

| Check | Result |
|---|---|
| File header | binary, not the ASCII `SQLite format 3` |
| Inserted string present in the raw bytes | no |
| `pragma cipher` | `chacha20` |
| Read back with the right key | succeeded |
| Read with a wrong key | failed, `file is not a database` |
| SQLite version | 3.53.4, the same as the unencrypted build |

## Consequences

### Positive

- Encryption is transparent. No field-level encryption code to write or get wrong.
- No extra dependency and no extra native library. The build hook that bundles SQLite anyway
  fetches an encrypted build instead.
- drift checks SQL at build time. A typo in a column name fails the build, not the app.
- drift has real migration support with tests. Schema changes stay safe.
- Repository tests use a real database in memory. They are fast and they catch real SQL bugs.
- Relational data stays relational. No object graph to flatten by hand.

### Negative

- **Changing the `source` define needs `flutter clean`.** The hook re-runs and downloads the right
  library, but Gradle keeps packaging the previously bundled one. The build succeeds and the app
  ships an unencrypted database. Confirm the swap by listing the APK and reading the library name:
  `unzip -l build/app/outputs/flutter-apk/app-debug.apk | grep libsqlite3`.
- SQLite3MultipleCiphers carries its own licence, which is not SQLite's public domain dedication.
- The encrypted database cannot be opened by ordinary SQLite tools during debugging. You need the
  key and a cipher-aware client.
- drift generates code. The build needs `build_runner`, and generated files must stay in sync.
- A cipher or format change between library versions can make an old file unreadable. Never back up
  the raw `.db` file. See [ADR-0010](0010-encrypted-logical-backup.md).

## Alternatives Considered

### `sqlcipher_flutter_libs`

This record originally named this package.

**Why rejected:** It is dead. It resolves to `0.7.0+eol` and performs no functionality; it exists
only to stop applications using the old Flutter-specific SQLite build scripts. Its own description
says to move to version 3.x of `package:sqlite3`. Declaring it would have produced an app that
looked encrypted and was not.

### SQLCipher through the same hook, `source: sqlcipher`

SQLCipher is about fifteen years old and widely audited. Signal uses it. It remains available as a
one-word change to the define above.

**Why rejected:** On Android its build links OpenSSL, which adds a second native library and a
second licence. `package:sqlite3` also warns that its SQLCipher build may ship an older SQLite than
the other two. SQLite3MultipleCiphers needs no extra library, tracked the current SQLite version in
the measurement above, and still reads a SQLCipher file after the compatibility pragmas. Both
encrypt whole pages with a modern cipher, and the threat in
[ADR-0006](0006-keystore-dek-with-pin-gate.md) is a stolen phone, not an attack on the cipher.

### `sqflite_sqlcipher`

**Why rejected:** It works and it is simpler to set up. It gives raw SQL strings with no build-time
checking and weaker migration tooling. Migrations matter here because backups must outlive schema
versions.

### Isar or Hive with encryption

**Why rejected:** Both are document stores. The data is relational, so joins would become manual
loops. Encryption support is also thinner, and neither has the audit history of a mainstream SQLite
cipher build.

### Plain SQLite with field-level encryption

**Why rejected:** It means writing crypto code for every sensitive column. It also leaks structure:
row counts, dates, and table sizes stay readable. Whole-file encryption leaks none of that.
