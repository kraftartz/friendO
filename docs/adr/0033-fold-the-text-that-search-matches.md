# ADR-0033: Search matches a Folded copy of the text

**Status:** Accepted
**Date:** 2026-09-09

## Context

Search uses `LIKE`, which
[`docs/research/fts5-over-the-encrypted-database.md`](../research/fts5-over-the-encrypted-database.md)
settled. `LIKE` folds case for ASCII and for nothing else, and it never removes an accent. This is
measured against the pinned sqlite3mc build, not assumed:

| Test | Result |
|---|---|
| `'Quinzelfarb' LIKE '%quin%'` | matches |
| `'MICHAŁ' LIKE '%michał%'` | **no match**. `Ł` does not fold. |
| `'Zoë' LIKE '%zoe%'` | **no match**. Accents never come off. |

So a User with a Friend called Michał types `michal` and finds nobody. The list is empty and the
app looks broken. The same holds for a Topic and for an Affinity label.

The question names two routes. One of them does not exist:

**A collation cannot help.** SQLite applies a collating sequence to `=`, to `<` and to `ORDER BY`.
`LIKE` ignores collations completely. Registering one from Dart would change nothing about the
three rows above. The real second route is a registered *function*, which gives
`WHERE fold(name) LIKE ?`.

That leaves a stored copy against a function call, and the cost is not symmetric. Search runs on
every keystroke, over a `UNION` of four arms. At the realistic largest size, 100 Friends with 20
Topics each, the function route crosses from SQLite into Dart about 2 000 times for every key the
User presses.

## Decision

### Keep Folded Text beside each thing the app searches

Each searched column gets a folded column next to it: the Friend name, the Topic body and the
Affinity label. One repository owns each write
([ADR-0022](0022-one-repository-per-aggregate.md)), so one statement writes both.

Search reads the folded column only.

Orbit needs no folded column. Its names are ASCII.

### Fold both sides

Fold what the User types, with the same function. Then `michal` finds Michał, and `michał` finds
Michał too. Folding one side only would trade one broken search for another.

### The fold has three steps, in this order

1. Replace `ß` with `ss`.
2. Lower case it, with Dart's `String.toLowerCase`. It covers all of Unicode. `MICHAŁ` gives
   `michał`.
3. Remove the diacritics, with the `diacritic` package. It holds an explicit table.

Step 3 needs a table and cannot use decomposition alone. `Ł` (U+0141), `Đ` (U+0110), `Ø` (U+00D8),
`Æ` (U+00C6), `ß` (U+00DF) and `Þ` (U+00DE) are single code points. They do not split into a letter
and an accent, so the usual method reaches none of them and `Michał` stays `michał`.

Step 1 exists because the table maps `ß` to `s`. Without the step, `Straße` gives `strase` and a
User who types `strasse` finds nothing.

Measured against `diacritic` 0.1.6 on 2026-09-09:

| Written | Folded |
|---|---|
| `MICHAŁ` | `michal` |
| `Zoë` | `zoe` |
| `Đorđe` | `dorde` |
| `Straße` | `strasse` |
| `Søren` | `soren` |
| `Þór` | `thor` |
| `Nguyễn` | `nguyen` |
| `Ægir` | `aegir` |

A test holds this table. A letter that folds wrongly is then a failing test and not a report from a
User.

### Folded Text is never shown

It exists to be matched. Every screen shows what the User wrote.

## Consequences

### Positive

- The fold costs one call for each write. The function route costs one call for each candidate row
  for each keystroke.
- No Dart sits inside the query. Search stays one SQL statement, and the timings in the research
  hold.
- The rule is a table. A letter that is missing is a data fix with a test beside it, not a new
  algorithm.
- Search now works for the names it was failing on, which include the name of the person who
  writes this app.

### Negative

- Three columns hold a copy of text the app could work out. This is the first derived value the
  project stores, and both [ADR-0008](0008-cadence-as-duration.md) and
  [ADR-0016](0016-derive-lastmet-from-meetings.md) refused to store one.

  The difference is what the value depends on. An Orbit and a `lastMet` summarise *other rows*, so
  they fall out of date when a row changes somewhere else. Folded Text is a pure function of the
  same row's own column, written in the same statement. It cannot drift while one repository owns
  the write.
- A change to the fold rule rewrites every folded column. That is a migration.
- The fold is deliberately wrong for Polish. In Polish, `ł` is a separate letter of the alphabet
  and not a decorated `l`, so a correct Polish search would refuse to match `michal` against
  `Michał`. friendO matches it, because a search over a hundred Friends is not a dictionary. Every
  phone address book makes the same choice.
- The table in `diacritic` is maintained by hand. A letter it misses fails quietly, and only for
  the User whose name holds it.

## Alternatives Considered

### Register a collation from Dart

**Why rejected:** It does not work. SQLite gives a collating sequence to `=`, `<` and `ORDER BY`,
and `LIKE` ignores it. The route was named in the question, and checking it removed it.

### Register a `fold()` function, and call it in the query

**Why rejected:** It works, and it puts a Dart call inside the query plan. Search runs on every
keystroke over four arms, which is about 2 000 crossings of the boundary for each key at the
realistic largest size. The stored copy pays the same work once, when the User saves.

It also keeps the schema honest at the cost of the hot path, which is the wrong way round. Writes
are rare here. Keystrokes are not.

### Fold with decomposition only, and keep no table

**Why rejected:** Measured, it fails on the name that raised the question. `Ł` holds no accent to
remove, so `Michał` stays `michał`.

### Fold the case and leave the accents

**Why rejected:** `Zoë` would still not answer to `zoe`. A half fix is harder to understand than no
fix, because the User cannot tell which names the search covers.
