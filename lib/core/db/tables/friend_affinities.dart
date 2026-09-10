import 'package:drift/drift.dart';

import 'affinities.dart';
import 'friends.dart';

/// Which Affinities a Friend carries.
@DataClassName('FriendAffinityRow')
class FriendAffinities extends Table {
  TextColumn get friendId => text().references(Friends, #id)();

  TextColumn get affinityId => text().references(Affinities, #id)();

  @override
  Set<Column> get primaryKey => {friendId, affinityId};
}
