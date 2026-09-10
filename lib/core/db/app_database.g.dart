// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FriendsTable extends Friends with TableInfo<$FriendsTable, FriendRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameFoldedMeta = const VerificationMeta(
    'nameFolded',
  );
  @override
  late final GeneratedColumn<String> nameFolded = GeneratedColumn<String>(
    'name_folded',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cadenceDaysMeta = const VerificationMeta(
    'cadenceDays',
  );
  @override
  late final GeneratedColumn<int> cadenceDays = GeneratedColumn<int>(
    'cadence_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameFolded, cadenceDays];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friends';
  @override
  VerificationContext validateIntegrity(
    Insertable<FriendRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_folded')) {
      context.handle(
        _nameFoldedMeta,
        nameFolded.isAcceptableOrUnknown(data['name_folded']!, _nameFoldedMeta),
      );
    } else if (isInserting) {
      context.missing(_nameFoldedMeta);
    }
    if (data.containsKey('cadence_days')) {
      context.handle(
        _cadenceDaysMeta,
        cadenceDays.isAcceptableOrUnknown(
          data['cadence_days']!,
          _cadenceDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cadenceDaysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FriendRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameFolded: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_folded'],
      )!,
      cadenceDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence_days'],
      )!,
    );
  }

  @override
  $FriendsTable createAlias(String alias) {
    return $FriendsTable(attachedDatabase, alias);
  }
}

class FriendRow extends DataClass implements Insertable<FriendRow> {
  final String id;
  final String name;
  final String nameFolded;

  /// The wanted Cadence, in whole days.
  final int cadenceDays;
  const FriendRow({
    required this.id,
    required this.name,
    required this.nameFolded,
    required this.cadenceDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['name_folded'] = Variable<String>(nameFolded);
    map['cadence_days'] = Variable<int>(cadenceDays);
    return map;
  }

  FriendsCompanion toCompanion(bool nullToAbsent) {
    return FriendsCompanion(
      id: Value(id),
      name: Value(name),
      nameFolded: Value(nameFolded),
      cadenceDays: Value(cadenceDays),
    );
  }

  factory FriendRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameFolded: serializer.fromJson<String>(json['nameFolded']),
      cadenceDays: serializer.fromJson<int>(json['cadenceDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameFolded': serializer.toJson<String>(nameFolded),
      'cadenceDays': serializer.toJson<int>(cadenceDays),
    };
  }

  FriendRow copyWith({
    String? id,
    String? name,
    String? nameFolded,
    int? cadenceDays,
  }) => FriendRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameFolded: nameFolded ?? this.nameFolded,
    cadenceDays: cadenceDays ?? this.cadenceDays,
  );
  FriendRow copyWithCompanion(FriendsCompanion data) {
    return FriendRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameFolded: data.nameFolded.present
          ? data.nameFolded.value
          : this.nameFolded,
      cadenceDays: data.cadenceDays.present
          ? data.cadenceDays.value
          : this.cadenceDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFolded: $nameFolded, ')
          ..write('cadenceDays: $cadenceDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameFolded, cadenceDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameFolded == this.nameFolded &&
          other.cadenceDays == this.cadenceDays);
}

class FriendsCompanion extends UpdateCompanion<FriendRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> nameFolded;
  final Value<int> cadenceDays;
  final Value<int> rowid;
  const FriendsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameFolded = const Value.absent(),
    this.cadenceDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendsCompanion.insert({
    required String id,
    required String name,
    required String nameFolded,
    required int cadenceDays,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nameFolded = Value(nameFolded),
       cadenceDays = Value(cadenceDays);
  static Insertable<FriendRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameFolded,
    Expression<int>? cadenceDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameFolded != null) 'name_folded': nameFolded,
      if (cadenceDays != null) 'cadence_days': cadenceDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? nameFolded,
    Value<int>? cadenceDays,
    Value<int>? rowid,
  }) {
    return FriendsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFolded: nameFolded ?? this.nameFolded,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameFolded.present) {
      map['name_folded'] = Variable<String>(nameFolded.value);
    }
    if (cadenceDays.present) {
      map['cadence_days'] = Variable<int>(cadenceDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFolded: $nameFolded, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeetingsTable extends Meetings
    with TableInfo<$MeetingsTable, MeetingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends (id)',
    ),
  );
  static const VerificationMeta _happenedOnMeta = const VerificationMeta(
    'happenedOn',
  );
  @override
  late final GeneratedColumn<int> happenedOn = GeneratedColumn<int>(
    'happened_on',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _happenedAtMinuteMeta = const VerificationMeta(
    'happenedAtMinute',
  );
  @override
  late final GeneratedColumn<int> happenedAtMinute = GeneratedColumn<int>(
    'happened_at_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthInMinutesMeta = const VerificationMeta(
    'lengthInMinutes',
  );
  @override
  late final GeneratedColumn<int> lengthInMinutes = GeneratedColumn<int>(
    'length_in_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feelingMeta = const VerificationMeta(
    'feeling',
  );
  @override
  late final GeneratedColumn<String> feeling = GeneratedColumn<String>(
    'feeling',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recapMeta = const VerificationMeta('recap');
  @override
  late final GeneratedColumn<String> recap = GeneratedColumn<String>(
    'recap',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    friendId,
    happenedOn,
    happenedAtMinute,
    createdAt,
    place,
    lengthInMinutes,
    feeling,
    recap,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeetingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('happened_on')) {
      context.handle(
        _happenedOnMeta,
        happenedOn.isAcceptableOrUnknown(data['happened_on']!, _happenedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedOnMeta);
    }
    if (data.containsKey('happened_at_minute')) {
      context.handle(
        _happenedAtMinuteMeta,
        happenedAtMinute.isAcceptableOrUnknown(
          data['happened_at_minute']!,
          _happenedAtMinuteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    }
    if (data.containsKey('length_in_minutes')) {
      context.handle(
        _lengthInMinutesMeta,
        lengthInMinutes.isAcceptableOrUnknown(
          data['length_in_minutes']!,
          _lengthInMinutesMeta,
        ),
      );
    }
    if (data.containsKey('feeling')) {
      context.handle(
        _feelingMeta,
        feeling.isAcceptableOrUnknown(data['feeling']!, _feelingMeta),
      );
    }
    if (data.containsKey('recap')) {
      context.handle(
        _recapMeta,
        recap.isAcceptableOrUnknown(data['recap']!, _recapMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeetingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeetingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friend_id'],
      )!,
      happenedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}happened_on'],
      )!,
      happenedAtMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}happened_at_minute'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      ),
      lengthInMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length_in_minutes'],
      ),
      feeling: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feeling'],
      ),
      recap: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recap'],
      ),
    );
  }

  @override
  $MeetingsTable createAlias(String alias) {
    return $MeetingsTable(attachedDatabase, alias);
  }
}

class MeetingRow extends DataClass implements Insertable<MeetingRow> {
  final String id;
  final String friendId;
  final int happenedOn;
  final int? happenedAtMinute;

  /// When the row was first written, in milliseconds from the epoch.
  ///
  /// It breaks a tie between two Meetings on one Civil Date, so a whole save
  /// carries the old instant forward rather than stamping a new one. See
  /// ADR-0021.
  final int createdAt;
  final String? place;

  /// How long the Meeting was, in minutes.
  final int? lengthInMinutes;

  /// How the Meeting felt, in the User's own words.
  final String? feeling;
  final String? recap;
  const MeetingRow({
    required this.id,
    required this.friendId,
    required this.happenedOn,
    this.happenedAtMinute,
    required this.createdAt,
    this.place,
    this.lengthInMinutes,
    this.feeling,
    this.recap,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['friend_id'] = Variable<String>(friendId);
    map['happened_on'] = Variable<int>(happenedOn);
    if (!nullToAbsent || happenedAtMinute != null) {
      map['happened_at_minute'] = Variable<int>(happenedAtMinute);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || place != null) {
      map['place'] = Variable<String>(place);
    }
    if (!nullToAbsent || lengthInMinutes != null) {
      map['length_in_minutes'] = Variable<int>(lengthInMinutes);
    }
    if (!nullToAbsent || feeling != null) {
      map['feeling'] = Variable<String>(feeling);
    }
    if (!nullToAbsent || recap != null) {
      map['recap'] = Variable<String>(recap);
    }
    return map;
  }

  MeetingsCompanion toCompanion(bool nullToAbsent) {
    return MeetingsCompanion(
      id: Value(id),
      friendId: Value(friendId),
      happenedOn: Value(happenedOn),
      happenedAtMinute: happenedAtMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(happenedAtMinute),
      createdAt: Value(createdAt),
      place: place == null && nullToAbsent
          ? const Value.absent()
          : Value(place),
      lengthInMinutes: lengthInMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthInMinutes),
      feeling: feeling == null && nullToAbsent
          ? const Value.absent()
          : Value(feeling),
      recap: recap == null && nullToAbsent
          ? const Value.absent()
          : Value(recap),
    );
  }

  factory MeetingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeetingRow(
      id: serializer.fromJson<String>(json['id']),
      friendId: serializer.fromJson<String>(json['friendId']),
      happenedOn: serializer.fromJson<int>(json['happenedOn']),
      happenedAtMinute: serializer.fromJson<int?>(json['happenedAtMinute']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      place: serializer.fromJson<String?>(json['place']),
      lengthInMinutes: serializer.fromJson<int?>(json['lengthInMinutes']),
      feeling: serializer.fromJson<String?>(json['feeling']),
      recap: serializer.fromJson<String?>(json['recap']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'friendId': serializer.toJson<String>(friendId),
      'happenedOn': serializer.toJson<int>(happenedOn),
      'happenedAtMinute': serializer.toJson<int?>(happenedAtMinute),
      'createdAt': serializer.toJson<int>(createdAt),
      'place': serializer.toJson<String?>(place),
      'lengthInMinutes': serializer.toJson<int?>(lengthInMinutes),
      'feeling': serializer.toJson<String?>(feeling),
      'recap': serializer.toJson<String?>(recap),
    };
  }

  MeetingRow copyWith({
    String? id,
    String? friendId,
    int? happenedOn,
    Value<int?> happenedAtMinute = const Value.absent(),
    int? createdAt,
    Value<String?> place = const Value.absent(),
    Value<int?> lengthInMinutes = const Value.absent(),
    Value<String?> feeling = const Value.absent(),
    Value<String?> recap = const Value.absent(),
  }) => MeetingRow(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    happenedOn: happenedOn ?? this.happenedOn,
    happenedAtMinute: happenedAtMinute.present
        ? happenedAtMinute.value
        : this.happenedAtMinute,
    createdAt: createdAt ?? this.createdAt,
    place: place.present ? place.value : this.place,
    lengthInMinutes: lengthInMinutes.present
        ? lengthInMinutes.value
        : this.lengthInMinutes,
    feeling: feeling.present ? feeling.value : this.feeling,
    recap: recap.present ? recap.value : this.recap,
  );
  MeetingRow copyWithCompanion(MeetingsCompanion data) {
    return MeetingRow(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      happenedOn: data.happenedOn.present
          ? data.happenedOn.value
          : this.happenedOn,
      happenedAtMinute: data.happenedAtMinute.present
          ? data.happenedAtMinute.value
          : this.happenedAtMinute,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      place: data.place.present ? data.place.value : this.place,
      lengthInMinutes: data.lengthInMinutes.present
          ? data.lengthInMinutes.value
          : this.lengthInMinutes,
      feeling: data.feeling.present ? data.feeling.value : this.feeling,
      recap: data.recap.present ? data.recap.value : this.recap,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeetingRow(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('happenedAtMinute: $happenedAtMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('place: $place, ')
          ..write('lengthInMinutes: $lengthInMinutes, ')
          ..write('feeling: $feeling, ')
          ..write('recap: $recap')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    friendId,
    happenedOn,
    happenedAtMinute,
    createdAt,
    place,
    lengthInMinutes,
    feeling,
    recap,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeetingRow &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.happenedOn == this.happenedOn &&
          other.happenedAtMinute == this.happenedAtMinute &&
          other.createdAt == this.createdAt &&
          other.place == this.place &&
          other.lengthInMinutes == this.lengthInMinutes &&
          other.feeling == this.feeling &&
          other.recap == this.recap);
}

class MeetingsCompanion extends UpdateCompanion<MeetingRow> {
  final Value<String> id;
  final Value<String> friendId;
  final Value<int> happenedOn;
  final Value<int?> happenedAtMinute;
  final Value<int> createdAt;
  final Value<String?> place;
  final Value<int?> lengthInMinutes;
  final Value<String?> feeling;
  final Value<String?> recap;
  final Value<int> rowid;
  const MeetingsCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.happenedOn = const Value.absent(),
    this.happenedAtMinute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.place = const Value.absent(),
    this.lengthInMinutes = const Value.absent(),
    this.feeling = const Value.absent(),
    this.recap = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeetingsCompanion.insert({
    required String id,
    required String friendId,
    required int happenedOn,
    this.happenedAtMinute = const Value.absent(),
    required int createdAt,
    this.place = const Value.absent(),
    this.lengthInMinutes = const Value.absent(),
    this.feeling = const Value.absent(),
    this.recap = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendId = Value(friendId),
       happenedOn = Value(happenedOn),
       createdAt = Value(createdAt);
  static Insertable<MeetingRow> custom({
    Expression<String>? id,
    Expression<String>? friendId,
    Expression<int>? happenedOn,
    Expression<int>? happenedAtMinute,
    Expression<int>? createdAt,
    Expression<String>? place,
    Expression<int>? lengthInMinutes,
    Expression<String>? feeling,
    Expression<String>? recap,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (happenedOn != null) 'happened_on': happenedOn,
      if (happenedAtMinute != null) 'happened_at_minute': happenedAtMinute,
      if (createdAt != null) 'created_at': createdAt,
      if (place != null) 'place': place,
      if (lengthInMinutes != null) 'length_in_minutes': lengthInMinutes,
      if (feeling != null) 'feeling': feeling,
      if (recap != null) 'recap': recap,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeetingsCompanion copyWith({
    Value<String>? id,
    Value<String>? friendId,
    Value<int>? happenedOn,
    Value<int?>? happenedAtMinute,
    Value<int>? createdAt,
    Value<String?>? place,
    Value<int?>? lengthInMinutes,
    Value<String?>? feeling,
    Value<String?>? recap,
    Value<int>? rowid,
  }) {
    return MeetingsCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      happenedOn: happenedOn ?? this.happenedOn,
      happenedAtMinute: happenedAtMinute ?? this.happenedAtMinute,
      createdAt: createdAt ?? this.createdAt,
      place: place ?? this.place,
      lengthInMinutes: lengthInMinutes ?? this.lengthInMinutes,
      feeling: feeling ?? this.feeling,
      recap: recap ?? this.recap,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (happenedOn.present) {
      map['happened_on'] = Variable<int>(happenedOn.value);
    }
    if (happenedAtMinute.present) {
      map['happened_at_minute'] = Variable<int>(happenedAtMinute.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (lengthInMinutes.present) {
      map['length_in_minutes'] = Variable<int>(lengthInMinutes.value);
    }
    if (feeling.present) {
      map['feeling'] = Variable<String>(feeling.value);
    }
    if (recap.present) {
      map['recap'] = Variable<String>(recap.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingsCompanion(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('happenedOn: $happenedOn, ')
          ..write('happenedAtMinute: $happenedAtMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('place: $place, ')
          ..write('lengthInMinutes: $lengthInMinutes, ')
          ..write('feeling: $feeling, ')
          ..write('recap: $recap, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyFoldedMeta = const VerificationMeta(
    'bodyFolded',
  );
  @override
  late final GeneratedColumn<String> bodyFolded = GeneratedColumn<String>(
    'body_folded',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _writtenOnMeta = const VerificationMeta(
    'writtenOn',
  );
  @override
  late final GeneratedColumn<int> writtenOn = GeneratedColumn<int>(
    'written_on',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedOnMeta = const VerificationMeta(
    'resolvedOn',
  );
  @override
  late final GeneratedColumn<int> resolvedOn = GeneratedColumn<int>(
    'resolved_on',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    friendId,
    label,
    body,
    bodyFolded,
    writtenOn,
    resolvedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('body_folded')) {
      context.handle(
        _bodyFoldedMeta,
        bodyFolded.isAcceptableOrUnknown(data['body_folded']!, _bodyFoldedMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyFoldedMeta);
    }
    if (data.containsKey('written_on')) {
      context.handle(
        _writtenOnMeta,
        writtenOn.isAcceptableOrUnknown(data['written_on']!, _writtenOnMeta),
      );
    } else if (isInserting) {
      context.missing(_writtenOnMeta);
    }
    if (data.containsKey('resolved_on')) {
      context.handle(
        _resolvedOnMeta,
        resolvedOn.isAcceptableOrUnknown(data['resolved_on']!, _resolvedOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friend_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      bodyFolded: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_folded'],
      )!,
      writtenOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}written_on'],
      )!,
      resolvedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_on'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String friendId;
  final String label;
  final String body;

  /// The Folded Text of [body], which search matches.
  final String bodyFolded;

  /// The Civil Date the row was written on.
  final int writtenOn;

  /// The Civil Date the User marked it done on. Null while it is open.
  final int? resolvedOn;
  const NoteRow({
    required this.id,
    required this.friendId,
    required this.label,
    required this.body,
    required this.bodyFolded,
    required this.writtenOn,
    this.resolvedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['friend_id'] = Variable<String>(friendId);
    map['label'] = Variable<String>(label);
    map['body'] = Variable<String>(body);
    map['body_folded'] = Variable<String>(bodyFolded);
    map['written_on'] = Variable<int>(writtenOn);
    if (!nullToAbsent || resolvedOn != null) {
      map['resolved_on'] = Variable<int>(resolvedOn);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      friendId: Value(friendId),
      label: Value(label),
      body: Value(body),
      bodyFolded: Value(bodyFolded),
      writtenOn: Value(writtenOn),
      resolvedOn: resolvedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedOn),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      friendId: serializer.fromJson<String>(json['friendId']),
      label: serializer.fromJson<String>(json['label']),
      body: serializer.fromJson<String>(json['body']),
      bodyFolded: serializer.fromJson<String>(json['bodyFolded']),
      writtenOn: serializer.fromJson<int>(json['writtenOn']),
      resolvedOn: serializer.fromJson<int?>(json['resolvedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'friendId': serializer.toJson<String>(friendId),
      'label': serializer.toJson<String>(label),
      'body': serializer.toJson<String>(body),
      'bodyFolded': serializer.toJson<String>(bodyFolded),
      'writtenOn': serializer.toJson<int>(writtenOn),
      'resolvedOn': serializer.toJson<int?>(resolvedOn),
    };
  }

  NoteRow copyWith({
    String? id,
    String? friendId,
    String? label,
    String? body,
    String? bodyFolded,
    int? writtenOn,
    Value<int?> resolvedOn = const Value.absent(),
  }) => NoteRow(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    label: label ?? this.label,
    body: body ?? this.body,
    bodyFolded: bodyFolded ?? this.bodyFolded,
    writtenOn: writtenOn ?? this.writtenOn,
    resolvedOn: resolvedOn.present ? resolvedOn.value : this.resolvedOn,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      label: data.label.present ? data.label.value : this.label,
      body: data.body.present ? data.body.value : this.body,
      bodyFolded: data.bodyFolded.present
          ? data.bodyFolded.value
          : this.bodyFolded,
      writtenOn: data.writtenOn.present ? data.writtenOn.value : this.writtenOn,
      resolvedOn: data.resolvedOn.present
          ? data.resolvedOn.value
          : this.resolvedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('body: $body, ')
          ..write('bodyFolded: $bodyFolded, ')
          ..write('writtenOn: $writtenOn, ')
          ..write('resolvedOn: $resolvedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, friendId, label, body, bodyFolded, writtenOn, resolvedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.label == this.label &&
          other.body == this.body &&
          other.bodyFolded == this.bodyFolded &&
          other.writtenOn == this.writtenOn &&
          other.resolvedOn == this.resolvedOn);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> friendId;
  final Value<String> label;
  final Value<String> body;
  final Value<String> bodyFolded;
  final Value<int> writtenOn;
  final Value<int?> resolvedOn;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.label = const Value.absent(),
    this.body = const Value.absent(),
    this.bodyFolded = const Value.absent(),
    this.writtenOn = const Value.absent(),
    this.resolvedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String friendId,
    required String label,
    required String body,
    required String bodyFolded,
    required int writtenOn,
    this.resolvedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendId = Value(friendId),
       label = Value(label),
       body = Value(body),
       bodyFolded = Value(bodyFolded),
       writtenOn = Value(writtenOn);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? friendId,
    Expression<String>? label,
    Expression<String>? body,
    Expression<String>? bodyFolded,
    Expression<int>? writtenOn,
    Expression<int>? resolvedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (label != null) 'label': label,
      if (body != null) 'body': body,
      if (bodyFolded != null) 'body_folded': bodyFolded,
      if (writtenOn != null) 'written_on': writtenOn,
      if (resolvedOn != null) 'resolved_on': resolvedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? friendId,
    Value<String>? label,
    Value<String>? body,
    Value<String>? bodyFolded,
    Value<int>? writtenOn,
    Value<int?>? resolvedOn,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      label: label ?? this.label,
      body: body ?? this.body,
      bodyFolded: bodyFolded ?? this.bodyFolded,
      writtenOn: writtenOn ?? this.writtenOn,
      resolvedOn: resolvedOn ?? this.resolvedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (bodyFolded.present) {
      map['body_folded'] = Variable<String>(bodyFolded.value);
    }
    if (writtenOn.present) {
      map['written_on'] = Variable<int>(writtenOn.value);
    }
    if (resolvedOn.present) {
      map['resolved_on'] = Variable<int>(resolvedOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('body: $body, ')
          ..write('bodyFolded: $bodyFolded, ')
          ..write('writtenOn: $writtenOn, ')
          ..write('resolvedOn: $resolvedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AffinitiesTable extends Affinities
    with TableInfo<$AffinitiesTable, AffinityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AffinitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelFoldedMeta = const VerificationMeta(
    'labelFolded',
  );
  @override
  late final GeneratedColumn<String> labelFolded = GeneratedColumn<String>(
    'label_folded',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSeedMeta = const VerificationMeta('isSeed');
  @override
  late final GeneratedColumn<bool> isSeed = GeneratedColumn<bool>(
    'is_seed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_seed" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, labelFolded, isSeed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'affinities';
  @override
  VerificationContext validateIntegrity(
    Insertable<AffinityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('label_folded')) {
      context.handle(
        _labelFoldedMeta,
        labelFolded.isAcceptableOrUnknown(
          data['label_folded']!,
          _labelFoldedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_labelFoldedMeta);
    }
    if (data.containsKey('is_seed')) {
      context.handle(
        _isSeedMeta,
        isSeed.isAcceptableOrUnknown(data['is_seed']!, _isSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_isSeedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AffinityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AffinityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      labelFolded: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_folded'],
      )!,
      isSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_seed'],
      )!,
    );
  }

  @override
  $AffinitiesTable createAlias(String alias) {
    return $AffinitiesTable(attachedDatabase, alias);
  }
}

class AffinityRow extends DataClass implements Insertable<AffinityRow> {
  final String id;
  final String label;

  /// The Folded Text of [label], which search matches.
  final String labelFolded;
  final bool isSeed;
  const AffinityRow({
    required this.id,
    required this.label,
    required this.labelFolded,
    required this.isSeed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['label_folded'] = Variable<String>(labelFolded);
    map['is_seed'] = Variable<bool>(isSeed);
    return map;
  }

  AffinitiesCompanion toCompanion(bool nullToAbsent) {
    return AffinitiesCompanion(
      id: Value(id),
      label: Value(label),
      labelFolded: Value(labelFolded),
      isSeed: Value(isSeed),
    );
  }

  factory AffinityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AffinityRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      labelFolded: serializer.fromJson<String>(json['labelFolded']),
      isSeed: serializer.fromJson<bool>(json['isSeed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'labelFolded': serializer.toJson<String>(labelFolded),
      'isSeed': serializer.toJson<bool>(isSeed),
    };
  }

  AffinityRow copyWith({
    String? id,
    String? label,
    String? labelFolded,
    bool? isSeed,
  }) => AffinityRow(
    id: id ?? this.id,
    label: label ?? this.label,
    labelFolded: labelFolded ?? this.labelFolded,
    isSeed: isSeed ?? this.isSeed,
  );
  AffinityRow copyWithCompanion(AffinitiesCompanion data) {
    return AffinityRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      labelFolded: data.labelFolded.present
          ? data.labelFolded.value
          : this.labelFolded,
      isSeed: data.isSeed.present ? data.isSeed.value : this.isSeed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AffinityRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('labelFolded: $labelFolded, ')
          ..write('isSeed: $isSeed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, labelFolded, isSeed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AffinityRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.labelFolded == this.labelFolded &&
          other.isSeed == this.isSeed);
}

class AffinitiesCompanion extends UpdateCompanion<AffinityRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> labelFolded;
  final Value<bool> isSeed;
  final Value<int> rowid;
  const AffinitiesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.labelFolded = const Value.absent(),
    this.isSeed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AffinitiesCompanion.insert({
    required String id,
    required String label,
    required String labelFolded,
    required bool isSeed,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       labelFolded = Value(labelFolded),
       isSeed = Value(isSeed);
  static Insertable<AffinityRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? labelFolded,
    Expression<bool>? isSeed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (labelFolded != null) 'label_folded': labelFolded,
      if (isSeed != null) 'is_seed': isSeed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AffinitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? labelFolded,
    Value<bool>? isSeed,
    Value<int>? rowid,
  }) {
    return AffinitiesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      labelFolded: labelFolded ?? this.labelFolded,
      isSeed: isSeed ?? this.isSeed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (labelFolded.present) {
      map['label_folded'] = Variable<String>(labelFolded.value);
    }
    if (isSeed.present) {
      map['is_seed'] = Variable<bool>(isSeed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AffinitiesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('labelFolded: $labelFolded, ')
          ..write('isSeed: $isSeed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendAffinitiesTable extends FriendAffinities
    with TableInfo<$FriendAffinitiesTable, FriendAffinityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendAffinitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends (id)',
    ),
  );
  static const VerificationMeta _affinityIdMeta = const VerificationMeta(
    'affinityId',
  );
  @override
  late final GeneratedColumn<String> affinityId = GeneratedColumn<String>(
    'affinity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES affinities (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [friendId, affinityId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friend_affinities';
  @override
  VerificationContext validateIntegrity(
    Insertable<FriendAffinityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('affinity_id')) {
      context.handle(
        _affinityIdMeta,
        affinityId.isAcceptableOrUnknown(data['affinity_id']!, _affinityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_affinityIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {friendId, affinityId};
  @override
  FriendAffinityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendAffinityRow(
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friend_id'],
      )!,
      affinityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}affinity_id'],
      )!,
    );
  }

  @override
  $FriendAffinitiesTable createAlias(String alias) {
    return $FriendAffinitiesTable(attachedDatabase, alias);
  }
}

class FriendAffinityRow extends DataClass
    implements Insertable<FriendAffinityRow> {
  final String friendId;
  final String affinityId;
  const FriendAffinityRow({required this.friendId, required this.affinityId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['friend_id'] = Variable<String>(friendId);
    map['affinity_id'] = Variable<String>(affinityId);
    return map;
  }

  FriendAffinitiesCompanion toCompanion(bool nullToAbsent) {
    return FriendAffinitiesCompanion(
      friendId: Value(friendId),
      affinityId: Value(affinityId),
    );
  }

  factory FriendAffinityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendAffinityRow(
      friendId: serializer.fromJson<String>(json['friendId']),
      affinityId: serializer.fromJson<String>(json['affinityId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'friendId': serializer.toJson<String>(friendId),
      'affinityId': serializer.toJson<String>(affinityId),
    };
  }

  FriendAffinityRow copyWith({String? friendId, String? affinityId}) =>
      FriendAffinityRow(
        friendId: friendId ?? this.friendId,
        affinityId: affinityId ?? this.affinityId,
      );
  FriendAffinityRow copyWithCompanion(FriendAffinitiesCompanion data) {
    return FriendAffinityRow(
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      affinityId: data.affinityId.present
          ? data.affinityId.value
          : this.affinityId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendAffinityRow(')
          ..write('friendId: $friendId, ')
          ..write('affinityId: $affinityId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(friendId, affinityId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendAffinityRow &&
          other.friendId == this.friendId &&
          other.affinityId == this.affinityId);
}

class FriendAffinitiesCompanion extends UpdateCompanion<FriendAffinityRow> {
  final Value<String> friendId;
  final Value<String> affinityId;
  final Value<int> rowid;
  const FriendAffinitiesCompanion({
    this.friendId = const Value.absent(),
    this.affinityId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendAffinitiesCompanion.insert({
    required String friendId,
    required String affinityId,
    this.rowid = const Value.absent(),
  }) : friendId = Value(friendId),
       affinityId = Value(affinityId);
  static Insertable<FriendAffinityRow> custom({
    Expression<String>? friendId,
    Expression<String>? affinityId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (friendId != null) 'friend_id': friendId,
      if (affinityId != null) 'affinity_id': affinityId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendAffinitiesCompanion copyWith({
    Value<String>? friendId,
    Value<String>? affinityId,
    Value<int>? rowid,
  }) {
    return FriendAffinitiesCompanion(
      friendId: friendId ?? this.friendId,
      affinityId: affinityId ?? this.affinityId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (affinityId.present) {
      map['affinity_id'] = Variable<String>(affinityId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendAffinitiesCompanion(')
          ..write('friendId: $friendId, ')
          ..write('affinityId: $affinityId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FactsTable extends Facts with TableInfo<$FactsTable, FactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, friendId, label, value, ordinal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friend_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
    );
  }

  @override
  $FactsTable createAlias(String alias) {
    return $FactsTable(attachedDatabase, alias);
  }
}

class FactRow extends DataClass implements Insertable<FactRow> {
  final String id;
  final String friendId;
  final String label;
  final String value;

  /// Where the Fact sits in the Friend's own order, from zero.
  ///
  /// The Friend holds the Facts in order and the aggregate carries no such
  /// number, so this column exists to give that order back on the next read.
  final int ordinal;
  const FactRow({
    required this.id,
    required this.friendId,
    required this.label,
    required this.value,
    required this.ordinal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['friend_id'] = Variable<String>(friendId);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<String>(value);
    map['ordinal'] = Variable<int>(ordinal);
    return map;
  }

  FactsCompanion toCompanion(bool nullToAbsent) {
    return FactsCompanion(
      id: Value(id),
      friendId: Value(friendId),
      label: Value(label),
      value: Value(value),
      ordinal: Value(ordinal),
    );
  }

  factory FactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactRow(
      id: serializer.fromJson<String>(json['id']),
      friendId: serializer.fromJson<String>(json['friendId']),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<String>(json['value']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'friendId': serializer.toJson<String>(friendId),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<String>(value),
      'ordinal': serializer.toJson<int>(ordinal),
    };
  }

  FactRow copyWith({
    String? id,
    String? friendId,
    String? label,
    String? value,
    int? ordinal,
  }) => FactRow(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    label: label ?? this.label,
    value: value ?? this.value,
    ordinal: ordinal ?? this.ordinal,
  );
  FactRow copyWithCompanion(FactsCompanion data) {
    return FactRow(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactRow(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('ordinal: $ordinal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, friendId, label, value, ordinal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactRow &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.label == this.label &&
          other.value == this.value &&
          other.ordinal == this.ordinal);
}

class FactsCompanion extends UpdateCompanion<FactRow> {
  final Value<String> id;
  final Value<String> friendId;
  final Value<String> label;
  final Value<String> value;
  final Value<int> ordinal;
  final Value<int> rowid;
  const FactsCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactsCompanion.insert({
    required String id,
    required String friendId,
    required String label,
    required String value,
    required int ordinal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendId = Value(friendId),
       label = Value(label),
       value = Value(value),
       ordinal = Value(ordinal);
  static Insertable<FactRow> custom({
    Expression<String>? id,
    Expression<String>? friendId,
    Expression<String>? label,
    Expression<String>? value,
    Expression<int>? ordinal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (ordinal != null) 'ordinal': ordinal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactsCompanion copyWith({
    Value<String>? id,
    Value<String>? friendId,
    Value<String>? label,
    Value<String>? value,
    Value<int>? ordinal,
    Value<int>? rowid,
  }) {
    return FactsCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      label: label ?? this.label,
      value: value ?? this.value,
      ordinal: ordinal ?? this.ordinal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactsCompanion(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('ordinal: $ordinal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, MilestoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendIdMeta = const VerificationMeta(
    'friendId',
  );
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
    'friend_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES friends (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onDateMeta = const VerificationMeta('onDate');
  @override
  late final GeneratedColumn<int> onDate = GeneratedColumn<int>(
    'on_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatsYearlyMeta = const VerificationMeta(
    'repeatsYearly',
  );
  @override
  late final GeneratedColumn<bool> repeatsYearly = GeneratedColumn<bool>(
    'repeats_yearly',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeats_yearly" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    friendId,
    label,
    onDate,
    repeatsYearly,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilestoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(
        _friendIdMeta,
        friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta),
      );
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('on_date')) {
      context.handle(
        _onDateMeta,
        onDate.isAcceptableOrUnknown(data['on_date']!, _onDateMeta),
      );
    } else if (isInserting) {
      context.missing(_onDateMeta);
    }
    if (data.containsKey('repeats_yearly')) {
      context.handle(
        _repeatsYearlyMeta,
        repeatsYearly.isAcceptableOrUnknown(
          data['repeats_yearly']!,
          _repeatsYearlyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repeatsYearlyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MilestoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilestoneRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      friendId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friend_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      onDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}on_date'],
      )!,
      repeatsYearly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeats_yearly'],
      )!,
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
}

class MilestoneRow extends DataClass implements Insertable<MilestoneRow> {
  final String id;
  final String friendId;
  final String label;
  final int onDate;
  final bool repeatsYearly;
  const MilestoneRow({
    required this.id,
    required this.friendId,
    required this.label,
    required this.onDate,
    required this.repeatsYearly,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['friend_id'] = Variable<String>(friendId);
    map['label'] = Variable<String>(label);
    map['on_date'] = Variable<int>(onDate);
    map['repeats_yearly'] = Variable<bool>(repeatsYearly);
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      friendId: Value(friendId),
      label: Value(label),
      onDate: Value(onDate),
      repeatsYearly: Value(repeatsYearly),
    );
  }

  factory MilestoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilestoneRow(
      id: serializer.fromJson<String>(json['id']),
      friendId: serializer.fromJson<String>(json['friendId']),
      label: serializer.fromJson<String>(json['label']),
      onDate: serializer.fromJson<int>(json['onDate']),
      repeatsYearly: serializer.fromJson<bool>(json['repeatsYearly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'friendId': serializer.toJson<String>(friendId),
      'label': serializer.toJson<String>(label),
      'onDate': serializer.toJson<int>(onDate),
      'repeatsYearly': serializer.toJson<bool>(repeatsYearly),
    };
  }

  MilestoneRow copyWith({
    String? id,
    String? friendId,
    String? label,
    int? onDate,
    bool? repeatsYearly,
  }) => MilestoneRow(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    label: label ?? this.label,
    onDate: onDate ?? this.onDate,
    repeatsYearly: repeatsYearly ?? this.repeatsYearly,
  );
  MilestoneRow copyWithCompanion(MilestonesCompanion data) {
    return MilestoneRow(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      label: data.label.present ? data.label.value : this.label,
      onDate: data.onDate.present ? data.onDate.value : this.onDate,
      repeatsYearly: data.repeatsYearly.present
          ? data.repeatsYearly.value
          : this.repeatsYearly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneRow(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('onDate: $onDate, ')
          ..write('repeatsYearly: $repeatsYearly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, friendId, label, onDate, repeatsYearly);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilestoneRow &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.label == this.label &&
          other.onDate == this.onDate &&
          other.repeatsYearly == this.repeatsYearly);
}

class MilestonesCompanion extends UpdateCompanion<MilestoneRow> {
  final Value<String> id;
  final Value<String> friendId;
  final Value<String> label;
  final Value<int> onDate;
  final Value<bool> repeatsYearly;
  final Value<int> rowid;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.label = const Value.absent(),
    this.onDate = const Value.absent(),
    this.repeatsYearly = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestonesCompanion.insert({
    required String id,
    required String friendId,
    required String label,
    required int onDate,
    required bool repeatsYearly,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendId = Value(friendId),
       label = Value(label),
       onDate = Value(onDate),
       repeatsYearly = Value(repeatsYearly);
  static Insertable<MilestoneRow> custom({
    Expression<String>? id,
    Expression<String>? friendId,
    Expression<String>? label,
    Expression<int>? onDate,
    Expression<bool>? repeatsYearly,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (label != null) 'label': label,
      if (onDate != null) 'on_date': onDate,
      if (repeatsYearly != null) 'repeats_yearly': repeatsYearly,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestonesCompanion copyWith({
    Value<String>? id,
    Value<String>? friendId,
    Value<String>? label,
    Value<int>? onDate,
    Value<bool>? repeatsYearly,
    Value<int>? rowid,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      label: label ?? this.label,
      onDate: onDate ?? this.onDate,
      repeatsYearly: repeatsYearly ?? this.repeatsYearly,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (onDate.present) {
      map['on_date'] = Variable<int>(onDate.value);
    }
    if (repeatsYearly.present) {
      map['repeats_yearly'] = Variable<bool>(repeatsYearly.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('onDate: $onDate, ')
          ..write('repeatsYearly: $repeatsYearly, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FriendsTable friends = $FriendsTable(this);
  late final $MeetingsTable meetings = $MeetingsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $AffinitiesTable affinities = $AffinitiesTable(this);
  late final $FriendAffinitiesTable friendAffinities = $FriendAffinitiesTable(
    this,
  );
  late final $FactsTable facts = $FactsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    friends,
    meetings,
    notes,
    affinities,
    friendAffinities,
    facts,
    milestones,
  ];
}

typedef $$FriendsTableCreateCompanionBuilder =
    FriendsCompanion Function({
      required String id,
      required String name,
      required String nameFolded,
      required int cadenceDays,
      Value<int> rowid,
    });
typedef $$FriendsTableUpdateCompanionBuilder =
    FriendsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> nameFolded,
      Value<int> cadenceDays,
      Value<int> rowid,
    });

final class $$FriendsTableReferences
    extends BaseReferences<_$AppDatabase, $FriendsTable, FriendRow> {
  $$FriendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeetingsTable, List<MeetingRow>>
  _meetingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.meetings,
    aliasName: 'friends__id__meetings__friend_id',
  );

  $$MeetingsTableProcessedTableManager get meetingsRefs {
    final manager = $$MeetingsTableTableManager(
      $_db,
      $_db.meetings,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_meetingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<NoteRow>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'friends__id__notes__friend_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FriendAffinitiesTable, List<FriendAffinityRow>>
  _friendAffinitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.friendAffinities,
    aliasName: 'friends__id__friend_affinities__friend_id',
  );

  $$FriendAffinitiesTableProcessedTableManager get friendAffinitiesRefs {
    final manager = $$FriendAffinitiesTableTableManager(
      $_db,
      $_db.friendAffinities,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _friendAffinitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FactsTable, List<FactRow>> _factsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.facts,
    aliasName: 'friends__id__facts__friend_id',
  );

  $$FactsTableProcessedTableManager get factsRefs {
    final manager = $$FactsTableTableManager(
      $_db,
      $_db.facts,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_factsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MilestonesTable, List<MilestoneRow>>
  _milestonesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milestones,
    aliasName: 'friends__id__milestones__friend_id',
  );

  $$MilestonesTableProcessedTableManager get milestonesRefs {
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.friendId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FriendsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameFolded => $composableBuilder(
    column: $table.nameFolded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> meetingsRefs(
    Expression<bool> Function($$MeetingsTableFilterComposer f) f,
  ) {
    final $$MeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableFilterComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> friendAffinitiesRefs(
    Expression<bool> Function($$FriendAffinitiesTableFilterComposer f) f,
  ) {
    final $$FriendAffinitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.friendAffinities,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendAffinitiesTableFilterComposer(
            $db: $db,
            $table: $db.friendAffinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> factsRefs(
    Expression<bool> Function($$FactsTableFilterComposer f) f,
  ) {
    final $$FactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableFilterComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> milestonesRefs(
    Expression<bool> Function($$MilestonesTableFilterComposer f) f,
  ) {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FriendsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameFolded => $composableBuilder(
    column: $table.nameFolded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FriendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameFolded => $composableBuilder(
    column: $table.nameFolded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => column,
  );

  Expression<T> meetingsRefs<T extends Object>(
    Expression<T> Function($$MeetingsTableAnnotationComposer a) f,
  ) {
    final $$MeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> friendAffinitiesRefs<T extends Object>(
    Expression<T> Function($$FriendAffinitiesTableAnnotationComposer a) f,
  ) {
    final $$FriendAffinitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.friendAffinities,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendAffinitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.friendAffinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> factsRefs<T extends Object>(
    Expression<T> Function($$FactsTableAnnotationComposer a) f,
  ) {
    final $$FactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.facts,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FactsTableAnnotationComposer(
            $db: $db,
            $table: $db.facts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> milestonesRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.friendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FriendsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FriendsTable,
          FriendRow,
          $$FriendsTableFilterComposer,
          $$FriendsTableOrderingComposer,
          $$FriendsTableAnnotationComposer,
          $$FriendsTableCreateCompanionBuilder,
          $$FriendsTableUpdateCompanionBuilder,
          (FriendRow, $$FriendsTableReferences),
          FriendRow,
          PrefetchHooks Function({
            bool meetingsRefs,
            bool notesRefs,
            bool friendAffinitiesRefs,
            bool factsRefs,
            bool milestonesRefs,
          })
        > {
  $$FriendsTableTableManager(_$AppDatabase db, $FriendsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameFolded = const Value.absent(),
                Value<int> cadenceDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FriendsCompanion(
                id: id,
                name: name,
                nameFolded: nameFolded,
                cadenceDays: cadenceDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String nameFolded,
                required int cadenceDays,
                Value<int> rowid = const Value.absent(),
              }) => FriendsCompanion.insert(
                id: id,
                name: name,
                nameFolded: nameFolded,
                cadenceDays: cadenceDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FriendsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                meetingsRefs = false,
                notesRefs = false,
                friendAffinitiesRefs = false,
                factsRefs = false,
                milestonesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (meetingsRefs) db.meetings,
                    if (notesRefs) db.notes,
                    if (friendAffinitiesRefs) db.friendAffinities,
                    if (factsRefs) db.facts,
                    if (milestonesRefs) db.milestones,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (meetingsRefs)
                        await $_getPrefetchedData<
                          FriendRow,
                          $FriendsTable,
                          MeetingRow
                        >(
                          currentTable: table,
                          referencedTable: $$FriendsTableReferences
                              ._meetingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FriendsTableReferences(
                                db,
                                table,
                                p0,
                              ).meetingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.friendId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<
                          FriendRow,
                          $FriendsTable,
                          NoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$FriendsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FriendsTableReferences(db, table, p0).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.friendId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (friendAffinitiesRefs)
                        await $_getPrefetchedData<
                          FriendRow,
                          $FriendsTable,
                          FriendAffinityRow
                        >(
                          currentTable: table,
                          referencedTable: $$FriendsTableReferences
                              ._friendAffinitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FriendsTableReferences(
                                db,
                                table,
                                p0,
                              ).friendAffinitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.friendId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (factsRefs)
                        await $_getPrefetchedData<
                          FriendRow,
                          $FriendsTable,
                          FactRow
                        >(
                          currentTable: table,
                          referencedTable: $$FriendsTableReferences
                              ._factsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FriendsTableReferences(db, table, p0).factsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.friendId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (milestonesRefs)
                        await $_getPrefetchedData<
                          FriendRow,
                          $FriendsTable,
                          MilestoneRow
                        >(
                          currentTable: table,
                          referencedTable: $$FriendsTableReferences
                              ._milestonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FriendsTableReferences(
                                db,
                                table,
                                p0,
                              ).milestonesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.friendId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FriendsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FriendsTable,
      FriendRow,
      $$FriendsTableFilterComposer,
      $$FriendsTableOrderingComposer,
      $$FriendsTableAnnotationComposer,
      $$FriendsTableCreateCompanionBuilder,
      $$FriendsTableUpdateCompanionBuilder,
      (FriendRow, $$FriendsTableReferences),
      FriendRow,
      PrefetchHooks Function({
        bool meetingsRefs,
        bool notesRefs,
        bool friendAffinitiesRefs,
        bool factsRefs,
        bool milestonesRefs,
      })
    >;
typedef $$MeetingsTableCreateCompanionBuilder =
    MeetingsCompanion Function({
      required String id,
      required String friendId,
      required int happenedOn,
      Value<int?> happenedAtMinute,
      required int createdAt,
      Value<String?> place,
      Value<int?> lengthInMinutes,
      Value<String?> feeling,
      Value<String?> recap,
      Value<int> rowid,
    });
typedef $$MeetingsTableUpdateCompanionBuilder =
    MeetingsCompanion Function({
      Value<String> id,
      Value<String> friendId,
      Value<int> happenedOn,
      Value<int?> happenedAtMinute,
      Value<int> createdAt,
      Value<String?> place,
      Value<int?> lengthInMinutes,
      Value<String?> feeling,
      Value<String?> recap,
      Value<int> rowid,
    });

final class $$MeetingsTableReferences
    extends BaseReferences<_$AppDatabase, $MeetingsTable, MeetingRow> {
  $$MeetingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias('meetings__friend_id__friends__id');

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$FriendsTableTableManager(
      $_db,
      $_db.friends,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeetingsTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get happenedAtMinute => $composableBuilder(
    column: $table.happenedAtMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lengthInMinutes => $composableBuilder(
    column: $table.lengthInMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feeling => $composableBuilder(
    column: $table.feeling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recap => $composableBuilder(
    column: $table.recap,
    builder: (column) => ColumnFilters(column),
  );

  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableFilterComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeetingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get happenedAtMinute => $composableBuilder(
    column: $table.happenedAtMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lengthInMinutes => $composableBuilder(
    column: $table.lengthInMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeling => $composableBuilder(
    column: $table.feeling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recap => $composableBuilder(
    column: $table.recap,
    builder: (column) => ColumnOrderings(column),
  );

  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableOrderingComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeetingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get happenedOn => $composableBuilder(
    column: $table.happenedOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get happenedAtMinute => $composableBuilder(
    column: $table.happenedAtMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<int> get lengthInMinutes => $composableBuilder(
    column: $table.lengthInMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feeling =>
      $composableBuilder(column: $table.feeling, builder: (column) => column);

  GeneratedColumn<String> get recap =>
      $composableBuilder(column: $table.recap, builder: (column) => column);

  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableAnnotationComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeetingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingsTable,
          MeetingRow,
          $$MeetingsTableFilterComposer,
          $$MeetingsTableOrderingComposer,
          $$MeetingsTableAnnotationComposer,
          $$MeetingsTableCreateCompanionBuilder,
          $$MeetingsTableUpdateCompanionBuilder,
          (MeetingRow, $$MeetingsTableReferences),
          MeetingRow,
          PrefetchHooks Function({bool friendId})
        > {
  $$MeetingsTableTableManager(_$AppDatabase db, $MeetingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> friendId = const Value.absent(),
                Value<int> happenedOn = const Value.absent(),
                Value<int?> happenedAtMinute = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> place = const Value.absent(),
                Value<int?> lengthInMinutes = const Value.absent(),
                Value<String?> feeling = const Value.absent(),
                Value<String?> recap = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingsCompanion(
                id: id,
                friendId: friendId,
                happenedOn: happenedOn,
                happenedAtMinute: happenedAtMinute,
                createdAt: createdAt,
                place: place,
                lengthInMinutes: lengthInMinutes,
                feeling: feeling,
                recap: recap,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendId,
                required int happenedOn,
                Value<int?> happenedAtMinute = const Value.absent(),
                required int createdAt,
                Value<String?> place = const Value.absent(),
                Value<int?> lengthInMinutes = const Value.absent(),
                Value<String?> feeling = const Value.absent(),
                Value<String?> recap = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingsCompanion.insert(
                id: id,
                friendId: friendId,
                happenedOn: happenedOn,
                happenedAtMinute: happenedAtMinute,
                createdAt: createdAt,
                place: place,
                lengthInMinutes: lengthInMinutes,
                feeling: feeling,
                recap: recap,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeetingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({friendId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (friendId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.friendId,
                                referencedTable: $$MeetingsTableReferences
                                    ._friendIdTable(db),
                                referencedColumn: $$MeetingsTableReferences
                                    ._friendIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingsTable,
      MeetingRow,
      $$MeetingsTableFilterComposer,
      $$MeetingsTableOrderingComposer,
      $$MeetingsTableAnnotationComposer,
      $$MeetingsTableCreateCompanionBuilder,
      $$MeetingsTableUpdateCompanionBuilder,
      (MeetingRow, $$MeetingsTableReferences),
      MeetingRow,
      PrefetchHooks Function({bool friendId})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String friendId,
      required String label,
      required String body,
      required String bodyFolded,
      required int writtenOn,
      Value<int?> resolvedOn,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> friendId,
      Value<String> label,
      Value<String> body,
      Value<String> bodyFolded,
      Value<int> writtenOn,
      Value<int?> resolvedOn,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias('notes__friend_id__friends__id');

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$FriendsTableTableManager(
      $_db,
      $_db.friends,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyFolded => $composableBuilder(
    column: $table.bodyFolded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get writtenOn => $composableBuilder(
    column: $table.writtenOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedOn => $composableBuilder(
    column: $table.resolvedOn,
    builder: (column) => ColumnFilters(column),
  );

  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableFilterComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyFolded => $composableBuilder(
    column: $table.bodyFolded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get writtenOn => $composableBuilder(
    column: $table.writtenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedOn => $composableBuilder(
    column: $table.resolvedOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableOrderingComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get bodyFolded => $composableBuilder(
    column: $table.bodyFolded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get writtenOn =>
      $composableBuilder(column: $table.writtenOn, builder: (column) => column);

  GeneratedColumn<int> get resolvedOn => $composableBuilder(
    column: $table.resolvedOn,
    builder: (column) => column,
  );

  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableAnnotationComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool friendId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> friendId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> bodyFolded = const Value.absent(),
                Value<int> writtenOn = const Value.absent(),
                Value<int?> resolvedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                friendId: friendId,
                label: label,
                body: body,
                bodyFolded: bodyFolded,
                writtenOn: writtenOn,
                resolvedOn: resolvedOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendId,
                required String label,
                required String body,
                required String bodyFolded,
                required int writtenOn,
                Value<int?> resolvedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                friendId: friendId,
                label: label,
                body: body,
                bodyFolded: bodyFolded,
                writtenOn: writtenOn,
                resolvedOn: resolvedOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({friendId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (friendId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.friendId,
                                referencedTable: $$NotesTableReferences
                                    ._friendIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._friendIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool friendId})
    >;
typedef $$AffinitiesTableCreateCompanionBuilder =
    AffinitiesCompanion Function({
      required String id,
      required String label,
      required String labelFolded,
      required bool isSeed,
      Value<int> rowid,
    });
typedef $$AffinitiesTableUpdateCompanionBuilder =
    AffinitiesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> labelFolded,
      Value<bool> isSeed,
      Value<int> rowid,
    });

final class $$AffinitiesTableReferences
    extends BaseReferences<_$AppDatabase, $AffinitiesTable, AffinityRow> {
  $$AffinitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FriendAffinitiesTable, List<FriendAffinityRow>>
  _friendAffinitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.friendAffinities,
    aliasName: 'affinities__id__friend_affinities__affinity_id',
  );

  $$FriendAffinitiesTableProcessedTableManager get friendAffinitiesRefs {
    final manager = $$FriendAffinitiesTableTableManager(
      $_db,
      $_db.friendAffinities,
    ).filter((f) => f.affinityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _friendAffinitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AffinitiesTableFilterComposer
    extends Composer<_$AppDatabase, $AffinitiesTable> {
  $$AffinitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelFolded => $composableBuilder(
    column: $table.labelFolded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSeed => $composableBuilder(
    column: $table.isSeed,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> friendAffinitiesRefs(
    Expression<bool> Function($$FriendAffinitiesTableFilterComposer f) f,
  ) {
    final $$FriendAffinitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.friendAffinities,
      getReferencedColumn: (t) => t.affinityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendAffinitiesTableFilterComposer(
            $db: $db,
            $table: $db.friendAffinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AffinitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $AffinitiesTable> {
  $$AffinitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelFolded => $composableBuilder(
    column: $table.labelFolded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSeed => $composableBuilder(
    column: $table.isSeed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AffinitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AffinitiesTable> {
  $$AffinitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get labelFolded => $composableBuilder(
    column: $table.labelFolded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSeed =>
      $composableBuilder(column: $table.isSeed, builder: (column) => column);

  Expression<T> friendAffinitiesRefs<T extends Object>(
    Expression<T> Function($$FriendAffinitiesTableAnnotationComposer a) f,
  ) {
    final $$FriendAffinitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.friendAffinities,
      getReferencedColumn: (t) => t.affinityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendAffinitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.friendAffinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AffinitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AffinitiesTable,
          AffinityRow,
          $$AffinitiesTableFilterComposer,
          $$AffinitiesTableOrderingComposer,
          $$AffinitiesTableAnnotationComposer,
          $$AffinitiesTableCreateCompanionBuilder,
          $$AffinitiesTableUpdateCompanionBuilder,
          (AffinityRow, $$AffinitiesTableReferences),
          AffinityRow,
          PrefetchHooks Function({bool friendAffinitiesRefs})
        > {
  $$AffinitiesTableTableManager(_$AppDatabase db, $AffinitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AffinitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AffinitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AffinitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> labelFolded = const Value.absent(),
                Value<bool> isSeed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AffinitiesCompanion(
                id: id,
                label: label,
                labelFolded: labelFolded,
                isSeed: isSeed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String labelFolded,
                required bool isSeed,
                Value<int> rowid = const Value.absent(),
              }) => AffinitiesCompanion.insert(
                id: id,
                label: label,
                labelFolded: labelFolded,
                isSeed: isSeed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AffinitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({friendAffinitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (friendAffinitiesRefs) db.friendAffinities,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (friendAffinitiesRefs)
                    await $_getPrefetchedData<
                      AffinityRow,
                      $AffinitiesTable,
                      FriendAffinityRow
                    >(
                      currentTable: table,
                      referencedTable: $$AffinitiesTableReferences
                          ._friendAffinitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AffinitiesTableReferences(
                            db,
                            table,
                            p0,
                          ).friendAffinitiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.affinityId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AffinitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AffinitiesTable,
      AffinityRow,
      $$AffinitiesTableFilterComposer,
      $$AffinitiesTableOrderingComposer,
      $$AffinitiesTableAnnotationComposer,
      $$AffinitiesTableCreateCompanionBuilder,
      $$AffinitiesTableUpdateCompanionBuilder,
      (AffinityRow, $$AffinitiesTableReferences),
      AffinityRow,
      PrefetchHooks Function({bool friendAffinitiesRefs})
    >;
typedef $$FriendAffinitiesTableCreateCompanionBuilder =
    FriendAffinitiesCompanion Function({
      required String friendId,
      required String affinityId,
      Value<int> rowid,
    });
typedef $$FriendAffinitiesTableUpdateCompanionBuilder =
    FriendAffinitiesCompanion Function({
      Value<String> friendId,
      Value<String> affinityId,
      Value<int> rowid,
    });

final class $$FriendAffinitiesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FriendAffinitiesTable,
          FriendAffinityRow
        > {
  $$FriendAffinitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias('friend_affinities__friend_id__friends__id');

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$FriendsTableTableManager(
      $_db,
      $_db.friends,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AffinitiesTable _affinityIdTable(_$AppDatabase db) => db.affinities
      .createAlias('friend_affinities__affinity_id__affinities__id');

  $$AffinitiesTableProcessedTableManager get affinityId {
    final $_column = $_itemColumn<String>('affinity_id')!;

    final manager = $$AffinitiesTableTableManager(
      $_db,
      $_db.affinities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_affinityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FriendAffinitiesTableFilterComposer
    extends Composer<_$AppDatabase, $FriendAffinitiesTable> {
  $$FriendAffinitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableFilterComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AffinitiesTableFilterComposer get affinityId {
    final $$AffinitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.affinityId,
      referencedTable: $db.affinities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffinitiesTableFilterComposer(
            $db: $db,
            $table: $db.affinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FriendAffinitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendAffinitiesTable> {
  $$FriendAffinitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableOrderingComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AffinitiesTableOrderingComposer get affinityId {
    final $$AffinitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.affinityId,
      referencedTable: $db.affinities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffinitiesTableOrderingComposer(
            $db: $db,
            $table: $db.affinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FriendAffinitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendAffinitiesTable> {
  $$FriendAffinitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableAnnotationComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AffinitiesTableAnnotationComposer get affinityId {
    final $$AffinitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.affinityId,
      referencedTable: $db.affinities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffinitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.affinities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FriendAffinitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FriendAffinitiesTable,
          FriendAffinityRow,
          $$FriendAffinitiesTableFilterComposer,
          $$FriendAffinitiesTableOrderingComposer,
          $$FriendAffinitiesTableAnnotationComposer,
          $$FriendAffinitiesTableCreateCompanionBuilder,
          $$FriendAffinitiesTableUpdateCompanionBuilder,
          (FriendAffinityRow, $$FriendAffinitiesTableReferences),
          FriendAffinityRow,
          PrefetchHooks Function({bool friendId, bool affinityId})
        > {
  $$FriendAffinitiesTableTableManager(
    _$AppDatabase db,
    $FriendAffinitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendAffinitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendAffinitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendAffinitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> friendId = const Value.absent(),
                Value<String> affinityId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FriendAffinitiesCompanion(
                friendId: friendId,
                affinityId: affinityId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String friendId,
                required String affinityId,
                Value<int> rowid = const Value.absent(),
              }) => FriendAffinitiesCompanion.insert(
                friendId: friendId,
                affinityId: affinityId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FriendAffinitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({friendId = false, affinityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (friendId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.friendId,
                                referencedTable:
                                    $$FriendAffinitiesTableReferences
                                        ._friendIdTable(db),
                                referencedColumn:
                                    $$FriendAffinitiesTableReferences
                                        ._friendIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (affinityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.affinityId,
                                referencedTable:
                                    $$FriendAffinitiesTableReferences
                                        ._affinityIdTable(db),
                                referencedColumn:
                                    $$FriendAffinitiesTableReferences
                                        ._affinityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FriendAffinitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FriendAffinitiesTable,
      FriendAffinityRow,
      $$FriendAffinitiesTableFilterComposer,
      $$FriendAffinitiesTableOrderingComposer,
      $$FriendAffinitiesTableAnnotationComposer,
      $$FriendAffinitiesTableCreateCompanionBuilder,
      $$FriendAffinitiesTableUpdateCompanionBuilder,
      (FriendAffinityRow, $$FriendAffinitiesTableReferences),
      FriendAffinityRow,
      PrefetchHooks Function({bool friendId, bool affinityId})
    >;
typedef $$FactsTableCreateCompanionBuilder =
    FactsCompanion Function({
      required String id,
      required String friendId,
      required String label,
      required String value,
      required int ordinal,
      Value<int> rowid,
    });
typedef $$FactsTableUpdateCompanionBuilder =
    FactsCompanion Function({
      Value<String> id,
      Value<String> friendId,
      Value<String> label,
      Value<String> value,
      Value<int> ordinal,
      Value<int> rowid,
    });

final class $$FactsTableReferences
    extends BaseReferences<_$AppDatabase, $FactsTable, FactRow> {
  $$FactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias('facts__friend_id__friends__id');

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$FriendsTableTableManager(
      $_db,
      $_db.friends,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FactsTableFilterComposer extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableFilterComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableOrderingComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableOrderingComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactsTable> {
  $$FactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableAnnotationComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactsTable,
          FactRow,
          $$FactsTableFilterComposer,
          $$FactsTableOrderingComposer,
          $$FactsTableAnnotationComposer,
          $$FactsTableCreateCompanionBuilder,
          $$FactsTableUpdateCompanionBuilder,
          (FactRow, $$FactsTableReferences),
          FactRow,
          PrefetchHooks Function({bool friendId})
        > {
  $$FactsTableTableManager(_$AppDatabase db, $FactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> friendId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion(
                id: id,
                friendId: friendId,
                label: label,
                value: value,
                ordinal: ordinal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendId,
                required String label,
                required String value,
                required int ordinal,
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion.insert(
                id: id,
                friendId: friendId,
                label: label,
                value: value,
                ordinal: ordinal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FactsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({friendId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (friendId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.friendId,
                                referencedTable: $$FactsTableReferences
                                    ._friendIdTable(db),
                                referencedColumn: $$FactsTableReferences
                                    ._friendIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactsTable,
      FactRow,
      $$FactsTableFilterComposer,
      $$FactsTableOrderingComposer,
      $$FactsTableAnnotationComposer,
      $$FactsTableCreateCompanionBuilder,
      $$FactsTableUpdateCompanionBuilder,
      (FactRow, $$FactsTableReferences),
      FactRow,
      PrefetchHooks Function({bool friendId})
    >;
typedef $$MilestonesTableCreateCompanionBuilder =
    MilestonesCompanion Function({
      required String id,
      required String friendId,
      required String label,
      required int onDate,
      required bool repeatsYearly,
      Value<int> rowid,
    });
typedef $$MilestonesTableUpdateCompanionBuilder =
    MilestonesCompanion Function({
      Value<String> id,
      Value<String> friendId,
      Value<String> label,
      Value<int> onDate,
      Value<bool> repeatsYearly,
      Value<int> rowid,
    });

final class $$MilestonesTableReferences
    extends BaseReferences<_$AppDatabase, $MilestonesTable, MilestoneRow> {
  $$MilestonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias('milestones__friend_id__friends__id');

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<String>('friend_id')!;

    final manager = $$FriendsTableTableManager(
      $_db,
      $_db.friends,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onDate => $composableBuilder(
    column: $table.onDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => ColumnFilters(column),
  );

  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableFilterComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onDate => $composableBuilder(
    column: $table.onDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => ColumnOrderings(column),
  );

  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableOrderingComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get onDate =>
      $composableBuilder(column: $table.onDate, builder: (column) => column);

  GeneratedColumn<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => column,
  );

  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.friendId,
      referencedTable: $db.friends,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FriendsTableAnnotationComposer(
            $db: $db,
            $table: $db.friends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestonesTable,
          MilestoneRow,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (MilestoneRow, $$MilestonesTableReferences),
          MilestoneRow,
          PrefetchHooks Function({bool friendId})
        > {
  $$MilestonesTableTableManager(_$AppDatabase db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> friendId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> onDate = const Value.absent(),
                Value<bool> repeatsYearly = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                friendId: friendId,
                label: label,
                onDate: onDate,
                repeatsYearly: repeatsYearly,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendId,
                required String label,
                required int onDate,
                required bool repeatsYearly,
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                friendId: friendId,
                label: label,
                onDate: onDate,
                repeatsYearly: repeatsYearly,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MilestonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({friendId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (friendId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.friendId,
                                referencedTable: $$MilestonesTableReferences
                                    ._friendIdTable(db),
                                referencedColumn: $$MilestonesTableReferences
                                    ._friendIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestonesTable,
      MilestoneRow,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (MilestoneRow, $$MilestonesTableReferences),
      MilestoneRow,
      PrefetchHooks Function({bool friendId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db, _db.friends);
  $$MeetingsTableTableManager get meetings =>
      $$MeetingsTableTableManager(_db, _db.meetings);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$AffinitiesTableTableManager get affinities =>
      $$AffinitiesTableTableManager(_db, _db.affinities);
  $$FriendAffinitiesTableTableManager get friendAffinities =>
      $$FriendAffinitiesTableTableManager(_db, _db.friendAffinities);
  $$FactsTableTableManager get facts =>
      $$FactsTableTableManager(_db, _db.facts);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db, _db.milestones);
}
