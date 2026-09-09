# The Friends List

The second screen. It answers a different question from the Dial: not *who next*, but *where is
this person, and what do I owe them?*

The Dial draws the ranking. This screen reads the same ranking, spells it out in words, and lets
the User reach any Friend by typing a few letters. It is also where the Dial sends the User when an
Orbit is too full to draw.

It follows two records closely:

| Record | What it settles here |
|---|---|
| [ADR-0033](../adr/0033-fold-the-text-that-search-matches.md) | Search matches a Folded copy of the text. The fold is three steps and a table. |
| [ADR-0028](../adr/0028-priority-order-as-two-groups.md) | The ranking arrives as two groups. This screen reads both, and re-sorts neither. |

It obeys six more without adding to them:

| Record | What it holds here |
|---|---|
| [ADR-0008](../adr/0008-cadence-as-duration.md) | The Orbit is worked out from the Cadence. Nothing stores one, so nothing filters on a stored one. |
| [ADR-0015](../adr/0015-dial-overflow-treatment.md) | The Overflow Badge opens this screen, filtered to one Orbit. |
| [ADR-0017](../adr/0017-note-kinds-are-labels.md) | A Topic is a label on a record. The app never clears one. |
| [ADR-0021](../adr/0021-civil-date-time-model.md) | Overdue compares two Civil Dates. A Friend is not Overdue on their Due Date. |
| [ADR-0022](../adr/0022-one-repository-per-aggregate.md) | A row that only draws takes a read model. One repository owns the write. |
| [ADR-0029](../adr/0029-name-the-dial-counts.md) | The four Standings, and where their boundaries fall. |

It sits on top of [docs/spec/boot-and-data.md](boot-and-data.md), which gives it an open
connection, a repository contract and a lock. It sits beside [docs/spec/dial.md](dial.md), which
owns the drawing of the same ranking. It repeats neither.

## Problem Statement

The Dial answers one question well and refuses every other one.

**It cannot show everybody.** Three Orbits hold 59 Beads and the product allows about 100 Friends.
When an Orbit fills, the Overflow Badge stands in for the rest and names nobody. The User taps it
and has to arrive somewhere that can show all of them.

**It cannot be asked about one person.** A Bead carries an Avatar and no name. To find one Friend
the User must recognise a small circle, and recognition fails exactly when it matters: the Friend
the User has not seen for a long time is the one whose Avatar they look at least.

**It cannot say why.** A Bead near 12:00 says a Meeting is wanted. It does not say the last one was
28 days ago at a coffee shop, and it does not say that the User wanted to ask about the pottery
workshop. That is the writing the User came for, and the Dial has no room for a sentence.

**Search fails on the names it must not fail on.** The plain match in SQLite folds case for ASCII
and nothing else, and it never removes an accent. A User with a Friend called Michał types
`michal`, gets an empty list, and reads it as an empty roster. ADR-0033 measured this against the
build the app ships; it is not a worry, it is a result.

**Overdue can be missed on the Dial.** Overdue Beads stop at 12:00 and stack into the Beads Queue,
where three Friends and eleven Friends look much the same. The count is honest, and the picture is
not sharp. Nothing on the Dial says *Sarah, four days ago*.

## Solution

One screen, in four parts, top to bottom.

**The Overdue banner.** When any Friend's Due Date has passed, a band at the top names them in
Priority Order, oldest first, and carries a count. It has one button, *Review*, which returns the
list to the state where those Friends are the first thing on it. When nobody is Overdue the banner
is not there.

**The search field.** Debossed, as the design system asks. The User types, and the list narrows on
every keystroke. It matches a Friend's name, a Topic waiting for them, an Affinity they hold, and
the name of their Orbit. It matches in the middle of a word, so `farb` finds *Quinzelfarb*. It
matches through accents and strokes both ways, so `michal` finds *Michał* and `michał` finds
*Michał*.

**Four Orbit chips.** *All*, *Inner*, *Middle* and *Outer*, each with the count of Friends it would
show. They filter one axis, and one only.

**The list.** One card per Friend, in Priority Order, so the Friend to see next is the first card
and the Overdue Friends are above every other. Each card carries the Friend's name, their Orbit and
Cadence, their Standing in words, a Phase bar with a whole-day label, the date and place of the
last Meeting, the newest Topic still waiting, and one button that logs a Meeting with them today.

Searching narrows the list. Filtering narrows the list. Neither ever reorders it, because there is
one ranking in this app and both screens read it.

## User Stories

### Finding a Friend by name

1. As a User with more Friends than the Dial can draw, I want a list that holds every Friend, so
   that nobody is reachable only by luck.
2. As a User, I want to type a few letters and see the list narrow, so that I reach one person
   without scrolling past ninety.
3. As a User, I want the list to narrow as I type rather than when I press a key marked Search, so
   that I can stop typing as soon as I see the person.
4. As a User who half remembers a name, I want a match inside a word and not only at its start, so
   that typing `farb` finds *Quinzelfarb*.
5. As a User, I want the case I type to make no difference, so that `SARAH` and `sarah` find the
   same person.
6. As a User, I want to clear the search with one tap, so that I get the whole list back without
   deleting letter by letter.
7. As a User who types a character with a special meaning to the database, such as `%` or `_`, I
   want it treated as a letter I typed, so that the search does not quietly match everybody.

### Names that are not ASCII

8. As a User whose Friend is called Michał, I want `michal` to find him, so that the app works for
   the names in my own address book.
9. As a User whose Friend is called Michał, I want `michał` to find him too, so that typing the
   name correctly is never the wrong thing to do.
10. As a User whose Friend is called Zoë, I want `zoe` to find her, so that an accent is not a wall.
11. As a User whose Friend is called Straße, I want `strasse` to find her, so that a letter that
    stands for two is not a special case I have to remember.
12. As a User, I want the folding rule to be the same on both sides, so that the search never
    depends on which spelling I happen to use.
13. As a User, I want the app to show me the name as I wrote it, so that a rule about matching never
    changes how a person's name appears.

### Finding a Friend by what they are into, or what I owe them

14. As a User, I want to search the Topics waiting for a Friend, so that I can find the person I
    wanted to ask about Kyoto without remembering who it was.
15. As a User, I want to search Affinities, so that I can see everybody I know through climbing.
16. As a User, I want a Friend to appear once even when the term matches their name and two of their
    Topics, so that one person is one card.
17. As a User, I want to search by Orbit name, so that typing `inner` shows the Friends I see often.
18. As a User, I want an Affinity search to fold like a name, so that a label with an accent behaves
    like everything else.
19. As a User, I want search to stay fast while I type, so that the list never lags behind the
    keyboard.

### Filtering by Orbit

20. As a User, I want four chips for *All*, *Inner*, *Middle* and *Outer*, so that I can look at one
    band of my roster at a time.
21. As a User, I want each chip to carry a count, so that I know how many Friends are in each Orbit
    before I tap.
22. As a User, I want a filter and a search term to work together, so that I can search inside one
    Orbit.
23. As a User arriving from the Overflow Badge on the Dial, I want the list to open already filtered
    to that Orbit, so that I see the Friends the Dial had no room to draw.
24. As a User, I want the chips to hold one idea only, so that a filter never mixes "which Orbit"
    with "how late".
25. As a User, I want an Orbit chip to mean the same thing here as on the Dial, so that a Friend on
    the inner Orbit is on the inner Orbit in both places.
26. As a User, I want the filter to survive while I edit the search term, so that clearing a word
    does not also throw away the Orbit I chose.

### The Overdue banner

27. As a User with Friends I have let slip, I want a banner that names them, so that the fact
    reaches me in words and not only as a stack of Beads.
28. As a User, I want the banner in Priority Order, oldest Due Date first, so that it agrees with
    every other ranking in the app.
29. As a User, I want the banner to carry a count, so that I know the size of the problem when the
    names do not all fit.
30. As a User with nobody Overdue, I want no banner at all, so that a calm roster looks calm.
31. As a User, I want the banner to describe my whole roster and not the view I have filtered to, so
    that a filter can never hide the alarm.
32. As a User, I want a *Review* button that returns the list to where those Friends are, so that
    the banner is a way in and not only a notice.
33. As a User, I want a Friend to leave the banner as soon as I log a Meeting with them, so that the
    banner is never a list of things I have already done.

### Reading a card

34. As a User, I want each card to name the Friend, so that I never have to recognise an Avatar.
35. As a User, I want the card to say the Orbit and the real Cadence, so that "inner" does not hide
    the difference between every 7 days and every 14.
36. As a User, I want the card to name the Standing in the app's own words, so that the card and the
    Dial counts agree.
37. As a User, I want a Phase bar, so that I can see at a glance how far through the Cadence the
    Friend has travelled.
38. As a User, I want a whole-day label such as `28/30d`, so that the bar has a number beside it.
39. As a User, I want the date of the last Meeting and where it happened, so that I remember the
    occasion and not only the date.
40. As a User, I want the newest Topic still waiting, so that the card tells me what to raise.
41. As a User with several Topics waiting, I want to know how many there are, so that I can tell one
    from five without opening the Friend.
42. As a User, I want an Overdue card to be readable as Overdue without me reading the number, so
    that the worst case is the fastest one to see.

### Logging a Meeting

43. As a User, I want a button on each card that logs a Meeting with that Friend today, so that I
    can record a call I have just finished without opening anything.
44. As a User, I want that button to sit on the card that names the Friend, so that a mis-tap can
    never write a Meeting against the wrong person.
45. As a User who logs a Meeting, I want the card to move to its new place in the list, so that the
    ranking stays true while I look at it.
46. As a User who logs a Meeting by mistake, I want the app never to delete anything I wrote about
    that Friend, so that one wrong tap costs one row and nothing else.

### The order of the list

47. As a User, I want the list in Priority Order, so that the top of the list and the Dial's next
    Friend are the same person.
48. As a User, I want Overdue Friends above every other Friend, so that scrolling is never needed to
    find them.
49. As a User, I want a search to narrow the list without reordering it, so that the first result is
    still the most pressing one.
50. As a User, I want two Friends who became Overdue on different days to appear oldest first, so
    that the list answers "who slipped first".

### When nothing matches

51. As a User with no Friends at all, I want the screen to invite me to add my first one, so that an
    empty app tells me what to do next.
52. As a User whose search matches nobody, I want to be told that the search matched nobody, so that
    I do not read it as an empty roster.
53. As a User whose filtered Orbit holds nobody, I want to be told that this Orbit is empty, so that
    I know to try another chip.
54. As a User, I want each of those three to say something different, so that the screen never
    explains the wrong problem.

### Time passing

55. As a User who leaves the app open past midnight, I want a Friend who has become Overdue to
    appear in the banner, so that the screen does not hold yesterday's answer.
56. As a User who returns after a week, I want the list to be correct on arrival, so that nothing
    has to run in the background to keep it true.
57. As a User who changes a Friend's Cadence, I want their card, their Orbit and their place in the
    list to follow at once, so that the screen never disagrees with the Friend.

### Privacy

58. As a User whose Profile locks, I want the list to hold nothing, so that no name and no Topic is
    drawn behind the PIN screen.
59. As a User whose Profile locks, I want the search term I typed to be cleared, so that the phone
    does not keep the name of the person I was looking for.
60. As a User who unlocks again, I want the list to come back with fresh data, so that I do not have
    to leave the screen and return to it.
61. As a User, I want a quiet list during a lock to look different from a roster with no Friends, so
    that the app never tells me my roster is empty when it is only closed.

## Implementation Decisions

### The list is the ranking, and it is the ranking the Dial already draws

[ADR-0028](../adr/0028-priority-order-as-two-groups.md) names this screen in its own consequences:

> The Dial and the Friends List can take the whole ranking through `all`, or the Beads Queue on its
> own through `overdue`, without re-filtering.

The cards come out in the order `all` gives. Overdue Friends first, oldest Due Date first, then the
On Track Friends by highest Phase. Search removes members from that list. A filter removes members
from that list. **Neither ever sorts it.**

There is no relevance ranking. A term that has already cut a hundred Friends down to four gains
nothing from ordering those four by how well they matched, and it would cost the one thing this
screen is for: the first card is the Friend to see next, always, whatever is typed above it.

Two things fall out of this for free, and both are decisions that would otherwise need state:

- The Overdue Friends are already the first cards, so the banner needs no filter of its own.
- The top of this list and the Friend named on the Dial's log button are the same person, with no
  rule written anywhere to keep them in step.

### What a row reads, and what it must never read

A card draws; it applies no rule. So it takes a read model, as
[ADR-0022](../adr/0022-one-repository-per-aggregate.md) requires, and never a loaded aggregate.

One row carries: the Friend id, the name **as the User wrote it**, the Cadence in days, the Civil
Date of the newest Meeting, the optional time of that Meeting, its place, the newest waiting Topic,
how many Topics are waiting, and the Avatar seed.

Three things it must never carry:

- **Never a BLOB.** An Avatar is a BLOB column, and a hundred of them would be read to draw a list
  that shows each one at 40 units across. v1 draws an initial and a colour from the Friend id, which
  is what the Dial already decided. Attachment columns are read on their own screen and never here.
- **Never Folded Text.** ADR-0033 says it is never shown. A field that never leaves the query cannot
  be drawn by mistake, and no later reader has to be told the rule.
- **Never a Phase, a Standing or a Due Date.** Those are the domain's, worked out from the Cadence
  and the newest Meeting date. A column holding one would be a stored derived value, which
  [ADR-0009](../adr/0009-derived-phase-and-overdue-queue.md) refused.

So a card is two halves that meet in the view: the writing, from the query, and the ranking, from
`Placing`.

### One `now` builds the whole list

Every `Placing` on one build takes the same `now`, read once from `core/time/`. Two reads could fall
on either side of midnight, and then two cards on one screen would disagree about what day it is.

### The fold lives beside the rows it writes, not in the domain

The fold is a piece of `core/`. It is not a domain function, for two reasons.

The aggregate does not carry Folded Text. Folded Text is a property of a stored row, kept so that a
query can match it. A `Friend` in memory has a name; it has no reason to hold a second, uglier copy
of that name that nothing may display. Keeping it out of the aggregate also removes a whole class of
bug: nothing can save a Friend whose folded copy has fallen behind, because there is no field to
fall behind.

The two callers are both in `lib/`: the repository, which writes both columns in one statement, and
the search, which folds what the User typed. The root package already declares the `diacritic`
package, so the dependency is already where the work is.

### The fold is three steps in one order, and a test holds the table

From [ADR-0033](../adr/0033-fold-the-text-that-search-matches.md), unchanged:

```
fold(text):
  1. replace 'ß' with 'ss'
  2. lower case, over all of Unicode
  3. remove diacritics, from an explicit table
```

Step 1 comes before step 3 because the table maps `ß` to `s`, so without it `Straße` folds to
`strase` and `strasse` finds nobody. Step 3 needs a table because `Ł`, `Đ`, `Ø`, `Æ`, `ß` and `Þ`
are single code points with no accent to take off.

The eight pairs ADR-0033 measured are a test in this repository, not a comment. A letter that folds
wrongly is then a red test and not a report from the one User whose name holds it.

### Both sides fold, through the same function

The stored copy is folded on write. What the User types is folded on every keystroke. **The same
function does both.** A second implementation on the query side is the exact bug ADR-0033 exists to
prevent, and it would fail in only one direction, which is the hardest kind to notice.

### Escape the wildcards, and escape the escape first

The term is folded, then escaped, then wrapped:

```
escaped = folded.replace('\', '\\')
                .replace('%', '\%')
                .replace('_', '\_')
pattern = '%' + escaped + '%'          //  ... LIKE ? ESCAPE '\'
```

The order of the three replacements is not a style choice. A backslash escaped last would also
escape the backslashes the other two steps had just added. Without the escaping at all, a User who
types `a_b` matches `axb`, and a User who types `%` matches every Friend they have.

### Search is one statement of four arms, and never a join with an `OR`

Four arms produce Friend ids, and `UNION` folds them into one set:

```
name matches            -> friends, on the folded name
a Topic matches         -> notes,   on the folded body, where the kind label is Topic
an Affinity matches     -> affinities, on the folded label, through the link table
an Orbit name matches   -> friends, on the Cadence day range   (see below)
```

`UNION`, never `UNION ALL`. A Friend with three matching Topics is one Friend, and the set operation
says so once instead of the view de-duplicating afterwards.

The join form was measured at three to four milliseconds against the union's third of one, on the
same hundred Friends. The union is not chosen for speed — both are far under one frame — but a shape
that is ten times slower for no gain is not worth writing.

### No Orbit threshold is ever written in SQL

[ADR-0008](../adr/0008-cadence-as-duration.md) promises this:

> Changing the orbit boundaries is a one-line change. It touches no stored data and needs no
> migration.

A `CASE` over Cadence days inside the search would make it two lines, in two languages, with nothing
that fails when only one is edited. So the numbers 14 and 60 appear in the domain and nowhere else.

**The domain gains one small thing, and it is the only addition this spec asks of it:** each Orbit
knows the range of Cadence days that belongs to it, and `Cadence.orbit` is written in terms of that
range rather than beside it. The two cannot then disagree, which is the same argument ADR-0028 made
for holding the ranking as two groups.

With that in place:

- **The search's Orbit arm** compares the typed term against the three Orbit names in Dart, and
  binds the day range of each name that matched. The statement holds parameters, never thresholds.
- **The Orbit chips** filter in Dart, over the ranked list, using the domain's own `orbit`. The list
  is about a hundred rows and already in memory, which is the size
  [docs/architecture.md](../architecture.md) fixed the design around.

The arm and the chip are two shapes of one rule. A test pins them together at the boundaries, where
a copied threshold would first show.

### Search narrows the set; the chips narrow it again; nothing else happens

The term and the chip are two independent narrowings of one ranked list, and they compose in either
order with the same result. Editing the term never clears the chip. Tapping a chip never clears the
term.

### The chips are one axis, and each count says what its tap will do

Four chips: *All*, *Inner*, *Middle*, *Outer*.

**A chip's count is the number of Friends that tapping it would show, with the search term in
force.** With no term they are roster counts, and *All* carries the size of the roster. With a term
they are counts within the results, and *All* carries the number of results. A count that described
the roster while a term narrowed the view would promise three Friends and deliver one.

Two things in the design are not built:

- **The fifth chip, `Due Soon (2)`, is not one of these.** It mixes two axes: four chips would ask
  *which Orbit* and one would ask *how late*. It is also a banned word.
  [CONTEXT.md](../../CONTEXT.md) lists "due soon" under Nearing, and
  [docs/feature-backlog.md](../feature-backlog.md) already records that this count is Nearing under
  another name. Nearing has a home, on the Dial's counts. Overdue has a home, in the banner above
  these chips.
- **A chip does not carry a Cadence.** The design labels them `Inner • 7d`. An Orbit is a range of
  Cadences and not one Cadence, which is the whole of ADR-0008. A User whose closest Friend is on
  every 10 days would be told that the inner Orbit is 7 days. The chip carries the Orbit name and
  the count.

### The banner reads `overdue`, and re-derives nothing

The banner takes `PriorityOrder.overdue` and draws it in the order it arrives. It does not sort it.
It does not build it by filtering `all`.

ADR-0028 names the mistake this avoids:

> Every caller that wants the Beads Queue would repeat the same filter, and one of them would use
> `phase > 1` instead of the Due Date comparison, which ADR-0021 shows is a different question.

A Friend on their Due Date has a Phase above 1 and is not Overdue. `phase > 1` would put them in the
banner, and the app would tell the User they had missed somebody they have not missed. The banner is
never built from a Phase.

### The banner describes the whole roster, and *Review* returns the view to it

The banner is built from the ranking of every Friend, never from the filtered view. A filter is a
way of looking; it must not be a way of silencing.

That leaves one confusion to answer: the banner can name a Friend who is not among the cards below,
because a chip or a term has hidden them. *Review* answers it. It clears the term, sets the chip to
*All*, and returns to the top of the list — where those Friends already are, because the list is in
Priority Order. No Overdue filter exists, and none is needed.

The banner names as many Friends as fit and always carries the true count, so the number is right
even when the names run out.

### What a card says, in the words the glossary chose

| On the card | Where it comes from |
|---|---|
| The name | The row, exactly as the User wrote it |
| The Orbit, and the Cadence in days | The domain, from the Cadence |
| The Standing | The domain: Freshly Reset, In Orbit, Nearing, Overdue |
| The Phase bar and its label | See below |
| The last Meeting: its Civil Date, its place | The row |
| The newest waiting Topic, and how many wait | The row |
| One button that logs a Meeting today | See below |

The Cadence in days sits beside the Orbit on purpose. ADR-0008 accepted that a User who reads an
Orbit as an exact value is slightly wrong, and said the real number belongs on a screen. This is
that screen.

The time of a Meeting is shown only when the User set one, which is the row
[docs/feature-backlog.md](../feature-backlog.md) already holds against
[ADR-0021](../adr/0021-civil-date-time-model.md).

Three phrases in the design are not used. *Drifting* is a banned word for Overdue. *Reset 2d ago (On
Track)* mixes a Standing with On Track, which covers three Standings and is not one. *No souls in
this orbit* is decorative, and the User is looking for a Friend.

### The bar is the Phase, the label is whole days, and one rule makes both

The bar fills by Phase and clamps when full. The label reads `28/30d`: the numerator is the number
of whole days from the last Meeting to today, and the denominator is the Cadence in days.

**The numerator comes from Civil Date arithmetic, never from the Phase.** ADR-0021 makes Overdue a
comparison of two Civil Dates, and it makes Phase a fraction that carries the hours since local
midnight. Take the label from the Phase and round it, and a Friend resting on their Due Date can
read `29/30d` beside a Standing that says the day has not passed. The label and the Standing then
disagree on one card, which is the failure ADR-0029 rejected day counts to avoid.

An Overdue Friend's label passes the Cadence — `33/30d` — and the bar stays full. That is the
honest reading and it needs no special case.

### One tap logs a Meeting, from the card that names the Friend

The button writes a Meeting with that Friend, dated today. It sits on the card, so the Friend is
named on the same surface as the button, and a mis-tap writes against a person the User can see.

The write goes through the aggregate, because "creation writes the first Meeting" and "never leave a
Friend with no Meeting" are the aggregate's rules
([ADR-0022](../adr/0022-one-repository-per-aggregate.md)). The reminder reschedule follows the write
and belongs to the repository, not to this screen
([ADR-0012](../adr/0012-opt-in-local-notifications.md)). A write while the Profile is locked throws,
per [docs/spec/boot-and-data.md](boot-and-data.md).

Nothing is deleted. [ADR-0017](../adr/0017-note-kinds-are-labels.md) is explicit that logging a
Meeting clears no Topic, and it names this as the change somebody will propose again.

After the write the watch stream emits, the ranking is rebuilt, and the card moves to its new place.
The screen holds no state that has to be told.

### The newest waiting Topic, and a count when more wait

ADR-0017 sorts Topics newest first and lets the list grow without limit. The card therefore shows
one Topic and a count, not a paragraph: the newest is the one the User most recently decided
mattered, and the count says whether there is more to read.

While no Topic can be marked done, every Topic is waiting. When the done mark in
[docs/feature-backlog.md](../feature-backlog.md) lands, *waiting* means *not marked done*, and this
card changes by one condition and nothing else.

### Three empty states, and a locked screen is not one of them

| State | What the screen says |
|---|---|
| The roster is empty | Invite the User to add their first Friend |
| A term matched nobody | Say that the search matched nobody, and offer to clear it |
| A filtered Orbit is empty | Say that this Orbit is empty, and offer *All* |
| The Profile is locked | None of the three |

The first three exist because each has a different next action, and a screen that offers the wrong
one is worse than a screen that offers none. The fourth is
[ADR-0025](../adr/0025-one-owner-for-the-database-connection.md)'s rule, and that record names this
screen as the place it goes wrong: a quiet stream read as an empty result draws an empty Friends
List behind the PIN screen.

### When the list recomputes, and where the midnight timer belongs

The same four triggers the Dial has: the watch stream emits, the app resumes, the Profile unlocks,
and local midnight passes while the screen is open. Nothing polls, and nothing ticks. That is
[ADR-0009](../adr/0009-derived-phase-and-overdue-queue.md)'s promise and this screen keeps it.

**The midnight timer moves out of the Dial and into `core/time/`.**
[docs/spec/dial.md](dial.md) put one timer on the Dial and called it the only timer on that screen.
A second screen now needs the same timer, with the same rule and the same cancellation. Two of them
would mean two places to leave one running behind a lock screen. `core/time/` already owns the Clock
and is already where every `now` comes from, so it owns the announcement that the Civil Date has
changed. Both screens listen.

This moves an object. It changes nothing that dial.md says the Dial does, and nothing that any
record says.

### Lock

The screen obeys the contract in [docs/spec/boot-and-data.md](boot-and-data.md) and adds one thing.

The bloc clears on lock. No name, no Topic, no place and no count stays in memory behind the PIN
screen. **The search term clears with them.** It is text the User typed about a person they were
looking for, and it is exactly the kind of thing ADR-0011 hides from a borrowed phone. The chip
returns to *All* at the same time, because the screen comes back as one state and not as a mixture
of what was private and what was not.

Locked and empty are drawn differently, as above.

### What draws what

The card is a `SoftCard`. The search field is a debossed `SoftWell`. The chips are `Pill`s. The log
button is a `SoftButton`. All four are treatments that already exist in `friendo_ui`.

**The Phase bar is drawn inside the feature, not in `friendo_ui`.**
[ADR-0018](../adr/0018-ui-package-and-widgetbook.md) fixes the rule for this:

> Build only what repeats. Six treatments now. The seventh earns its place when it appears twice.

It appears once. The Friend Detail design draws the same fraction, but as a ring around a number
rather than as a bar, so it is a second drawing of one idea and not a second use of one treatment.
If a shared "fill to a fraction" treatment is ever wanted, it has to cover both shapes, and that is
a larger question than this screen. Until then the bar lives with the card.

Whatever draws it takes a fraction and a colour. It must never take a `Phase` or a `Standing`:
`friendo_ui` may not import the domain, and the day the bar moves into the package is the day that
rule is tested.

### What this screen does not own

**Routing.** `friendO-njf` holds the open question of `go_router` against the current cubit. This
spec neither settles it nor depends on the answer. The screen produces two requests — open this
Friend, and add a Friend — and whatever routes them reads those values.

**The Orbit that arrives from the Dial.** ADR-0015 sends the User here from the Overflow Badge,
filtered to one Orbit. Carrying that value between two features is `app/`'s work. What this screen
fixes is the shape of what it accepts: an Orbit, and nothing else. It is the same chip the User
could have tapped.

## Testing Decisions

### What a good test looks like here

It writes Friends into a real database, types a term, and reads what the screen would show. It
names no query, no column and no widget.

The thing most likely to break on this screen is not Dart. It is what SQLite does with `LIKE`, and
that is the one thing a test of the code cannot see. A test that asserts on the text of the query is
worse than no test: it passes while `MICHAŁ` fails to match `michał`, which is the measured
behaviour that ADR-0033 exists to work around. So the search is proved by running it, against the
engine the app ships, over rows a person can read in the test.

### One new seam, and one test a record already asks for

**The seam is the Friends List's state.** One bloc, over a real `FriendRepository`, over a real
in-memory drift database, with a fixed `now`. Everything on this screen meets there: the term, the
chip, the ranking, the banner, the counts, the empty states and the lock. Search is SQL and the
banner is domain arithmetic, and both are proved by the same test reading the same state.

That is the same seam [docs/spec/dial.md](dial.md) chose for the Dial, for the same reason, and it
keeps the count of seams in this project at the number those two specs share.

**The fold is tested directly, and that is not a second seam.** ADR-0033 already requires it:

> A test holds this table. A letter that folds wrongly is then a failing test and not a report from
> a User.

It is a pure function tested with no widget and no database, which is the shape
[ADR-0013](../adr/0013-testing-strategy.md) already names for the Dial layout. Testing it through
the state would mean writing a Friend called `Þór` into a database to assert one letter.

**No new golden.** ADR-0013 allows exactly one golden test, and it is the Dial's. This screen is
cards in a column, and a golden of it would break on every spacing change while proving nothing
about what the cards say.

### The tests

**The fold**

1. Each of the eight pairs ADR-0033 measured folds as the record says: `MICHAŁ`, `Zoë`, `Đorđe`,
   `Straße`, `Søren`, `Þór`, `Nguyễn`, `Ægir`.
2. `Straße` folds to `strasse` and not to `strase`, so step 1 runs before step 3.
3. Folding a folded string changes nothing.
4. A string of plain ASCII is unchanged apart from its case.
5. An empty string folds to an empty string.

**Search**

6. A term in the middle of a name matches: `farb` finds *Quinzelfarb*.
7. Case makes no difference in either direction.
8. `michal` finds *Michał*, and `michał` finds *Michał*. Both directions, one test each.
9. `zoe` finds *Zoë*, and `strasse` finds *Straße*.
10. A term matching a Topic body returns that Topic's Friend.
11. A term matching an Affinity label returns every Friend holding it.
12. A term matching an Orbit name returns every Friend on that Orbit.
13. A Friend whose name and three of whose Topics all match appears exactly once.
14. `%` typed by the User matches a Friend whose name holds a `%`, and does not match everybody.
15. `_` typed by the User does not match any single character.
16. A backslash typed by the User is matched as a backslash.
17. An empty term shows the whole roster.
18. A term matching nobody gives the empty result, and not the whole roster.
19. A term never changes the order of what remains.
20. A term and a chip narrow together, and give the same set in either order.

**The Orbit rule**

21. A Cadence of 14 days is on the inner Orbit and a Cadence of 15 days is on the middle Orbit.
22. A Cadence of 60 days is on the middle Orbit and a Cadence of 61 days is on the outer Orbit.
23. The search's Orbit arm and the chip filter return the same Friends for the same Orbit, at each
    of those four boundary Cadences.
24. Each chip's count equals the number of cards that tapping it shows, with a term in force.
25. With no term, the counts of the three Orbit chips add up to the *All* chip.
26. A screen opened with an Orbit, as the Dial's Overflow Badge opens it, starts on that chip.

**The banner and the order**

27. Two Overdue Friends appear oldest Due Date first.
28. On track Friends follow, highest Phase first.
29. Every Overdue Friend is above every On Track Friend, whatever their Phases.
30. A Friend resting on their Due Date has a Phase above 1, is **not** in the banner, and is drawn
    as Nearing.
31. With nobody Overdue there is no banner.
32. The banner names the same Friends in the same order as `PriorityOrder.overdue`.
33. A chip that hides an Overdue Friend does not remove them from the banner.
34. A term that hides an Overdue Friend does not remove them from the banner.
35. *Review* clears the term, sets the chip to *All*, and the Overdue Friends are the first cards.
36. Logging a Meeting with an Overdue Friend removes them from the banner.
37. The banner's count is the true count even when fewer names are drawn.

**The state**

38. Every card on one build is worked out from one `now`.
39. A Cadence change moves the Friend's card, its Orbit and its place in the list.
40. Logging a Meeting writes one Meeting dated today and moves the card.
41. Logging a Meeting deletes no Topic.
42. A lock clears the cards, the term and the chip.
43. A locked state and an empty roster are different states.
44. The three empty states are told apart: no roster, no match, no Friend in this Orbit.
45. The stream goes quiet across a lock and delivers fresh data on unlock, without the screen
    resubscribing.
46. A write attempted while locked throws `DatabaseLockedError`.
47. Local midnight passing re-reads, and a Friend who became Overdue joins the banner.
48. A resume re-reads.

**The card**

49. A card names the Standing with the glossary word for each of the four Standings.
50. The whole-day label is worked out from Civil Dates: a Friend on their Due Date with a 30 day
    Cadence reads `30/30d`, and an Overdue Friend reads past their Cadence.
51. The bar clamps at full for a Phase above 1.
52. A card shows the newest waiting Topic, and how many wait.

`tool/lint.sh` and `tool/test.sh` both pass.

## Out of Scope

**Add a Friend, and Friend Detail.** This screen opens them and draws neither. The card's tap target
and the button that adds a Friend produce a request; the screens themselves are other specs.

**Editing anything.** No Cadence is changed here, no name, no Topic and no Affinity. The one write
this screen makes is a Meeting dated today.

**Avatar photos.** A card draws an initial and a colour from the Friend id. Reading the BLOB belongs
to the screen that shows one Friend, and [ADR-0026](../adr/0026-attachments-as-blobs-and-a-framed-backup.md)
already holds the rule.

**Searching anything but the four.** Updates, Notes, Facts, Milestones, Meeting places and Meeting
recaps are not searched. The research names the case for revisiting this — a Profile holding
thousands of Friends, or a page of prose against each one — and neither is v1.

**FTS5.** [docs/research/fts5-over-the-encrypted-database.md](../research/fts5-over-the-encrypted-database.md)
settled it: it works, it is faster, it cannot search two of the four things, and it cannot match
inside a word without tripling the stored text.

**Any second ordering.** No alphabetical sort, no relevance ranking, no "sort by" control. One
ranking.

**Bulk actions, swipes and undo.** No multi-select, no swipe to log, and no undo of a logged
Meeting. Undoing a Meeting is a real gap and it belongs with whatever screen owns deleting one,
where [ADR-0016](../adr/0016-derive-lastmet-from-meetings.md)'s "never leave a Friend with no
Meeting" rule already lives.

**Affinity chips.** Filtering by Affinity is an obvious second axis and it is not built. Search
already reaches an Affinity by name.

**The done mark on a Topic.** It is in the backlog. This card is written so that it changes by one
condition when the mark exists.

**Reminders.** The reschedule follows the write, inside the repository.

**Routing, tablet and desktop layouts, pagination and caching.** The last two are refused by
[docs/architecture.md](../architecture.md) at this size, not merely deferred.

## Further Notes

**Two issues land before this one.** `friendO-xdb` writes the Friend aggregate, and `friendO-fff`
gives the open connection, the repository contract and the lock. Draw both edges against the child
that needs them, not against the epic. An edge to the epic holds them blocked until every child
closes.

**The schema this screen needs is already described.** The folded columns, the Affinity table and
its link table, and the place on a Meeting are all in
[docs/feature-backlog.md](../feature-backlog.md), which ADR-0033 already amended. This spec adds no
column.

**Five conflicts between the designs and the records, and four of them are new.**
[docs/feature-backlog.md](../feature-backlog.md) holds the table of these. These five are not in it
yet:

| Item | The design | The record | What this spec does |
|---|---|---|---|
| The banner | Names Friends who are *due in 2d* and *due in 4d* | The PRD says the banner names Friends whose Due Date has **passed** | The banner is Overdue only |
| The word | *2 Friend Orbits Drifting* | `drifting` is a banned word for Overdue | Use Overdue |
| The fifth chip | `Due Soon (2)` beside three Orbits | Two axes, and a banned word for Nearing | Four chips, one axis |
| The chip label | `Inner • 7d` | An Orbit is a range of Cadences | Name and count only |
| The empty state | *No souls in this orbit* | The glossary word is Friend | Plain words, three states |

**Every boundary here is arbitrary, and the records say so.** ADR-0008 says the Orbit thresholds
need tuning against real use. ADR-0029 says the same of the Standing boundaries. This screen shows
both to the User in words, so tuning either changes what this screen says, and that is the point of
keeping the numbers in one place.

**The fold is deliberately wrong for Polish, and that is recorded.** In Polish, `ł` is a letter of
the alphabet and not a decorated `l`. ADR-0033 chose to match anyway, because a search over a
hundred Friends is not a dictionary, and because every phone address book makes the same choice. Do
not "fix" this without reopening the record.

**One rule from the research belongs to the database setup and not here.** Never set
`PRAGMA temp_store = FILE`, and leave `plaintext_header_size` and `mc_legacy_wal` alone: a large
sort spills temp files, and sqlite3mc does not encrypt them. `friendO-mts` holds it. Nothing on this
screen can spill at a hundred Friends, and the rule guards a later edit.

**A term is folded on every keystroke, and that is cheap.** The measured cost of the whole search is
under half a millisecond at a hundred Friends on a desktop, and a few milliseconds on a phone.
There is no debounce, because a delay the User can feel would be added to protect against a cost
they cannot.
