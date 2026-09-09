# ADR-0030: First Run creates one Profile, and says what is not kept

**Status:** Accepted
**Date:** 2026-09-09

## Context

No document says what happens the first time somebody opens friendO. The PRD starts at the Dial,
and the Dial has no Friends yet.

Three records leave a question here, and none of them answers it.

[ADR-0020](0020-no-os-level-backup.md) turns the operating system backup off. It asks for one
sentence and does not say where the sentence goes:

> The app should still say so plainly on first run.

[ADR-0007](0007-database-per-profile.md) allows two Profiles on one phone. It does not say where the
second Profile comes from.

[ADR-0024](0024-keystore-holds-a-wrapping-key.md) gives the Profile list a shape, and parks one
field as a question it cannot answer:

> An Avatar on the Profile picker is a picture of a real face in the one unencrypted file. A colour
> and an initial would do the same job. That is a product question.

## Decision

### First Run is three screens, and the third one is the app

**One screen creates the Profile.** It takes a name and a six-digit PIN. The User types the PIN
twice, because [ADR-0031](0031-a-forgotten-pin-loses-the-profile.md) gives no way back from a typo.
Six digits submit on the sixth press, so the daily unlock needs no confirm button.

**One screen states the cost.** It appears after the PIN and before the Dial. It says that friendO
keeps everything on this phone, that nothing is copied anywhere, and that a lost phone loses what is
in it. This is the sentence ADR-0020 asked for. It gets a screen of its own because it is the one
thing a User cannot learn later by exploring, and the consequence of not knowing it is total.

**Then the Dial, with nothing on it.** Three empty Orbits, the axis at 12:00, the three counts
reading zero, and one call to add the first Friend. The empty Dial is the drawing that teaches what
the app is for, so the app shows it rather than hiding it behind a panel.

### The Profile list drops the Avatar

`profiles.json` loses `avatarId`. The picker draws a colour and an initial from the name.

This answers the question ADR-0024 parked. It keeps a photograph of a real face out of the one file
that is not encrypted, and it keeps a photo permission prompt out of the first minute.

The shape becomes:

```
profiles.json    { version, profiles: [ { id, displayName, pinHash, kdfParams } ] }
```

[ADR-0031](0031-a-forgotten-pin-loses-the-profile.md) adds one more field to the same row.

### The second Profile comes from settings

Three screens carry a Profile, and each does one job:

| Screen | When it appears | What it holds |
|---|---|---|
| PIN screen | Always | The keypad for one named Profile |
| Profile picker | Only when two Profiles exist | The list, and nothing else |
| Creation screen | From settings | The same screen First Run uses |

Settings holds **Add a Profile** and **Lock friendO**. Nothing is added to the lock screen, and one
creation route exists rather than two.

### What First Run does not do

- No tour. The Dial teaches itself, and a walkthrough of an empty Dial teaches nothing.
- No sample Friend. A false Friend in an app about real ones is the wrong first impression, and the
  User must then delete it.
- No biometric offer. [ADR-0011](0011-app-lock-and-screen-privacy.md) keeps biometric unlock, and
  settings offers it, next to the lock timer.
- No notification prompt. [ADR-0012](0012-opt-in-local-notifications.md) already settled that.

## Consequences

### Positive

- A User reaches the Dial after two taps and one typed name. Nothing stands between them and the
  app.
- No permission dialog appears before the User has seen what the app does. Every prompt is earned
  later, by an action the User chose.
- The unencrypted file holds a name and a hash, and no face.
- One creation route means the second Profile cannot drift from the first.
- The sentence ADR-0020 wanted now has a place, and it cannot be missed.

### Negative

- A User who taps past the backup screen still loses everything with the phone. A screen is the
  most the app can do, and it is not proof that anybody read it.
- The empty Dial shows three counts of zero, which looks like a broken screen until the first
  Friend exists. The call to add one has to carry that weight.
- A colour and an initial tell two Profiles apart less quickly than two faces do.
- Settings holds the only door to a second Profile, so a User looking on the lock screen will not
  find it.

## Alternatives Considered

### A guided tour after the PIN

**Why rejected:** It explains a Dial that holds nothing. The metaphor lands when a real Friend
travels around it, and that cannot happen during First Run.

### Seed a sample Friend so the Dial is not empty

**Why rejected:** friendO is about real people. A fictional one on the first screen sets the wrong
expectation, and the first thing the User learns is how to delete something.

### Keep the Avatar on the Profile

**Why rejected:** It puts a photograph of a real face in the one file with no encryption, and it
raises a photo permission prompt in the first minute. A colour and an initial separate two Profiles
just as well. The names in that file are already visible on the picker, so the file leaks nothing
the screen does not; a face is different, and it is avoidable.

### Offer the second Profile during First Run

**Why rejected:** It asks a question that almost nobody needs, before the User has one Friend. Two
Profiles on one phone is the rare case, and settings is where a rare case belongs.

### Put the backup sentence under the PIN keypad

**Why rejected:** It arrives while the User is doing something else, which is when text is not read.
It is the one warning the app owes, so it gets a screen and a button.
