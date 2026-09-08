# ADR-0026: Store attachments as BLOBs, and write the Backup as a framed file

**Status:** Accepted
**Date:** 2026-09-08

Supersedes the container format in [ADR-0010](0010-encrypted-logical-backup.md). Everything else in
that record stands: the logical export, the Backup Passphrase, the KDF parameters in the header, and
the re-entry on every export. See [ADR-0019](0019-correcting-and-partly-superseding-a-record.md).

## Context

The designs store two kinds of binary file: an Avatar for each Friend, and an audio recap for a
Meeting.

`docs/architecture.md` already decided where they go, in a line in the module map:

> `core/media/` Avatar images and audio recaps. Stored as blobs.

`docs/feature-backlog.md` calls the same question open, gives the reason that settles it, and adds a
hard precondition:

> **SQLCipher encrypts the database file. It does not encrypt a file on disk.**

> **ADR-0010 must change before any attachment ships.**

The architecture document is ahead of the record. That is the smaller half of the problem.

The larger half is one that neither document costs out. ADR-0010 exports **one JSON document**. JSON
cannot hold bytes, so every attachment has to be base64. A one-shot export then holds all of this in
memory at the same time:

```
raw bytes  ->  base64 text  ->  one JSON string  ->  UTF-8 bytes  ->  ciphertext
   80 MB        107 MB            107 MB              107 MB          107 MB
```

That is roughly 350 MB at the peak for 80 MB of attachments, on a phone, during the one operation
the owner must be able to trust. It is an out-of-memory crash.

Avatars are not what gets it there. A hundred Avatars at 512 px are a few megabytes. **Audio drives
the size.** A 38-second recap is about 150 KB, and there is one per Meeting, on every Friend,
for as long as the owner keeps using the app. That number grows without bound and nothing in the
design ever deletes one.

There is also a cryptographic trap in the obvious fix. AES-GCM **cannot be streamed by simply
splitting the ciphertext.** Its tag only validates after the last byte. Decrypting a large file in
chunks and writing each chunk out as it arrives emits unauthenticated plaintext, and that destroys
the tamper detection ADR-0010 sells:

> AES-GCM detects tampering. A damaged file fails loudly instead of importing wrong data.

## Decision

### Attachments are BLOBs in the database

Store Avatar bytes and audio bytes as BLOB columns in the SQLCipher file. They inherit the
database's encryption with no key path, no file layout, and no delete rule to write. Deleting a
Friend deletes their Avatar in the same transaction, and cannot leave an orphan file behind.

Reject a separate encrypted file store. It keeps the database small and costs a second key path, a
directory layout, an orphan sweep, and a second thing to get right in the Backup. At this size that
buys nothing.

Two limits at capture, because they are the cheapest saving available and they do not depend on the
Backup format at all:

- Downscale an Avatar to 512 px on the long edge before storing it.
- Cap audio bitrate, and cap a recap's length.

### The Backup is a framed file, not one JSON document

```
+--------+---------+------------+------+--------------+
| MAGIC  | version | kdf params | salt | nonce prefix |   header, plaintext
+--------+---------+------------+------+--------------+
| frame 0: the manifest, as JSON                      |   encrypted
+-----------------------------------------------------+
| frame 1..n: raw attachment bytes                    |   encrypted
+-----------------------------------------------------+
```

Every frame is `uint32 length` followed by ciphertext and its tag. Frames are 1 MiB of plaintext.

**Frame 0 is the manifest**: the JSON document ADR-0010 already describes, holding Friends,
Meetings, Notes and settings, plus one row per attachment saying which frames hold it, how many
bytes it is, and what it belongs to. It is text, so it stays small, and it still survives schema
changes exactly as ADR-0010 argues.

**Frames 1 and up carry raw bytes.** No base64. The encoding existed only because JSON cannot hold
bytes, and changing the container removes both the 33% growth and the memory ceiling at once.

**Each frame is encrypted on its own, and its place in the file is bound into its nonce:**

```
nonce = 7-byte random prefix  ||  uint32 frame counter  ||  1 byte, 1 on the last frame
```

This is the STREAM construction, which `age` and Tink both use. It gives three properties that a
single AES-GCM call over a chunked read cannot:

- A frame that was moved, repeated or dropped fails its tag, because the counter is wrong.
- A truncated file fails, because the last frame it holds does not carry the final flag.
- Nothing is written out until its own frame has been checked, so no unauthenticated plaintext ever
  reaches the disk.

Peak memory becomes one frame plus the manifest, whatever the file's size.

## Consequences

### Positive

- Export and import no longer scale their memory with the data. A 2 GB Backup uses the same memory
  as a 2 MB one.
- The 33% base64 growth disappears. A Backup is now about the size of what is in it.
- Tamper detection survives the change to streaming, and gets stronger: reordering and truncation
  are caught, which one AES-GCM call over the whole file would not catch until the very end.
- `docs/architecture.md` and `docs/feature-backlog.md` stop disagreeing, and the precondition the
  backlog set is met.
- Deleting a Friend cannot orphan a file, because there is no file.

### Negative

- The Backup format is now ours, not "a JSON document". It needs a written specification, and the
  reader has to be exact about lengths and counters.
- The version byte in the header now has real work to do. A future format change must keep reading
  version 1.
- BLOBs make the database large. Every open, every migration and every vacuum touches more bytes,
  and drift will happily read a whole row into memory. Attachment columns must be read on their own
  and never in a list query.
- SQLite is slower at very large BLOBs than a file store. At an Avatar and a short recap per Meeting
  it does not matter. If audio ever grows to minutes, revisit this.
- Nothing deletes an old recap. The database grows for as long as the app is used, and the owner
  has no screen that shows why. A size figure in settings would cost little and is worth doing.
- Audio capture needs the microphone permission. The manifest still holds no INTERNET permission, so
  [ADR-0003](0003-offline-only-no-internet-permission.md) holds.

## Alternatives Considered

### Keep one JSON document and base64 the attachments

**Why rejected:** It is the smallest change and it crashes. Roughly 350 MB at the peak for 80 MB of
attachments, during the operation that exists so the owner does not lose their data.

### Keep JSON, and stream it out with a chunked encoder

**Why rejected:** It fixes the memory on export and not on import, because a JSON parser must see a
whole string value before it can hand back the bytes. It also keeps base64 and its 33%.

### Write a ZIP with a JSON member and one member per attachment

**Why rejected:** It is the familiar shape and the crypto is wrong for it. Encrypting members
one by one leaves the file listing readable, and ZIP's own encryption is either weak or
non-standard. Encrypting the finished ZIP puts the memory problem back.

### Write an encrypted file store on disk instead of BLOBs

**Why rejected:** It adds a key path, a directory layout, an orphan sweep and a second delete rule,
to save a size problem this app does not have. Revisit only if audio grows.

### Split the ciphertext of one AES-GCM call into chunks

**Why rejected:** This is the trap named in the Context. The tag only validates after the last byte,
so a chunked reader either buffers everything, which is the original problem, or writes plaintext it
has not authenticated, which removes the property the record promises.

### Leave attachments out of the Backup

**Why rejected:** An Avatar and a voice are the parts of a memory that text cannot carry. A Backup
that drops them is not the disaster archive ADR-0010 describes.
