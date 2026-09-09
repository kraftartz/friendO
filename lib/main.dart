import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/db/database_session.dart';
import 'core/profiles/data_key_store.dart';
import 'core/profiles/profile_creator.dart';
import 'core/profiles/profile_list.dart';

/// Resolves the data directory once, reads the Profile list, and starts the
/// app on the screen that list calls for.
///
/// This is the only place that asks the phone where its files go. Everything
/// below takes the directory as an argument, which is also what lets a test
/// hand it a temporary one.
///
/// A damaged list throws here, and the app does not start. That is deliberate:
/// starting First Run over a list that cannot be read would write a new list
/// over the Profiles this phone still holds, and nothing could recover them.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationSupportDirectory();
  final profiles = ProfileList(directory);

  runApp(
    FriendoApp(
      firstRunCreator: (await profiles.read()).isEmpty
          ? ProfileCreator(
              profiles: profiles,
              databases: DatabaseSession(directory),
              dataKeys: const DataKeyStore(),
            )
          : null,
    ),
  );
}
