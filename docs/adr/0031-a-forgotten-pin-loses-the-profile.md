# ADR-0031: A forgotten PIN loses the Profile

**Status:** Accepted
**Date:** 2026-09-09

Partly supersedes [ADR-0006](0006-keystore-dek-with-pin-gate.md). The key design in ADR-0006 stands.
Its promise of a reset flow does not.

## Context

[ADR-0006](0006-keystore-dek-with-pin-gate.md) lists this among its consequences:

> A forgotten PIN does not destroy the data. A reset flow can rebuild the gate and keep the file.

That sentence is true, and it is the problem.

[ADR-0024](0024-keystore-holds-a-wrapping-key.md) says why. The Keystore holds a wrapping key. The
app asks the hardware to unwrap the data key, and the hardware asks for no PIN. The PIN is checked
in Dart, against a hash in `profiles.json`, beside the unwrap and not inside it.

So a reset needs no secret at all. Rewrite the hash, unwrap, open. Anybody holding the phone can do
it, to any Profile on it.

That contradicts the opening of [ADR-0007](0007-database-per-profile.md), which states the reason
the PIN exists:

> Person B must not read person A's notes. That is the whole reason the login exists.

Two accepted records cannot both hold. A reset flow with no secret makes the PIN a courtesy screen,
and the second Profile on a shared phone becomes readable by the first.

Recovery is only possible if the app captures a secret when the PIN is made. First Run is therefore
where this is settled, and it is settled now.

## Decision

### There is no way back

friendO captures no recovery secret, and it offers no reset. A User who forgets a PIN cannot open
that Profile again.

The data is not destroyed. It stays on the phone, sealed, and nothing can open it.

### There is no in-app path to delete a Profile you cannot open

The only remedy is clearing the app's data through the operating system, which takes **every**
Profile with it.

This is deliberate. A delete button reachable without a PIN would let anybody holding the phone
destroy another User's Friends. Encryption never promised to stop destruction, but the app does not
have to hand the power out.

The cost falls on the rare phone with two Profiles, where one PIN is forgotten and the other User
loses their Friends too. The Backup makes this survivable: back up the Profile that still opens,
clear the data, restore it. The Backup is out of scope for v1, so **in v1 that route does not
exist**, and the wipe is total. That is accepted.

### Wrong attempts slow down, and never wipe

| Wrong attempts | What happens |
|---|---|
| 1 to 4 | Nothing. A User mistypes. |
| 5 | The keypad rests for 30 seconds. |
| 6 and up | The rest doubles: 1, 2, 4, 8 minutes, and stops at 15. |

A correct PIN clears the count. The count belongs to one Profile, so failures against one never
delay the other.

`profiles.json` gains one field per row:

```
{ id, displayName, pinHash, kdfParams, failedAttempts }
```

**Store the count, not a deadline.** Measure the rest with a timer inside the app, from the moment
the PIN screen appears. A stored "locked until" time is beaten by changing the phone clock. A count
held only in memory is beaten by closing the app. A stored count with an in-app timer is beaten by
neither, and it is less code than either.

**The app never wipes a Profile after wrong attempts.** iOS wipes after ten tries because iOS has a
backup. v1 has none, so a child at the keypad would destroy everything, with nothing to restore
from.

### What the delay does and does not stop

It stops the realistic attack: somebody holding the phone who tries the ten codes they can guess.
A birth year, `123456`, `000000`, the PIN of the phone itself.

It does nothing against an attacker who reads the storage. `profiles.json` is plaintext by design,
so the hash can be attacked offline, where no delay in the app applies. ADR-0007 and ADR-0024
already accept that file as readable, and the Profile picker shows the same names on screen anyway.

## Consequences

### Positive

- ADR-0007's guarantee holds. One User cannot reach another User's Friends, on any path the app
  offers.
- First Run stays one screen. Nothing has to be written down before the app is used.
- A forgotten PIN costs one Profile and never the other, until somebody clears the app's data.
- Nobody holding the phone can destroy a Profile from the lock screen.
- The delay costs a snoop their handful of guesses, which is the attack that happens.

### Negative

- A forgotten PIN is final. The Friends, the Meetings and the Notes in that Profile are gone, and no
  support route exists.
- In v1 the remedy for a locked Profile destroys the other one too. It stays that way until the
  Backup ships.
- The delay protects nothing against somebody who reads the storage. It is a gate against people,
  not against tools.
- One more field in `profiles.json`, and one more thing to write on every failed attempt.
- A User who mistypes six times waits 30 seconds for no reason they caused.

## Alternatives Considered

### Keep ADR-0006's reset flow

**Why rejected:** It needs no secret, so it opens every Profile on the phone to whoever holds it.
That removes the only reason ADR-0007 gives for the PIN existing.

### Capture a recovery secret during First Run

**Why rejected:** It is the strongest option, and it costs the most in the place that can least
afford it. It asks a User to write down a Backup Passphrase before they have added one Friend, and
a secret written down under protest is lost as surely as a PIN. It also builds half the Backup
before the Backup is in scope. Reconsider when the Backup ships.

### Delete the Profile from the picker, behind a typed confirmation

**Why rejected:** It gives a way out of a forgotten PIN, and it hands anybody holding the phone a
button that destroys another User's Friends. The forgotten PIN needs two Profiles and a bad memory;
the destructive button needs only a bad afternoon.

### Wipe the Profile after ten wrong attempts

**Why rejected:** v1 has no Backup, so the wipe is permanent and nothing restores it. The app would
destroy data to defend a gate that an offline attack walks around anyway.

### Store a `lockedUntil` timestamp

**Why rejected:** The phone's clock belongs to whoever holds the phone. Setting it forward clears
the wait. A counter and an in-app timer cost less and cannot be moved.

### No delay at all

**Why rejected:** Six digits by hand is hopeless for a real attacker, so the delay is not about
brute force. It is about the ten codes a person close to you can guess, and those ten are exactly
what an unthrottled keypad allows.
