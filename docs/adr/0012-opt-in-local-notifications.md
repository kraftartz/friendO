# ADR-0012: Offer local reminders, off by default

**Status:** Accepted. [ADR-0032](0032-a-cadence-change-moves-the-due-date.md) adds one rule.
A Cadence change that puts the Due Date in the past schedules no reminder.
**Date:** 2026-09-07

## Context

The app tells you who to see next. That only helps if you open it.

A reminder app that you must remember to open depends on a habit it cannot create. Notifications
fix that, and they bring real cost: a permission prompt, scheduling code, timezone handling, and
platform limits on background work.

Notifications also risk the product. A nagging app gets muted, then deleted.

The product owner set a rule for cases like this:

> I'm providing options; not holding the hand.

## Decision

Ship local notifications. Keep them **off by default**. The user turns them on in settings.

Use `flutter_local_notifications` with the `timezone` package. Schedule each reminder from the
friend's `dueAt`. No push service and no server is involved, so this does not affect
[ADR-0003](0003-offline-only-no-internet-permission.md).

Reschedule whenever `lastMet` or `cadence` changes. A logged meeting must move that friend's
reminder, or the app will nag about someone you saw yesterday.

Keep the notification text vague. Use "Time to catch up with Anna". Never put note content on the
lock screen.

## Consequences

### Positive

- The app can work as a real reminder for users who want that.
- Reminders stay local. No network and no server.
- Off by default means no permission prompt on first launch. The app earns the prompt later.
- Vague text keeps private notes off the lock screen, which fits
  [ADR-0011](0011-app-lock-and-screen-privacy.md).

### Negative

- Every write to `lastMet` or `cadence` must trigger a reschedule. A missed path causes a wrong
  reminder, and that bug is hard to notice.
- iOS limits pending local notifications to 64. With 100 friends the app must schedule only the
  nearest ones and top up when the app opens.
- Timezone and daylight-saving changes shift fire times. The `timezone` package handles this and
  must be initialised correctly.
- Most users never open settings, so most users will never see a reminder. Accepted.

## Alternatives Considered

### No notifications at all

**Why rejected:** It is much simpler and it makes the app depend on a habit. The dial is good, but
nobody opens an app to be reminded of the thing that would have reminded them.

### Notifications on by default

**Why rejected:** It reaches more users and it contradicts the product rule above. A badly tuned
default is the fastest way to be muted. A muted app is worse than a silent one, because the user
will not turn it back on.

### A single daily digest

**Why rejected as the first version:** It is a good idea and it needs a chosen hour, digest text,
and grouping rules. Per-friend reminders are simpler. Reconsider once the 64-notification limit
starts to bite, because a digest solves that too.
