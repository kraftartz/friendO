# Spec: First Run

**Status:** Ready for an agent
**Date:** 2026-09-09

First Run is the one time a phone has no Profile at all. It ends when the first Profile exists.
See [CONTEXT.md](../../CONTEXT.md).

This spec covers the creation of a Profile and nothing else. It is the work that forces the
wrapping key, the wrapped data key, `profiles.json`, the encrypted database file and the Argon2id
PIN hash into existence for the first time.

## Problem Statement

A User opens friendO on a phone that holds no Profile. Nothing exists yet: no key, no database
file, no list of Profiles. The app cannot show the Dial, because there is nowhere to read a Friend
from and no key to read it with.

The User also does not know what they are agreeing to. friendO keeps everything on the phone. If
the phone is lost, the data is lost with it. [ADR-0020](../adr/0020-no-os-level-backup.md) asked
for one sentence that says so, and gave it no home.

A third problem is silent. A half-made Profile is worse than none. If a row appears in the Profile
list before its key exists, the User owns a Profile that can never open, and
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) offers no way to remove it. The only
remedy is clearing the app's data, which takes every Profile with it.

## Solution

Three screens, in order.

1. **Create the Profile.** The User types a name and a six-digit PIN, then the same PIN again.
2. **State the cost.** One screen says that friendO keeps everything on this phone, that nothing is
   copied anywhere, and that a lost phone loses what is in it. One button continues.
3. **The Dial, empty.** Three empty Orbits and a call to add the first Friend.

Behind the first screen, one call does all the key work in a fixed order and commits last. Either a
Profile exists in full, or nothing changed.

This is [ADR-0030](../adr/0030-first-run-creates-one-profile.md), built.

## User Stories

### Making the Profile

1. As a User opening friendO for the first time, I want the app to start on a screen that creates a
   Profile, so that I do not look at a Dial I cannot use.
2. As a User, I want to type a name for my Profile, so that a second Profile on this phone can be
   told apart from mine.
3. As a User, I want a name of my choosing rather than one taken from the phone, so that the app
   asks the phone for nothing about me.
4. As a User, I want to type a six-digit PIN, so that a person holding my phone cannot read my
   notes about my Friends.
5. As a User, I want the keypad to submit on the sixth press, so that I never look for a confirm
   button.
6. As a User, I want to type the PIN a second time, so that a typo does not lock me out of a
   Profile that has no way back.
7. As a User whose two entries differ, I want to be told and returned to the first entry, so that I
   know which one to correct.
8. As a User, I want the digits I type to be hidden on screen, so that a person beside me learns
   nothing.
9. As a User, I want to correct a digit I mistyped, so that one wrong press does not force me to
   start again.
10. As a User, I want the app to refuse an empty name, so that my Profile is not a blank row on the
    picker.

### Knowing the cost

11. As a User, I want one screen that says friendO keeps everything on this phone, so that I learn
    the one thing I cannot discover later by exploring.
12. As a User, I want that screen to say that a lost phone loses the data, so that I can decide
    whether to trust the app before I write anything private in it.
13. As a User, I want that screen to appear after the PIN and before the Dial, so that it arrives
    when I am not busy typing.
14. As a User, I want a single button that continues, so that the screen does not ask me to agree
    to anything.
15. As a User, I do not want to be able to go back into the creation screen from that screen, so
    that I cannot make a second Profile by accident.

### Reaching the app

16. As a User, I want to land on the Dial with nothing on it, so that I see what the app is for
    before I add anybody.
17. As a User, I want a clear call to add my first Friend, so that three counts of zero do not read
    as a broken screen.
18. As a User, I do not want a tour, so that nothing stands between me and the app.
19. As a User, I do not want a sample Friend, so that the first thing I learn is not how to delete
    something.
20. As a User, I do not want a permission prompt during First Run, so that every prompt I see later
    is one I earned.

### Privacy of what is written

21. As a User, I want my Friends held in a file that is encrypted on disk, so that a thief with my
    phone gets nothing.
22. As a User, I want the key to be random rather than made from my PIN, so that six digits never
    limit its strength.
23. As a User, I want the key held by the phone hardware in a form that cannot be exported, so that
    copying the storage does not copy the key.
24. As a User, I want my PIN stored only as a hash, so that reading the Profile list does not give
    my PIN away.
25. As a User, I want the hash to carry its own cost settings, so that a stronger setting later
    still opens my Profile.
26. As a User sharing a phone, I want my Profile in its own file with its own key, so that the
    other User cannot read my Friends even when their Profile is open.
27. As a User, I do not want a picture of a face in the one file that is not encrypted, so that the
    readable file names me and shows nothing more.

### Nothing half made

28. As a User, I want the app to finish making the Profile or change nothing at all, so that I never
    hold a Profile that cannot open.
29. As a User whose phone died during First Run, I want the app to start First Run again, so that I
    can simply do it a second time.
30. As a User, I want a failure to say so on the screen where I typed, so that I am not sent to a
    Dial that has no data behind it.
31. As a User, I want the app to refuse to start rather than start First Run when the Profile list
    is damaged, so that a bad file never hides the Profiles I already have.
32. As a User, I want a Profile list the app does not understand to stop the app, so that a newer
    version's file is not overwritten by an older one.

### Making the second Profile

33. As a User adding a second Profile from settings, I want the same screen and the same rules, so
    that the second Profile cannot differ from the first.
34. As a User, I want failures against one Profile to leave the other untouched, so that one
    mistake costs one Profile.

## Implementation Decisions

### One call creates a Profile

A single object in a new `core/profiles/` module owns the whole sequence. It takes a display name
and a PIN, and it returns the created Profile. Nothing else writes `profiles.json`, and nothing
else mints a data key.

```
createProfile(displayName, pin) -> Profile
```

`core/profiles/` is a new module, beside `core/db/` and `core/crypto/`. The Profile list is read
before any Profile is unlocked, so it belongs to no feature. Add one line for it to the module map
in `docs/architecture.md`.

The same call serves the settings route that [ADR-0030](../adr/0030-first-run-creates-one-profile.md)
adds. The settings screen itself is out of scope.

### The app never wraps anything

[ADR-0006](../adr/0006-keystore-dek-with-pin-gate.md) and
[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) draw two keys. Their diagrams read as if
the app performs the wrapping. It does not.

`flutter_secure_storage` creates the non-exportable Keystore or Keychain key by itself, and it uses
that key to wrap what the app gives it. So the app writes **one** thing and holds **no** wrapping
code:

| Key | Who makes it | Where it lives |
|---|---|---|
| Wrapping key | `flutter_secure_storage`, on first write | Keystore or Keychain, non-exportable |
| Data key | This app, 32 random bytes | Handed to `flutter_secure_storage`, stored wrapped |

Write no wrapping, unwrapping or key-agreement code. A repository that grows its own is a defect.

### Files and names

Two kinds of file sit in the app's data directory.

```
profiles.json            the list, plaintext by design
friendo_<profileId>.db   one encrypted file per Profile
```

- `profileId` is 128 random bits, written as 32 lowercase hex characters. It is safe in a file
  name, it carries no meaning, and it never collides.
- The data key is stored under the name `dataKey.<profileId>`, so one Profile's key can be found
  and removed without touching another's.
- The directory arrives as an argument. `app/` resolves it once with `path_provider` at startup and
  passes it in. Nothing below `app/` calls `path_provider`.

### The order of the writes, and what commits

The order is not a detail. It decides what a crash leaves behind.

```
1. mint      profileId, a 16-byte salt, and a 32-byte data key   (Random.secure)
2. hash      the PIN with Argon2id, using the salt
3. store     the data key under dataKey.<profileId>
4. create    friendo_<profileId>.db, set the key, migrate to the current schema, close
5. commit    append the row to profiles.json
```

**Step 5 is the commit.** A row that names a Profile with no key and no file is a Profile that can
never open, and [ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) gives no way to delete
one. So the row is written last, when everything it names already exists.

A crash before step 5 leaves a stored key and a database file that no row names. Both are
invisible, and neither can be reached. v1 accepts them and sweeps nothing. Their number is bounded
by the count of failed First Runs, which is small, and a fresh `profileId` on the next try cannot
collide with one.

A failure at any step returns to the creation screen with a message. Nothing is retried
automatically.

### `profiles.json`

The shape is fixed by [ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md),
[ADR-0030](../adr/0030-first-run-creates-one-profile.md) and
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md). This spec adds the salt, which
verification cannot work without, and puts it inside `kdfParams`.

```json
{
  "version": 1,
  "profiles": [
    {
      "id": "9f2c...",
      "displayName": "Michal",
      "pinHash": "<base64 of the 32-byte digest>",
      "kdfParams": {
        "algorithm": "argon2id",
        "version": 19,
        "m": 19456,
        "t": 2,
        "p": 1,
        "salt": "<base64 of 16 random bytes>"
      },
      "failedAttempts": 0
    }
  ]
}
```

- Every Profile carries its own salt and its own `kdfParams`. A later, costlier setting applies to
  new Profiles, and old ones still open.
- `failedAttempts` starts at `0`. What reads it belongs to the unlock work, not here.
- No `avatarId`. The picker draws a colour and an initial. See below.

**Write it atomically.** Write a temporary file in the same directory, flush it, then rename over
the target. A rename inside one directory is atomic on both platforms, so a torn write cannot
appear.

**Reading it has three outcomes, and only one of them is First Run.**

| What is found | What happens |
|---|---|
| No file, or a file with an empty `profiles` list | First Run |
| A valid file with at least one Profile | Not First Run |
| A file that does not parse, or a `version` the app does not know | Stop, and say so |

The third row matters most. A damaged file must never read as "no Profile exists", because First Run
would then write a new list over the Profiles that are still on the phone. This is the loud failure
[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) asked for.

### Argon2id, settled

[ADR-0006](../adr/0006-keystore-dek-with-pin-gate.md) left the package unverified and allowed
PBKDF2-HMAC-SHA256 as a fallback. Measured on 2026-09-09, the fallback is not needed.

**Use `hashlib`, and Argon2id.** Declare it in the root `pubspec.yaml` and remove the comment that
says an Argon2id implementation is absent on purpose.

| Check | Result |
|---|---|
| RFC 9106 Argon2id test vector | reproduced exactly |
| Native code | none. Pure Dart, no FFI |
| Declared platforms | android, ios, linux, macos, web, windows |
| Licence | BSD 3-Clause |
| Cost at `m=19456 KiB, t=2, p=1` | 62 ms AOT on an x86-64 host, 64 ms under `flutter test` |

Pure Dart matters twice. It adds no second native library beside `libsqlite3mc.so`, and it runs the
same code in a host test as on the phone.

Take the cost settings from `Argon2Security.owasp2`, which is OWASP's `m=19456 KiB, t=2, p=1`. Write
the numbers into `kdfParams` rather than the preset's name, so the file stays readable when the
preset moves.

The digest is 32 bytes.

### The database file

First Run creates the file through the one object that
[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) puts in `core/db/`. It opens with
the data key, migrates to the current schema version, and closes.

This spec builds only the creation half of that object. Locking, closing on a timer, re-opening at
process start and publishing the open state belong to the unlock work.

The contract First Run holds is narrow: **after step 4 the file exists, it is encrypted with the
data key, and it stands at the current schema version.** Which tables that version holds is the
Friend aggregate's business (`friendO-xdb`). A schema with no tables is a valid starting point.

Confirm the pragmas while the connection is open, which also discharges `friendO-mts`:

| Pragma | Required value | Why |
|---|---|---|
| `cipher` | `chacha20` | The file is encrypted |
| `temp_store` | never `1` (FILE) | A spilled sort would write private text in the clear |
| `plaintext_header_size` | `0` | No part of the file is readable |
| `mc_legacy_wal` | `0` | The write-ahead log is encrypted too |

### Apple

Two things follow from [ADR-0020](../adr/0020-no-os-level-backup.md), and both are set at the
moment the thing is created.

- Give the stored data key the accessibility `first_unlock_this_device`. The name ends in
  `ThisDeviceOnly`, so the item never enters a backup and never travels to another phone.
- Set `NSURLIsExcludedFromBackupKey` on the database file and on `profiles.json`.

The wider Apple work is tracked by `friendO-1xn`.

### The screens

Three screens, and the key work sits between the first and the second.

| Screen | What it does | What it holds |
|---|---|---|
| Create | Takes the name, then the PIN twice | The typed PIN, until the call returns |
| Cost | States what friendO does not keep | Nothing |
| Dial | The app | Nothing of First Run's |

**The key work runs when the second PIN entry matches, before the cost screen appears.** The PIN
then leaves memory at the earliest moment it can, and the cost screen has no way to fail. A User who
closes the app on the cost screen owns a finished Profile and sees the Dial next time.

**The cost screen is one way.** The back gesture does not return to the creation screen. The
Profile already exists, and going back would offer to make a second one.

PIN rules:

- Exactly six digits, digits only.
- The sixth press submits. There is no confirm button.
- The digits are hidden as they are typed, and one press deletes the last one.
- A mismatch clears both entries, says they differ, and returns to the first.

Name rules: at least one character after trimming. Trim before storing.

### Colour and initial

The picker draws a colour and an initial rather than an Avatar. Derive both on read and store
neither.

- The initial is the first character of the display name.
- The colour comes from `id`, not from the name. A rename then leaves the colour alone, which is
  what a User expects.

The picker itself is out of scope. This decision sits here so that no colour field is added to
`profiles.json` later by habit.

## Testing Decisions

### What a good test looks like here

A good test drives `createProfile` and then reads what is on disk and in the store. It asserts on
the artifacts, not on the steps that made them. It names no private method, and it counts no call.
The internals of the sequence must be free to change while the tests stay still.

[ADR-0013](../adr/0013-testing-strategy.md) already forbids asserting on mocks. This spec needs no
mock at all.

### One new seam

`createProfile` is the seam. Everything below it is private.

Two collaborators arrive as arguments rather than as fakes:

- **The directory.** Tests pass a temporary directory. `path_provider` never enters a test.
- **The cost settings.** Tests pass a cheap Argon2id setting, which takes under a millisecond
  instead of 62. This is not a mock. `kdfParams` is stored per Profile by design, so a cheap
  setting is a legitimate value and the code under test is the shipped code.

One collaborator uses the seam its own package provides:

- **The store.** `FlutterSecureStorage.setMockInitialValues` installs the package's own in-memory
  platform. Verified present in `flutter_secure_storage 11.0.0`. Write no interface of your own
  over it.

### The database engine is real, and it is not mocked

Verified on this repository on 2026-09-09: `flutter test` on a Linux host loads the same
`sqlite3mc` build the phone gets. A probe reported `cipher=chacha20`, `temp_store=0`, a binary file
header, no plaintext leak, and SQLite 3.53.4.

So these tests write a **real encrypted file to a real temporary directory**. Do not substitute
drift's in-memory driver here. An in-memory database has no file, and the file is half of what this
spec produces.

### What to test

**Against `createProfile`:**

1. `profiles.json` appears, parses, holds `version` 1 and exactly one Profile.
2. The row holds the trimmed name and `failedAttempts` of `0`.
3. The stored `pinHash` accepts the PIN that made it and rejects a different one.
4. `kdfParams` holds the algorithm, the cost numbers and a salt.
5. Two Profiles made in one directory hold two ids, two salts and two different `pinHash` values,
   even when both PINs are the same string.
6. The database file exists and its first bytes are not `SQLite format 3`.
7. The file opens with the key that was stored for it, and fails to open with any other key.
8. The store holds 32 bytes under `dataKey.<profileId>`, and 32 bytes under the second Profile's
   name too.
9. Two calls mint two different data keys.
10. The four pragmas hold their safe values on the connection the app opens. This is `friendO-mts`.

**Against failure:**

11. A failure before the commit leaves no row in `profiles.json`. Force it by making the directory
    unwritable at the right moment, or by passing a database name that cannot be created.
12. A `profiles.json` that does not parse makes the read fail loudly. It must not report that no
    Profile exists.
13. A `profiles.json` whose `version` is unknown does the same.
14. An empty `profiles` list reports First Run.
15. An absent file reports First Run.

**Against the bloc:**

16. Six digits submit. Five do not.
17. A second entry that differs returns to the first entry and reports the mismatch.
18. A name of spaces alone is refused.
19. A failure from `createProfile` leaves the bloc on the creation screen with a message.

### Prior art

- `test/navigation_cubit_test.dart` is the existing `bloc_test` in this repository. Follow its
  shape for stories 16 to 19.
- `packages/friendo_domain/test/` holds the plain unit tests that
  [ADR-0013](../adr/0013-testing-strategy.md) describes. `createProfile` is not pure, so its tests
  live under `test/` in the root package, where Flutter and the real engine are available.
- `tool/test.sh` runs the root package already. These tests need no new script and no new
  dependency beyond `hashlib`.

## Out of Scope

**The whole unlock path.** Process start, reading the Profile list to decide which screen to show,
the PIN screen for an existing Profile, unwrapping the data key, opening the file, and handing
connections to repositories. None of it is here.

**The lock lifecycle.** [ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) describes
an object that publishes `locked`, `opening` and `open`, closes on a timer and re-opens. This spec
builds only the part that creates a file. The rest arrives with the unlock work.

**The retry delay.** [ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) sets a delay after
five wrong attempts. First Run writes `failedAttempts: 0` and reads it never.

**The Profile picker**, which appears only when two Profiles exist.

**The settings entry to a second Profile.** The same call serves it. The screen that reaches the
call is not specified here.

**Biometric unlock**, which [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) puts in settings.

**Screen privacy.** `FLAG_SECURE` and the iOS cover view are app-wide and belong to
[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md). The PIN keypad is a screen worth hiding, so
this should not ship long after First Run does.

**The Dial's contents.** First Run ends by showing the Dial. What the Dial draws when it holds no
Friend is the Dial's work.

**The database schema.** The Friend aggregate defines it (`friendO-xdb`). First Run only requires
that the file stands at the current version.

**The Backup**, which v1 does not have. `friendO-j74` holds it.

**Repositories.** Nothing reads or writes a Friend during First Run.

## Further Notes

### The PHC string is a better shape, and it needs a record

`hashlib` returns a digest that encodes itself in the standard PHC form:

```
$argon2id$v=19$m=19456,t=2,p=1$<salt>$<hash>
```

One field carries the algorithm, the version, every cost number and the salt. It is the shape every
other tool reads, and it cannot drift out of step with the digest beside it.

[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) names two fields, `pinHash` and
`kdfParams`, and [ADR-0030](../adr/0030-first-run-creates-one-profile.md) and
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) repeat them. **This spec follows the
records.** Replacing both fields with one PHC string would contradict three accepted records, and
[ADR-0019](../adr/0019-correcting-and-partly-superseding-a-record.md) sets the way to do that. It is
worth reopening, and it is cheapest to reopen before the first file is written.

### The cost of Argon2id at unlock

62 ms on a host is likely 200 ms to 400 ms on a mid-range phone. At First Run that is invisible,
because the User has just pressed the sixth digit and expects a moment. At every unlock it is a
blocked frame. Whether the hash runs in its own isolate is the unlock work's decision, not this
one's. The measurement is here so that the decision starts from a number.

### What this spec does not decide

- **Weak PINs.** No record refuses `000000` or `123456`.
  [ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) answers the guessable PIN with a
  delay instead. Refusing one would be a new product rule, so it is not invented here.
- **Sweeping orphans.** A key and a file left by a crashed First Run stay. A sweep needs a rule for
  telling an orphan from a Profile whose row has not been read yet, and v1 does not need one.
- **A cap on the display name.** The field can hold what a User types. A cap is a UI judgement and
  no record sets one.

### Records this spec builds

[ADR-0006](../adr/0006-keystore-dek-with-pin-gate.md),
[ADR-0007](../adr/0007-database-per-profile.md),
[ADR-0020](../adr/0020-no-os-level-backup.md),
[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md),
[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) in part,
[ADR-0030](../adr/0030-first-run-creates-one-profile.md),
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) in part.

It closes `friendO-ih7` and `friendO-mts`.
