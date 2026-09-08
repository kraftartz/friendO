# Architecture Review — friendO

**Reviewed:** 2026-09-08
**Commit:** `7fc3f5a`
**Scope:** the documents in `docs/`, `CONTEXT.md`, `AGENTS.md`, the package split, the build
configuration, and the code that exists today.

This review uses the words from [CONTEXT.md](CONTEXT.md).

---

## Resolution, 2026-09-08

Every finding below was acted on in the same session the review was written. The review text is
left as it stood, because it is the reasoning the records were written from.

| # | Closed by |
|---|---|
| B1 | [ADR-0020](docs/adr/0020-no-os-level-backup.md). Three manifest attributes, two rule files, and a CI check that reads them back out of the release APK. |
| B2 | [ADR-0021](docs/adr/0021-civil-date-time-model.md). A Meeting carries a Civil Date and an optional time of day. `CivilDate`, `Cadence` and `Phase` now hold the rules. |
| B3 | [ADR-0022](docs/adr/0022-one-repository-per-aggregate.md). One repository per aggregate, in `core/friends/`. The feature rule stands. |
| B4 | [ADR-0023](docs/adr/0023-check-the-guarantees-in-ci.md). `tool/boundaries.sh` and `tool/manifest_guard.sh`. Both were run against a bad input and both failed as intended. |
| S1 | [ADR-0022](docs/adr/0022-one-repository-per-aggregate.md). The rule: an operation that spans more than one row belongs to the domain. |
| S2 | [ADR-0024](docs/adr/0024-keystore-holds-a-wrapping-key.md). Wrapping key, not data key. Biometric binding deferred with a reason. `profiles.json` named. |
| S3 | [ADR-0025](docs/adr/0025-one-owner-for-the-database-connection.md). `core/db/` owns the connection and publishes open or locked. |
| S4 | [ADR-0026](docs/adr/0026-attachments-as-blobs-and-a-framed-backup.md). BLOBs at rest, a framed file in the Backup, and no base64. |
| S5 | [ADR-0029](docs/adr/0029-name-the-dial-counts.md). Four Standings, boundaries in Phase, all four named in `CONTEXT.md`. |
| S6 | The three package READMEs are written. |
| S7 | [ADR-0019](docs/adr/0019-correcting-and-partly-superseding-a-record.md). A factual correction may be edited in place; a record may be superseded in part. |
| G1 | [ADR-0027](docs/adr/0027-domain-value-objects-and-equality.md). `Cadence`, `Phase` and `CivilDate` validate once at construction. |
| G2 | [ADR-0028](docs/adr/0028-priority-order-as-two-groups.md). `PriorityOrder` holds two groups, so "Overdue first" needs no comparator branch. |
| G3 | [ADR-0027](docs/adr/0027-domain-value-objects-and-equality.md). `equatable`, and the domain's rule is "no Flutter, no clock, no input and no output" rather than "no dependencies". |
| G4 | `dial-minute` is in `CONTEXT.md`. |
| G5 | The term is now **Beads Queue**, with a cross-reference on both entries. |

One correction to the review itself: it repeats the backlog's instruction to correct ADR-0014's
Orbit radii. ADR-0014 already reads 62 / 102 / 142. The stale line was in
`docs/feature-backlog.md`, and that is the file that changed.

---

## Verdict

**Greenlight, conditional on four blockers.**

The architecture is sound. The package split is real, not decorative. The decision records are
better than most professional projects produce, and several of them rejected the option I would
have raised. I found no reason to change the shape of the system.

The four blockers below share one property: each is cheap to settle now and expensive to settle
after the first schema ships or the first repository is written. None of them asks you to redesign
anything. Three of them ask you to write down a choice you have already half-made.

One theme runs through all four. **The project's best idea is that a rule should hold by
compilation, not by review.** ADR-0004 and ADR-0018 both say so, and both deliver. The blockers are
the four places where the project states a guarantee and then leaves it to memory.

| # | Finding | Severity |
|---|---|---|
| B1 | Android Auto Backup copies the plaintext Profile list off the phone | **Blocker** |
| B2 | The time model is undefined: instant or civil date, and in which timezone | **Blocker** |
| B3 | "A feature must not import another feature" collides with the data model | **Blocker** |
| B4 | Two guarantees are stated but not enforced: no INTERNET, and the package boundaries | **Blocker** |
| S1 | Invariants have no owner, so the domain risks going anemic | Should fix |
| S2 | `flutter_secure_storage` does not deliver what ADR-0006 describes | Should fix |
| S3 | The database connection lifecycle across lock and unlock has no owner | Should fix |
| S4 | Attachments: `architecture.md` decides what `feature-backlog.md` calls open | Should fix |
| S5 | The Dial counters name three states that no document defines | Should fix |
| S6 | Two package READMEs are unedited Flutter boilerplate | Should fix |
| S7 | The ADR process has no route for correcting a factual error | Should fix |
| G1 | `Cadence` and `Phase` are raw `Duration` and `double` | Suggestion |
| G2 | Overdue and on-track are one list sorted by two keys | Suggestion |
| G3 | The domain has no equality story | Suggestion |
| G4 | `dial-minute` is used in an ADR and missing from the glossary | Suggestion |
| G5 | `Queue` is both a defined term and an avoided word | Suggestion |

---

## Blockers

### B1. Android Auto Backup copies the plaintext Profile list off the phone

**Evidence.** `android/app/src/main/AndroidManifest.xml` does not set `android:allowBackup`, and it
declares no `dataExtractionRules` or `fullBackupContent`. The Android default is `true`. Android
then copies the app's private directory, its databases and its shared preferences to the owner's
Google Drive, on the system's own schedule.

**Why this matters more here than in most apps.** ADR-0007 puts the Profile list *outside* the
encrypted files, on purpose:

> Store the profile list itself outside the encrypted files. It holds only a display name, an
> avatar, and a PIN hash.

So the file that names both people who share the phone, holds their Avatars, and holds their PIN
hashes, is the one file with no encryption. That file leaves the phone in the clear, to a Google
server, with no INTERNET permission and no code in this repository.

ADR-0003 is the product's headline promise:

> Anyone can read the manifest and confirm the promise. The claim stops being a matter of trust.

The manifest check is necessary and it is not sufficient. It proves the *app* opens no socket. It
proves nothing about what the *OS* uploads on the app's behalf. Right now the answer is: the
Profile list, in the clear.

**Second effect, on restore.** The encrypted database files are also copied. The Keystore key is
not, because it cannot be. An owner who restores onto a new phone therefore receives a database that
nothing can open, while believing Google backed the app up. That silently competes with the backup
story in ADR-0010, which is the one that actually works.

**Remediation.**

1. Set `android:allowBackup="false"` in the main manifest, and set `android:dataExtractionRules`
   (API 31+) and `android:fullBackupContent` (below 31) to exclude everything. Belt and braces,
   because the two attributes apply on different API levels.
2. On iOS, do the same job in the two places it exists: set `NSURLIsExcludedFromBackupKey` on the
   database files and the app's data directory, and give every Keychain item a
   `...ThisDeviceOnly` accessibility class so it never enters an iCloud or iTunes backup.
3. Write an ADR. This is a real decision with a real cost, and it belongs in the record beside
   ADR-0003. The cost: the owner loses the OS-level restore they may expect, which makes ADR-0010's
   Backup the only route to a new phone. That is already the design, and it should be a choice on
   paper rather than a side effect of a manifest attribute.
4. Add the manifest attributes to the CI check described in B4.

**Consider also.** If the Profile list must stay outside encryption, keep it as small as the ADR
says. An Avatar is a picture of a real person's face. Ask whether the Profile picker needs one, or
whether a colour and an initial would do. That is a product question, not an architecture one, but
this is the moment to ask it.

---

### B2. The time model is undefined

**Evidence.** Four documents describe the same field differently.

| Source | Says |
|---|---|
| `docs/architecture.md` | `meetings : [Instant]` |
| ADR-0016 | "Let a meeting carry any past date", "Reject future dates" |
| `docs/feature-backlog.md` | `meetings(id, friend_id, happened_on, ...)` |
| `CONTEXT.md` | "on any date up to today" |
| `packages/friendo_domain/lib/src/phase.dart` | `DateTime lastMet`, `DateTime now` |

An instant and a civil date are different types with different bugs. The code takes `DateTime`,
which in Dart is either, depending on a flag the caller sets.

**Why this cannot wait.** It decides a column type. Julian day as an `INTEGER`, or milliseconds
since epoch, are not the same column, and changing one to the other after the first Backup exists
means writing the format migration that ADR-0010 warns will grow.

**Three concrete failures that follow from not choosing.**

1. *An owner who travels.* Store a Meeting as midnight of a local date, fly east, and `now` in the
   new zone can precede the stored `lastMet`. `phaseOf` returns a negative number. ADR-0016 believes
   that state cannot exist, because it "removed" the friend-with-no-meeting case. The domain today
   returns the negative quietly, and `phase_test.dart` asserts that it does. That test encodes an
   unreachable-by-design state as expected behaviour without saying what the app should do with it.
2. *Daylight saving.* `dueAt = lastMet + cadence`. Dart's `DateTime.add` adds absolute time. A local
   `lastMet` plus `Duration(days: 30)` across a DST boundary lands an hour off. Near midnight that
   moves the Due Date to a different calendar day, which moves a reminder to 23:00 the night before.
   ADR-0012 already flags timezone handling as a cost. This is the specific shape of it.
3. *"Reject future dates" against which clock.* The device clock, in local time, means an owner who
   travels can log a Meeting for a date that is tomorrow where the data is stored.

**Decided, 2026-09-08.** A Meeting carries a civil date and no time. The reasoning is recorded
below so the ADR can be written from it.

- A Meeting happens on a **civil date**. No time, no zone. Store it as a day number.
- `lastMet` is a civil date. `now` stays an instant, taken from the injected `Clock`.
- `phase` reads `now` against local midnight of `lastMet`, so a Bead moves smoothly through the day
  rather than jumping once every 24 hours. On a 7-day Cadence a whole-day quantisation would give
  seven visible positions, which the Dial cannot afford.
- `dueAt` is a civil date: `lastMet` plus the Cadence in whole days. Reminders fire at a chosen hour
  on that date, computed in the owner's current zone at scheduling time.
- Then say what a negative `phase` means. If it stays impossible, make `phaseOf` reject it the way
  it already rejects a non-positive Cadence. If it is possible, the Dial needs a rule for drawing it.

The reason a time was considered and dropped: the app never collects one. ADR-0016 specifies a date
picker, so a `DateTime` column would hold an hour nobody entered. Fabricated precision is worse than
none, because the column then carries two kinds of value with nothing marking which is which. The
designs agree: `friend_detail` renders a Meeting as "October 14 (28 days ago) at Blue Bottle" with a
Duration and no clock time.

**Three time values, three types.** They are different kinds of time and they do not share a
representation.

| Value | Type | Why |
|---|---|---|
| A Meeting happened | civil date | The owner's calendar is the truth. "I saw Anna on Tuesday" must stay Tuesday when the owner travels. |
| Due Date | civil date | Derived: `happened_on` plus the Cadence in whole days. |
| A reminder fires | civil datetime **plus IANA zone**, resolved to an instant at scheduling time | A future instant computed today can be wrong tomorrow. |

**The rule for reminders, which no record states yet.** Never persist a precomputed UTC instant for
a future reminder. Governments change daylight-saving rules, so a fire time computed six months out
drifts by an hour without anything writing to it. Store the civil datetime and the zone id, and
resolve at scheduling time. ADR-0012 names the `timezone` package and not this rule; `TZDateTime`
exists for exactly it. The cost is nothing, because ADR-0012's iOS limit of 64 pending notifications
already forces a reschedule on every open.

A reminder's time of day is a setting, not a property of a Meeting. An hour chosen once in settings
serves every Friend. Seeing somebody at 03:00 must not produce a 03:00 reminder.

**Add `created_at` as a real instant.** It is a machine event, so it is the one value here that is
genuinely an instant. It gives a stable tiebreak for two Meetings on one civil date without putting
a fabricated hour on `happened_on`.

**Where a time would land if it is ever wanted.** Two future features would need one, and neither is
a field on a Meeting:

- *"You are visiting Paul today at 14:00."* That is a plan. ADR-0016 already excludes plans: "A
  future date is a plan, not a meeting, and the app does not hold plans." A planned Meeting is a new
  concept with its own record, not an hour added to a past one.
- *Calendar integration.* It needs the INTERNET permission, so ADR-0003 has to be superseded first.
  Calendars carry all-day events anyway, so even then a time is optional.

Both land beside the Meeting rather than inside it, so choosing a civil date now closes no door.

---

### B3. "A feature must not import another feature" collides with the data model

**Evidence.** `docs/architecture.md` states two rules together:

> Each feature folder holds its own `bloc/`, `view/`, and repository.
> A feature must not import another feature.

And the module map assigns Meetings and Notes to `features/journal/`.

Now read the PRD against that. The Friends List (PRD 4.2) shows, per Friend card, "the date of the
last Meeting, and where it happened", "the Topics waiting for the next Meeting", and "an inline
one-tap button to log a Meeting". The Dial (PRD 4.1) needs every Friend's Meetings to derive
`lastMet` at all, and carries its own one-tap Meeting logging.

So three features read Meetings and two of them write Meetings. Under the two rules above, that
means three repositories over the same tables, each with its own queries and its own row mapping.

**The rule that breaks first.** ADR-0012 requires a reschedule on every change to `lastMet` or
`cadence`, and names the failure honestly:

> A missed path causes a wrong reminder, and that bug is hard to notice.

There are now three write paths and no owner for the reschedule. `features/settings/` holds the
reminder switch, so the scheduler presumably lives there, and no other feature may import it.

**The deeper version of the same point.** ADR-0016 establishes an invariant that spans two tables:

> Because creation always records one meeting, every friend always has at least one.

and

> Deleting the only meeting would empty `lastMet` again. Block that.

A rule that must hold across a Friend and that Friend's Meetings is the definition of an aggregate
boundary. Friend is the root. Meeting, Note, Fact, Affinity and Milestone have no life outside a
Friend and no screen reaches them except through one. **There is one aggregate here, so there is one
repository, and a repository loads and saves the whole aggregate.** Splitting it across `friends/`
and `journal/` splits the aggregate, and the invariant then has nowhere to live except in whichever
bloc happens to be running.

**Remediation.** Keep the feature rule. Move the seam.

Repositories are not feature-private. They belong beside the tables they own, in `core/`:

```
lib/core/
  db/          drift tables, SQLCipher setup, migrations
  friends/     FriendRepository  — the whole aggregate: Friend, Meetings, Notes, Facts,
               Affinities, Milestones. One place that enforces "at least one Meeting".
  reminders/   Watches the repository. Reschedules. Owned by nobody's feature.
```

Then `features/dial/`, `features/friends/` and `features/journal/` all depend on `core/friends/`
and never on each other. The rule survives intact, and it now means something, because there is a
legal place for shared data to live.

Two smaller notes on the same seam:

- Reads that only display can skip the aggregate. The Friends List row wants a name, a date, a
  place and a Phase. Give it a read model: a plain record returned by one query, with no aggregate
  loaded and no rules applied. That keeps the aggregate honest without making the list slow to
  write.
- Update `docs/architecture.md` and ADR-0004 together. ADR-0004's sentence "Each feature holds
  `bloc/`, `view/`, and a repository" is the one to change, and it deserves a short new ADR rather
  than an edit, per your own process.

---

### B4. Two stated guarantees are not enforced

The project's strongest habit is turning a rule into a build error. It has done that twice, well.
It states two more guarantees that nothing checks.

**B4a. The INTERNET permission check does not exist.** ADR-0003 specifies it:

> Add a check to CI that fails the build if the INTERNET permission appears in the merged manifest.
> A transitive dependency can add that permission without anyone noticing.

`.github/workflows/ci.yml` has no such step. The risk is live right now: `drift`,
`flutter_local_notifications`, `flutter_secure_storage` and `path_provider` are declared in
`pubspec.yaml` and not yet wired in. Each brings a manifest.

There is a trap in writing this check. `android/app/src/debug/AndroidManifest.xml` and
`.../profile/AndroidManifest.xml` both declare INTERNET, correctly, because the Flutter tool needs
it for hot reload. CI only runs `flutter build apk --debug`. A naive grep fails on a clean tree, and
a check that cries wolf gets deleted.

*Remediation.* Build the release APK in CI and read the permissions out of the packaged manifest,
which is the artefact the promise is actually about:

```bash
flutter build apk --release
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk \
  | grep -q 'android.permission.INTERNET' \
  && { echo 'INTERNET permission is in the release APK'; exit 1; }
```

Add the B1 attributes to the same step, since they live in the same merged manifest. The release
build needs a signing config; `build.gradle.kts` currently signs release with the debug key, which
is fine for this check and must not reach a store.

**B4b. Nothing guards the package boundaries.** ADR-0004 and ADR-0018 both claim the compiler holds
the line, and both are right today. But the guarantee lives entirely in three `pubspec.yaml` files,
and nothing watches those files. Add `flutter` to `packages/friendo_domain/pubspec.yaml` and CI goes
green. The compiler proves the code you wrote compiles. It does not prove the boundary still exists.

*Remediation.* A short script in `tool/`, called from `tool/lint.sh`, that fails when a forbidden
dependency appears:

| Package | Must not declare |
|---|---|
| `friendo_domain` | `flutter`, and anything Flutter-only |
| `friendo_ui` | `flutter_bloc`, `drift`, `friendo_domain` |
| `friendo_ui_book` | anything except `flutter`, `friendo_ui`, `widgetbook`, `cupertino_icons` |

Ten lines of `grep`. It converts three prose rules into three build errors, which is the standard
this project already sets for itself elsewhere.

---

## Should fix

### S1. Invariants have no owner, so the domain risks going anemic

ADR-0004 rejects a use case class per operation, and it is right to. Forty classes of
`Future<void> call(Friend f) => repo.add(f);` are noise. The record's reasoning is sound and I would
not reopen it.

But the record then draws a line that is one step too wide:

> Call the repository straight from the bloc. Write no use case class for a plain CRUD call.

Three operations in this app are not plain CRUD, because each carries a rule that the record
elsewhere insists on:

| Operation | Rule it must hold | Where the rule is written |
|---|---|---|
| Add a Friend | Creation writes the first Meeting | ADR-0016 |
| Log a Meeting | Date is today or earlier; the reminder reschedules | ADR-0016, ADR-0012 |
| Delete a Meeting | Never leave a Friend with zero Meetings | ADR-0016 |

Under the rule as written, those three rules land in blocs. ADR-0004 sees this coming and names it:

> Blocs can slowly collect logic that belongs in the domain. Nothing stops that automatically.
> Watch for it in review.

That is the one place in the whole record set where the project accepts a review convention for a
rule it cares about. Everywhere else it argues the opposite, and argues it well:

> A folder cannot fail to compile. "Widgets hold no BLoC" would stay a review convention, and review
> conventions decay. — ADR-0018

Both cannot be true. I do not think the answer is Clean Architecture; ADR-0004 already killed that
fairly. The answer is smaller.

**Remediation.** Let the rules live in the aggregate, and let the blocs stay thin.

- Give `friendo_domain` a `Friend` type that owns its Meetings and refuses to lose the last one.
  Then `deleteMeeting` cannot produce an invalid Friend, because the method that would do it does
  not exist. The invariant becomes unreachable rather than guarded.
- Keep calling the repository straight from the bloc for the operations that really are CRUD.
  Editing a Note's text is CRUD. Renaming a Friend is CRUD. Those stay exactly as ADR-0004 says.
- Write the distinction into ADR-0004's successor as a test, not a taxonomy: *if the operation must
  hold a rule that spans more than one row, the domain owns it. Otherwise the bloc calls the
  repository.*

This costs three or four methods on one class, not forty classes.

### S2. `flutter_secure_storage` does not deliver what ADR-0006 describes

ADR-0006 says two things about the data key that the declared dependency cannot do:

> Store it in the Android Keystore or the iOS Keychain. Both are hardware-backed and mark the key as
> **non-exportable**.

and

> Prefer the platform's biometric or device-credential binding on the Keystore entry where it is
> available.

A non-exportable key never leaves the secure hardware. The data key must reach Dart, because Dart
passes it to `pragma key`. So the data key is *not* the non-exportable key. What actually happens on
Android is that `flutter_secure_storage` uses a non-exportable Keystore key to **wrap** a value, and
keeps the wrapped value in shared preferences. That design is fine, and it is the right one. It is
simply not what the record says, and the difference matters twice: it is the reason B1 leaks (the
wrapped blob is in shared preferences, which Auto Backup copies), and it is the reason the second
sentence is hard to honour, because `flutter_secure_storage` exposes no
`setUserAuthenticationRequired` on the Keystore entry.

**Remediation.**

1. Correct the wording in a new record: the Keystore holds a non-exportable **key-wrapping key**;
   the data key is stored wrapped and is decrypted into process memory to open the database. This is
   still a complete answer to the stolen-phone threat, and saying it precisely costs nothing.
2. Decide whether the biometric or device-credential binding is in scope for v1. If it is, it needs
   platform channel code or a package that exposes the flag, and that is a real cost worth recording
   before ADR-0011 assumes it. If it is not, mark it deferred so the preference does not read as a
   commitment.
3. Say where the Profile list lives. ADR-0007 says it sits outside the encrypted files and does not
   say in which file, or in what format. It holds PIN hashes, so it deserves a named home.

### S3. The database connection lifecycle has no owner

ADR-0011 makes a correct security decision with a large structural consequence, in one sentence:

> Close the database handle when locking, so the key leaves the open connection.

Every drift stream in the app dies at that moment, and every bloc watching one has to survive the
gap and re-subscribe on unlock. That is a cross-cutting lifecycle, and no document assigns it to
anyone. It affects every feature and it is exactly the kind of thing that gets discovered by the
fourth feature and retrofitted badly into the first three.

**Remediation.** Name the owner now, in `docs/architecture.md`. A single object in `core/db/` that
holds the open connection, exposes it to repositories, and publishes an open or closed state.
Repositories ask it for a connection rather than holding one. Blocs react to the closed state by
clearing, not by throwing. One paragraph in the architecture document, written before the first
repository, saves the retrofit.

### S4. Attachments: two documents disagree, and the record is missing

`docs/architecture.md` already decides:

> `core/media/` Avatar images and audio recaps. Stored as blobs.

`docs/feature-backlog.md` calls the same question open, lists two options, and adds a hard
precondition:

> **ADR-0010 must change before any attachment ships.**

The backlog's analysis is right, including the reason: SQLCipher encrypts the database file and not
a loose file on disk, so an Avatar written to app storage defeats ADR-0006. The BLOB answer is
almost certainly correct at this size. It is simply not recorded, and the architecture document is
quietly ahead of the record.

One consequence neither document costs out. ADR-0010 exports one JSON document. Base64 of a hundred
Avatars plus audio recaps is tens of megabytes, inflated by a third, assembled as a single string in
a phone's memory before it is encrypted. That is an out-of-memory crash during the one operation the
owner must be able to trust.

**Remediation.** Write the attachments ADR, decide BLOB versus file store there, and settle the
Backup container in the same record: either a streaming format with a JSON part and a blob part, or
a JSON document that carries attachments as separate encrypted members. Do not leave the format to
the moment the first Avatar ships.

### S5. The Dial counters name three states that no document defines

PRD 4.1 asks for "Live counts of Friends who are *near their Due Date*, *on track*, and *recently
met*". The designs show `1 Nearing 12:00`, `4 In Orbit`, `2 Freshly Reset`. `feature-backlog.md`
says the domain can return them.

No document says what the boundaries are. Is "near their Due Date" a Phase above 0.75, or a Due Date
within three days? Those give different answers for a weekly Friend and a quarterly one, which is
the same distinction ADR-0009 was careful enough to record for Priority Order.

`CONTEXT.md` defines **Overdue** and nothing else in this family, yet the app shows three more
states on its main screen. The project's own rule applies:

> If a needed word is missing, add it there first.

**Remediation.** Name the three states in `CONTEXT.md`, define each boundary as a Phase threshold or
a day count, and put the classification in `friendo_domain` beside `phase`. It is a pure function of
the same ordered list, and it belongs in the same place, with the same tests.

### S6. Two package READMEs are unedited Flutter boilerplate

`packages/friendo_domain/README.md` and `packages/friendo_ui/README.md` both still read
"TODO: Put a short description of the package here". `packages/friendo_ui_book/README.md` is the
default Flutter application README.

In most repositories this is a shrug. Here it is worth ten minutes, because these three packages are
the architecture, and a reader who opens `friendo_domain` to learn what the boundary means finds a
template. Each pubspec already contains an excellent description. Move it up.

### S7. The ADR process has no route for correcting a factual error

`docs/feature-backlog.md` instructs, in its conflicts table:

> Orbit radii: 62 / 102 / 142 versus 60 / 100 / 140 — Correct ADR-0014

ADR-0001 forbids that:

> Do not edit an accepted record to match a new opinion. Write a new record and mark the old one
> `Superseded`.

Both are reasonable. Correcting a measurement is not changing an opinion, and superseding a whole
record because one number was mistyped would bury the reasoning that is still correct. The process
simply has no third option, and without one, either the backlog's instruction or ADR-0001 gets
broken quietly.

**Remediation.** Add one line to `docs/adr/README.md`: a factual correction may be edited in place
if it is marked, with the date and what changed. ADR-0005 already does this well and without
permission, in its header: `Date: 2026-09-07. Encryption mechanism revised 2026-09-08.` Make that
pattern the rule.

---

## Suggestions

These are not defects. Each is a small move that would make the code hold a rule the way the rest of
the project likes to hold rules.

### G1. `Cadence` and `Phase` are raw `Duration` and `double`

`phaseOf` defends against a non-positive Cadence on every call, because a `Duration` can be zero or
negative and a Cadence cannot. A `Cadence` type validates once at construction, and the guard then
disappears from every function that takes one. It is also the natural home for `orbit(cadence)` from
ADR-0008, which is a rule about a Cadence and currently has nowhere to be.

`Phase` has a weaker case, and a real one: it carries a rule about its own range that a `double`
cannot express, and `overdue` is a property of it.

*Honest cost.* ADR-0018 sets the standard "build only what repeats", and this is two small types for
a package that today holds one function. Do it when `friend.dart` is written, not before.

### G2. Overdue and on-track are one list sorted by two keys

ADR-0009 defines the Priority Order as two groups with different sort keys: Overdue by `dueAt`
ascending, on-track by `phase` descending. Written as one comparator over a flat list, that becomes
an `if` on `phase > 1` inside a compare function, where a mistake between the groups sorts wrongly
and no test is obviously missing.

Two named types make the total order fall out of the structure: sort each group by its own key, then
concatenate, with Overdue always first. The rule "Overdue friends always come before on-track
friends" then holds by construction rather than by a comparator branch, which is the same trick
ADR-0014 already uses and praises:

> A stable partition of a sorted list means orbit order can never contradict global order. That
> holds by construction, so no test has to guard it.

### G3. The domain has no equality story

`friendo_domain` declares no dependencies at all, which is a fine property and worth keeping on
purpose rather than by accident. When `Friend` and `Meeting` arrive they will need value equality
for tests to read well. `equatable` is already in the app's `pubspec.yaml`, and it is pure Dart, so
it could go in the domain. Dart 3 records and a hand-written `==` are the other two answers.

Decide once, in the record that introduces the types, and say whether the zero-dependency property
is a rule or a coincidence.

### G4. `dial-minute` is used in an ADR and missing from the glossary

ADR-0014's capacity table is in "dial-minutes", and the numbers only make sense once you work out
that a lap is 720 of them, not 60. The arithmetic is correct — I checked all three rows — but the
unit is invented in that table and defined nowhere. `CONTEXT.md` claims authority over every word.

### G5. `Queue` is both a defined term and an avoided word

`CONTEXT.md` defines **Queue** as "the line of Overdue Beads resting at the top of an Orbit", and
four entries later lists `queue` under *Avoid* for **Priority Order**. Both are deliberate and the
distinction is real: one is a drawing, the other is a ranking. A reader meeting the second entry
first will think the word is banned. A cross-reference on both entries fixes it.

---

## On ADR-0015, which is still `Proposed`

I looked hard at whether an undecided record should block the greenlight. It should not, and the
reason is a credit to the design.

ADR-0014 specifies that the packer returns two things: the placed Beads, and the Beads that did not
fit. All four options in ADR-0015 read that same set. None of them touches the domain. So the
decision is genuinely deferrable, and the record says so accurately:

> Deciding late costs nothing here, because the packer already produces the overflow set and the
> domain is untouched by all four options.

That is what a well-placed seam looks like. The one thing to hold onto is the record's own caution,
because it is easy to skip: ship a count with the interim behaviour, so an owner with thirty close
friends is told that some are not drawn rather than left to notice.

---

## Already tracked

I checked the issue tracker before writing. These are known and correctly filed, and I raise none of
them again: iOS is never built in CI (`friendO-6gv`), routing is undecided (`friendO-njf`), and the
Flutter pin needs a decision (`friendO-nx7`).

`docs/feature-backlog.md` also already carries two open product questions that need an answer before
the screens they belong to are built: which Cadence preset list wins (7/30/90 or 7/14/30/60), and
whether a guest Profile's database survives a restart.

---

## What is good

A review that only lists faults is not a useful review. These are the things I would copy into
another project.

**The glossary is the best artefact here.** `CONTEXT.md` does not only define words; it lists the
words you may not use, which is the half that most glossaries skip and the half that does the work.
"Avoid: contact, person, connection" is what stops `ContactEntity` appearing in month four. The rule
that it wins over every other file, including in code and in text shown to an owner, is what makes it
enforceable rather than decorative.

**The boundaries are real.** Three packages that resolve dependencies independently is a stronger
guarantee than any lint, and the pubspecs explain *why* they are empty, which is the comment that
survives someone trying to be helpful. Refusing a pub workspace for exactly this reason is a
subtle call and the right one.

**The decision records reject well.** The Alternatives sections are the point of the format and they
are done properly: ADR-0006 explains why deriving the key from the PIN is weaker despite sounding
stronger, ADR-0009 records that two overdue orderings look interchangeable and are not, ADR-0014
names an option as "proposed and wrong" and says why, and ADR-0018 reverses its own earlier choice
on code generation and states plainly that the original reason was mistaken. Several of these
pre-empt exactly the suggestion I would otherwise have made.

**The derived-state model is right.** Storing a Cadence and the Meetings, and deriving everything
else on read, removes a whole class of bug rather than handling it. "The dial is also correct after
the phone sleeps for a month" is the sentence that proves the design. ADR-0016 then removes the
null `lastMet` case by construction instead of guarding it, which is the same instinct applied
twice.

**The negatives are honest.** ADR-0005 documents that changing the `source` define silently ships an
unencrypted database, with the command to verify it. ADR-0002 states that BLoC was chosen to learn
BLoC and tells the reader not to infer a performance reason. ADR-0018 rejects a code generator partly
because it posts telemetry, which is the kind of detail most projects find out later. Records that
admit their costs get read.

**The scaffolding earns its place.** Declaring the dependencies that the accepted records commit to,
before they are used, so that a version clash surfaces against an empty app, is a good trick. So is
leaving out the Argon2id package with a comment saying the candidate is unverified, rather than
guessing.

---

## Summary

Four blockers, seven should-fixes, five suggestions. None of them changes the shape of the system.

The three that would genuinely hurt if deferred are B1, because it contradicts the product's central
promise today and the fix is four manifest attributes; B2, because it decides a column type and a
Backup format; and B3, because the first repository written commits the answer either way.

Fix those, add the two CI guards in B4, and start building.
