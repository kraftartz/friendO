import 'dart:io';

import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/core/profiles/profile_session.dart';
import 'package:hashlib/hashlib.dart';

/// One directory, one connection, and the two objects that use them.
///
/// It hashes at a cost a test can pay, and it keeps the creator and the
/// session over one connection, the way the app wires them.
class Wiring {
  Wiring(Directory directory)
    : this.over(ProfileList(directory), DatabaseSession(directory));

  Wiring.over(this.profiles, this.databases)
    : creator = ProfileCreator(
        profiles: profiles,
        databases: databases,
        dataKeys: const DataKeyStore(),
        security: Argon2Security.test,
      ),
      session = ProfileSession(
        profiles: profiles,
        databases: databases,
        dataKeys: const DataKeyStore(),
      );

  final ProfileList profiles;

  final DatabaseSession databases;

  final ProfileCreator creator;

  final ProfileSession session;
}
