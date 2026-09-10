import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendo/features/dial/bloc/dial_cubit.dart' show DialCubit;
import 'package:friendo/features/dial/bloc/dial_state.dart' show DialState;
import 'package:friendo/features/dial/view/dial_body.dart' show DialBody;
import 'package:friendo_domain/friendo_domain.dart' show Orbit;

/// The main screen: who should I see next, and one tap to say I did.
///
/// The two requests it raises go out as arguments. Opening a Friend and
/// opening the Friends List filtered to an Orbit are both somebody else's
/// screens, and what routes them is still an open question.
class DialPage extends StatelessWidget {
  const DialPage({
    this.onAddFriend,
    this.onOpenFriend,
    this.onShowOrbit,
    super.key,
  });

  final VoidCallback? onAddFriend;

  final void Function(String friendId)? onOpenFriend;

  final void Function(Orbit orbit)? onShowOrbit;

  @override
  Widget build(BuildContext context) => BlocBuilder<DialCubit, DialState>(
    builder: (context, reading) => DialBody(
      reading: reading,
      onLogMeeting: context.read<DialCubit>().logMeeting,
      onAddFriend: onAddFriend,
      onOpenFriend: onOpenFriend,
      onShowOrbit: onShowOrbit,
    ),
  );
}
