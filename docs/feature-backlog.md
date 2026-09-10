# Feature backlog from the designs

The designs show features that the ADRs do not cover. This file lists them.
Each entry names the screen, the data it needs, and the architecture it touches.

The designs use decorative words such as "celestial" and "rhythm". This file uses
plain words. See `../CONTEXT.md` for the canonical terms.

## 1. New stored data

### Fact
A label and a value that describe a Friend and change rarely.
Examples: employer, city, favourite drink, partner's name.

Seen on: Friend Detail (`Figma · Bay Area`), Add Friend.

    facts(id, friend_id, label, value, position)

The owner writes both the label and the value. To suggest labels, read
`SELECT DISTINCT label FROM facts`. **A Fact needs no label table.** A label is
text that you display, not an entity that you filter by. A separate table would
add orphan rows and rename rules for no gain.

### Affinity
A label that groups Friends. The app ships a starting set. The owner can add more.
A new label becomes a suggestion for every other Friend.

Seen on: Add Friend (`Family, Close Friend, College Buddy, Creative Colleague, Mentor`),
Friend Detail (`Close Friends · Monthly Orbit`), Directory filters.

    affinities(id, label, label_folded, is_seed)
    friend_affinities(friend_id, affinity_id)

`label_folded` holds the Folded Text that search matches. Every searched column carries one, so
the Friend name and the Topic body do too. See
[ADR-0033](adr/0033-fold-the-text-that-search-matches.md).

**An Affinity does need its own table.** You filter the Directory by it, so two
spellings of one label are a defect. A Fact label has no such risk.

An Affinity does not set the Cadence. Two Friends tagged `Family` can hold
different Cadences. Keep the two ideas apart.

### Milestone
A fixed date that belongs to a Friend. A Milestone repeats every year, or it
happens once.

Seen on: Add Friend (`Birthday Oct 14`, `Met at MIT Media Lab`).

    milestones(id, friend_id, label, on_date, repeats_yearly)

A Milestone does not move a Bead. The Dial shows Cadence only. Show Milestones in
a separate list. Decide later if a Milestone can raise a notification.

### Meeting detail
The Meeting record today holds a date. The designs add four fields.

Seen on: Friend Detail (`October 14 ... at Blue Bottle Coffee`, `Duration 1.5 hrs`,
`Vibe: Warm & Energized`, a free text recap, `0:38 audio reflection`).

    meetings(id, friend_id, happened_on, happened_at_minute, created_at,
             place, minutes, vibe, recap, audio_id)

All four design fields are optional. `happened_on` is a civil date and stays the
only field that the Dial reads. `happened_at_minute` is the optional time of day
from [ADR-0021](adr/0021-civil-date-time-model.md); it is shown and never drawn.

### Note state
A Note carries a date and a label already. The designs add a done mark and a
count of open Notes.

Seen on: Friend Detail (`3 active`, `Noted Oct 22 · Travel & Arts`, done and dismiss buttons).

    notes(... , resolved_on)

This does not break ADR-0017. The app still never clears a Note. The owner sets
`resolved_on`, and the owner alone.

## 2. Attachments — settled by ADR-0026

The designs store two kinds of binary file:
- an avatar photo per Friend (Add Friend, `photo_camera`),
- an audio recap per Meeting (Friend Detail, `0:38 audio reflection`).

**SQLCipher encrypts the database file. It does not encrypt a file on disk.**
An avatar written to app storage sits there in clear bytes. This defeats the
threat model in ADR-0006.

[ADR-0026](adr/0026-attachments-as-blobs-and-a-framed-backup.md) decides both
halves. Attachments are BLOB columns in the database. The backup becomes a
framed file: an encrypted JSON manifest, then encrypted raw bytes, one frame at
a time. Base64 is gone, and so is the out-of-memory crash it caused.

Still to do when the feature is built:
- Downscale an avatar to 512 px on capture. Cap the audio bitrate and length.
  Audio drives the size, not avatars, and nothing ever deletes a recap.
- Read attachment columns on their own. A list query must never pull a BLOB.
- Audio capture needs the microphone permission. The manifest still holds no
  INTERNET permission, so ADR-0003 holds.

## 3. Derived views — no new storage

### Counts
Home shows three buckets: `1 Nearing 12:00`, `4 In Orbit`, `2 Freshly Reset`.
Directory shows counts per orbit and a `Due Soon` count.

[ADR-0029](adr/0029-name-the-dial-counts.md) names the four Standings and sets
their boundaries in Phase. `PriorityOrder.counts` returns them. Nothing new is
stored. `Due Soon` on the Directory is the Nearing count under another name;
use the glossary word.

### Meeting history
The designs show only the newest Meeting. A full history per Friend is the
obvious next screen, and the table already holds every row.

### Directory row
Each row shows the newest Meeting date, its place, one Note, and progress
(`28/30d`). All of it derives from data listed above.

## 4. Security additions

### Biometric unlock
Seen on: Vault (`fingerprint`).

The fingerprint opens the same key that the PIN opens. It is a second gate, not a
second key. ADR-0006 does not change, and ADR-0011 already states that the PIN
always stays available.

Binding the biometric to the Keystore entry itself is deferred. See
[ADR-0024](adr/0024-keystore-holds-a-wrapping-key.md): it only helps against an
attacker who already owns the running OS, which ADR-0006 puts out of scope.

### Guest profile
Seen on: Vault (`Create Guest Orbit`, `Temporary visitor?`).

A third profile beside the two owners. ADR-0007 gives each profile its own
database, so a guest costs nothing new. Decide whether a guest database survives
a restart.

## 5. Conflicts to settle

| Item | Design | ADR | Action |
|---|---|---|---|
| Bead motion | `animate-orbit-*` spins the beads | Angle means phase | Drop the animation |
| Last seen date | No field on Add Friend | ADR-0016 needs one | Add the field |
| Overdue | No mock shows it | ADR-0015 | Draw the Beads Queue at 12:00 |
| Meeting time | `October 14 ... at Blue Bottle`, no hour | ADR-0021 allows an optional one | Show the hour only when the User set it |
| Dial capacity | 57 slots | 59, then an Overflow Badge | Draw the Badge, ADR-0015 |
| Bead size | 32px outer, 28px inner | — | Use 28px everywhere |
| Orbit radii | 62 / 102 / 142 | 62 / 102 / 142 | Settled. ADR-0014 already agrees. |
| Bead name label | A name under every Bead | ADR-0014 spaces Beads 4 units apart | Drop the label. Name the Friend on a tap |
| Cadence presets | 7/30/90 and 7/14/30/60 | Free duration | Pick one preset list |

### From the Friends List

The Friends List designs raise five more. Four of them are new here. The fifth, the time of a
Meeting, is the row above.

| Item | Design | ADR | Action |
|---|---|---|---|
| The Overdue banner | Names Friends due in 2d and 4d | The PRD names Friends whose Due Date has passed | Name Overdue Friends only |
| The word for it | `2 Friend Orbits Drifting` | `drifting` is a banned word for Overdue | Use Overdue |
| The fifth chip | `Due Soon (2)` beside three Orbits | Two axes in one row, and a banned word for Nearing | Four chips, one axis |
| The chip label | `Inner • 7d` | An Orbit is a range of Cadences, ADR-0008 | The chip carries a name and a count |
| The empty state | `No souls in this orbit` | The glossary word is Friend | Plain words, and three states with three next actions |
