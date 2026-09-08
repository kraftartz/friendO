import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation/home_shell.dart';
import 'navigation/navigation_cubit.dart';
import 'theme.dart';

/// The root widget.
///
/// It wires three things and holds no logic of its own: the theme, the
/// navigation Cubit, and the shell that reads them.
class FriendoApp extends StatelessWidget {
  /// Create the app.
  const FriendoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'friendO',
    theme: friendoTheme(),
    home: BlocProvider(
      create: (_) => NavigationCubit(),
      child: const HomeShell(),
    ),
  );
}
