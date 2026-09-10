import 'package:drift/drift.dart';
import 'package:friendo_domain/friendo_domain.dart'
    show
        Affinity,
        Cadence,
        CivilDate,
        Fact,
        Friend,
        Meeting,
        Milestone,
        Note,
        NoteLabel;

import '../db/app_database.dart';
import '../db/database_session.dart';
import '../text/folded_text.dart';
import '../time/clock.dart';
import 'dial_friend.dart';
import 'friend_search.dart';
import 'listed_friend.dart';

/// One row per Friend: the id, the name, the Cadence, and the Civil Date of
/// the newest Meeting.
///
/// It names its four columns rather than taking a whole Friend, so a column
/// added to the table never joins this read. The Avatar picture and the audio
/// recap are BLOB columns, and a Dial query that pulled one would read
/// megabytes to draw a circle 28 units wide. See ADR-0026.
const dialFriendsStatement =
    'select f.id, f.name, f.cadence_days, max(m.happened_on) as last_met '
    'from friends f join meetings m on m.friend_id = f.id '
    'group by f.id, f.name, f.cadence_days order by f.name';

/// One row per Friend, holding everything a card on the Friends List draws.
///
/// The newest Meeting arrives as one row of the meetings table, so that its
/// place and its optional time belong to the same Meeting as the Civil Date.
/// Two Meetings on one Civil Date are told apart by the instant the store
/// wrote them, which ADR-0021 keeps for this.
///
/// While no Topic can be marked done, every Topic is waiting. When the done
/// mark lands, both sub-queries gain the same one condition.
const listedFriendsStatement =
    'select f.id, f.name, f.cadence_days, '
    'm.happened_on as last_met, m.happened_at_minute, m.place, '
    '(select n.body from notes n '
    ' where n.friend_id = f.id and n.label = ? '
    ' order by n.written_on desc, n.id desc limit 1) as newest_topic, '
    '(select count(*) from notes n '
    ' where n.friend_id = f.id and n.label = ?) as topics_waiting '
    'from friends f join meetings m on m.id = '
    '(select newest.id from meetings newest where newest.friend_id = f.id '
    ' order by newest.happened_on desc, newest.created_at desc, '
    ' newest.id desc limit 1) '
    'order by f.name';

/// The one door to a Friend.
///
/// It holds the connection owner and asks it on every call, so that no dead
/// handle survives a lock. A call that arrives while the Profile is locked
/// throws [DatabaseLockedError], and no caller needs a try around a query.
class FriendRepository {
  const FriendRepository(this.databases, {this.clock = const Clock()});

  final DatabaseSession databases;

  final Clock clock;

  /// Reads the whole Friend, or null when this Profile holds no such Friend.
  Future<Friend?> load(String friendId) async {
    final database = databases.database;

    final row = await (database.select(
      database.friends,
    )..where((friend) => friend.id.equals(friendId))).getSingleOrNull();
    if (row == null) return null;

    return Friend.hydrate(
      id: row.id,
      name: row.name,
      cadence: Cadence.ofDays(row.cadenceDays),
      meetings: await _meetingsOf(database, friendId),
      notes: await _notesOf(database, friendId),
      facts: await _factsOf(database, friendId),
      affinities: await _affinitiesOf(database, friendId),
      milestones: await _milestonesOf(database, friendId),
    );
  }

  /// Writes the whole Friend, in one transaction.
  ///
  /// A Friend and their first Meeting land together or not at all. A failure
  /// between the two rows would leave a Friend whose lastMet cannot be worked
  /// out.
  ///
  /// The name and every Affinity label are folded here. No screen above knows
  /// that the fold exists.
  Future<void> save(Friend friend) {
    final database = databases.database;

    return database.transaction(() async {
      await database
          .into(database.friends)
          .insertOnConflictUpdate(
            FriendsCompanion.insert(
              id: friend.id,
              name: friend.name,
              nameFolded: foldedText(friend.name),
              cadenceDays: friend.cadence.days,
            ),
          );

      // Read before the clear, because the clear takes the answer away.
      final born = await _bornAtOf(database, friend.id);

      await _clearChildrenOf(database, friend.id);

      for (final meeting in friend.meetings) {
        await database
            .into(database.meetings)
            .insert(
              MeetingsCompanion.insert(
                id: meeting.id,
                friendId: friend.id,
                happenedOn: meeting.happenedOn.epochDay,
                happenedAtMinute: Value(meeting.happenedAtMinute),
                createdAt:
                    born[meeting.id] ?? clock.now().millisecondsSinceEpoch,
                place: Value(meeting.place),
                lengthInMinutes: Value(meeting.lengthInMinutes),
                feeling: Value(meeting.feeling),
                recap: Value(meeting.recap),
              ),
            );
      }

      for (final note in friend.notes) {
        await database
            .into(database.notes)
            .insert(
              NotesCompanion.insert(
                id: note.id,
                friendId: friend.id,
                label: note.label.name,
                body: note.body,
                bodyFolded: foldedText(note.body),
                writtenOn: note.writtenOn.epochDay,
                resolvedOn: Value(note.resolvedOn?.epochDay),
              ),
            );
      }

      for (var ordinal = 0; ordinal < friend.facts.length; ordinal++) {
        final fact = friend.facts[ordinal];
        await database
            .into(database.facts)
            .insert(
              FactsCompanion.insert(
                id: fact.id,
                friendId: friend.id,
                label: fact.label,
                value: fact.value,
                ordinal: ordinal,
              ),
            );
      }

      for (final milestone in friend.milestones) {
        await database
            .into(database.milestones)
            .insert(
              MilestonesCompanion.insert(
                id: milestone.id,
                friendId: friend.id,
                label: milestone.label,
                onDate: milestone.onDate.epochDay,
                repeatsYearly: milestone.repeatsYearly,
              ),
            );
      }

      for (final affinity in friend.affinities) {
        // A label that is already there keeps what it holds, so that a label
        // the app ships does not lose the mark that says so.
        await database
            .into(database.affinities)
            .insert(
              AffinitiesCompanion.insert(
                id: affinity.id,
                label: affinity.label,
                labelFolded: foldedText(affinity.label),
                isSeed: false,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await database
            .into(database.friendAffinities)
            .insert(
              FriendAffinitiesCompanion.insert(
                friendId: friend.id,
                affinityId: affinity.id,
              ),
            );
      }
    });
  }

  /// Takes the Friend and everything that belongs to them away.
  ///
  /// The Affinity labels stay, because they belong to the Profile and not to
  /// one Friend.
  Future<void> delete(String friendId) {
    final database = databases.database;

    return database.transaction(() async {
      await _clearChildrenOf(database, friendId);
      await (database.delete(
        database.friends,
      )..where((friend) => friend.id.equals(friendId))).go();
    });
  }

  /// Every Friend the Dial draws, watched.
  ///
  /// One Friend gives one row, whatever the number of their Meetings, and the
  /// newest Meeting arrives as one Civil Date rather than as the Meetings it
  /// was worked out from. The largest Civil Date is taken in the query, and
  /// nothing stores it. See ADR-0016.
  ///
  /// No reading is worked out here, and no clock is read. A caller gives one
  /// `now` to the whole packing it builds, so a Standing that turns at
  /// midnight is a re-read of these same rows rather than a new stream.
  Stream<List<DialFriend>> watchDialFriends() => databases.watch(
    (database) => database
        .customSelect(
          dialFriendsStatement,
          readsFrom: {database.friends, database.meetings},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => DialFriend(
                  id: row.read<String>('id'),
                  name: row.read<String>('name'),
                  cadence: Cadence.ofDays(row.read<int>('cadence_days')),
                  lastMet: CivilDate.fromEpochDay(row.read<int>('last_met')),
                ),
              )
              .toList(),
        ),
  );

  /// Every Friend the Friends List draws, watched.
  ///
  /// No reading is worked out here, and no clock is read. One `now` from the
  /// caller then builds the whole screen, so two cards never fall on either
  /// side of midnight.
  Stream<List<ListedFriend>> watchListedFriends() => databases.watch(
    (database) => database
        .customSelect(
          listedFriendsStatement,
          variables: [
            Variable<String>(NoteLabel.topic.name),
            Variable<String>(NoteLabel.topic.name),
          ],
          readsFrom: {database.friends, database.meetings, database.notes},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ListedFriend(
                  id: row.read<String>('id'),
                  name: row.read<String>('name'),
                  cadence: Cadence.ofDays(row.read<int>('cadence_days')),
                  lastMet: CivilDate.fromEpochDay(row.read<int>('last_met')),
                  lastMetAtMinute: row.read<int?>('happened_at_minute'),
                  lastMetPlace: row.read<String?>('place'),
                  newestTopic: row.read<String?>('newest_topic'),
                  topicsWaiting: row.read<int>('topics_waiting'),
                ),
              )
              .toList(),
        ),
  );

  /// Name every Friend the term matches, or null when the term narrows
  /// nothing.
  ///
  /// The term is folded through the same function that folded the stored
  /// copy, so a plain spelling finds a name with a stroke and the name with
  /// the stroke finds it too.
  Future<Set<String>?> friendIdsMatching(String term) async {
    final search = FriendSearch.forTerm(term);
    if (search == null) return null;

    final database = databases.database;
    final rows = await database
        .customSelect(
          search.statement,
          variables: search.variables,
          readsFrom: {
            database.friends,
            database.notes,
            database.affinities,
            database.friendAffinities,
          },
        )
        .get();

    return {for (final row in rows) row.read<String>('id')};
  }

  /// When the store first wrote each Meeting this Friend holds.
  ///
  /// A whole save takes every child row away and puts it back. Without this
  /// the instant would be the time of the last write, and ADR-0021 asks it to
  /// break a tie between two Meetings on one Civil Date, which a moving
  /// instant cannot do.
  Future<Map<String, int>> _bornAtOf(
    AppDatabase database,
    String friendId,
  ) async {
    final rows = await (database.select(
      database.meetings,
    )..where((row) => row.friendId.equals(friendId))).get();

    return {for (final row in rows) row.id: row.createdAt};
  }

  Future<void> _clearChildrenOf(AppDatabase database, String friendId) async {
    await (database.delete(
      database.meetings,
    )..where((row) => row.friendId.equals(friendId))).go();
    await (database.delete(
      database.notes,
    )..where((row) => row.friendId.equals(friendId))).go();
    await (database.delete(
      database.facts,
    )..where((row) => row.friendId.equals(friendId))).go();
    await (database.delete(
      database.milestones,
    )..where((row) => row.friendId.equals(friendId))).go();
    await (database.delete(
      database.friendAffinities,
    )..where((row) => row.friendId.equals(friendId))).go();
  }

  Future<List<Meeting>> _meetingsOf(
    AppDatabase database,
    String friendId,
  ) async {
    final rows = await (database.select(
      database.meetings,
    )..where((row) => row.friendId.equals(friendId))).get();

    return rows
        .map(
          (row) => Meeting(
            id: row.id,
            happenedOn: CivilDate.fromEpochDay(row.happenedOn),
            happenedAtMinute: row.happenedAtMinute,
            place: row.place,
            lengthInMinutes: row.lengthInMinutes,
            feeling: row.feeling,
            recap: row.recap,
          ),
        )
        .toList();
  }

  Future<List<Note>> _notesOf(AppDatabase database, String friendId) async {
    final rows = await (database.select(
      database.notes,
    )..where((row) => row.friendId.equals(friendId))).get();

    return rows
        .map(
          (row) => Note(
            id: row.id,
            label: NoteLabel.values.byName(row.label),
            body: row.body,
            writtenOn: CivilDate.fromEpochDay(row.writtenOn),
            resolvedOn: row.resolvedOn == null
                ? null
                : CivilDate.fromEpochDay(row.resolvedOn!),
          ),
        )
        .toList();
  }

  Future<List<Fact>> _factsOf(AppDatabase database, String friendId) async {
    final rows =
        await (database.select(database.facts)
              ..where((row) => row.friendId.equals(friendId))
              ..orderBy([(row) => OrderingTerm(expression: row.ordinal)]))
            .get();

    return rows
        .map((row) => Fact(id: row.id, label: row.label, value: row.value))
        .toList();
  }

  Future<List<Milestone>> _milestonesOf(
    AppDatabase database,
    String friendId,
  ) async {
    final rows = await (database.select(
      database.milestones,
    )..where((row) => row.friendId.equals(friendId))).get();

    return rows
        .map(
          (row) => Milestone(
            id: row.id,
            label: row.label,
            onDate: CivilDate.fromEpochDay(row.onDate),
            repeatsYearly: row.repeatsYearly,
          ),
        )
        .toList();
  }

  Future<List<Affinity>> _affinitiesOf(
    AppDatabase database,
    String friendId,
  ) async {
    final rows = await database
        .customSelect(
          'select a.id, a.label from affinities a '
          'join friend_affinities fa on fa.affinity_id = a.id '
          'where fa.friend_id = ?',
          variables: [Variable<String>(friendId)],
          readsFrom: {database.affinities, database.friendAffinities},
        )
        .get();

    return rows
        .map(
          (row) => Affinity(
            id: row.read<String>('id'),
            label: row.read<String>('label'),
          ),
        )
        .toList();
  }
}
