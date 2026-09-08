# ADR-0024: The Keystore holds a wrapping key, and the Profile list has a home

**Status:** Accepted
**Date:** 2026-09-08

Corrects the description in [ADR-0006](0006-keystore-dek-with-pin-gate.md). The decision in
ADR-0006 stands. This record says accurately what it does, and answers two questions it left open.

## Context

[ADR-0006](0006-keystore-dek-with-pin-gate.md) describes the data key like this:

> Store it in the Android Keystore or the iOS Keychain. Both are hardware-backed and mark the key
> as **non-exportable**.

Two sentences cannot both be true. A non-exportable key never leaves the secure hardware. The data
key must reach Dart, because Dart passes it to `pragma key` to open the SQLCipher file. So the data
key is not the non-exportable key.

What `flutter_secure_storage` actually does on Android is right, and it is not what the record says.
It uses a non-exportable Keystore key to **wrap** a value, and it keeps the wrapped value in shared
preferences. The design is correct. The wording is not, and the gap matters twice:

- It is why the leak in [ADR-0020](0020-no-os-level-backup.md) existed. The wrapped blob sits in
  shared preferences, and Android Auto Backup copies shared preferences.
- It is why ADR-0006's second sentence is hard to keep. `flutter_secure_storage` exposes no
  `setUserAuthenticationRequired` on the Keystore entry, so "prefer the platform's biometric or
  device-credential binding" cannot be done with the declared dependency alone.

ADR-0007 leaves a third question open. It says the Profile list sits outside the encrypted files.
It does not say in which file, or in what format, and that file holds PIN hashes.

## Decision

### Say what actually happens

```
Keystore / Keychain          Shared preferences / Keychain item      File
-------------------          ------------------------------          ----
wrapping key  (non-          wrapped data key  (ciphertext)          friendo_A.db
exportable, per Profile)  ->  unwrapped in process memory  ------->   (SQLCipher)
```

The **wrapping key** is random, per Profile, and non-exportable. It never leaves the hardware.

The **data key** is random, 256-bit, and stored wrapped. The app asks the hardware to unwrap it, and
the plaintext key then lives in the Dart heap for as long as the Profile is unlocked.

This is still a complete answer to the stolen-phone threat that ADR-0006 chose. A thief with the
file and the wrapped blob has neither key, because the wrapping key cannot be exported from the
hardware. Saying it precisely costs nothing.

ADR-0006's other negative already covered the memory half and stays true: "Dart cannot wipe memory
reliably."

### Biometric binding on the Keystore entry is out of scope for v1

`setUserAuthenticationRequired` needs platform channel code or a package that exposes the flag.
Neither is written, and neither is cheap.

This does **not** remove biometric unlock. [ADR-0011](0011-app-lock-and-screen-privacy.md) keeps it,
as a gate in front of the app. The difference:

| | Where the check runs | What it stops |
|---|---|---|
| ADR-0011, shipped | In the app, before unwrapping | A person holding the unlocked phone |
| Keystore binding, deferred | In the hardware, at unwrap time | Code on a rooted phone that calls unwrap itself |

The second only helps against an attacker who already owns the running OS, which ADR-0006 states
plainly is out of scope. So this is deferred on the same reasoning that decided ADR-0006, and not
on cost alone.

### The Profile list has a named home

One file, outside every encrypted database, holding one row per Profile:

```
profiles.json    { version, profiles: [ { id, displayName, avatarId, pinHash, kdfParams } ] }
```

- It is JSON, not a fourth SQLite file. It holds at most a handful of rows, it is read once before
  any Profile is unlocked, and it must be readable when no key is available.
- `pinHash` is Argon2id with its parameters beside it, so the cost can rise later and old files
  still open. This matches the rule [ADR-0010](0010-encrypted-logical-backup.md) sets for the
  Backup header.
- The Avatar is stored by id in the same directory, not inline, so the file stays small.
- [ADR-0020](0020-no-os-level-backup.md) keeps this file on the phone. It is the file that made
  that record necessary.

## Consequences

### Positive

- The record now matches what the code will do, so a reader will not build to a design that cannot
  exist.
- The reason ADR-0020 was needed is written down where somebody will find it.
- "Prefer the platform's binding" stops reading as a commitment that the declared dependency cannot
  meet.
- The Profile list has one shape, so the PIN reset flow and the Profile picker are built against
  the same thing.

### Negative

- The wrapped data key sits in shared preferences on Android. That is normal and it is one more
  place to remember when reasoning about what leaves the phone.
- `profiles.json` is plaintext by design. An attacker with the storage learns how many Profiles
  exist and what they are called. ADR-0007 already accepts that leak; this names the file it lives
  in.
- Deferring the Keystore binding means an attacker on a rooted phone can call unwrap. ADR-0006
  accepts that threat, and this record does not widen it.
- JSON has no schema. A hand-edited or half-written file must fail loudly rather than lose a
  Profile.

## Alternatives Considered

### Edit ADR-0006 in place

**Why rejected:** [ADR-0019](0019-correcting-and-partly-superseding-a-record.md) allows an in-place
edit for a fact. This is not one sentence of fact. It changes what a reader would build, and it
answers two questions ADR-0006 never asked. That makes it a record.

### Keep the data key in the hardware and encrypt page by page through it

**Why rejected:** SQLCipher needs the key material in the process to open the file. Wrapping every
page through a hardware call would be a different storage engine and slower by orders of magnitude,
for a threat ADR-0006 already declined to fight.

### Store the Profile list in its own SQLCipher file

**Why rejected:** Its key would have to be readable before any Profile is unlocked, so the
encryption would protect nothing. It would add a fourth database, a fourth migration path, and no
security.

### Put the Profile list in shared preferences

**Why rejected:** It is the platform's habit and it is the wrong shape. A list of records with a
version and a KDF block is a document. It also puts one more thing in the store that
[ADR-0020](0020-no-os-level-backup.md) had to exclude.
