import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/profiles/profile_creator.dart';
import 'first_run_state.dart';

/// The number of digits in a PIN. The last one submits the entry, so no
/// confirm button is needed here or at any later unlock.
const pinLength = 6;

/// Walks First Run from an empty phone to a Profile that opens.
///
/// The Profile is made the moment the two PIN entries match, and before the
/// cost screen appears. The PIN then leaves this state at the earliest moment
/// it can, and the cost screen has no way to fail.
class FirstRunCubit extends Cubit<FirstRunState> {
  FirstRunCubit(this._creator) : super(const FirstRunState());

  final ProfileCreator _creator;

  /// Takes the name and asks for the first PIN entry.
  ///
  /// A name of spaces alone is refused, because a blank row on the picker
  /// names no Profile.
  void submitName(String name) {
    if (name.trim().isEmpty) {
      emit(state.copyWith(name: name, message: 'A Profile needs a name.'));

      return;
    }

    emit(FirstRunState(step: FirstRunStep.pin, name: name));
  }

  /// Adds one digit to the entry that is open.
  ///
  /// The entry takes no more than [pinLength] digits. The last one submits it:
  /// the first entry asks for the second, and the second either makes the
  /// Profile or reports that the two differ.
  void pressDigit(int digit) {
    final entry = _entry();
    if (entry == null || entry.length >= pinLength) return;

    final typed = '$entry$digit';
    emit(_withEntry(typed));

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
          message: 'The two entries differ. Type the PIN again.',
        ),
      );
    }
  }

  /// Drops the last digit of the entry that is open.
  void deleteDigit() {
    final entry = _entry();
    if (entry == null || entry.isEmpty) return;

    emit(_withEntry(entry.substring(0, entry.length - 1)));
  }

  /// Leaves the cost screen for the app.
  void continueToApp() => emit(state.copyWith(step: FirstRunStep.done));

  Future<void> _create() async {
    final name = state.name;
    final pin = state.pin;
    emit(FirstRunState(step: FirstRunStep.working, name: name));

    try {
      await _creator.createProfile(name, pin);
      emit(FirstRunState(step: FirstRunStep.cost, name: name));
    } on Object catch (error) {
      emit(
        FirstRunState(
          step: FirstRunStep.pin,
          name: name,
          message: 'The Profile was not made: $error',
        ),
      );
    }
  }

  String? _entry() => switch (state.step) {
    FirstRunStep.pin => state.pin,
    FirstRunStep.confirm => state.confirmation,
    _ => null,
  };

  FirstRunState _withEntry(String entry) => state.step == FirstRunStep.pin
      ? state.copyWith(pin: entry)
      : state.copyWith(confirmation: entry);
}
