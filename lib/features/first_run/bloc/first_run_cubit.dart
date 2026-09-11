import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/profiles/pin.dart';
import '../../../core/profiles/profile_creator.dart';
import '../../../core/profiles/profile_session.dart';
import 'first_run_state.dart';

/// Walks First Run from an empty phone to a Profile that opens.
///
/// The Profile is made the moment the two PINs match, and before the
/// cost screen appears. The PIN then leaves this state at the earliest moment
/// it can, and the cost screen has no way to fail.
class FirstRunCubit extends Cubit<FirstRunState> {
  FirstRunCubit(this._creator, this._session) : super(const FirstRunState());

  final ProfileCreator _creator;

  final ProfileSession _session;

  /// Takes the name and asks for the PIN.
  ///
  /// A name of spaces alone is refused, because a Profile with no name tells
  /// two Profiles apart from each other not at all.
  void submitName(String name) {
    if (name.trim().isEmpty) {
      emit(state.copyWith(name: name, message: 'A Profile needs a name.'));

      return;
    }

    emit(FirstRunState(step: FirstRunStep.pin, name: name));
  }

  /// Adds one digit to the PIN that is open.
  ///
  /// A PIN takes no more than [pinLength] digits, and the last one submits it.
  /// The first PIN asks for the second, and the second either makes the
  /// Profile or reports that the two differ.
  void pressDigit(int digit) {
    final open = _open();
    if (open == null || open.length >= pinLength) return;

    final typed = '$open$digit';
    emit(_withTyped(typed));

    if (typed.length < pinLength) return;

    if (state.step == FirstRunStep.pin) {
      emit(state.copyWith(step: FirstRunStep.confirm));

      return;
    }

    if (typed == state.pin) {
      unawaited(_create());
    } else {
      emit(
        FirstRunState(
          step: FirstRunStep.pin,
          name: state.name,
          message: 'The two PINs differ. Type the PIN again.',
        ),
      );
    }
  }

  /// Drops the last digit of the PIN that is open.
  void deleteDigit() {
    final open = _open();
    if (open == null || open.isEmpty) return;

    emit(_withTyped(open.substring(0, open.length - 1)));
  }

  /// Leaves the cost screen for the app.
  void continueToApp() => emit(state.copyWith(step: FirstRunStep.done));

  Future<void> _create() async {
    final name = state.name;
    final pin = state.pin;
    emit(FirstRunState(step: FirstRunStep.working, name: name));

    try {
      final profile = await _creator.createProfile(name, pin);
      // The User chose this PIN and typed it twice a moment ago, so the
      // Profile opens without a third asking. A Profile that will not open
      // still reaches the cost screen: it exists, and making a second one
      // would be worse than asking for the PIN at the next start.
      await _session.openProfile(profile.id);
      emit(
        FirstRunState(
          step: FirstRunStep.cost,
          name: name,
          profileId: profile.id,
        ),
      );
    } on Object {
      emit(
        FirstRunState(
          step: FirstRunStep.pin,
          name: name,
          message: 'The Profile was not made. Try again.',
        ),
      );
    }
  }

  /// The PIN the next digit belongs to, or null while none takes a digit.
  String? _open() => switch (state.step) {
    FirstRunStep.pin => state.pin,
    FirstRunStep.confirm => state.confirmation,
    _ => null,
  };

  FirstRunState _withTyped(String typed) => state.step == FirstRunStep.pin
      ? state.copyWith(pin: typed)
      : state.copyWith(confirmation: typed);
}
