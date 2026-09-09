# Spec: Boot and the data layer

**Scope:** process start, the PIN check, unwrapping the data key, opening the encrypted file,
serving that connection to repositories, and the lock lifecycle that closes it again.

**Reads:** [ADR-0005](../adr/0005-drift-and-encrypted-sqlite.md),
[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md),
[ADR-0022](../adr/0022-one-repository-per-aggregate.md),
[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md). It also builds on
[ADR-0007](../adr/0007-database-per-profile.md),
[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md),
[ADR-0030](../adr/0030-first-run-creates-one-profile.md) and
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md).

**Pairs with:** [docs/spec/first-run.md](first-run.md). That spec makes the Profile, its keys and
its file exist. This spec is everything that happens on every start after that one. Where the two
touch, First Run creates and this one consumes.

## Problem Statement

A User has a Profile. They press the friendO icon.

Nothing in the app answers what happens next. The Profile is a name in a plaintext file, a wrapped
key in the phone's hardware and an encrypted file that no tool can read. None of it is open. The
Dial cannot draw a single Friend until somebody turns that into a live connection.

The User does not want to think about any of that. They want the app to open, ask for six digits,
and show the Dial.

Three things then go wrong if nobody designs the rest of it.

**The app has to lock itself again.** [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) locks
after 60 seconds in the background and closes the database, so the key leaves the open connection.
That happens on a timer. It happens while a screen is built and while a form is half filled in.

**Every screen loses its data at that moment.** A stream that drift was feeding stops. A bloc
holding a Friend is holding private text behind a PIN screen. A write that arrives one millisecond
late has nowhere to go.

**A wrong PIN has to cost something.** [ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md)
rests the keypad after five wrong tries, and the rest must survive the User closing the app and
moving the phone's clock.

## Solution

One path, walked in the same order every time.

The process starts and reads the Profile list. That list decides the first screen: First Run, one
PIN screen, or the Profile picker. Nothing touches a database yet.

The User types six digits. The app checks them against the stored Argon2id hash, asks the phone to
unwrap that Profile's data key, opens the encrypted file with it, and runs any migration the file
needs. The Dial then draws.

While the Profile is open, one object holds the connection and publishes that it is open.
Repositories ask that object for the connection every time and never keep one.

When the app goes to the background and stays there, the same object closes the file. Every stream
goes quiet. Every bloc clears what it holds. The PIN screen comes back, and the walk repeats from
the six digits.

## User Stories

### Starting the app

1. As a User, I want friendO to open on the PIN screen for my Profile, so that I reach my Friends
   in one action.
2. As a User with no Profile yet, I want the app to start First Run, so that I am not asked for a
   PIN that does not exist.
3. As a User who shares the phone, I want to pick my Profile before I type, so that my six digits
   are checked against the right Profile.
4. As the only User of the phone, I want no picker at all, so that I never choose from a list of
   one.
5. As a User, I want the app to reach the PIN screen without opening any database, so that my
   Friends stay encrypted until I have proved who I am.
6. As a User, I want the app to stop and say so when the Profile list is damaged, so that it never
   quietly decides I have no Profiles and writes over the ones I have.
7. As a User, I want the app to feel instant before the PIN screen, so that starting friendO is
   never a wait.

### Opening the Profile

8. As a User, I want the sixth digit to open the app, so that unlocking needs no confirm button.
9. As a User, I want a visible sign that the app is working during the moment after the sixth
   digit, so that a slow phone does not read as a frozen one.
10. As a User, I want the app to stay responsive while it hashes my PIN, so that the keypad does not
    freeze on a mid-range phone.
11. As a User, I want my Friends on screen as soon as the file opens, so that the Dial is never
    drawn empty and then filled.
12. As a User whose file needs a schema migration, I want it applied when the Profile opens, so
    that an app update never asks me to do anything.
13. As a User, I want a failure to open the file to say that it failed, so that a broken install is
    never reported as a wrong PIN.

### Getting the PIN wrong

14. As a User, I want the first four mistakes to cost nothing, so that a mistyped digit is not
    punished.
15. As a User, I want the keypad to rest after five wrong tries, so that somebody guessing my PIN
    runs out of patience.
16. As a User, I want each further wrong try to rest longer, so that guessing gets worse and worse.
17. As a User, I want the rest to survive me closing the app, so that a guesser cannot skip it by
    force-quitting.
18. As a User, I want the rest to survive the phone's clock changing, so that a guesser cannot skip
    it by moving the date.
19. As a User, I want a correct PIN to clear the count, so that yesterday's mistakes do not follow
    me.
20. As a User, I want wrong tries against one Profile never to delay the other, so that my partner's
    bad memory is not my problem.
21. As a User, I want the app never to wipe a Profile after wrong tries, so that a child at the
    keypad cannot destroy my Friends.
22. As a User, I want to see how long the rest has left, so that I know the app is not broken.

### Being away from the app

23. As a User, I want friendO to lock itself after a short time in the background, so that a phone
    left on a table shows nothing.
24. As a User, I want the encrypted file closed when it locks, so that the key is not sitting in an
    open connection.
25. As a User, I want a quick app switch not to lock me out, so that answering a message does not
    cost me six digits.
26. As a User, I want the lock to happen even if the phone was asleep for a week, so that a long
    absence is not treated as a short one.
27. As a User, I want the app to lock rather than trust a clock that moved backwards, so that the
    safe answer is the default.
28. As a User, I want the task switcher to show nothing readable, so that a glance at my phone
    shows no Friend and no Note.

### What the screens do while locked

29. As a User, I want no Friend of mine to stay on screen behind the PIN screen, so that nothing
    private is one gesture away.
30. As a User, I want the app to come back to a working screen after I unlock, so that I do not
    have to restart it.
31. As a User, I want the data I see after unlocking to be current, so that I never read a stale
    screen from before the lock.
32. As a User, I want a screen that is waiting for data to look like it is waiting, so that an empty
    Friends list and a locked one are never drawn the same way.
33. As a User, I want a save that arrives while the app is locking to fail loudly, so that my
    writing is never silently thrown away.

### Reading and writing while open

34. As a developer, I want one place to ask for the connection, so that no part of the app can hold
    a dead handle across a lock.
35. As a developer, I want a repository to survive a lock without a `try` around every query, so
    that the lock lifecycle stays out of code that has nothing to do with it.
36. As a developer, I want a watch stream to go quiet on lock and re-run on unlock, so that a bloc
    re-subscribes to nothing and gets fresh data when the Profile comes back.
37. As a developer, I want a write while locked to throw one named failure, so that every write
    path handles the same thing.
38. As a developer, I want the Friend aggregate to reach the connection through the same door as
    everything else, so that there is one lifecycle and not two.

### Two Profiles

39. As a User, I want switching Profile to walk the same path as unlocking, so that the app has one
    way in and not two.
40. As a User, I want the other Profile's file closed before mine opens, so that only one Profile is
    ever readable at a time.
41. As a User, I want the other Profile's key out of the app when I switch, so that the separation
    ADR-0007 promises is real.

### Leaving the app

42. As a User, I want to lock friendO on purpose, so that I can hand the phone over without waiting
    for a timer.
43. As a User, I want the app to lock when I close it, so that reopening always asks for the PIN.

## Implementation Decisions

### Four owners, and nothing else touches these things

The work splits along lines the records already drew. Nothing here invents a new layer.

| Module | Owns | New here |
|---|---|---|
| `core/profiles/` | `profiles.json`, the PIN hash, the wrapped data key by name | Reading, verifying, unlocking, the attempt count |
| `core/db/` | The open connection, the schema, migrations | Everything except the create-and-close half |
| `core/security/` | *When* to lock: the timer, the lifecycle, screen privacy | All of it |
| `features/auth/` | The picker, the keypad, the rest countdown | All of it |

[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) sets the split between the last
three: `core/security/` decides when to lock, and `core/db/` decides what closing means. The timer
is a product rule. The connection is a resource. They stay apart.

`core/profiles/` already exists after First Run and already holds `createProfile`. It grows the
read and the unlock, because it is the module that knows the hash, the salt and the name the data
key is stored under. Nothing else may read `dataKey.<profileId>`.

### The boot read has four outcomes

The process starts, resolves the data directory once in `app/`, and reads the Profile list. It
opens no database and asks the phone for no key.

| What the Profile list holds | First screen |
|---|---|
| No file, or an empty list | First Run |
| Exactly one Profile | The PIN screen for that Profile |
| Two or more Profiles | The Profile picker |
| A file that does not parse, or an unknown `version` | A stop screen that says the list is damaged |

The first three rows come from [ADR-0030](../adr/0030-first-run-creates-one-profile.md). The fourth
is the loud failure [ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) asked for, and
[docs/spec/first-run.md](first-run.md) already requires the same read to produce it.

**The stop screen offers no way forward.** It does not offer to start First Run, because that would
write a new list over Profiles that are still on the phone. It says what is wrong and names the file.
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) already accepts that the only remedy
for an unopenable Profile is clearing the app's data through the operating system, and that remedy
belongs to the User and not to a button.

### One new seam: the Profile session

One object in `core/profiles/` walks the whole path from six digits to an open connection. It is
the only new seam this spec adds.

```
unlock(profileId, pin) -> Unlocked | WrongPin(attempts) | Resting(remaining) | Failed(reason)
lock()                                  closes the connection and drops the key
```

It coordinates and owns nothing. The verification reads the hash that `core/profiles/` holds. The
unwrap goes to `flutter_secure_storage`. The open goes to `core/db/`.

**The state stream stays where ADR-0025 put it.** `core/db/` publishes `locked | opening | open`,
and that is the one thing repositories and blocs watch. This object does not publish a second
state, because two streams describing one fact drift apart.

**Verifying the PIN and opening the Profile are separate steps inside it.** The step that unwraps
and opens takes a `profileId` and no PIN. [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md)
adds biometric unlock later as a second gate on the same key. A later biometric route confirms with
the operating system and then reaches the same open step. If the unwrap hid inside the PIN check,
that route would have to copy the path, and two copies of an unlock path is how one of them gets a
fix and the other does not.

### The unlock sequence

```
1. read     the Profile row: pinHash, kdfParams (with the salt), failedAttempts
2. rest     if failedAttempts is 5 or more, refuse and report the remaining time
3. hash     the PIN with the row's own kdfParams, in a separate isolate
4. compare  the digest against pinHash, in constant time
5. count    on a mismatch, write failedAttempts + 1 and stop
6. unwrap   read dataKey.<profileId> from the store
7. open     the encrypted file with that key, and migrate it to the current schema
8. clear    write failedAttempts back to 0
```

**Step 5 is written before the User is told.** A count written after the message lets a guesser kill
the app between the two and try again for free.

**Step 8 comes after the open, not after the compare.** A correct PIN that cannot open the file has
not proved the app works, and clearing the count on it would be a small lie in the one place the
User cannot check.

**Step 3 runs in its own isolate.** [docs/spec/first-run.md](first-run.md) measured 62 ms on a
host and left this decision here. On a mid-range phone the same work is likely 200 ms to 400 ms,
which is a dropped frame on every unlock rather than an invisible pause once. `hashlib` is pure
Dart, so it moves to an isolate with no native library and no platform channel. Send the PIN, the
salt and the cost numbers in; take the digest out.

The PIN is copied into the isolate, so it exists twice for that moment.
[ADR-0006](../adr/0006-keystore-dek-with-pin-gate.md) already states that Dart cannot wipe memory
reliably, so this widens no threat. **Never send the data key through an isolate.** It has no
reason to leave the main one.

**Step 4 compares in constant time.** The comparison is local and the attacker holds the phone, so
this is cheap insurance rather than a defence against a measured attack. Write it once, correctly.

### The failures are told apart

A single "wrong PIN" message for every failure is the easy mistake here, and it makes a broken
install unfixable.

| What happened | What the User is told | What the app does |
|---|---|---|
| The digest does not match | The PIN is wrong | Counts the attempt |
| `failedAttempts` is 5 or more | The keypad is resting, with the time left | Refuses before hashing |
| `dataKey.<profileId>` is missing | This Profile cannot be opened on this phone | Counts nothing |
| The file will not open with the stored key | This Profile cannot be opened | Counts nothing |
| The migration fails | The app could not update the stored data | Counts nothing |

The last three are not the User's mistake, so none of them touches `failedAttempts`. A missing key
after a successful hash means the store lost the item or the app data was partly cleared. It is
rare, it is final, and it must not read as "try again".

### The rest, and which clock measures it

[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) fixes the table and the storage:

| Wrong attempts | Rest |
|---|---|
| 1 to 4 | none |
| 5 | 30 seconds |
| 6 and up | 1, 2, 4, 8 minutes, and then 15 for every further try |

The count is stored. The deadline is not. The rest is measured **from the moment the PIN screen
appears**, by a timer inside the app.

Two timers exist in this spec and they use different clocks on purpose.

| Timer | Clock | Why |
|---|---|---|
| The rest after wrong PINs | An in-app timer, from when the screen appears | The phone's clock belongs to whoever holds the phone |
| The auto-lock | Wall clock, through `core/time/` | The app is not running to hold a timer while suspended |

The rest applies **on arrival at the keypad**, computed from the stored count, and not only after a
failure in this run of the app. That is what makes closing the app cost the guesser the wait
instead of skipping it.

### The auto-lock

`core/security/` watches the app lifecycle and decides one thing: lock, or do not lock.

- Record the instant when the app leaves the foreground.
- On return, lock when the gap is longer than the timeout, which defaults to 60 seconds per
  [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md).
- **Lock when the gap is negative.** A clock moved backwards is not a short absence. The safe answer
  costs six digits and the unsafe one costs the Profile.
- Lock when the process is being torn down, so that a relaunch always asks.

Hold this as a decision over `(wentAway, cameBack, timeout)` rather than as a live `Timer`. A
`Timer` does not run while the process is suspended, so a phone asleep for a week would come back
unlocked, which is story 26. A decision over two instants has no such gap and needs no widget tree
to test.

Locking calls the same `lock()` the settings entry calls. "Lock friendO" in settings and the timer
are one path with two triggers.

### Screen privacy

[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) holds two decisions, and the second one has
no other home. It is set once, app-wide, at the same wiring point as the lock, so it sits here
rather than falling between two specs.

- **Android:** set `FLAG_SECURE` on the window. It blanks the task switcher preview and blocks
  screenshots.
- **iOS:** draw a cover over the app when the lifecycle state becomes `inactive`, and remove it on
  `resumed`. Use `inactive`, not `paused`: the system takes its snapshot before `paused` arrives.

The iOS half cannot be checked on this machine. `friendO-6gv` already tracks that no iOS build has
ever been verified, and this rides with it.

### The connection owner, in full

[docs/spec/first-run.md](first-run.md) built one half of the object
[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) describes: create a file, migrate
it, close it. This spec builds the rest.

```
open(profileId, dataKey)   opens the file, runs migrations, publishes open
close()                    closes the handle, drops the key, publishes locked
state                      Stream<DatabaseState>:  locked | opening | open
database                   the drift database while open; throws while locked
```

- `opening` exists so that the keypad can show that work is happening. It covers the hash, the
  unwrap, the open and the migration, which together are the only visible wait in the app.
- `state` is a broadcast stream and it replays its current value to a new listener. A repository
  that subscribes after the Profile opened must not wait for the next change to learn that it is
  open.
- `close()` is safe to call while already locked, because the auto-lock and a deliberate lock can
  both arrive.
- `open()` on an already-open Profile is a defect and throws. Switching Profile closes first.
- The four sqlite3mc pragmas that First Run asserts hold on every open, not only the first.

**The data key is dropped on close.** The field is cleared. [ADR-0006](../adr/0006-keystore-dek-with-pin-gate.md)
already states that Dart cannot wipe memory, so this removes the reference and nothing more. It is
still worth doing, because it is what makes a leak a bug rather than the design.

### What a repository may and may not do

[ADR-0022](../adr/0022-one-repository-per-aggregate.md) puts repositories in `core/`, beside the
tables they own. [ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) says how they
reach the connection. This spec turns those two into a contract that the first repository can be
built against.

**A repository holds no connection.** It holds the connection owner and asks it every call. A
cached `GeneratedDatabase` would be a dead handle after the first lock, and the bug would appear one
screen away from its cause.

**A read that returns once throws `DatabaseLockedError` while locked.** There is nothing else it can
return. A caller that reads at the moment of a lock is already on a screen that is about to be
replaced.

**A watch goes quiet while locked, and never fails.** Build it by switching on `state`:

```
state → locked   emit nothing, and hold the subscription
      → opening  emit nothing
      → open     re-run the query and emit, then follow drift's own stream
```

The stream stays alive across a lock. A bloc therefore keeps one subscription for the life of the
screen and receives fresh data when the Profile comes back. This is story 36, and it is the
behaviour ADR-0025 chose over letting every bloc catch.

**A write while locked throws `DatabaseLockedError`.** A read that is a stream can wait. A write
cannot be silently dropped. This is story 33.

**A bloc clears on lock, and does not throw.** A bloc that holds a Friend listens to `state` and
clears when it becomes `locked`, so nothing private stays in memory behind the PIN screen and
nothing stale is drawn on return.

**"Locked" and "empty" must look different to a bloc.** ADR-0025 names this as the thing that goes
wrong: a quiet stream read as an empty result draws an empty Friends list behind the lock screen.
A bloc's state carries the two apart, and story 32 is the test.

`DatabaseLockedError` belongs to `core/db/`, beside the object that throws it.

### Switching Profile reuses the path

Switching is `lock()` and then `unlock(otherId, pin)`. It is not a second mechanism.
[ADR-0007](../adr/0007-database-per-profile.md) gets what it promises: the first file is closed and
its key is gone before the second file opens, so one Profile is readable at a time.

The screen that offers the switch is out of scope. The path is here so that the screen has one call
to make.

### Wiring

`app/` resolves the data directory once with `path_provider` and passes it down. Nothing below
`app/` calls `path_provider`, which is the rule [docs/spec/first-run.md](first-run.md) set and the
reason its tests need no plugin.

`app/` builds the connection owner, the Profile session and the auto-lock, and provides them above
the router. They outlive every screen, because the lock arrives while a screen is being built.

Routing stays as it is. `friendO-njf` holds the open question of whether this app moves to
`go_router`, and a boot path that picks between four first screens is the strongest argument that
issue will get. This spec does not settle it, and it does not depend on the answer: the four
outcomes are a value, and whatever draws them reads that value.

## Testing Decisions

### What a good test looks like here

A good test drives the Profile session and then asks the connection owner what state it is in, or
runs a real query. It asserts on what a caller can see: the state, the returned outcome, the rows,
the failure that was thrown. It names no private method and counts no call.

[ADR-0013](../adr/0013-testing-strategy.md) forbids asserting on mocks. This spec needs none.

### One new seam, and one existing observation point

`unlock` and `lock` are the seam. Everything below them is private.

`state` is not a second seam. It is the stream ADR-0025 requires the app to have, so a test that
watches it watches the shipped contract.

Three collaborators arrive as arguments, exactly as they do in
[docs/spec/first-run.md](first-run.md):

- **The directory.** Tests pass a temporary directory.
- **The cost settings.** A test creates its Profile with a cheap Argon2id setting and unlocks it
  with the same one, because `kdfParams` is stored per Profile by design. The code under test is
  the shipped code.
- **The store.** `FlutterSecureStorage.setMockInitialValues` gives the package's own in-memory
  platform.

The auto-lock takes its two instants and its timeout as arguments, so its tests are arithmetic and
need no widget tree and no clock to stub.

### The engine is real, and the file is real

Verified on this repository on 2026-09-09: `flutter test` on a Linux host loads the same `sqlite3mc`
build the phone gets.

So these tests **create a Profile through `createProfile` and then unlock it**, against a real
encrypted file in a real temporary directory. Do not substitute drift's in-memory driver. Half of
what this spec does is prove that a file closes and opens again, and an in-memory database has no
file to close.

Using `createProfile` as the fixture is deliberate. It is the only supported way a Profile comes
into existence, so a test that hand-writes `profiles.json` would be testing a file shape the app
never produces.

### The lock contract needs a table, and does not need the schema

The Friend aggregate owns the tables (`friendO-xdb`), and it may not have landed. The lock contract
still has to be proved.

Test it with `customSelect(...).watch()` over a table the test creates inside the open connection.
That exercises a real drift stream over a real encrypted file, and it invents no table in `lib/`
that would have to be deleted when the real schema arrives.

### What to test

**The boot read:**

1. An absent Profile list reports First Run.
2. An empty `profiles` list reports First Run.
3. One Profile reports the PIN screen, and names that Profile.
4. Two Profiles report the picker.
5. A file that does not parse reports damage, and does not report First Run.
6. An unknown `version` reports damage.
7. The read opens no database file and reads no key from the store.

**Unlocking:**

8. The right PIN opens the Profile, and `state` becomes `open`.
9. `state` passes through `opening` before `open`.
10. A real query runs against the opened file.
11. The wrong PIN does not open it, and `state` stays `locked`.
12. The wrong PIN increments `failedAttempts` in the Profile list.
13. The right PIN clears `failedAttempts` back to `0`.
14. A missing `dataKey.<profileId>` reports that the Profile cannot be opened, and is not reported
    as a wrong PIN.
15. A missing `dataKey.<profileId>` does not increment `failedAttempts`.
16. A data key that is not the Profile's own fails to open the file, and reports a failure rather
    than a wrong PIN.
17. Unlocking Profile A and then Profile B reads only B's Friends, with A's file closed.

**The rest:**

18. Four wrong PINs impose no rest.
19. The fifth wrong PIN sets the count to 5, and the next arrival at the keypad is refused with a
    30-second rest.
20. A refusal while resting does not increment the count further, and does not hash the PIN.
21. The rest doubles with each further wrong try and stops at 15 minutes.
22. A correct PIN after four wrong ones opens the Profile and clears the count.
23. Wrong tries against one Profile leave the other Profile's count at `0`.
24. A new Profile session, made after the count reached 5, still refuses. The count survives a
    restart.

**The lock lifecycle:**

25. `lock()` closes the connection and `state` becomes `locked`.
26. `database` throws while locked.
27. A write while locked throws `DatabaseLockedError`.
28. A watch stream opened while the Profile is open emits nothing on lock, stays alive, and emits
    fresh rows on the next unlock.
29. A row written between the lock and the unlock appears in the stream after the unlock.
30. `lock()` on an already-locked Profile is safe.
31. `open()` on an already-open Profile throws.
32. The four sqlite3mc pragmas hold on a re-opened file, not only on a newly created one.

**The auto-lock decision:**

33. A gap shorter than the timeout does not lock.
34. A gap longer than the timeout locks.
35. A gap equal to the timeout does not lock. The boundary is decided once, here, rather than
    guessed at each call site.
36. A negative gap locks.

**Blocs:**

37. A bloc holding data clears it when `state` becomes `locked`.
38. A bloc distinguishes "locked" from "no rows", and does not draw an empty list while locked.
39. The keypad submits on the sixth digit and not on the fifth.
40. The keypad reports the remaining rest while resting, and refuses input.

### Prior art

- `test/navigation_cubit_test.dart` is the existing `bloc_test` in this repository. Follow its
  shape for items 37 to 40.
- The First Run tests are the direct neighbours. They already create a Profile against a real file
  in a temporary directory, and these tests start from the same fixture.
- `packages/friendo_domain/test/` holds the plain unit tests
  [ADR-0013](../adr/0013-testing-strategy.md) describes. Items 33 to 36 are that kind of test, even
  though the code lives in `lib/`, because the auto-lock decision is arithmetic.
- `tool/test.sh` runs the root package already. No new script and no new dependency are needed.

## Out of Scope

**First Run.** [docs/spec/first-run.md](first-run.md) holds it. This spec consumes what that one
creates and adds nothing to the creation path.

**The Friend aggregate and the schema.** `friendO-xdb` owns the tables and the rows. This spec owns
the connection those tables live in, the migration machinery that moves them forward, and the
contract a repository is written against. It declares no table of its own.

**`FriendRepository` itself.** Its methods, its whole loads and whole saves, and the "at least one
Meeting" rule are [ADR-0022](../adr/0022-one-repository-per-aggregate.md)'s and
[ADR-0016](../adr/0016-derive-lastmet-from-meetings.md)'s. This spec says how it reaches a
connection and how it behaves across a lock, and stops there.

**Biometric unlock.** [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) keeps it and puts the
switch in settings. This spec only makes sure the open step takes no PIN, so that the second gate
can be added without copying the path.

**Every settings screen.** The lock timeout setting, the biometric switch, "Add a Profile" and
"Lock friendO" all live in settings per
[ADR-0030](../adr/0030-first-run-creates-one-profile.md). The timeout arrives here as a value with a
60-second default. The screen that changes it is not specified here.

**The Profile picker's drawing.** The colour and the initial are decided in
[docs/spec/first-run.md](first-run.md). This spec decides only that the picker is the first screen
when two Profiles exist.

**The Dial, the Friends list and every other screen.** What they draw is theirs. What they do on
lock is here, as a contract.

**Reminder rescheduling.** [ADR-0012](../adr/0012-opt-in-local-notifications.md) reschedules on
changes to `lastMet` or `cadence`, and `core/reminders/` owns it. Whether a reschedule can run
while the Profile is locked is a real question and it belongs with that work, not here.

**The Backup.** `friendO-j74` holds it. A Backup needs an open Profile, so it sits on top of this
spec rather than inside it.

**Sweeping orphans.** A key and a file left by a crashed First Run stay invisible.
[docs/spec/first-run.md](first-run.md) accepted them and this spec does not go looking.

**Deleting a Profile.** [ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) gives the app
no path to delete one, opened or not.

## Further Notes

### This spec settles one thing First Run left open

[docs/spec/first-run.md](first-run.md) measured Argon2id at 62 ms on a host and wrote:

> Whether the hash runs in its own isolate is the unlock work's decision, not this one's.

It is decided above: it runs in an isolate. First Run may keep it on the main isolate, because it
happens once and the User has just pressed a digit, but there is no reason for two paths. Use the
same call in both.

### The PHC string is still open

[docs/spec/first-run.md](first-run.md) raises `$argon2id$v=19$m=19456,t=2,p=1$<salt>$<hash>` as a
better shape than the two fields
[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) names, and leaves it as a candidate for
[ADR-0019](../adr/0019-correcting-and-partly-superseding-a-record.md) rather than deciding it.

This spec is the second reader of those fields and it changes nothing. It is worth saying that the
window is closing: once a phone holds a `profiles.json` that this code wrote, changing the shape
costs a migration of the one file that has no schema.

### What this spec does not decide

- **Whether the lock timeout is configurable in v1.** The default is 60 seconds and the value is an
  argument. ADR-0011 says the timer needs a setting; the screen for it is settings' work.
- **What the empty-list screen looks like while locked.** Story 32 requires that "locked" and
  "empty" are different states. Which drawing each gets is the Dial's and the Friends list's work.
- **Whether `go_router` replaces the cubit.** `friendO-njf` holds it. See above.
- **How a schema migration failure is recovered.** It is reported and the Profile does not open.
  v1 has no Backup to restore from, so there is nothing better to offer yet.

### Records this spec builds

[ADR-0005](../adr/0005-drift-and-encrypted-sqlite.md),
[ADR-0007](../adr/0007-database-per-profile.md),
[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md),
[ADR-0022](../adr/0022-one-repository-per-aggregate.md) in part,
[ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) in part,
[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md) in full,
[ADR-0030](../adr/0030-first-run-creates-one-profile.md) in part,
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) in full.
