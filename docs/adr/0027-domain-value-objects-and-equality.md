# ADR-0027: Wrap the domain's values in types, and get equality from `equatable`

**Status:** Accepted
**Date:** 2026-09-08

## Context

The domain held one function and three raw types: a `Duration` for the Cadence, a `double` for the
Phase, and a `DateTime` for the date of a Meeting.

Each of those carries a rule that its type cannot express.

- A `Duration` can be zero or negative. A Cadence cannot. `phaseOf` therefore checked for it on
  every call, and every future function that takes a Cadence would have to check again.
- A `double` can be negative or `NaN`. A Phase cannot.
  [ADR-0021](0021-civil-date-time-model.md) settles that a Phase starts at zero.
- A `DateTime` is an instant or a local reading, depending on a flag the caller sets. ADR-0021
  settles that a Meeting happens on a calendar day with no zone at all. No flag can say that.

[ADR-0008](0008-cadence-as-duration.md) also defines `orbit(cadence)`, which is a rule about a
Cadence and had nowhere to live.

A second question arrives with the types. Values have to compare by what they hold, or every test
reads `expect(a.days, b.days)` instead of `expect(a, b)`, and a `Set<Cadence>` behaves wrongly. Dart
gives no equality for free unless the type is a record, and a record cannot refuse to be built.

## Decision

### Wrap each value, and validate once

| Type | Holds | Refuses |
|---|---|---|
| `CivilDate` | year, month, day | The 30th of February. It throws rather than rolling forward. |
| `Cadence` | whole days | Zero and negative |
| `Phase` | a fraction | Negative and `NaN` |

Validation happens in the factory, so an invalid value cannot exist. The guard then disappears from
every function that takes one, instead of being repeated in each.

`Cadence` owns `orbit`. It is a rule about a Cadence, and the boundaries move without a migration
because no row stores an Orbit.

`Phase` does **not** own `overdue`. Overdue compares two Civil Dates, which a fraction cannot do.
See [ADR-0021](0021-civil-date-time-model.md). `Phase` owns `hasArrived`, which is the different and
smaller question of whether the Bead has reached the top of its Orbit.

### Equality comes from `equatable`

Every value type in `friendo_domain` extends `Equatable` and lists its fields in `props`.

The choice is between three live options in Dart today, because language-level data classes do not
exist and the macro work that would have brought them was cancelled.

`equatable` wins for one reason that is not brevity: **`==` and `hashCode` read the same list.** A
hand-written pair has two places to edit when a field is added, and the failure when somebody edits
one is silent. Two equal objects with different hash codes make a `Set` keep both, and a test that
compares with `==` still passes.

`equatable` also needs no code generation, which keeps
[ADR-0018](0018-ui-package-and-widgetbook.md)'s rejection of `build_runner` intact for this package.

### The domain's rule is not "no dependencies"

`friendo_domain` declared nothing before this record, and that was a coincidence rather than a
choice. Name the rule so it stops being read as one:

> `friendo_domain` has **no Flutter, no clock, no input and no output**. It may depend on a pure
> Dart package that brings none of those.

`equatable` is pure Dart. `tool/boundaries.sh` holds the line by allowlist, so a second dependency
fails the build until somebody adds it there on purpose. See
[ADR-0023](0023-check-the-guarantees-in-ci.md).

## Consequences

### Positive

- An invalid Cadence, Phase or date cannot exist anywhere in the app. The check runs once.
- `phaseOf` lost its guard clause and got shorter, and so will every function added later.
- `orbit` has a home that matches what it is about.
- Tests read as `expect(order.next, longOverdue)` instead of comparing fields one at a time.
- `props` is one list, so `==` and `hashCode` cannot drift apart.
- The domain's dependency rule is written down, so the next pure Dart package is a decision and not
  an argument.

### Negative

- More types to read. Four small classes stand where three built-in types stood.
- `equatable` is a dependency in the package whose emptiness was a selling point. The rule above is
  the answer, and it is a weaker guarantee than "nothing at all".
- `props` can still be wrong. A field left out of the list is invisible to equality, and nothing
  catches it. This is the same failure as a hand-written `hashCode`, in one place instead of two.
- `Equatable` is a superclass, so these types cannot extend anything else.
- Every construction now goes through a factory that can throw. Callers reading owner input must
  validate before they build, or catch.

## Alternatives Considered

### Hand-written `==` and `hashCode` with `Object.hash`

**Why rejected:** It is the zero-dependency answer and it has two lists instead of one. When they
disagree, a `Set` misbehaves and no test fails. For a handful of types with a handful of fields the
saving is a dependency, and the cost is a class of silent bug.

### Dart 3 records

**Why rejected:** A record has structural equality for free, which is exactly what is wanted, and it
cannot refuse to be built. `(days: 0)` is a valid record and an invalid Cadence. The validation is
the reason these types exist.

### `freezed` or `dart_mappable`

**Why rejected:** Both need `build_runner`. ADR-0018 already rejected a generator for this project,
and the reasoning holds here: generated files, a build step before analysis, and a slower loop, for
a package with a handful of small types.

### Extension types over the raw values

**Why rejected:** An extension type is erased at run time, so it costs nothing and enforces nothing.
`Cadence` would still be a `Duration` underneath, and any `Duration` could be cast to it.

### Leave the raw types until `friend.dart` is written

**Why rejected:** This was the right advice while the domain held one function. It stopped being
right when [ADR-0021](0021-civil-date-time-model.md) chose a Civil Date, because `DateTime` cannot
represent a day without a zone at all.
