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
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
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
    minutes,
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
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
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
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
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

  /// When the row was written, in milliseconds from the epoch.
  final int createdAt;
  final String? place;

  /// How long the Meeting was, in minutes.
  final int? minutes;

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
    this.minutes,
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
    if (!nullToAbsent || minutes != null) {
      map['minutes'] = Variable<int>(minutes);
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
      minutes: minutes == null && nullToAbsent
          ? const Value.absent()
          : Value(minutes),
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
      minutes: serializer.fromJson<int?>(json['minutes']),
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
      'minutes': serializer.toJson<int?>(minutes),
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
    Value<int?> minutes = const Value.absent(),
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
    minutes: minutes.present ? minutes.value : this.minutes,
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
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
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
          ..write('minutes: $minutes, ')
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
    minutes,
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
          other.minutes == this.minutes &&
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
  final Value<int?> minutes;
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
    this.minutes = const Value.absent(),
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
    this.minutes = const Value.absent(),
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
    Expression<int>? minutes,
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
      if (minutes != null) 'minutes': minutes,
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
    Value<int?>? minutes,
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
      minutes: minutes ?? this.minutes,
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
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
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
          ..write('minutes: $minutes, ')
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, friendId, label, value, position];
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
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
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
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
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
  final int position;
  const FactRow({
    required this.id,
    required this.friendId,
    required this.label,
    required this.value,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['friend_id'] = Variable<String>(friendId);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<String>(value);
    map['position'] = Variable<int>(position);
    return map;
  }

  FactsCompanion toCompanion(bool nullToAbsent) {
    return FactsCompanion(
      id: Value(id),
      friendId: Value(friendId),
      label: Value(label),
      value: Value(value),
      position: Value(position),
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
      position: serializer.fromJson<int>(json['position']),
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
      'position': serializer.toJson<int>(position),
    };
  }

  FactRow copyWith({
    String? id,
    String? friendId,
    String? label,
    String? value,
    int? position,
  }) => FactRow(
    id: id ?? this.id,
    friendId: friendId ?? this.friendId,
    label: label ?? this.label,
    value: value ?? this.value,
    position: position ?? this.position,
  );
  FactRow copyWithCompanion(FactsCompanion data) {
    return FactRow(
      id: data.id.present ? data.id.value : this.id,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactRow(')
          ..write('id: $id, ')
          ..write('friendId: $friendId, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, friendId, label, value, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactRow &&
          other.id == this.id &&
          other.friendId == this.friendId &&
          other.label == this.label &&
          other.value == this.value &&
          other.position == this.position);
}

class FactsCompanion extends UpdateCompanion<FactRow> {
  final Value<String> id;
  final Value<String> friendId;
  final Value<String> label;
  final Value<String> value;
  final Value<int> position;
  final Value<int> rowid;
  const FactsCompanion({
    this.id = const Value.absent(),
    this.friendId = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactsCompanion.insert({
    required String id,
    required String friendId,
    required String label,
    required String value,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendId = Value(friendId),
       label = Value(label),
       value = Value(value),
       position = Value(position);
  static Insertable<FactRow> custom({
    Expression<String>? id,
    Expression<String>? friendId,
    Expression<String>? label,
    Expression<String>? value,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendId != null) 'friend_id': friendId,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactsCompanion copyWith({
    Value<String>? id,
    Value<String>? friendId,
    Value<String>? label,
    Value<String>? value,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return FactsCompanion(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      label: label ?? this.label,
      value: value ?? this.value,
      position: position ?? this.position,
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
    if (position.present) {
      map['position'] = Variable<int>(position.value);
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
          ..write('position: $position, ')
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
          (FriendRow, BaseReferences<_$AppDatabase, $FriendsTable, FriendRow>),
          FriendRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (FriendRow, BaseReferences<_$AppDatabase, $FriendsTable, FriendRow>),
      FriendRow,
      PrefetchHooks Function()
    >;
typedef $$MeetingsTableCreateCompanionBuilder =
    MeetingsCompanion Function({
      required String id,
      required String friendId,
      required int happenedOn,
      Value<int?> happenedAtMinute,
      required int createdAt,
      Value<String?> place,
      Value<int?> minutes,
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
      Value<int?> minutes,
      Value<String?> feeling,
      Value<String?> recap,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
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

  ColumnOrderings<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
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

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

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

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<String> get feeling =>
      $composableBuilder(column: $table.feeling, builder: (column) => column);

  GeneratedColumn<String> get recap =>
      $composableBuilder(column: $table.recap, builder: (column) => column);
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
          (
            MeetingRow,
            BaseReferences<_$AppDatabase, $MeetingsTable, MeetingRow>,
          ),
          MeetingRow,
          PrefetchHooks Function()
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
                Value<int?> minutes = const Value.absent(),
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
                minutes: minutes,
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
                Value<int?> minutes = const Value.absent(),
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
                minutes: minutes,
                feeling: feeling,
                recap: recap,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (MeetingRow, BaseReferences<_$AppDatabase, $MeetingsTable, MeetingRow>),
      MeetingRow,
      PrefetchHooks Function()
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

  ColumnFilters<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  ColumnOrderings<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

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
          (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
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
          (
            AffinityRow,
            BaseReferences<_$AppDatabase, $AffinitiesTable, AffinityRow>,
          ),
          AffinityRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        AffinityRow,
        BaseReferences<_$AppDatabase, $AffinitiesTable, AffinityRow>,
      ),
      AffinityRow,
      PrefetchHooks Function()
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

class $$FriendAffinitiesTableFilterComposer
    extends Composer<_$AppDatabase, $FriendAffinitiesTable> {
  $$FriendAffinitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get friendId => $composableBuilder(
    column: $table.friendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get affinityId => $composableBuilder(
    column: $table.affinityId,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get friendId => $composableBuilder(
    column: $table.friendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get affinityId => $composableBuilder(
    column: $table.affinityId,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

  GeneratedColumn<String> get affinityId => $composableBuilder(
    column: $table.affinityId,
    builder: (column) => column,
  );
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
          (
            FriendAffinityRow,
            BaseReferences<
              _$AppDatabase,
              $FriendAffinitiesTable,
              FriendAffinityRow
            >,
          ),
          FriendAffinityRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        FriendAffinityRow,
        BaseReferences<
          _$AppDatabase,
          $FriendAffinitiesTable,
          FriendAffinityRow
        >,
      ),
      FriendAffinityRow,
      PrefetchHooks Function()
    >;
typedef $$FactsTableCreateCompanionBuilder =
    FactsCompanion Function({
      required String id,
      required String friendId,
      required String label,
      required String value,
      required int position,
      Value<int> rowid,
    });
typedef $$FactsTableUpdateCompanionBuilder =
    FactsCompanion Function({
      Value<String> id,
      Value<String> friendId,
      Value<String> label,
      Value<String> value,
      Value<int> position,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
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
          (FactRow, BaseReferences<_$AppDatabase, $FactsTable, FactRow>),
          FactRow,
          PrefetchHooks Function()
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
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion(
                id: id,
                friendId: friendId,
                label: label,
                value: value,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendId,
                required String label,
                required String value,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => FactsCompanion.insert(
                id: id,
                friendId: friendId,
                label: label,
                value: value,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (FactRow, BaseReferences<_$AppDatabase, $FactsTable, FactRow>),
      FactRow,
      PrefetchHooks Function()
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

  ColumnFilters<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  ColumnOrderings<String> get friendId => $composableBuilder(
    column: $table.friendId,
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

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get onDate =>
      $composableBuilder(column: $table.onDate, builder: (column) => column);

  GeneratedColumn<bool> get repeatsYearly => $composableBuilder(
    column: $table.repeatsYearly,
    builder: (column) => column,
  );
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
          (
            MilestoneRow,
            BaseReferences<_$AppDatabase, $MilestonesTable, MilestoneRow>,
          ),
          MilestoneRow,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        MilestoneRow,
        BaseReferences<_$AppDatabase, $MilestonesTable, MilestoneRow>,
      ),
      MilestoneRow,
      PrefetchHooks Function()
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
