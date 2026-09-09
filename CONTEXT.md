# friendO

friendO keeps the people you care about on a repeating Cadence. You say how often you want to see
each of them. The app tells you who is next.

This repository holds one context. There is no `CONTEXT-MAP.md`.

Capitals inside this file point to another entry. Everywhere else, write these words in
normal prose casing.

## Language

### People

**Friend**:
A person you have chosen to see on a repeating Cadence. The word covers family, old friends, and
colleagues alike.
_Avoid_: contact, person, connection, relationship, entry

**Avatar**:
The picture that stands for a Friend.
_Avoid_: photo, image, icon, profile picture

**Profile**:
One private space on a shared phone, belonging to one of its Users. Two Profiles never see each
other's Friends. A Profile is the space, not the person.
_Avoid_: account, login, identity

**User**:
A person who holds a Profile on this phone. One phone may have two.
_Avoid_: owner, account holder, member
The banned `owner` is the word for a person. A component that owns a resource keeps the word.

### The App

**First Run**:
The one time a phone has no Profile at all. It ends when the first Profile exists.
_Avoid_: onboarding, setup, welcome flow, install

**Folded Text**:
A copy of a piece of text, reduced so that a search can match it. It is lower case, and it holds no
accent and no stroke. The app keeps one beside each thing it searches, and never shows one.
_Avoid_: normalised text, slug, search key, ascii text, search index

### Timing

**Civil Date**:
One day on a calendar, with no time and no zone. A Meeting happens on one. It stays the same day
when the User flies to another zone.
_Avoid_: date, day, timestamp, datetime

**Cadence**:
How often you want to see a Friend, held as a length of time.
_Avoid_: cycle, interval, frequency, tempo, period, rhythm, schedule

**Meeting**:
A recorded occasion when you saw a Friend, on a Civil Date up to today. The newest one starts that
Friend's current Cadence. A Meeting may also carry a time of day. That time is optional, the app
shows it, and the Dial ignores it.
_Avoid_: meet, catch-up, hangout, visit, interaction, touchpoint, event

**Due Date**:
The Civil Date when a Friend's next Meeting is wanted. It falls one Cadence after the last Meeting.
A Friend is not yet Overdue on it.
_Avoid_: next date, target, deadline, expiry

**Phase**:
How far a Friend has travelled through their current Cadence, as a fraction. It is zero at the last
Meeting and one at the start of the Due Date. It is never below zero.
_Avoid_: progress, elapsed, completion, angle, position

**Standing**:
The same reading as a name. Every Friend has exactly one of the four below, so the Dial counts add
up to every Friend. Phase gives the number; Standing gives the name.
_Avoid_: bucket, health, urgency, category

**Freshly Reset**:
The Standing of a Friend seen lately. Phase below a quarter.
_Avoid_: recent, fresh, new, just met

**In Orbit**:
The Standing of a Friend who is travelling with no call to act. Phase from a quarter to three
quarters.
_Avoid_: healthy, fine, normal, coasting

**Nearing**:
The Standing of a Friend close to their Due Date, or resting on it. Phase from three quarters up to
the end of the Due Date.
_Avoid_: due soon, approaching, upcoming, imminent

**Overdue**:
The Standing of a Friend whose Due Date has passed.
_Avoid_: drifting, late, lapsed, missed, neglected, due

**Priority Order**:
The single ranking of every Friend, from the one to see next down to the one least in need. Overdue
Friends come first, oldest Due Date first.
_Avoid_: queue, ranking, backlog, sort order, list
The banned `queue` is the bare word. The **Beads Queue** is a different thing with its own entry: a
drawing, not a ranking.

**On Track**:
Every Friend who is not Overdue. It is the second half of the Priority Order, ranked by highest
Phase. It covers three Standings and is not the same as In Orbit.
_Avoid_: healthy, safe, ok, current

**Placing**:
One Friend reduced to what the Dial needs: their Cadence, Due Date, Phase and Standing. The app
works one out on read and never stores one.
_Avoid_: item, row, entry, record, DTO

### The Dial

**Dial**:
The round main screen. Friends travel around its centre and the top means "now".
_Avoid_: clock, clock face, chart, wheel, orbit view

Reserve **Clock** for the source of the current time. Never use it for this screen.

**Bead**:
One Friend drawn on the Dial.
_Avoid_: dot, marker, token, node, planet, point

**Orbit**:
One of the three tracks a Bead travels. A short Cadence puts a Friend on an inner Orbit, so their
lap is quick.
_Avoid_: ring, tier, band, lane, level, circle

**Beads Queue**:
The line of Beads resting at the top of an Orbit, in Priority Order. A Bead joins it when its Phase
reaches one, so the line holds the Overdue Friends and the ones due today.
Always both words. The bare `queue` is banned under Priority Order, which is a ranking rather than a
drawing.
_Avoid_: queue, stack, pile, cluster, waiting list

**Overflow**:
The Beads that an Orbit has no room to draw.
_Avoid_: excess, remainder, hidden beads, spillover

**Overflow Badge**:
The last place on a crowded Orbit. It holds a count and stands for the Overflow, so it is not a
Bead and it names no Friend.
Always both words. The banned `marker` is the bare word, and this is a different thing with its
own entry, in the same way as the Beads Queue.
_Avoid_: marker, cluster, pill, chip, more-bead, overflow bead

**dial-minute**:
The unit of arc on the Dial. One lap is 720 of them, because the Dial reads like a 12-hour face and
each hour holds 60. It measures spacing between Beads and nothing else. It is not a length of time
and never reaches the domain.
_Avoid_: minute, degree, tick, slot

### What You Remember

None of these three is ever cleared by the app. The User deletes what has gone stale.

**Topic**:
Something you want to raise the next time you see a Friend. It looks forward.
_Avoid_: talking point, agenda, reminder, to-do

**Update**:
Something that has changed in a Friend's life. It looks back.
_Avoid_: what's new, news, life event, change

**Note**:
Free text about a Friend that is neither a Topic nor an Update.
_Avoid_: comment, memo, remark, description

### About a Friend

These three describe a Friend rather than a Meeting. The app never invents one; the User writes
them.

**Fact**:
A small piece of standing information about a Friend, held as a label and a value. Where they live,
what they drink, the name of their dog. The User writes both halves and chooses the label.
_Avoid_: field, attribute, property, detail, trait

**Affinity**:
Something a Friend is into, taken from a shared set that the User can add to. Two Friends who
share one can be found together.
_Avoid_: tag, category, interest, hobby

**Milestone**:
A day in a Friend's life worth coming back to, such as a birthday. It returns every year.
_Avoid_: event, reminder, key date

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
