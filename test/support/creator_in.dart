import 'dart:io';

import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:hashlib/hashlib.dart';

/// A way to make a Profile in [directory], hashing at a cost a test can pay.
ProfileCreator creatorIn(Directory directory) => ProfileCreator(
  profiles: ProfileList(directory),
  databases: DatabaseSession(directory),
  dataKeys: const DataKeyStore(),
  security: Argon2Security.test,
);
