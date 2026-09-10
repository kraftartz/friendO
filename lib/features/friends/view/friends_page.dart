import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:friendo/features/friends/bloc/friends_cubit.dart'
    show FriendsCubit;
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show FriendsListState;
import 'package:friendo/features/friends/view/friends_body.dart'
    show FriendsBody;

/// The Friends List, joined to its state.
class FriendsPage extends StatelessWidget {
  const FriendsPage({this.onAddFriend, this.onOpenFriend, super.key});

  final VoidCallback? onAddFriend;

  final void Function(String friendId)? onOpenFriend;

  @override
  Widget build(BuildContext context) {
    final friends = context.read<FriendsCubit>();

    return BlocBuilder<FriendsCubit, FriendsListState>(
      builder: (context, reading) => FriendsBody(
        reading: reading,
        onSearch: friends.search,
        onShowOrbit: friends.showOrbit,
        onReview: friends.review,
        onLogMeeting: friends.logMeeting,
        onAddFriend: onAddFriend,
        onOpenFriend: onOpenFriend,
      ),
    );
  }
}
