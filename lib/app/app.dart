import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/profiles/profile_creator.dart';
import '../features/first_run/bloc/first_run_cubit.dart';
import '../features/first_run/bloc/first_run_state.dart';
import '../features/first_run/view/first_run_page.dart';
import 'navigation/home_shell.dart';
import 'navigation/navigation_cubit.dart';
import 'theme.dart';

class FriendoApp extends StatefulWidget {
  const FriendoApp({this.firstRun, super.key});

  /// The way to make the first Profile, for a phone that holds none.
  ///
  /// It is null when a Profile already exists, and the app opens on the Dial.
  final ProfileCreator? firstRun;

  @override
  State<FriendoApp> createState() => _FriendoAppState();
}

class _FriendoAppState extends State<FriendoApp> {
  late ProfileCreator? _firstRun = widget.firstRun;

  @override
  Widget build(BuildContext context) {
    final firstRun = _firstRun;

    return MaterialApp(
      title: 'friendO',
      theme: friendoTheme(),
      home: firstRun == null
          ? BlocProvider(
              create: (_) => NavigationCubit(),
              child: const HomeShell(),
            )
          : BlocProvider(
              create: (_) => FirstRunCubit(firstRun),
              child: BlocListener<FirstRunCubit, FirstRunState>(
                listenWhen: (_, state) => state.step == FirstRunStep.done,
                listener: (_, _) => setState(() => _firstRun = null),
                child: const FirstRunPage(),
              ),
            ),
    );
  }
}
