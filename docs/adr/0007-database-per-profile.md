# ADR-0007: Give each profile its own database file

**Status:** Accepted
**Date:** 2026-09-07

## Context

Two people may share one phone. A couple shares a tablet. A partner borrows a phone.

Each person keeps private notes about their own friends. Person B must not read person A's notes.
That is the whole reason the login exists. There is no other multi-user feature, no sharing, and
no shared data of any kind.

The app must decide how to separate the two sets of data.

## Decision

Give each profile its own SQLCipher file and its own data key.

```
Keystore                          Files
--------                          -----
profile_A_key  ------------->     friendo_A.db
profile_B_key  ------------->     friendo_B.db
```

Unlocking profile B loads only profile B's key. Profile A's file stays encrypted with a key that is
not in memory.

Store the profile list itself outside the encrypted files. It holds only a display name, an avatar,
and a PIN hash. It holds no friend data.

## Consequences

### Positive

- The separation is cryptographic. Profile B cannot read profile A's file even with a bug in the
  query layer.
- No query needs a `WHERE profile_id = ?` clause. A forgotten clause cannot leak data, because
  there is no shared table to leak from.
- Deleting a profile means deleting one file and one key. Nothing is left behind in shared tables.
- Backup and restore work per profile with no filtering.

### Negative

- The app opens and closes database connections when switching profiles. Switching is slower than
  a query filter would be.
- Two files mean two migration runs. A schema change must apply to each file as it is opened.
- The profile list sits outside encryption. An attacker learns that two profiles exist and what
  they are named. That metadata leak is accepted.

## Alternatives Considered

### One database with a `profile_id` column

**Why rejected:** One key would decrypt both people's data. Once profile B unlocks the app, profile
A's rows are readable in memory, and only application code stops them being shown. A single missing
`WHERE` clause becomes a privacy breach. The whole point of the login is that this cannot happen.

### One database, with the second profile's rows encrypted per field

**Why rejected:** It mixes both models and gains nothing. It still shares a file, and it adds
field-level crypto code that [ADR-0005](0005-drift-and-sqlcipher.md) already rejected.
