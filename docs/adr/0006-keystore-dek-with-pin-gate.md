# ADR-0006: Keep the data key in the Keystore, gate it with a PIN

**Status:** Accepted
**Date:** 2026-09-07

## Context

The app holds private notes about real people. The data must be encrypted on disk.

The threat is stated plainly by the product owner:

> The encryption is just for a stolen phone. If someone has a rooted device then I really don't
> care.

That sentence decides this record. The app defends against a thief who takes the phone and reads
the storage. The app does not try to defend against an attacker who already owns the running
operating system. That second fight cannot be won by an app anyway.

The app also needs a PIN. Two people may share one phone, and a passer-by should not read the
screen.

The key must come from somewhere. Three sources are possible: the user's memory, the phone
hardware, or both.

## Decision

Generate a random 256-bit **data key** on first launch. Store it in the Android Keystore or the
iOS Keychain. Both are hardware-backed and mark the key as non-exportable.

Use the **PIN as a gate, not as a key**. Store an Argon2id hash of the PIN for checking only. The
PIN never derives the data key.

The unlock flow:

```
PIN typed  ->  Argon2id hash matches?  ->  read data key from Keystore  ->  open SQLCipher file
```

Prefer the platform's biometric or device-credential binding on the Keystore entry where it is
available.

## Consequences

### Positive

- A stolen phone gives a thief an encrypted file and no key. That is the threat we chose to stop.
- A forgotten PIN does not destroy the data. A reset flow can rebuild the gate and keep the file.
- Changing the PIN is instant. It rewrites one hash. It does not re-encrypt the database.
- The key is random, so it has full 256-bit strength. A 4-digit PIN never limits it.

### Negative

- The key sits on the device. An attacker with root and a running OS can reach it. We accept this.
- A factory reset, or some OS upgrades, can wipe the Keystore. The data then becomes unreadable.
  Backups are the answer. See [ADR-0010](0010-encrypted-logical-backup.md).
- Dart cannot wipe memory reliably. Once unlocked, the key exists in the process heap. A memory
  dump of a running, unlocked app would expose it. This is a known limit, not a bug to fix.
- Keystore behaviour differs between Android versions and vendors. Expect device-specific bugs.

## Alternatives Considered

### Derive the key from the PIN with Argon2id

**Why rejected:** It sounds stronger and is weaker in practice. A 4 to 6 digit PIN has at most a
million values. An attacker holding the file can try them all offline, and no key stretching fixes
that few possibilities. It also makes a forgotten PIN destroy the data forever, and a PIN change
re-encrypt the whole database. It costs a lot and buys nothing against our stated threat.

### Wrap the data key twice, by the Keystore and by the PIN

**Why rejected:** This is the strongest design of the three. It also has the most moving parts and
the most ways to fail. Against a stolen-phone threat it adds no protection the Keystore does not
already give. Reconsider only if the threat model changes.

### Note on Argon2id availability

Argon2id is used here only to hash the PIN. If no maintained Dart package is available, use
PBKDF2-HMAC-SHA256 with a high iteration count from the `cryptography` package. That is weaker
against GPUs, and it is acceptable, because the PIN hash guards a gate and not the key itself.
