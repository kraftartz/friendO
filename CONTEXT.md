# friendO

friendO keeps the people you care about on a repeating rhythm. You say how often you want to see
each of them. The app tells you who is next.

This repository holds one context. There is no `CONTEXT-MAP.md`.

Capitals inside this file point to another entry. Everywhere else, write these words in
normal prose casing.

## Language

### People

**Friend**:
A person you have chosen to see on a repeating rhythm. The word covers family, old friends, and
colleagues alike.
_Avoid_: contact, person, connection, relationship, entry

**Avatar**:
The picture that stands for a Friend.
_Avoid_: photo, image, icon, profile picture

**Profile**:
One private space on a shared phone, belonging to one of its owners. Two Profiles never see each
other's Friends.
_Avoid_: user, account, login, identity

### Rhythm

**Cadence**:
How often you want to see a Friend, held as a length of time.
_Avoid_: cycle, interval, frequency, tempo, period, rhythm, schedule

**Meeting**:
A recorded occasion when you saw a Friend, on any date up to today. The newest one starts that
Friend's current Cadence.
_Avoid_: meet, catch-up, hangout, visit, interaction, touchpoint, event

**Due Date**:
When a Friend's next Meeting is wanted. It falls one Cadence after the last Meeting.
_Avoid_: next date, target, deadline, expiry

**Phase**:
How far a Friend has travelled through their current Cadence, as a fraction. It is zero at the last
Meeting and one at the Due Date.
_Avoid_: progress, elapsed, completion, angle, position

**Overdue**:
The state of a Friend whose Due Date has passed.
_Avoid_: drifting, late, lapsed, missed, neglected, due

**Priority Order**:
The single ranking of every Friend, from the one to see next down to the one least in need. Overdue
Friends come first, oldest Due Date first.
_Avoid_: queue, ranking, backlog, sort order, list

### The Dial

**Dial**:
The round main screen. Friends travel around its centre and the top means "now".
_Avoid_: clock, clock face, chart, wheel, orbit view

Reserve **Clock** for the source of the current time. Never use it for this screen.

**Bead**:
One Friend drawn on the Dial.
_Avoid_: dot, marker, token, node, planet, point

**Ring**:
One of the three tracks a Bead travels. A short Cadence puts a Friend on an inner Ring, so their lap
is quick.
_Avoid_: orbit, tier, band, lane, level, circle

**Orbit** is the metaphor behind the Dial and is fine in words shown to the user. Use **Ring** for
the three tracks everywhere else.

**Queue**:
The line of Overdue Beads resting at the top of a Ring, in Priority Order.
_Avoid_: stack, pile, cluster, waiting list

**Overflow**:
The Beads that a Ring has no room to draw.
_Avoid_: excess, remainder, hidden beads, spillover

### What You Remember

None of these three is ever cleared by the app. The owner deletes what has gone stale.

**Topic**:
Something you want to raise the next time you see a Friend. It looks forward.
_Avoid_: talking point, agenda, reminder, to-do

**Update**:
Something that has changed in a Friend's life. It looks back.
_Avoid_: what's new, news, life event, change

**Note**:
Free text about a Friend that is neither a Topic nor an Update.
_Avoid_: comment, memo, remark, description

### Privacy

**PIN**:
The short code that unlocks a Profile.
_Avoid_: passcode, password, passphrase, code

**Backup Passphrase**:
The separate, longer secret that unlocks a Backup. It is never the PIN.
_Avoid_: password, PIN, recovery code, key

**Backup**:
One encrypted file holding everything in one Profile, meant to outlive the phone that wrote it.
_Avoid_: export, dump, archive, snapshot, save file
