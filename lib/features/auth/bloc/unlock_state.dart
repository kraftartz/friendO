import 'package:equatable/equatable.dart';

import '../../../core/profiles/profile.dart';

/// Where the keypad stands.
enum UnlockStep {
  /// It waits for digits.
  typing,

  /// It works on the PIN that was typed, and takes no more digits.
  working,

  /// It refuses digits until the delay has passed.
  delayed,

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
    this.delay = Duration.zero,
    this.message,
  });

  final Profile profile;

  final UnlockStep step;

  final String typed;

  /// What is left of the delay. It is [Duration.zero] unless the keypad waits.
  final Duration delay;

  final String? message;

  UnlockState copyWith({
    UnlockStep? step,
    String? typed,
    Duration? delay,
    String? message,
  }) => UnlockState(
    profile: profile,
    step: step ?? this.step,
    typed: typed ?? this.typed,
    delay: delay ?? this.delay,
    // Not `message ?? this.message`. A message answers the try that raised it
    // and nothing after it, so the next state drops it unless it says one.
    message: message,
  );

  @override
  List<Object?> get props => [profile, step, typed, delay, message];
}
