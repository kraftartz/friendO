# ADR-0006: Wrap the data key with a Keystore key, and gate it with a PIN

**Status:** Accepted. The reset flow in Consequences is superseded by
[ADR-0031](0031-a-forgotten-pin-loses-the-profile.md): a forgotten PIN has no way back.
**Date:** 2026-09-07. Key mechanism corrected 2026-09-09, and biometric binding marked out of
scope. [ADR-0024](0024-keystore-holds-a-wrapping-key.md) found both gaps and holds the reasoning.

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

Use **two keys**, not one.

Generate a random **wrapping key** for each Profile. Keep it in the Android Keystore or the iOS
Keychain, which mark it non-exportable. It never leaves the hardware.

Generate a random 256-bit **data key**. Ask the hardware to wrap it, and store only the wrapped
value. SQLCipher needs the data key in plain text, so the app asks the hardware to unwrap it at
unlock. The plain data key then lives in the Dart heap until the Profile locks.

```
Keystore / Keychain           Shared preferences / Keychain item     File
-------------------           ----------------------------------     ----
wrapping key (non-            wrapped data key (ciphertext)          friendo_A.db
exportable, per Profile)  ->  unwrapped in process memory  ------->  (SQLCipher)
```

Two keys are necessary, not extra. A non-exportable key never leaves the hardware, and SQLCipher
must receive a key in Dart. One key cannot do both jobs.

A thief gets the file and the wrapped value. The thief gets neither key, because the wrapping key
cannot leave the hardware. That answers the threat this record chose.

Use the **PIN as a gate, not as a key**. Store an Argon2id hash of the PIN for checking only. The
PIN never derives either key.

The unlock flow:

```
PIN typed  ->  Argon2id hash matches?  ->  unwrap the data key  ->  open SQLCipher file
```

**Biometric binding on the Keystore entry is out of scope for v1.** `flutter_secure_storage`
exposes no `setUserAuthenticationRequired`, so the flag needs platform channel code that nobody has
written. [ADR-0011](0011-app-lock-and-screen-privacy.md) keeps biometric unlock as a gate in front
of the app. That is a different check, in a different place.

## Consequences

### Positive

- A stolen phone gives a thief an encrypted file and no key. That is the threat we chose to stop.
- A forgotten PIN does not destroy the data, and a reset flow can rebuild the gate.
  **No longer true.** [ADR-0031](0031-a-forgotten-pin-loses-the-profile.md) removes the reset
  flow, because it needed no secret and made the PIN a courtesy screen.
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
