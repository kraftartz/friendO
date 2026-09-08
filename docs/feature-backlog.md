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

    affinities(id, label, is_seed)
    friend_affinities(friend_id, affinity_id)

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

    meetings(id, friend_id, happened_on, place, minutes, vibe, recap, audio_id)

All four fields are optional. `happened_on` stays the only field that the Dial reads.

### Note state
A Note carries a date and a label already. The designs add a done mark and a
count of open Notes.

Seen on: Friend Detail (`3 active`, `Noted Oct 22 · Travel & Arts`, done and dismiss buttons).

    notes(... , resolved_on)

This does not break ADR-0017. The app still never clears a Note. The owner sets
`resolved_on`, and the owner alone.

## 2. Attachments — the largest change

The designs store two kinds of binary file:
- an avatar photo per Friend (Add Friend, `photo_camera`),
- an audio recap per Meeting (Friend Detail, `0:38 audio reflection`).

**SQLCipher encrypts the database file. It does not encrypt a file on disk.**
An avatar written to app storage sits there in clear bytes. This defeats the
threat model in ADR-0006.

Two ways to fix it:

| Option | Cost |
|---|---|
| Store the bytes as a BLOB in the database | SQLCipher covers them. The database grows. The backup grows. Simple. |
| Write an encrypted file store | Keeps the database small. Adds a key path, a file layout, and a delete rule. |

For 100 Friends with one avatar each, and short audio, the BLOB option is enough.
Pick it unless a real size problem appears.

Consequences either way:
- Audio capture needs the microphone permission. The manifest still holds no
  INTERNET permission, so ADR-0003 holds.
- ADR-0010 exports logical JSON. JSON cannot hold raw bytes. The backup needs
  base64 fields, or a container with a JSON part and a blob part. **ADR-0010 must
  change before any attachment ships.**

## 3. Derived views — no new storage

### Counts
Home shows three buckets: `1 Nearing 12:00`, `4 In Orbit`, `2 Freshly Reset`.
Directory shows counts per ring and a `Due Soon` count.

These are aggregates over the same ordered list that the Dial reads. The domain
package can return them. Nothing new is stored.

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
second key. ADR-0006 does not change. ADR-0011 needs an amendment that states:
the PIN always stays available, because biometrics fail.

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
| Overdue | No mock shows it | ADR-0015 open | Resolve ADR-0015 |
| Dial capacity | 57 slots | Cap is ~100 Friends | Resolve ADR-0015 |
| Bead size | 32px outer, 28px inner | — | Use 28px everywhere |
| Ring radii | 62 / 102 / 142 | 60 / 100 / 140 | Correct ADR-0014 |
| Cadence presets | 7/30/90 and 7/14/30/60 | Free duration | Pick one preset list |
