# ADR-0036: Where a setting lives

**Status:** Accepted
**Date:** 2026-09-10

## Context

The app owes five settings. [ADR-0012](0012-opt-in-local-notifications.md) ships reminders off and
puts the switch in settings, and a reminder fires on a Civil Date, which carries no time, so an
hour has to come from somewhere. [ADR-0011](0011-app-lock-and-screen-privacy.md) accepted two costs
and answered both with *add a setting later*: a short lock timer annoys a User who switches apps
often, and `FLAG_SECURE` blocks the User's own screenshots. The same record added biometric unlock.

The app holds two stores. `profiles.json` is plaintext, sits beside the database files, and is read
before any Profile is unlocked ([ADR-0024](0024-keystore-holds-a-wrapping-key.md)). The database is
encrypted, one per Profile ([ADR-0007](0007-database-per-profile.md)), and readable only while that
Profile is open ([ADR-0025](0025-one-owner-for-the-database-connection.md)).

Put every setting in the database and one of them cannot be read when it is needed. Put every
setting in the file and four preferences leak into the one plaintext file on the phone.

## Decision

**A setting the lock screen must read before anything is unlocked goes in `profiles.json`.
Everything else goes in the encrypted database.**

That puts exactly one setting in the plaintext file: whether a Profile offers biometric unlock.
ADR-0011 requires it:

> The biometric prompt names the profile it unlocks. One finger cannot choose between two
> profiles, so the user picks the profile first and authenticates second.

The PIN screen has to know whether to offer a fingerprint for the Profile the User has just picked,
and at that moment no database is open. A flag in the database could only be read after the unlock
it was meant to offer.

It is a safe thing to leave in the clear. It says that a Profile uses a fingerprint. It is not a
credential, it opens nothing, and [ADR-0024](0024-keystore-holds-a-wrapping-key.md) keeps the
wrapping key in hardware whatever the file says. `profiles.json` already holds a display name and
KDF parameters, so this adds a boolean to a shape that is public by design.

The reminder switch, the reminder hour, the auto-lock seconds and the screenshot allowance are read
only while the Profile is open. They go in one row in the encrypted database.

**The store lives in `core/settings/`.** `core/security/` reads the auto-lock wait and
`core/reminders/` reads the switch and the hour. Neither may import a feature, so the store cannot
belong to `features/settings/`. The feature draws the screen and owns nothing.

**A setting is written through the same connection owner as everything else.** A write while locked
throws `DatabaseLockedError` and a watch goes quiet, with no second rule for preferences.

**While the Profile is locked, the app behaves as though every unread setting is at its safest
value.** The screenshot allowance is in the database, so the PIN screen cannot read it and is
always secure. That is the correct default and not a limitation.

## Consequences

**Good.** The test for the split is one question a reader can answer in a second: can the lock
screen read it? A setting added later lands in the right store without a discussion.

**Good.** The plaintext file stays close to what it already was. One boolean joins a display name
and KDF parameters, and none of the three says anything about a Friend.

**Good.** Settings need no second lock rule, no second migration story and no second store class.
They are rows.

**Bad.** Two stores means two write paths, and a reader has to know which one a given setting uses.
This record is the answer, and the module map points at it.

**Bad.** A setting that later needs reading at the lock screen has to move stores, which is a
migration. Nothing in the current five is close to that line, and the one that was is already in
the file.

**Bad.** The screenshot allowance cannot be honoured on the PIN screen. A User who allowed
screenshots still cannot take one of the keypad. That is the safe direction, and it is worth
stating so that nobody reports it as a defect.

## Alternatives considered

**Every setting in `profiles.json`.** One store, one write path, readable at any time. It puts the
User's reminder hour, their lock habit and their screenshot choice in a plaintext file on a phone
that may be shared. ADR-0011's threat model is a borrowed phone, and these say something about how
the User lives with the app.

**Every setting in the database, and the biometric offer worked out another way.** The lock screen
would have to try the fingerprint blind and hide the failure, or the app would have to keep a
second marker file that is the flag under another name. Both are the flag, with the rule hidden.

**A third store, such as `shared_preferences`.** A third file on the phone with its own lifetime,
its own backup behaviour ([ADR-0020](0020-no-os-level-backup.md)) and no encryption. It answers a
question the two stores already answer.
