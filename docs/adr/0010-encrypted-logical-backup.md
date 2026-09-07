# ADR-0010: Export an encrypted logical backup

**Status:** Accepted
**Date:** 2026-09-07

## Context

The app keeps everything on one phone and encrypts it there. See
[ADR-0003](0003-offline-only-no-internet-permission.md) and
[ADR-0006](0006-keystore-dek-with-pin-gate.md).

That design has one hard consequence. Lose the phone and you lose years of notes. A factory reset
or a wiped Keystore does the same. There is no server copy to fall back on.

A backup must therefore exist. It must survive the phone that made it.

This creates a problem that follows straight from ADR-0006. **The Keystore key cannot leave the
device.** That is the point of hardware-backed storage. So the backup cannot use that key, or it
would be unreadable on a new phone. The backup needs a second key, from something the user carries
in their head.

## Decision

Export a **logical backup**, not the database file. Write a versioned JSON document that holds
friends, meetings, notes, and settings.

Encrypt it with a key derived from a **backup passphrase**, separate from the app PIN.

```
BEK = Argon2id(passphrase, salt)
body = AES-256-GCM(json, BEK)
```

Write a header that travels with the file:

```
+-------+---------+------------+------+-------+------------+-----+
| MAGIC | version | kdf params | salt | nonce | ciphertext | tag |
+-------+---------+------------+------+-------+------------+-----+
```

Hand the finished file to the OS share sheet. The user picks the destination.

Ask for the passphrase on **every export**, not only the first. Each export then rehearses the
passphrase the user will need years later.

Import reverses the process. The user picks a file, types the passphrase, and the app rebuilds the
data into the current schema.

## Consequences

### Positive

- A backup restores onto a new phone with no account and no server.
- The KDF parameters sit inside the file. Costs can rise in a later version, and old files still
  open.
- A logical export survives schema changes. A 2026 backup imports into a 2029 app through normal
  migrations.
- Forced re-entry turns each export into practice. A passphrase typed twice a year is remembered.
- AES-GCM detects tampering. A damaged file fails loudly instead of importing wrong data.

### Negative

- The user must remember a second secret. Forgetting it makes the backup useless.
- A leaked file is attackable offline. Passphrase strength is the only defence at that point.
- Import needs mapping code from every old format version to the current schema. That code grows.
- The app cannot tell the user whether a backup exists or is recent. It never sees the destination.

The last two negatives are accepted on purpose. The product owner set the rule:

> I'm providing options; not holding the hand.

## Alternatives Considered

### Copy the raw SQLCipher database file

**Why rejected:** It ties the backup to one schema version and one SQLCipher build. A library
upgrade can change the file format and orphan every old backup. A disaster archive must outlive the
app that wrote it.

### Protect the backup with the app PIN

**Why rejected:** The PIN is the most memorable secret the user has, which is a real argument for
it. It is also 4 to 6 digits. A leaked file falls to an offline search of a million values. A
passphrase costs one screen and removes that risk.

### Generate a high-entropy recovery code

**Why rejected:** It is the strongest option and it has the worst failure mode. A lost code makes
the backup unreadable, which recreates the exact total loss the backup exists to prevent.

### Integrate a cloud provider and back up automatically

**Why rejected:** It needs the INTERNET permission. See
[ADR-0003](0003-offline-only-no-internet-permission.md).
