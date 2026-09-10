import 'package:equatable/equatable.dart';

import '../../../core/profiles/profile.dart';

/// Where the keypad stands.
enum UnlockStep {
  /// It waits for digits.
  typing,

  /// It works on the PIN that was typed, and takes no more digits.
  working,

  /// It refuses digits until the rest has passed.
  resting,

  /// The Profile is open.
  open,

  /// The Profile cannot be opened, and no PIN will help.
  failed,
}

class UnlockState extends Equatable {
  const UnlockState({
    required this.profile,
    this.step = UnlockStep.typing,
    this.typed = '',
    this.rest = Duration.zero,
    this.message,
  });

  final Profile profile;

  final UnlockStep step;

  final String typed;

  /// What is left of the rest. It is [Duration.zero] unless the keypad rests.
  final Duration rest;

  final String? message;

  UnlockState copyWith({
    UnlockStep? step,
    String? typed,
    Duration? rest,
    String? message,
  }) => UnlockState(
    profile: profile,
    step: step ?? this.step,
    typed: typed ?? this.typed,
    rest: rest ?? this.rest,
    message: message,
  );

  @override
  List<Object?> get props => [profile, step, typed, rest, message];
}
