# ADR-0025: One owner for the database connection

**Status:** Accepted
**Date:** 2026-09-08

## Context

[ADR-0011](0011-app-lock-and-screen-privacy.md) makes a correct security decision in one sentence:

> Close the database handle when locking, so the key leaves the open connection.

That sentence has a large structural consequence. Every drift stream in the app dies at that moment.
Every bloc watching one has to survive the gap and re-subscribe when the Profile is unlocked again.
It happens on a timer, so it happens while screens are built and while a form is half filled in.

[ADR-0007](0007-database-per-profile.md) adds a second reason for the same machinery. Switching
Profile closes one file and opens another. The connection is not a fixed thing that exists for the
life of the process.

No document assigns this lifecycle to anyone. It touches every feature, and it is the kind of thing
that gets discovered by the fourth feature and retrofitted badly into the first three.

## Decision

One object in `core/db/` owns the connection. Nothing else opens or closes one.

```
core/db/DatabaseSession
  open(profileId, dataKey)   opens the SQLCipher file, runs migrations
  close()                    closes the handle
  state                      Stream<DatabaseState>:  locked | opening | open
  database                   the drift database while open; throws while locked
```

**Repositories ask for the connection. They never hold one.** A repository that cached a
`GeneratedDatabase` would keep a dead handle across a lock, and the bug would appear one screen
away from its cause.

**A watch stream goes quiet while locked, and does not fail.** A repository builds a watch by
switching on `state`: it emits nothing while locked, and re-runs its query on `open`. A bloc
therefore re-subscribes to nothing and gets fresh data when the Profile comes back.

**A write while locked throws `DatabaseLockedError`.** A read that is a stream can wait. A write
cannot be silently dropped, so it fails loudly and the bloc shows the lock screen.

**Blocs clear on lock. They do not throw.** A bloc that holds a Friend clears it when `state`
becomes `locked`, so nothing private stays in memory behind the PIN screen and nothing stale is
drawn on return. This also serves ADR-0011's second goal, because a cleared bloc cannot leak into a
screenshot.

`core/security/` decides *when* to lock. `core/db/` decides *what closing means*. The two are
separate on purpose: the timer is a product rule, and the connection is a resource.

## Consequences

### Positive

- Lock, unlock and Profile switch are one problem with one owner, settled before the first
  repository is written.
- No bloc needs a `try` around a query for a reason that has nothing to do with that query.
- A dead handle cannot be held, because no repository holds one.
- Switching Profile reuses the same path as unlocking. It is not a second mechanism.
- Clearing on lock removes private data from memory at the moment the owner expects it gone.

### Negative

- Every repository call goes through one object. It is a single point of failure, and a bug there
  shows up everywhere at once.
- A stream that goes quiet is easy to confuse with a query that returned nothing. The two must look
  different to a bloc, or an empty Friends List will be drawn behind the lock screen.
- Re-subscribing on unlock re-runs every open query. At about 100 Friends that is not noticeable.
- `DatabaseLockedError` is a new failure that every write path has to handle, including ones far
  from the lock feature.

## Alternatives Considered

### Let each repository open its own connection

**Why rejected:** Locking would then have to find and close every one of them. That is the
retrofit this record exists to avoid, and a missed one keeps the key in memory, which is the whole
point of closing.

### Keep the connection open and drop the key instead

**Why rejected:** SQLCipher holds key material in the open connection. Leaving the handle open
leaves it reachable, so the lock would protect the screen and not the data. ADR-0011 chose the
stronger option deliberately.

### Let queries throw while locked and let blocs catch

**Why rejected:** It spreads one lifecycle across every bloc in the app. Every screen would grow
the same `catch` for the same reason, and the one that forgot would crash on a timer.

### Rebuild the whole widget tree on lock, so no bloc survives

**Why rejected:** It works and it loses everything the owner was doing. A half-written Note would
disappear on a 60-second timer. Clearing what is private is enough.
