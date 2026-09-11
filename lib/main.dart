import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/boot.dart';
import 'app/platform_edges.dart';
import 'core/db/database_session.dart';
import 'core/profiles/data_key_store.dart';
import 'core/profiles/profile_creator.dart';
import 'core/profiles/profile_list.dart';
import 'core/profiles/profile_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationSupportDirectory();
  final profiles = ProfileList(directory);
  final databases = DatabaseSession(directory);
  const dataKeys = DataKeyStore();

  runApp(
    FriendoApp(
      edges: PlatformEdges.ofThisPhone(),
      firstScreen: await readFirstScreen(profiles),
      creator: ProfileCreator(
        profiles: profiles,
        databases: databases,
        dataKeys: dataKeys,
      ),
      session: ProfileSession(
        profiles: profiles,
        databases: databases,
        dataKeys: dataKeys,
      ),
    ),
  );
}
