# ADR-0005: Store data in drift over SQLCipher

**Status:** Accepted
**Date:** 2026-09-07

## Context

The app stores friends, meetings, and notes. The shape is relational. One friend has many
meetings. One friend has many notes. Queries join across them.

The data must be encrypted on disk. See [ADR-0006](0006-keystore-dek-with-pin-gate.md).

The data set is small. About 100 friends, each with a handful of notes. Everything fits in memory.
Query speed is not a concern at this size.

Two things do matter. First, backups must survive schema changes, so migrations must be reliable.
Second, repository tests must be fast and real, not mocked.

The author has not used SQLCipher before, so the setup should be well documented and widely used.

## Decision

Use **drift** as the database layer. Use **`sqlcipher_flutter_libs`** to supply an encrypted SQLite
build underneath it.

SQLCipher is SQLite with AES-256 page encryption built in. You open the database with a key. Every
page is encrypted on write and decrypted on read. The SQL you write does not change.

SQLCipher is about fifteen years old and widely audited. Signal uses it. This is settled
technology, not a new idea. That is the point.

Use drift's in-memory driver for repository tests. Tests then run real SQL against a real engine.

## Consequences

### Positive

- Encryption is transparent. No field-level encryption code to write or get wrong.
- drift checks SQL at build time. A typo in a column name fails the build, not the app.
- drift has real migration support with tests. Schema changes stay safe.
- Repository tests use a real database in memory. They are fast and they catch real SQL bugs.
- Relational data stays relational. No object graph to flatten by hand.

### Negative

- The native SQLCipher library adds a few megabytes to the app size.
- drift generates code. The build needs `build_runner`, and generated files must stay in sync.
- The encrypted database cannot be opened by ordinary SQLite tools during debugging. You need the
  key and a SQLCipher-aware client.
- SQLCipher version upgrades can change the file format. Never back up the raw `.db` file. See
  [ADR-0010](0010-encrypted-logical-backup.md).

## Alternatives Considered

### `sqflite_sqlcipher`

**Why rejected:** It works and it is simpler to set up. It gives raw SQL strings with no build-time
checking and weaker migration tooling. Migrations matter here because backups must outlive schema
versions.

### Isar or Hive with encryption

**Why rejected:** Both are document stores. The data is relational, so joins would become manual
loops. Encryption support is also thinner than SQLCipher's, and neither has SQLCipher's audit
history.

### Plain SQLite with field-level encryption

**Why rejected:** It means writing crypto code for every sensitive column. It also leaks structure:
row counts, dates, and table sizes stay readable. Whole-file encryption leaks none of that.
