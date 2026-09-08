# ADR-0020: Turn off the operating system backup

**Status:** Accepted
**Date:** 2026-09-08

## Context

[ADR-0003](0003-offline-only-no-internet-permission.md) makes the product's headline promise
checkable:

> Anyone can read the manifest and confirm the promise. The claim stops being a matter of trust.

The manifest check proves that the **app** opens no socket. It proves nothing about what the **OS**
sends on the app's behalf.

Android turns its own backup on by default. With `android:allowBackup` unset, the system copies the
app's private directory, its databases and its shared preferences to the owner's Google Drive, on
its own schedule, with no code in this repository.

That default hurts this app more than most, because of a choice made on purpose in
[ADR-0007](0007-database-per-profile.md):

> Store the profile list itself outside the encrypted files. It holds only a display name, an
> avatar, and a PIN hash.

So the one file with no encryption is the file that names both people who share the phone, holds
their Avatars, and holds their PIN hashes. Today that file leaves the phone in the clear.

There is a second effect, on restore. Android copies the encrypted database files too. It cannot
copy the Keystore key, because the key is not exportable. An owner who restores onto a new phone
therefore receives a database that nothing can open, while believing that Google backed the app up.
That belief competes with [ADR-0010](0010-encrypted-logical-backup.md), which is the route that
works.

## Decision

The OS backs up nothing.

**Android.** Set three attributes on `<application>`:

| Attribute | Covers |
|---|---|
| `android:allowBackup="false"` | The Google Drive backup |
| `android:dataExtractionRules="@xml/data_extraction_rules"` | Android 12 and above |
| `android:fullBackupContent="@xml/backup_rules"` | Android 11 and below |

All three are needed. `allowBackup="false"` does not stop the Android 12 device-to-device transfer,
which reads `<device-transfer>` in `dataExtractionRules` instead. Both rule sets in that file
exclude every domain, and a rule set that lists no `<exclude>` backs the app up in full.

**iOS.** Do the same job in the two places it exists there:

- Set `NSURLIsExcludedFromBackupKey` on the database files and on the app's data directory, so
  iCloud and iTunes skip them.
- Give every Keychain item an accessibility class that ends in `ThisDeviceOnly`, so the item never
  enters a backup and never travels to a new phone.

**CI.** Read the three Android attributes out of the built release APK, beside the INTERNET check.
See [ADR-0023](0023-check-the-guarantees-in-ci.md).

The Backup in [ADR-0010](0010-encrypted-logical-backup.md) is therefore the only route to a new
phone. That was already the design. This record makes it a choice on paper instead of a side effect
of an unset attribute.

## Consequences

### Positive

- The Profile list, with its PIN hashes and Avatars, stays on the phone.
- The promise in ADR-0003 becomes true of the whole system and not only of the app's own code.
- No owner receives a restored database that no key can open. The confusing half-restore cannot
  happen.
- A `--release` build now proves both promises at once, from one artefact.

### Negative

- The owner loses the OS restore they may expect. A new phone starts empty unless the owner made a
  Backup. This is the cost, and it is the same cost ADR-0010 already accepts.
- Somebody who never opens the backup screen loses everything with the phone. The product rule
  stands: "I'm providing options; not holding the hand." The app should still say so plainly on
  first run.
- The iOS half is code, not configuration. It cannot be checked by reading a file, so it needs a
  test on a real device. iOS is not built in CI at all today.
- `dataExtractionRules` needs `targetSdk` 31 or above to be read. A future drop in `targetSdk`
  would silently disable half of this.

## Alternatives Considered

### Encrypt the Profile list, and leave the OS backup on

**Why rejected:** It moves the problem and does not remove it. The list must be readable before any
Profile is unlocked, so its key cannot be gated by a PIN. It would also still ship the encrypted
databases to Drive without their keys, which is the confusing half-restore above.

### Set `allowBackup="false"` alone

**Why rejected:** It is the well-known attribute and it is not sufficient. Android 12's
device-to-device transfer reads `dataExtractionRules`, so a phone-to-phone copy would still carry
the Profile list across.

### Use `dataExtractionRules` to back up only the harmless parts

**Why rejected:** There are no harmless parts. Every file this app writes is either a PIN hash, an
Avatar, or an encrypted database whose key cannot travel.

### Drop the Avatar from the Profile list

**Why rejected here, and worth keeping open:** An Avatar on the Profile picker is a picture of a
real face in the one unencrypted file. A colour and an initial would do the same job. That is a
product question and it does not change this record, which turns the backup off either way.
