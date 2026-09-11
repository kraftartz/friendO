# ADR-0037: `go_router` owns every screen, and the lock is one redirect

**Status:** Accepted
**Date:** 2026-09-11

## Context

`friendO-njf` held this open from the first week, with a warning:

> `NavigationCubit` with an `IndexedStack` is correct for three tabs and wrong for an app with deep
> links, nested routes or a back stack. Do not let the scaffolding choice harden into the answer by
> default.

Two of those three arrived. Adding the Friend Notepad and Add a Friend
([docs/spec/add-notepad-and-settings.md](../spec/add-notepad-and-settings.md)) gave the app a back
stack, and [docs/spec/boot-and-data.md](../spec/boot-and-data.md) had already named the other:

> a boot path that picks between four first screens is the strongest argument that issue will get.

The app had grown three ways of changing what is on screen, none of which knew about the others:

| Mechanism | What it moved |
|---|---|
| `NavigationCubit` over an `IndexedStack` | the three sections |
| `setState` on `MaterialApp.home` | the four boot screens |
| `Navigator.push` | Add a Friend, the Friend Notepad |

**The lock is what made that untenable.** [ADR-0011](0011-app-lock-and-screen-privacy.md) hides the
Friends the moment a Profile closes, and the boot path swaps `MaterialApp.home` to do it. A route
pushed on top is not `home`, so it survived the swap and rested over the PIN screen, drawn blank,
holding the User away from the one control that gets them back. The fix, under the imperative
shape, was a `BlocListener` on each pushed route that pops itself when its own state reads locked.

That is a rule every future screen has to remember. It is the failure
[ADR-0012](0012-opt-in-local-notifications.md) names in another corner of this app:

> A missed path causes a wrong reminder, and that bug is hard to notice.

[ADR-0022](0022-one-repository-per-aggregate.md) answered that one by making `core/reminders/`
*watch* rather than be called, so a new write path cannot forget it. Navigation had the same shape
of problem and no such answer.

Two further screens are owed and both make it worse: the Backup (`friendO-j74`), and switching
Profile, which was already a dead control on the Settings screen (`friendO-z0z`) because reaching
another Profile's keypad from inside the app had no mechanism at all.

## Decision

**One `GoRouter` owns the boot screens, the three sections and everything pushed over them.**

**The lock is one redirect condition, not a rule per screen.** `decideLocation` is a pure function
of four values — where the User is, what the Profile list says, whether a Profile is open, and
which Profile they asked for next — and it is consulted for every route. A screen cannot forget it,
because a screen is not asked.

**The app draws nothing until the boot reading lands.** The reading is a file and a redirect
answers in one step, so the router opens on a screen that holds no Friend, no bar and no Dial, and
moves the moment the reading arrives. The old shape drew the Dial first and swapped it, which is a
frame of the Friends behind a lock.

**`DatabaseSession` says which Profile is open.** The owner of the connection is the one object
that always knows, so nothing else is told and nothing else can be told wrongly. `AppStatus` reads
it rather than holding a copy.

**Switching Profile stays `lock()` and then `unlock()`**, exactly as
[docs/spec/boot-and-data.md](../spec/boot-and-data.md) built it. The Settings screen makes the
first half and says which Profile the second half is for; the redirect carries the User to that
Profile's keypad; the keypad does the unlock it already did. There is no second unlock path, and
the PIN is still typed in one place.

**`NavigationCubit` is deleted.** The shell owns the section, and a cubit holding a copy of it
would be a second answer to one question.

## Consequences

**Good.** The lock is checked for every screen, including ones not written yet. The test for it is
one table of paths rather than one widget test per screen, and it fails loudly when a path is added
without thought.

**Good.** The redirect rule is a pure function. It reads no widget and no context, so it can be
read and tested on its own, which is what
[ADR-0013](0013-testing-strategy.md) asks of any rule worth having.

**Good.** Switching Profile has a home, and it is the path that already existed.

**Bad.** A dependency, and a large one. `go_router` brings its own concepts — branches, shells,
redirects — and a reader now needs them to follow `lib/app/`.

**Bad.** The routing tests are harder to write than they were. A redirect is a route transition, so
a test must pump with a duration and wait for the animation, where the old `setState` swap was
immediate. Three test files carry that cost.

**Bad.** `firstScreen: null` changed meaning. It used to say "nothing stands in the way"; it now
says "no reading has been taken". Production always takes the reading before `runApp`, so only
tests saw the old meaning, and they were rewritten.

**Neutral.** Deep links are still not supported and `go_router` is not needed for them.
[ADR-0003](0003-offline-only-no-internet-permission.md) makes them unlikely to ever arrive. This
record does not rest on them.

## Alternatives considered

**Stay with the cubit, the `setState` and the `Navigator`, and write it down.** The cheapest today.
It keeps three mechanisms with no owner and leaves the lock as a standing obligation on every
future pushed screen, enforced by nothing. This was the shape the app had already drifted into
without a decision, which is the drift `friendO-njf` existed to stop.

**One imperative owner of our own.** A sealed route type and an object in `app/` holding the stack,
clearing it on lock. It removes the forgettable rule with no dependency, and it means writing and
testing navigation machinery that `go_router` already ships, for an app whose routing is not
unusual.

**`Navigator` 2.0 directly.** The same work as the previous option with a harder API, and the
reason `go_router` exists.
