# ADR-0003: Ship without the INTERNET permission

**Status:** Accepted
**Date:** 2026-09-07

## Context

friendO holds private notes about real people. It holds what they told you, what is new in their
life, and how often you bother to see them. That data is more sensitive than most contact apps.

The product promise is simple: the data stays on the phone. There is no account, no sync, and no
sharing with anyone.

A promise in a privacy policy is a claim. A user cannot check it. The app should make the promise
checkable instead.

The app still needs one way to move data off the phone: a backup file. See
[ADR-0010](0010-encrypted-logical-backup.md).

## Decision

Write no network code. Do not declare `android.permission.INTERNET` in the manifest. Add no cloud
SDK, no analytics SDK, and no crash reporting SDK.

Move the backup file out through the OS share sheet. The app writes a file and hands it to the
system. The user then picks Drive, Files, a cable, or anything else. The app never learns where it
went.

Add a check to CI that fails the build if the INTERNET permission appears in the merged manifest.
A transitive dependency can add that permission without anyone noticing.

## Consequences

### Positive

- Anyone can read the manifest and confirm the promise. The claim stops being a matter of trust.
- The Android system blocks all sockets. Data cannot leak, even through a bug or a bad dependency.
- No server means no accounts, no hosting bill, no uptime, and no breach to disclose.
- The user picks their own backup destination. The app takes no position on it.

### Negative

- No sync. A second phone starts empty.
- A lost phone loses everything, unless the user made a backup.
- No crash reports and no usage data. Bug reports arrive only by word of mouth.
- Any future feature that needs a server needs this record superseded first. That is on purpose.

## Alternatives Considered

### Optional cloud sync, switched off by default

**Why rejected:** It needs accounts, a server, and the INTERNET permission. The permission is the
whole point. Once it is in the manifest, the checkable promise is gone, whether or not the feature
is switched on.

### Crash reporting only

**Why rejected:** Same problem. It needs the INTERNET permission for a benefit that helps the
developer, not the user.

### Integrate the Google Drive API for backups

**Why rejected:** It needs the INTERNET permission, an OAuth flow, and access to the user's Google
account. The share sheet reaches Drive with none of that. It also reaches every other destination.
