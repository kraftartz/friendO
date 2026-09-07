# ADR-0011: Lock the app and hide the screen preview

**Status:** Accepted
**Date:** 2026-09-07

## Context

Encryption protects a phone that is switched off or stolen. It does nothing while the app is open
on a table.

Two everyday leaks matter more than a thief with a disk image:

1. Someone picks up the unlocked phone and reads your notes about them.
2. The app preview shows in the task switcher. Anyone glancing at the phone sees a friend's name
   and your private note about them.

Banking apps solve both. The app locks itself, and it hides its own preview.

## Decision

**Lock on a timer.** Lock the app after a set time in the background. Default to 60 seconds. Show
the PIN screen on return. Close the database handle when locking, so the key leaves the open
connection.

**Hide the preview.** The two platforms need different work:

| Platform | Method |
|---|---|
| Android | Set `FLAG_SECURE` on the window. It blanks the switcher preview and blocks screenshots. |
| iOS | No equivalent flag exists. Draw a cover view over the app when `AppLifecycleState` becomes `inactive`. Remove it on `resumed`. |

Use `inactive` on iOS, not `paused`. The system takes its snapshot before `paused` arrives.

## Consequences

### Positive

- A borrowed phone shows a PIN screen, not somebody's notes.
- The task switcher shows nothing readable on either platform.
- `FLAG_SECURE` blocks screenshots and screen recording on Android at no extra cost.

### Negative

- `FLAG_SECURE` also blocks the user's own screenshots. Some users will want them. Accept this, or
  add a setting later.
- The iOS cover view can flicker on some transitions. It needs testing on real devices.
- A short lock timer annoys users who switch apps often. The timer needs a setting.
- Closing the database on lock costs a reopen on unlock. At this data size that is not noticeable.
- Dart cannot wipe the key from memory. Locking removes it from the open connection and nothing
  more. See [ADR-0006](0006-keystore-dek-with-pin-gate.md).

## Alternatives Considered

### Lock only when the phone locks

**Why rejected:** It misses the common case. The phone stays unlocked while it changes hands.

### Blur the content instead of covering it

**Why rejected:** A blur can still leak layout, avatar shapes, and colour. A solid cover leaks
nothing and is simpler to build.

### Biometric unlock instead of a PIN

**Why rejected as the only method:** Two profiles share one phone, and one fingerprint cannot pick
between them. Biometrics may be added later as a shortcut, with the PIN kept as the fallback.
