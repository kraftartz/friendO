# Add a Friend, the Friend Notepad, and Settings

Three screens, and one spec, because they are the three places a User *writes*. Every screen
specified so far reads: the Dial draws the ranking, the Friends List spells it out. Neither can
create a Friend, and neither can change one. This spec covers the writing side of the app.

It follows three records closely:

| Record | What it settles here |
|---|---|
| [ADR-0016](../adr/0016-derive-lastmet-from-meetings.md) | Adding a Friend asks when the User last saw them, and stores the answer as the first Meeting. |
| [ADR-0017](../adr/0017-note-kinds-are-labels.md) | Topic, Update and Note are one record with a label. The app clears none of them. |
| [ADR-0012](../adr/0012-opt-in-local-notifications.md) | Reminders ship off. The User turns them on here. |

It obeys seven more without adding to them:

| Record | What it holds here |
|---|---|
| [ADR-0008](../adr/0008-cadence-as-duration.md) | A Cadence is whole days. An Orbit is a range of them, and nothing stores one. |
| [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) | The auto-lock timer and biometric unlock each need a setting. This is that screen. |
| [ADR-0021](../adr/0021-civil-date-time-model.md) | A Meeting happens on a Civil Date. Its time of day is optional, shown, and never drawn. |
| [ADR-0022](../adr/0022-one-repository-per-aggregate.md) | One aggregate, one repository, whole loads and whole saves. A rule spanning rows lives in the domain. |
| [ADR-0026](../adr/0026-attachments-as-blobs-and-a-framed-backup.md) | An Avatar and an audio recap are BLOB columns, read on their own. |
| [ADR-0027](../adr/0027-domain-value-objects-and-equality.md) | A Cadence rejects zero once, so no later screen guards it. |
| [ADR-0032](../adr/0032-a-cadence-change-moves-the-due-date.md) | A Cadence change moves the Due Date and never the last Meeting. The picker shows the result first. |

It sits on top of [docs/spec/boot-and-data.md](boot-and-data.md), which gives it an open connection,
a repository contract and a lock. The Friends List and the Dial open two of these screens and draw
neither. This spec repeats nothing those three say.

## Problem Statement

The app can show a roster it has no way to build.

**Nothing creates a Friend.** Every screen so far reads rows that no screen writes. The Friends
List's empty state invites the User to add their first Friend and has nowhere to send them.

**A first Friend is two facts, and one of them is easy to get wrong.** ADR-0016 requires a Meeting
at creation, because `lastMet` is `max` over a Friend's Meetings and a Friend with none divides by
nothing. That record also names the cost of the fix: a User who accepts a default without reading
it records a Meeting that did not happen. The field has to be worded so that a person adding
somebody they have not seen for two years answers truthfully in one tap.

**Nothing changes a Cadence.** ADR-0032 settles what a change *means* and says the picker must show
the result before the User commits. No screen exists to show it.

**The writing has nowhere to go.** The Friends List card shows the newest waiting Topic and a
count, and taps through to a screen that is not specified. The Topics, the Updates, the Notes, the
Facts, the Milestones and the Meeting history are the reason the app exists, and they are all
unreachable.

**Reminders are decided and unreachable.** ADR-0012 ships them off by default and puts the switch
in settings. `features/settings/` holds a placeholder that draws the words *Settings page*. So the
app carries the whole cost of the decision and delivers none of its value.

**Two more settings are owed.** ADR-0011 accepted `FLAG_SECURE` blocking the User's own
screenshots and a lock timer that annoys a User who switches apps often, and answered both with
*add a setting later*. Later is this spec.

## Solution

Three screens.

**Add a Friend.** One form, in four parts: who they are, when the User last saw them, how often they
want to see them, and anything they already know. Only the first three are needed. The Cadence part
offers the three preset Orbits and a custom number of days, and it says what each one gives before
the User commits. Saving writes a Friend and their first Meeting in one step, and returns to the
screen that asked for it.

**The Friend Notepad.** One Friend, top to bottom: who they are and where they stand, the writing
waiting for the next Meeting, the Meeting history newest first, the standing facts about them, and
the controls that change the friendship — the Cadence, and this Friend's own reminder. It is the
screen the User reads on the way to a coffee and writes on the way home.

**Settings.** The Profile's own options, in three groups: reminders, privacy, and the Profile
itself. Nothing here touches a Friend.

The three screens share one write path. Every change goes through `FriendRepository` to the `Friend`
aggregate, so the rules that span rows hold in one place and the reminder reschedules once.

## User Stories

### Naming a new Friend

1. As a User with an empty roster, I want to add my first Friend, so that the app has something to
   draw.
2. As a User, I want to type a Friend's name and nothing else to be required beyond a date and a
   Cadence, so that adding somebody takes seconds.
3. As a User, I want the name stored exactly as I wrote it, so that a rule about searching never
   changes how a person's name appears.
4. As a User whose Friend's name carries a stroke or an accent, I want to find them later by typing
   plain letters, so that adding them costs me nothing at search time.
5. As a User, I want a Friend with no name to be refused, so that the roster never holds a card that
   names nobody.
6. As a User, I want leading and trailing spaces trimmed from a name, so that two taps of the space
   bar do not make a second person.
7. As a User adding somebody who shares a name with a Friend I already have, I want the app to
   accept it, so that my two friends called Anna both exist.
8. As a User, I want to see the Avatar the app will draw for this Friend while I type, so that the
   card I get is the card I expected.
9. As a User, I want every Friend to get an Avatar without me finding a picture, so that adding
   somebody is never blocked by a photo I do not have.
10. As a User, I want two Friends never to be given the same Avatar, so that the Dial stays
    readable.

### Saying when I last saw them

11. As a User, I want to be asked when I last saw this Friend, so that the app places them correctly
    from the first moment.
12. As a User adding somebody I saw today, I want today to be the default, so that the common case
    is one tap.
13. As a User adding somebody I have not seen for two years, I want to enter that date, so that the
    app tells me the truth about them instead of a flattering guess.
14. As a User, I want the field worded so that I understand it records a Meeting, so that I do not
    accept a default that says something untrue.
15. As a User, I want a future date refused, so that the app never holds a plan disguised as a
    Meeting.
16. As a User, I want to see what my chosen date means for this Friend before I save, so that an
    Overdue Friend on day one is a thing I chose and not a surprise.
17. As a User, I want the date I pick to be a calendar day with no time and no zone, so that flying
    to another country does not change when I last saw somebody.
18. As a User, I want to add a time of day to that first Meeting if I want one, and to leave it out
    if I do not, so that the app records what I know and does not ask for what I do not.

### Choosing a Cadence

19. As a User, I want to say how often I want to see this Friend, so that the app can tell me when
    they are next due.
20. As a User, I want presets for the three Orbits, so that I do not have to invent a number for
    every person.
21. As a User, I want each preset to say who it is for in plain words, so that I can choose without
    knowing what an Orbit is.
22. As a User, I want a custom number of days, so that a Friend I see every ten days is not forced
    into seven or thirty.
23. As a User, I want a Cadence of zero or fewer days refused, so that the app cannot hold a Friend
    it can never place.
24. As a User, I want to see the Due Date and the Standing that each Cadence would give, before I
    choose, so that I understand the consequence rather than discover it.
25. As a User, I want to know which Orbit a Cadence puts a Friend on, so that the Dial holds no
    surprise when I get there.
26. As a User, I want the preset that matches my custom number to read as chosen, so that 30 typed
    by hand and 30 tapped as a preset are one state and not two.

### What I already know about them

27. As a User, I want to write the Topics I already want to raise, so that the first Meeting after
    adding somebody is not a blank page.
28. As a User, I want to record their birthday, so that the app can hold the day I always forget.
29. As a User, I want to record a Milestone that is not a birthday, so that the day we met is
    somewhere.
30. As a User, I want to say whether a Milestone returns every year, so that a birthday and a
    one-off day are told apart.
31. As a User, I want to record Facts such as where they live or what they drink, so that I write
    down the small things I keep forgetting.
32. As a User, I want to choose the label on a Fact myself, so that the app never asks me to fit a
    person into its own fields.
33. As a User, I want to give a Friend Affinities, so that I can later find everybody I know through
    one thing.
34. As a User, I want to add an Affinity the app has never seen, so that my own words are available.
35. As a User, I want an Affinity I invent to be offered for every other Friend afterwards, so that
    I only spell it once.
36. As a User, I want all of this to be optional, so that adding a Friend never becomes a form I
    give up on.

### Saving a new Friend

37. As a User, I want one clear action that saves the Friend, so that I am never unsure whether it
    worked.
38. As a User, I want the save refused with a clear reason when something needed is missing, so that
    I know which field to fix.
39. As a User, I want a half-finished Friend never written, so that a failure part way through
    leaves no wreckage in my roster.
40. As a User, I want to be returned to where I came from after saving, so that adding a Friend from
    the empty Friends List leaves me looking at a list with one Friend in it.
41. As a User, I want the new Friend to appear on the Dial and in the list at once, so that nothing
    has to be reopened.
42. As a User, I want to abandon a half-typed Friend, so that opening the screen by mistake costs me
    nothing.
43. As a User who abandons a half-typed Friend, I want to be asked first, so that a mis-tap does not
    throw away five minutes of typing.

### Reading a Friend before a Meeting

44. As a User about to see somebody, I want one screen holding everything I know about them, so that
    I read one thing and not five.
45. As a User, I want the Friend's name, Avatar, Orbit and real Cadence at the top, so that I know
    who and how often before I read anything else.
46. As a User, I want their Standing and how far through the Cadence they are, so that the screen
    agrees with the Dial I came from.
47. As a User, I want the Topics waiting for this Friend, so that I remember what I wanted to ask.
48. As a User, I want the Updates about their life, so that I do not ask about a job they left.
49. As a User, I want Topics, Updates and Notes told apart on the screen, so that what I want to say
    and what I learned do not blur together.
50. As a User, I want the newest writing first, so that the freshest thing is the first thing.
51. As a User, I want their Facts visible, so that I remember the drink to order.
52. As a User, I want their Milestones and how far away each is, so that a birthday next week
    reaches me.
53. As a User, I want the last Meeting with its date and place, so that I remember the occasion.

### Writing about a Friend

54. As a User, I want to add a Topic, so that a thing I want to raise survives until I see them.
55. As a User, I want to add an Update, so that what changed in their life is written down while I
    remember it.
56. As a User, I want to add a plain Note, so that writing that is neither of those has a home.
57. As a User, I want to choose which of the three I am writing, so that the grouping stays true.
58. As a User, I want to change the label on something I already wrote, so that a Topic I have
    raised can become an Update.
59. As a User, I want to edit the words of anything I wrote, so that a typo is not permanent.
60. As a User, I want to delete anything I wrote, so that stale writing leaves when I decide it
    should.
61. As a User, I want the app to clear nothing by itself, so that logging a Meeting never destroys
    what I wrote about the person.
62. As a User who logs a Meeting by mistake, I want every Topic still there afterwards, so that one
    wrong tap costs one row and nothing else.
63. As a User, I want each piece of writing to carry the day I wrote it, so that I can tell an old
    Topic from a new one.

### Meetings

64. As a User, I want to log a Meeting from this screen, so that I can record a coffee while I am
    still reading about the person.
65. As a User, I want the Meeting to default to today, so that the common case is one tap.
66. As a User, I want to log a Meeting on an earlier date, so that a coffee I remember a week later
    still counts.
67. As a User, I want a Meeting on a future date refused, so that the app holds no plans.
68. As a User, I want to record where a Meeting happened, so that the place reaches the card
    afterwards.
69. As a User, I want to record how long it was and how it felt, so that the history says more than
    a date.
70. As a User, I want to write a recap of what was said, so that the next Meeting starts where this
    one ended.
71. As a User, I want every field beyond the date to be optional, so that logging a Meeting stays a
    one-tap action when I am in a hurry.
72. As a User, I want the Friend's place on the Dial to move as soon as I log a Meeting, so that the
    app agrees with what I just told it.
73. As a User, I want the full history of Meetings with this Friend, so that I can see the shape of
    the friendship and not only its last day.
74. As a User, I want to edit a Meeting I logged, so that a wrong date can be corrected.
75. As a User, I want to delete a Meeting I logged by mistake, so that a wrong tap is undoable.
76. As a User, I want the app to refuse to delete the only Meeting a Friend has, so that I cannot
    leave a Friend the app can no longer place.
77. As a User who deletes the newest Meeting, I want the Friend to fall back to the one before it,
    so that the Dial stays correct without me doing anything.

### Changing the Cadence

78. As a User, I want to change how often I see a Friend, so that the app follows the friendship as
    it changes.
79. As a User, I want to see what the new Cadence gives before I commit, so that I am never
    surprised by the result.
80. As a User, I want to be told plainly when a shorter Cadence will make this Friend Overdue at
    once, so that I choose it knowing what it means.
81. As a User, I want no dialog asking me to confirm, so that the app never teaches me that Overdue
    is an error.
82. As a User, I want a change of Cadence never to alter when I last saw somebody, so that a
    recorded day stays a recorded day.
83. As a User, I want a change of Cadence to be reversible, so that setting it back returns every
    reading.
84. As a User, I want the Friend to move Orbit when the new Cadence crosses a boundary, so that the
    Dial and this screen agree.

### How a reminder follows a Friend

85. As a User with reminders on, I want a reminder on the day a Friend is due, so that the app
    speaks on the day it matters.
86. As a User, I want the reminder to name the Friend and say nothing else, so that my lock screen
    never shows what I wrote about them.
87. As a User who changes a Cadence, I want the reminder to move with it, so that the app never nags
    me about a Friend I saw yesterday.
88. As a User who logs a Meeting, I want the reminder to move with it, so that a Friend I have just
    seen does not remind me tomorrow.
89. As a User whose Friend is already Overdue, I want no reminder about a day that has gone, so that
    the app does not report the past as news.

### Removing a Friend

90. As a User, I want to delete a Friend, so that somebody I no longer track leaves the roster.
91. As a User, I want to be asked before a Friend is deleted, so that a mis-tap does not erase years
    of writing.
92. As a User, I want deleting a Friend to take everything about them, so that no orphan writing is
    left behind.
93. As a User, I want their reminder cancelled with them, so that a deleted Friend cannot send me a
    notification.

### Reminders in Settings

94. As a User, I want reminders off until I ask for them, so that the app does not demand a
    permission before it has earned one.
95. As a User, I want one switch that turns reminders on, so that the decision is in one place.
96. As a User, I want the permission asked for at the moment I turn reminders on, so that the prompt
    makes sense when it arrives.
97. As a User who refuses the permission, I want the switch to return to off and to be told why, so
    that the app never claims to be doing something it cannot do.
98. As a User who turned the permission off in the phone's own settings, I want the app to notice
    and say so, so that I am not waiting for reminders that cannot come.
99. As a User, I want to set how many days of warning I get by default, so that new Friends inherit
    a sensible number.
100. As a User, I want to know that a reminder never puts a Friend's name on my lock screen beyond
     what I would say aloud, so that reminders do not undo the lock.
101. As a User who turns reminders off, I want every pending reminder cancelled, so that off means
     off.

### Privacy in Settings

102. As a User, I want to set how long the app waits before it locks itself, so that the timer suits
     how I use my phone.
103. As a User, I want a short timer available, so that a phone that changes hands often is safe.
104. As a User, I want to lock the app now, so that I can hand the phone over without waiting for a
     timer.
105. As a User, I want to turn on unlocking with a fingerprint, so that I do not type six digits a
     dozen times a day.
106. As a User, I want the PIN to keep working when the fingerprint fails, so that wet hands never
     lock me out.
107. As a User, I want my biometric choice to apply to my Profile alone, so that my fingerprint
     never opens somebody else's.
108. As a User, I want to allow my own screenshots if I want them, so that the app's privacy is not
     also a wall around my own data.
109. As a User, I want to be told plainly what allowing screenshots costs, so that I choose it
     knowing the task switcher will show my notes.

### The Profile in Settings

110. As a User, I want to see which Profile I am in, so that a shared phone never leaves me
     guessing.
111. As a User, I want to rename my Profile, so that the name on the lock screen is the one I want.
112. As a User, I want to switch to another Profile, so that I can hand the phone to the person I
     share it with.
113. As a User who switches, I want my own Profile closed before the other one opens, so that one
     Profile is readable at a time.
114. As a User, I want the app to state that a forgotten PIN loses the Profile, so that the one
     unrecoverable fact is not a surprise.
115. As a User, I want to know that nothing here leaves the phone, so that the promise is stated
     where I would look for it.

### Time passing, and privacy

116. As a User who leaves the Notepad open past midnight, I want the Standing and the day counts to
     follow, so that the screen does not hold yesterday's answer.
117. As a User who returns after a week, I want every screen correct on arrival, so that nothing has
     to run in the background to keep it true.
118. As a User whose Profile locks while I am writing, I want what I typed not to be written, so
     that the lock is a lock.
119. As a User whose Profile locks, I want the Notepad to hold no name, no Topic and no Meeting, so
     that nothing private is drawn behind the PIN screen.
120. As a User whose Profile locks, I want a half-typed Friend cleared, so that the phone keeps no
     draft about a person.
121. As a User who unlocks again, I want the screen to come back with fresh data, so that I do not
     have to leave it and return.
122. As a User, I want a locked screen to look different from a Friend with nothing written about
     them, so that the app never tells me a page is empty when it is only closed.

## Implementation Decisions

### One feature holds both Friend screens, and `features/journal/` is not built

[docs/architecture.md](../architecture.md) sketches two feature folders where this spec needs one:
`friends/` for "Add, edit, delete people" and `journal/` for "Meetings, notes, topics, what is new".
The Notepad is both of those on one screen. It draws the Cadence and it draws the Meetings, and a
feature may not import another feature.

The Cadence picker settles it. Add a Friend needs one and the Notepad needs one, and it is the same
picker: [ADR-0032](../adr/0032-a-cadence-change-moves-the-due-date.md) requires it to show the Due
Date and the Standing that each Cadence would give. That widget reads `Cadence`, `Orbit`,
`dueDateOf` and `Standing`, so it cannot go in `friendo_ui`, which
[ADR-0018](../adr/0018-ui-package-and-widgetbook.md) forbids from importing the domain. Split the
two screens across two features and the picker has no legal home.

**So `features/friends/` holds Add a Friend and the Friend Notepad, and `features/journal/` is not
created.** The picker is one widget inside one feature, used twice.

This contradicts an illustration in
[ADR-0022](../adr/0022-one-repository-per-aggregate.md), which names three features by way of
showing that none imports another:

> `features/dial/`, `features/friends/` and `features/journal/` all depend on `core/friends/` and
> never on each other.

That sentence is an example of the rule, not the decision the record makes. Its decision is that a
repository lives in `core/`, and this spec keeps it exactly. Merging two feature folders leaves the
rule stronger, because the import that would have broken it now cannot be written. No record is
reopened. If a reader disagrees, [ADR-0019](../adr/0019-correcting-and-partly-superseding-a-record.md)
sets the process.

### Creating a Friend is one call, and it carries the first Meeting

[ADR-0022](../adr/0022-one-repository-per-aggregate.md) already named the constructor:

> `Friend.started(...)` makes a new one, and it takes the first Meeting, because
> [ADR-0016](../adr/0016-derive-lastmet-from-meetings.md) says a Friend cannot exist without one.

The screen collects a name, a Civil Date, a Cadence and whatever else was typed, and hands the lot
to the repository in one call. The repository writes it in one transaction.

**A Friend and their first Meeting are written together or not at all.** A failure between the two
rows would leave a Friend that `lastMet` cannot be worked out for, which is exactly the state
ADR-0016 removed rather than handled. One transaction makes the bad state unreachable instead of
recoverable.

The screen never writes a Friend and then writes a Meeting. Two calls would put the rule in the
bloc, and ADR-0022 moved it out of there on purpose.

### The last-seen field says that it records a Meeting

ADR-0016 accepted one cost and asked for one mitigation:

> Creating a friend writes a meeting the user may not have thought about. A user who accepts the
> default without reading it records a meeting that did not happen. Word the field clearly.

The field is labelled as the day the User last saw this Friend, it defaults to today, and it states
in words that saving records a Meeting on that day. It is not called *start date* and not called
*added on*, because both of those are true of a row and untrue of a friendship.

Beside it, the screen shows what the chosen date gives once a Cadence is picked: the Due Date and
the Standing. A User adding somebody they have not seen for two years sees `Overdue` before they
save, and that is the honest reading ADR-0016 argued for.

The date accepts today and any earlier day. A later day is refused, because
[ADR-0016](../adr/0016-derive-lastmet-from-meetings.md) says a future date is a plan and the app
holds no plans. The same rule governs every Meeting the Notepad writes, so it belongs to the
aggregate and not to either screen.

The time of day is optional, exactly as [ADR-0021](../adr/0021-civil-date-time-model.md) allows. It
is shown where it was set and it never reaches the Dial.

### One Cadence picker, and it shows the result before the User commits

The picker is the same widget on both screens, and ADR-0032 fixes what it does:

> Beside each Cadence the picker shows what that Cadence gives: the Due Date and the Standing, for
> example `Due 13 days ago · Overdue`. The User reads the consequence and then chooses.

It takes the Friend's last Meeting date and a `now`, and for each Cadence on offer it works out the
Due Date and the Standing through the domain. Nothing is stored and nothing is written until the
User saves.

**There is no confirmation dialog, on either screen.** ADR-0032 rejected one by name, and the reason
holds at creation too: a dialog on the Overdue case only would teach the User that Overdue is an
error, which contradicts the first product principle.

**The presets are three, and the fourth control is a number.** The three are the Orbits: an inner
preset, a middle preset and an outer preset. The custom control takes whole days.
[docs/feature-backlog.md](../feature-backlog.md) records the conflict — one design shows 7/30/90 and
another shows 7/14/30/60 — and this spec picks the shorter list, because a preset per Orbit is the
only list that stays true when
[ADR-0008](../adr/0008-cadence-as-duration.md) tunes the boundaries.

**The preset day counts come from the domain, and the thresholds never appear here.** Each Orbit
already knows its Cadence day range;
[docs/spec/friends-list.md](friends-list.md) added that. A preset is the value that range
recommends, so the numbers 14 and 60 stay in one file, which is what ADR-0008 promised:

> Changing the orbit boundaries is a one-line change. It touches no stored data and needs no
> migration.

A typed number that falls in a preset's Orbit shows that preset as chosen. The picker holds one
value, a `Cadence`, and the presets are three ways of setting it rather than a second piece of
state. `Cadence.ofDays` already refuses zero and below
([ADR-0027](../adr/0027-domain-value-objects-and-equality.md)), so the screen validates the typed
number by building one and reporting the failure, and no second rule is written.

### The Avatar is generated, and no picture is stored in v1

Both existing screens already decided this. [docs/spec/dial.md](dial.md) draws an initial and a
colour from the Friend id, and [docs/spec/friends-list.md](friends-list.md) put Avatar photos out of
scope with the reason:

> An Avatar is a BLOB column, and a hundred of them would be read to draw a list that shows each
> one at 40 units across.

Add a Friend therefore shows the generated Avatar while the User types, and offers no picture
picker. The seed is the Friend id, so the Avatar is settled before the name is finished and never
changes afterwards.

A picture is real work and it is listed as such: capture, a downscale to 512 px, a permission, and a
BLOB read on every screen that shows one.
[docs/feature-backlog.md](../feature-backlog.md) holds all four. None of it is needed to add a
Friend.

### Affinities are chosen from a set, and a new one joins the set

An Affinity has its own table because the Friends List searches it, and two spellings of one label
are a defect there ([docs/feature-backlog.md](../feature-backlog.md)). So the screen offers the
labels that already exist, and typing a new one writes a new row that every other Friend can then be
given.

**The folded copy is written by the repository, in the same statement as the label.**
[ADR-0033](../adr/0033-fold-the-text-that-search-matches.md) and
[docs/spec/friends-list.md](friends-list.md) both put the fold in `core/`, beside the write, and
keep it out of the aggregate. This spec adds no second caller: the Friend's name and the Affinity
label are folded on the way to the database by the same function the search uses, and neither screen
knows the fold exists.

**An Affinity does not set a Cadence.** The backlog is explicit, and the design invites the mistake
by naming its Affinities *Family* and *Close Friend* beside a Cadence picker. Two Friends tagged
*Family* hold whatever Cadence the User gave them.

**A Fact needs no table and no fixed label.** The User writes both halves. To offer labels they have
used before, read the distinct labels already stored. The backlog settled this and this spec adds
nothing to it.

### Nothing half made, and a draft dies with the lock

The screen holds what the User has typed in its own state and writes none of it until they save.
There is no draft row and no partial Friend, which is the same promise
[docs/spec/first-run.md](first-run.md) makes about a Profile.

Leaving the screen with anything typed asks first. Leaving it with nothing typed does not, because
a question about nothing is noise.

**A lock clears the draft without asking.** The lock is not a moment to hold a question open over a
screen that is about to be covered, and a half-written Friend is exactly the private text
[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) hides from a borrowed phone. The User loses
what they typed. That is the cost of the lock and it is the right way round.

### The Notepad loads the aggregate, and the Friends List row does not

[ADR-0022](../adr/0022-one-repository-per-aggregate.md) draws the line by what a screen does:

> A read that only draws does not load the aggregate.

The Notepad writes. It adds a Meeting, edits a Note, changes the Cadence and deletes a Milestone, so
it loads the whole `Friend` and saves the whole `Friend`. That is the shape the record asks for, and
it is the opposite of the Friends List row, which draws and takes a read model.

**No attachment is built here, and the rule for when one is stands.** An Avatar picture and an audio
recap are both BLOB columns ([ADR-0026](../adr/0026-attachments-as-blobs-and-a-framed-backup.md)),
and neither is in this spec. The rule that governs them is worth stating where the load is written:
a Friend with forty Meetings would pull forty recordings to draw a list of dates, so an attachment
is read on its own and never with the aggregate.
[docs/feature-backlog.md](../feature-backlog.md) holds it. A Meeting's written recap is a text
column and is loaded with the rest.

### Topic, Update and Note are one record, one editor, and one label

[ADR-0017](../adr/0017-note-kinds-are-labels.md) is the whole design:

> Keep Topic, Update, and Note as **labels** on one kind of record. The label changes how the app
> groups and filters. It changes nothing else.

So there is one editor. It takes text and a label. Changing a Topic into an Update writes one field
and moves the record between two groups on the screen. There is no conversion, because there is
nothing to convert.

The screen groups the three and sorts each newest first, which is the sort ADR-0017 chose to keep
the stale tail out of the way.

### The app clears nothing, and the done mark is deliberately not built

ADR-0017 says it twice, and names the change somebody will propose again:

> **The app never clears, archives, or hides a note by itself.** The owner deletes what has gone
> stale.

Logging a Meeting from the Notepad therefore writes one Meeting and touches no Topic. That is a test
in this spec, not a comment in the code, because it is the exact behaviour a later reader will
"improve".

[docs/feature-backlog.md](../feature-backlog.md) holds a `resolved_on` column, and the design draws
a tick and a count of *3 active*. **This spec does not build it**, and the reason is ADR-0017's own
ordering:

> Sort topics newest first, so the stale tail sinks out of the way. If the growing list becomes a
> real complaint, revisit this record. Add a manual tick before you add anything automatic.

The complaint is the trigger, and no Profile has yet held a Topic long enough to make one. The User
who wants a Topic gone can delete it today. When the mark lands it adds one column and one
condition, and [docs/spec/friends-list.md](friends-list.md) is already written so that *waiting*
becomes *not marked done* by that one condition.

### A Meeting can be corrected, and the last one cannot be removed

The history shows every Meeting, newest first, with its Civil Date, its optional time, its place,
its length, how it felt and its recap. All but the date are optional, so logging a Meeting stays one
tap and the rest can be filled in later.

Editing a Meeting is an edit of the aggregate. Moving a date moves `lastMet` when that Meeting is
the newest one, and moves nothing when it is not, because `lastMet` is `max` over the dates and the
`max` does not care which row changed. ADR-0016 chose the rule for exactly this:

> The order you enter meetings no longer matters. `max` gives the same answer either way.

**Deleting the only Meeting is not refused at run time. It is unreachable.** ADR-0022 states the
shape:

> `deleteMeeting` cannot produce an invalid Friend, because the method that would do it does not
> exist. The rule becomes unreachable rather than guarded.

So the aggregate owns this, `friendO-xdb` builds it, and the Notepad's part is to draw the delete
control as unavailable on a Friend with one Meeting and to say why. The screen never re-implements
the rule. It reports it.

Deleting the newest Meeting falls back to the one before, and every reading follows on the next
read. Nothing recalculates, because nothing was stored.

### Changing the Cadence writes one field, and the reminder follows

The Notepad's tuner is the picker from Add a Friend, over this Friend's real last Meeting date, so
the preview shows this Friend's real result. Saving writes the Cadence and nothing else.
ADR-0032 is explicit that the last Meeting does not move, and this is the screen where a well-meant
"keep the Phase" edit would be written.

Three results follow the save, all of them ADR-0032's, and none of them a special case here: the
Friend may become Overdue at once, may stop being Overdue at once, and may change Orbit. The screen
draws whatever the next read gives.

**The reschedule is not this screen's work.** [ADR-0012](../adr/0012-opt-in-local-notifications.md)
requires one on every change to `lastMet` or `cadence` and names the failure honestly:

> A missed path causes a wrong reminder, and that bug is hard to notice.

ADR-0022 answered it with one owner and one write path to hook. So the Cadence write goes through
the repository, and `core/reminders/` reacts to it. The Notepad calls no scheduler.

### Deleting a Friend takes everything, and asks first

A Friend owns their Meetings, Notes, Facts, Milestones and Affinity links
([ADR-0022](../adr/0022-one-repository-per-aggregate.md)), so deleting the root deletes all of them
in one transaction. The Affinity labels themselves survive, because they belong to the Profile and
not to one Friend.

It asks first. This is the one action in the app that destroys writing the User cannot get back, and
it is the opposite case from a logged Meeting, where ADR-0017 guarantees that a mis-tap costs one
row.

The pending reminder is cancelled with the Friend, by the same owner that schedules it.

### One `now` builds one screen

Every reading on one build of the Notepad takes the same `now`, read once from `core/time/`. Two
reads could fall on either side of midnight, and the header would then disagree with the history
below it. This is the rule [docs/spec/friends-list.md](friends-list.md) set, and it holds here for
the same reason.

The midnight announcement in `core/time/` re-reads the Notepad exactly as it re-reads the other two
screens. Nothing polls and nothing ticks.

### Where a setting lives, and the one that cannot go with the others

Settings split across two stores, and the rule that decides which is short.

**A setting the lock screen must read before anything is unlocked goes in `profiles.json`.
Everything else goes in the encrypted database.**

That puts exactly one setting in the plaintext file: whether this Profile has enabled biometric
unlock. [ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) requires it:

> The biometric prompt names the profile it unlocks. One finger cannot choose between two profiles,
> so the user picks the profile first and authenticates second.

The PIN screen has to know whether to offer a fingerprint for the Profile the User just picked, and
at that moment no database is open. A flag in the database could only be read after the unlock it
was meant to offer.

It is a safe thing to leave in the clear. It says that a Profile uses a fingerprint. It is not a
credential, it opens nothing, and [ADR-0024](../adr/0024-keystore-holds-a-wrapping-key.md) keeps the
wrapping key in hardware whatever this file says. `profiles.json` already holds a display name and
KDF parameters, so this adds a boolean to a shape that is already public by design.

Everything else — the reminder switch, the reminder hour, the auto-lock timer and the screenshot
allowance — is read only while the Profile is open, so it goes in the database and is encrypted like
the rest.

**The store lives in `core/settings/`, not in `features/settings/`.** Two things below the feature
layer read these values: `core/security/` reads the auto-lock timer and `core/reminders/` reads the
switch and the hour. Neither may import a feature. The feature draws the screen and owns nothing.

**A setting is written through the same connection owner as everything else**
([ADR-0025](../adr/0025-one-owner-for-the-database-connection.md)), so a write while locked throws
and a watch goes quiet, with no second rule for preferences.

**While the Profile is locked, the app behaves as though every unread setting is at its safest
value.** The screenshot allowance is in the database, so the PIN screen cannot read it and is always
secure. That is the correct default and not a limitation.

### The reminder switch earns the permission, and off means off

[ADR-0012](../adr/0012-opt-in-local-notifications.md) ships reminders off and gives the reason:

> Off by default means no permission prompt on first launch. The app earns the prompt later.

So the switch is off in a new Profile, and the permission is requested at the moment the User turns
it on. **The switch follows the permission, not the intention.** A refused permission returns the
switch to off and says why, because a switch that reads *on* over a system that will deliver nothing
is a lie the User has no way to detect.

The app re-reads the permission on every resume. A User who turns notifications off in the phone's
own settings comes back to a switch that says off, with one line explaining where it went. Nothing
is re-requested on its own.

**The reminder carries a name and nothing else.** ADR-0012 fixes the text:

> Keep the notification text vague. Use "Time to catch up with Anna". Never put note content on the
> lock screen.

No Topic, no place, no recap and no count. This is the same promise
[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) makes about the task switcher, and a
notification is the one part of this app that draws outside its own lock.

**The hour is a setting, and there is no lead time.** ADR-0012 says to schedule from the Friend's
Due Date, and the Due Date is a Civil Date with no time in it, so an hour has to come from
somewhere. It is one Profile-wide choice. A reminder that arrives on the Due Date is not late: that
is the day the Meeting is wanted, and [ADR-0021](../adr/0021-civil-date-time-model.md) makes the
Friend not Overdue until the day ends.

**Turning the switch off cancels every pending reminder.** Leaving them scheduled would deliver a
notification from a feature the User has turned off, which is the fastest way to be muted.

### `core/reminders/` owns the schedule, and no screen calls it

The scheduler watches two things: the repository, and the reminder settings. From them it works out
what should be pending, and it makes the system agree.

It is the only place that talks to `flutter_local_notifications`. That is ADR-0022's answer to
ADR-0012's hardest sentence, and it is the reason the Notepad, Add a Friend and Settings all write
through the repository and then stop.

Four rules it owns, each from a record:

- **Reschedule on every change to `lastMet` or `cadence`** ([ADR-0012](../adr/0012-opt-in-local-notifications.md)).
  Because it watches the repository rather than being called, a new write path cannot forget it.
- **A Due Date in the past schedules nothing** ([ADR-0032](../adr/0032-a-cadence-change-moves-the-due-date.md)).
  Cancel the old reminder and schedule no replacement. The Beads Queue and the Overdue banner
  already carry the Friend, and a notification about a day that has gone is noise.
- **Schedule only the nearest, and top up when the app opens** ([ADR-0012](../adr/0012-opt-in-local-notifications.md)).
  iOS allows 64 pending local notifications and the product allows about 100 Friends. The nearest
  Due Dates are scheduled and the rest wait. The top-up is not a background job; the app has to be
  open, which is the platform limit ADR-0012 accepted.
- **Initialise the `timezone` package before scheduling anything** ([ADR-0012](../adr/0012-opt-in-local-notifications.md)).
  A daylight-saving change moves a fire time, and the package handles it only when it is set up.

A deleted Friend's reminder is cancelled. A Profile that locks does not cancel anything: the
reminders belong to the Profile, and locking the app is not turning them off.

### The lock timer, the lock now, and the fingerprint

[ADR-0011](../adr/0011-app-lock-and-screen-privacy.md) accepted a cost and named the answer:

> A short lock timer annoys users who switch apps often. The timer needs a setting.

The setting is a choice from a short list of durations, defaulting to the 60 seconds ADR-0011 set.
It is read by `core/security/`, which owns the auto-lock, and this screen only writes it.

**Lock now is one control, and it is the same `lock()` the auto-lock calls.** It closes the
connection and drops the key ([docs/spec/boot-and-data.md](boot-and-data.md)). There is no second
mechanism, which is the same argument that record made about switching Profile.

**Biometric unlock is a switch that writes one flag, and the PIN never goes away.** ADR-0011 bounds
it in three sentences and this screen keeps all three: the PIN stays available, the prompt names the
Profile it unlocks, and each Profile enables it on its own. Turning it on confirms with the
operating system once, so that a User who has no enrolled fingerprint learns it here rather than at
the lock screen.

The unlock path itself is already built. [docs/spec/boot-and-data.md](boot-and-data.md) separated
the PIN check from the unwrap for this reason:

> A later biometric route confirms with the operating system and then reaches the same open step.

### Screenshots are the User's own data, and the cost is stated

ADR-0011 accepted this and deferred it:

> `FLAG_SECURE` also blocks the user's own screenshots. Some users will want them. Accept this, or
> add a setting later.

The setting defaults to secure. Turning it off says plainly what it costs: the task switcher will
show the screen, and screenshots and screen recording will work. That is the whole of ADR-0011's
first leak, offered as a choice.

It changes `FLAG_SECURE` on Android and the cover view on iOS together, because a User who allows
screenshots on one platform means the same thing on both. The PIN screen stays secure whatever this
says, as above.

### The Profile row, and the one fact that has no recovery

The screen names the Profile the User is in, because a shared phone should never leave that to
memory.

**Renaming writes `profiles.json`, atomically.** [docs/spec/first-run.md](first-run.md) fixed the
method — write a temporary file in the same directory, flush, then rename over the target — and a
rename is the only write this screen makes to that file besides the biometric flag.

**Switching Profile is `lock()` then `unlock()`**, which
[docs/spec/boot-and-data.md](boot-and-data.md) already built:

> Switching is `lock()` and then `unlock(otherId, pin)`. It is not a second mechanism.

This screen is the one that record called out of scope. It offers the list and makes one call. The
first file is closed and its key is gone before the second opens, which is what
[ADR-0007](../adr/0007-database-per-profile.md) promises.

**The screen states that a forgotten PIN loses the Profile.**
[ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md) settled that v1 has no way back, and a
fact that severe belongs where a User would look for it and not only on the day they made the
Profile.

Creating a second Profile is [docs/spec/first-run.md](first-run.md)'s path and this screen does not
draw it.

### Lock

All three screens obey the contract in [docs/spec/boot-and-data.md](boot-and-data.md). The bloc
clears on lock and does not throw, a watch goes quiet and stays subscribed, a write while locked
throws `DatabaseLockedError`, and locked is a different state from empty.

Two things are particular here:

- **A half-written Friend and a half-written Note are cleared, not held.** They are the private text
  ADR-0011 exists to hide, and a screen that came back with them would keep them in memory for as
  long as the phone was in somebody else's hand.
- **A Friend with nothing written about them is a real and calm state.** A new Friend has one
  Meeting and no Notes. That screen must not look like the locked one, which is
  [ADR-0025](../adr/0025-one-owner-for-the-database-connection.md)'s named failure applied to this
  screen.

### What draws what

The cards are `SoftCard`s, every field is a debossed `SoftWell`, the Cadence presets and the Note
labels are `Pill`s, and the save and log controls are `SoftButton`s. The Notepad's header uses
`AvatarHalo` and `Glow`. All six are treatments that already exist in `friendo_ui`.

**The Cadence picker and the Note editor are built inside the feature.**
[ADR-0018](../adr/0018-ui-package-and-widgetbook.md) sets the test:

> Build only what repeats. Six treatments now. The seventh earns its place when it appears twice.

Both are concepts rather than treatments, and both read the domain, which `friendo_ui` may not
import. The picker repeats across two screens inside one feature, which is what the merge above
makes possible.

The Notepad's Phase ring draws the same fraction as the Friends List's Phase bar in a different
shape. [docs/spec/friends-list.md](friends-list.md) already looked at this and declined to build a
shared treatment for it, because covering both shapes is a larger question than either screen. That
holds. Whatever draws the ring takes a fraction and a colour, and never a `Phase` or a `Standing`.

### What these screens do not own

**Routing.** `friendO-njf` holds the open question of `go_router` against the current cubit. These
screens produce requests — add a Friend, open this Friend, switch to that Profile — and whatever
routes them reads those values. This spec neither settles it nor depends on the answer.

**The reminder schedule.** `core/reminders/` owns it. Settings writes a switch and an hour, and the
two Friend screens write through the repository.

**The unlock path, the connection and the lock timer's mechanism.**
[docs/spec/boot-and-data.md](boot-and-data.md) owns all three. Settings writes one number and calls
two methods that already exist.

**The Friend aggregate's rules.** `friendO-xdb` owns them. These screens call them and report what
they refuse.

## Testing Decisions

### What a good test looks like here

It writes a Friend through the screen's own state, over a real repository on a real database, and
reads what the screen would show or what the database then holds. It names no column, no query and
no widget.

These are the writing screens, so the thing worth proving is what survives the write. A test that
asserts a bloc emitted a state after calling a mocked repository proves that the test's own script
ran. [ADR-0013](../adr/0013-testing-strategy.md) rejected both mocks by name, for both reasons:

> In-memory drift is fast enough and tests real behaviour. A mocked repository only proves the bloc
> calls the mock the way the test says it should.

Two properties make the tests read as examples, and both are already decided. `now` is an argument
everywhere, so nothing stubs a clock. The transaction is real, so "nothing half made" is a fact a
test can read out of the database rather than a promise about code.

### The seams

**Three screen states, on the seam the two existing specs already chose.** Add a Friend's state, the
Notepad's state and Settings' state, each a bloc over a real `FriendRepository`, over a real
in-memory drift database, with a fixed `now`. That is the shape
[docs/spec/dial.md](dial.md) and [docs/spec/friends-list.md](friends-list.md) both took, and the
reason is the same: the validation, the domain call, the write, the transaction and the lock all
meet in one place, and one test reads them together.

**One genuinely new seam: the scheduler in `core/reminders/`.** It sits over the same real
repository and the same real database, with a fake notification sink standing in for the platform.
It is the only new seam this spec adds.

**No new domain seam.** *Creation writes the first Meeting*, *a Meeting is dated today or earlier*
and *never leave a Friend with no Meeting* are the aggregate's rules
([ADR-0022](../adr/0022-one-repository-per-aggregate.md)), and `friendO-xdb` already owns testing
them with no database and no widget. This spec tests that the screens report those refusals, not
that the rules hold.

### Why the scheduler is a seam and not a set of screen tests

ADR-0012 names the failure this seam exists to catch:

> A missed path causes a wrong reminder, and that bug is hard to notice.

Prove reminders through the Settings screen and three rules have no home. The 64-notification top-up
is about a roster larger than any screen test would write. The reschedule on a Cadence change
happens on a screen that never calls the scheduler. ADR-0032's "a Due Date in the past schedules
nothing" is a rule about the *absence* of a notification, and absence is only readable where the
whole schedule is.

So the scheduler is tested where it lives: write Friends, change one, and read what the sink holds.
The screens are tested for what they write, and stop there.

### No golden, and no widget test on these screens

[ADR-0013](../adr/0013-testing-strategy.md) allows exactly one golden test and it is the Dial's.
These three screens are forms and lists, which is the case that record covered plainly:

> The rest of the app is forms and lists. Heavy testing there costs time and finds little.

A golden of a form breaks on every spacing change and proves nothing about what the form writes.

### Prior art

`packages/friendo_domain/test/` holds the shape for a pure test that reads as an example.
[docs/spec/dial.md](dial.md) and [docs/spec/friends-list.md](friends-list.md) hold the shape for a
bloc over a real repository with a fixed `now`. `test/navigation_cubit_test.dart` holds the existing
`bloc_test` setup. Nothing here needs a shape that does not already exist in this repository.

### What to test

Numbered so that a ticket can name one.

**Adding a Friend**

1. Saving a name, a date and a Cadence writes one Friend and exactly one Meeting.
2. The Meeting written at creation carries the date the User chose, not the day of the save.
3. The date defaults to today.
4. A future date is refused and the Friend is not written.
5. A blank name is refused, and a name of spaces alone is refused.
6. A name is stored with its leading and trailing spaces removed and its inner text untouched.
7. Two Friends may hold the same name.
8. A name with a stroke or an accent is stored as typed, and the Friends List finds it by its plain
   spelling.
9. A Cadence of zero days is refused, and so is a negative one.
10. A failure part way through the save leaves no Friend and no Meeting in the database.
11. A Friend added with a date two years ago reads as Overdue on the first read after the save.
12. A Friend added with today's date reads as Freshly Reset.
13. The new Friend appears in the Priority Order on the next read, with no reopening.
14. Affinities chosen at creation are linked to the Friend.
15. An Affinity typed for the first time is written once and is then offered for another Friend.
16. Two Friends given the same new Affinity share one row, not two.
17. Facts and Milestones written at creation are stored against the Friend.
18. A Milestone that repeats every year is told apart from one that does not.
19. A first Meeting given a time of day keeps it, and one given none stores none.

**The Cadence picker**

20. For each Cadence on offer, the preview's Due Date is the last Meeting plus that Cadence in whole
    days.
21. The preview's Standing is the one the domain gives for that Cadence at the fixed `now`.
22. A Cadence that puts the Due Date in the past previews as Overdue.
23. A typed number that falls in a preset's Orbit shows that preset as chosen.
24. The three presets fall one in each Orbit.
25. The picker holds one value: setting it by preset and typing the same number give one state.

**The Notepad**

26. The screen loads the Friend, their Meetings, Notes, Facts, Milestones and Affinities.
27. The screen loads every Meeting for the Friend, newest first.
28. A Note is written with its label, and appears in that label's group and no other.
29. Changing a Note's label moves it between groups and changes nothing else about it.
30. Editing a Note's text leaves its label and its date alone.
31. Deleting a Note removes it and touches nothing else.
32. Each group is sorted newest first.
33. Logging a Meeting writes one Meeting dated today and deletes no Note of any label.
34. Logging a Meeting moves the Friend's place in the Priority Order on the next read.
35. A Meeting may be logged on an earlier date, and a future date is refused.
36. A Meeting's place, length, feel and recap are optional and are stored when given.
37. Editing the newest Meeting's date moves `lastMet`.
38. Editing an older Meeting's date to something still older moves nothing.
39. Editing an older Meeting's date past the newest one moves `lastMet` to it.
40. Deleting the newest Meeting falls back to the one before it, and every reading follows.
41. A Friend with one Meeting offers no delete for it, and the aggregate has no method that would
    remove it.
42. Deleting a Friend removes their Meetings, Notes, Facts, Milestones and Affinity links.
43. Deleting a Friend leaves the Affinity labels themselves in place for other Friends.
44. One `now` builds the whole screen.

**Changing the Cadence**

45. Saving a Cadence writes that field and leaves every Meeting untouched.
46. A shorter Cadence that puts the Due Date in the past makes the Friend Overdue on the next read.
47. A longer Cadence ends an Overdue on the next read.
48. A Cadence crossing 14 or 60 days moves the Friend between Orbits.
49. Setting a Cadence back to its old value returns every reading, because nothing was overwritten.

**The scheduler**

50. With the switch off, no reminder is scheduled for any Friend.
51. Turning the switch on schedules a reminder for each Friend whose Due Date is ahead.
52. Turning the switch off cancels every pending reminder.
53. Changing a Cadence reschedules that Friend's reminder to the new Due Date.
54. Logging a Meeting reschedules that Friend's reminder.
55. A Cadence change that puts the Due Date in the past cancels the old reminder and schedules none.
56. A Friend already Overdue when the switch is turned on gets no reminder.
57. Deleting a Friend cancels their reminder.
58. With more Friends than the platform allows pending, only the nearest Due Dates are scheduled.
59. Opening the app tops the schedule up as earlier reminders pass.
60. A scheduled reminder's text carries the Friend's name and no Note, place or recap.
61. The reminder fires at the hour the setting holds.

**Settings**

62. A new Profile has reminders off.
63. A refused notification permission returns the switch to off.
64. A permission revoked outside the app is noticed on resume, and the switch reads off.
65. The auto-lock timer is written and read back, and defaults to 60 seconds.
66. Lock now closes the connection and the app reads as locked.
67. The biometric flag is written to `profiles.json` and not to the database.
68. `profiles.json` survives a rename with its other fields intact, and the write is atomic.
69. One Profile's biometric flag does not change another's.
70. The screenshot allowance is written to the database and not to `profiles.json`.
71. Switching Profile closes the first connection before the second opens.

**Lock and privacy**

72. A lock clears the Notepad's Friend, Notes and Meetings.
73. A lock clears a half-typed Friend on Add a Friend, and asks nothing first.
74. A lock clears a half-typed Note on the Notepad.
75. A locked Notepad and a Friend with nothing written about them are different states.
76. A write attempted while locked throws `DatabaseLockedError` on each of the three screens.
77. A watch goes quiet across a lock and delivers fresh data on unlock, with no resubscription.
78. Local midnight passing re-reads the Notepad, and a Friend who has become Overdue reads as
    Overdue.
79. A resume re-reads.
80. Leaving Add a Friend with text typed asks first, and leaving it with nothing typed does not.

`tool/lint.sh` and `tool/test.sh` both pass.

## Out of Scope

**Attachments.** No Avatar picture and no audio recap. Both are BLOB columns under
[ADR-0026](../adr/0026-attachments-as-blobs-and-a-framed-backup.md), and both carry work the
backlog already lists: a capture flow, a downscale to 512 px, a bitrate and length cap, a
microphone permission, and a read path that never joins them to a list. The Avatar is generated and
a Meeting's recap is written text.

**The done mark on a Topic.** Deliberately not built, for ADR-0017's own reason rather than for
cost. See the decision above.

**A per-Friend reminder, and a lead time.** One switch and one hour, for the whole Profile.
[ADR-0012](../adr/0012-opt-in-local-notifications.md) schedules from the Due Date and says nothing
about warning in advance, and the Due Date is already the day the Meeting is wanted. Both are second
axes and both are cheap to add later: a nullable column each.

**The daily digest.** ADR-0012 called it a good idea and deferred it, and named the trigger for
reconsidering it — the 64-notification limit starting to bite. It has not.

**Milestone reminders.** [docs/feature-backlog.md](../feature-backlog.md) says a Milestone does not
move a Bead and leaves the notification question open. It stays open. This spec stores Milestones
and shows them.

**The Backup.** `friendO-j74` holds it and calls it the first thing after v1. Settings does not draw
a row for it.

**Creating a Profile, and the guest Profile.** [docs/spec/first-run.md](first-run.md) owns creation.
The guest Profile is in the backlog with an open question about whether it survives a restart.

**Changing or resetting a PIN.** [ADR-0031](../adr/0031-a-forgotten-pin-loses-the-profile.md)
settled that v1 has no way back from a forgotten one. Changing a PIN the User still knows is a
different feature and it needs its own thought about the wrapped key.

**Importing from the phone's address book.** It would fill a roster quickly and it needs a
permission that [ADR-0003](../adr/0003-offline-only-no-internet-permission.md)'s promises would then
have to be re-argued around. Every Friend is typed.

**Editing an Affinity across every Friend.** Renaming a label, merging two, or deleting one from the
set. Adding a label is in scope; tidying the set is not.

**Searching inside the Notepad.** A Friend holds tens of Notes, not thousands. The Friends List
already searches Topics across the roster.

**Undo, beyond deleting a Meeting.** Deleting a Meeting is the undo for logging one, and it is the
case [ADR-0016](../adr/0016-derive-lastmet-from-meetings.md)'s rule already lives in. There is no
general undo stack.

**Routing, tablet and desktop layouts, pagination and caching.** The last two are refused by
[docs/architecture.md](../architecture.md) at this size, not merely deferred.

## Further Notes

### Two issues land before this one

`friendO-xdb` writes the Friend aggregate, and `friendO-fff` gives the open connection, the
repository contract and the lock. Draw both edges against the child that needs them, not against the
epic. An edge to the epic holds them blocked until every child closes.

This spec leans on `friendO-xdb` harder than its two neighbours do. The Dial and the Friends List
read the aggregate's results; these screens exercise its rules. `Friend.started`, the refusal of a
future date, and the absent method that would remove a last Meeting are all its work.

### This spec changes the module map in three places

[docs/architecture.md](../architecture.md) needs three edits when this lands:

| Change | Why |
|---|---|
| `features/journal/` is not built | The Notepad is both feature folders on one screen, and the Cadence picker has no legal home if they are split. See the decision above. |
| `core/settings/` is added | Two things below the feature layer read a setting, and neither may import a feature. |
| `core/reminders/` gains its contents | The map already names it. This spec says what it owns. |

The first also touches an illustration in
[ADR-0022](../adr/0022-one-repository-per-aggregate.md), and the decision above says why that is a
change to an example rather than to a record.

### Two records this spec is likely to owe

Neither is written yet, and neither blocks the work.

**Where a setting lives.** The split between the encrypted database and `profiles.json` is a rule
that a later reader will otherwise have to rediscover from one boolean. It has a clear test — can
the lock screen read it? — and a clear cost if it is got wrong, which is a preference leaking into
the one plaintext file on the phone.

**One feature for both Friend screens.** The argument is short and it sits against an example in
ADR-0022. A record would stop the merge being quietly reversed by somebody reading the module map.

Follow [ADR-0019](../adr/0019-correcting-and-partly-superseding-a-record.md) if either turns out to
contradict more than this spec claims.

### The schema is nearly all described already

[docs/feature-backlog.md](../feature-backlog.md) holds the Fact table, the Affinity table and its
link table, the Milestone table, the four extra Meeting fields and the folded columns. This spec
adds two things and no more:

- **A settings row per Profile**, in the encrypted database: the reminder switch, the reminder hour,
  the auto-lock seconds and the screenshot allowance.
- **A boolean in `profiles.json`**, for biometric unlock.

The `resolved_on` column the backlog lists is not added, because the mark that would write it is not
built.

### Four conflicts between the designs and the records

[docs/feature-backlog.md](../feature-backlog.md) holds the running table of these, and
[docs/spec/friends-list.md](friends-list.md) added five. These four are new:

| Item | The design | The record | What this spec does |
|---|---|---|---|
| Cadence presets | `7 / 30 / 90` on Add Friend, `7 / 14 / 30 / 60 / 90` on Friend Detail | The backlog's open item: pick one preset list | Three presets, one per Orbit, taken from the domain's own ranges |
| The last-seen field | Add Friend has none | [ADR-0016](../adr/0016-derive-lastmet-from-meetings.md) needs one | Add the field, and word it as a Meeting. The backlog already records this one |
| Affinity as Cadence | `Family`, `Close Friend` sit beside the Cadence picker and read as though they set it | The backlog: an Affinity does not set the Cadence | Two controls, and neither reads the other |
| The Topic tick | `3 active`, a done button and a dismiss button | [ADR-0017](../adr/0017-note-kinds-are-labels.md): a manual tick comes only after a real complaint | Not built. Delete serves the same User today |

The designs' decorative words are not used anywhere here. *Celestial Cadence Studio*, *Orbital
Frequency*, *Harmonic Timing*, *Initial Memory Bank* and *Gentle Celestial Nudge* all name things
[CONTEXT.md](../../CONTEXT.md) has plain words for.

### The one thing on these screens that cannot be tested from a screen

Every rule above is provable from a seam except one: that a reminder is *not* delivered. Test 55
reads an absence out of a fake sink, and a fake sink is not the platform. The iOS 64-notification
limit, a daylight-saving shift and a revoked permission all behave in ways only a device shows.
ADR-0012 accepted this when it accepted notifications at all, and the honest mitigation is to run
the reminder path on real hardware once before v1, not to add a test that cannot see the thing it
claims to check. `friendO-6gv` already records that the iOS build is never verified.
