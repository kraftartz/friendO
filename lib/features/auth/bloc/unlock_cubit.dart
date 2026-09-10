import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/profiles/pin.dart';
import '../../../core/profiles/profile.dart';
import '../../../core/profiles/profile_session.dart';
import 'unlock_state.dart';

/// How often the countdown of a waiting keypad is drawn again.
const pinDelayTick = Duration(seconds: 1);

/// The keypad: six digits in, and a Profile open or a reason why not.
class UnlockCubit extends Cubit<UnlockState> {
  UnlockCubit({required this.session, required Profile profile})
    : super(UnlockState(profile: profile)) {
    unawaited(_arrive());
  }

  final ProfileSession session;

  Timer? _countdown;

  /// Takes one digit. The last one submits the PIN, and there is no key that
  /// does that instead.
  void pressDigit(int digit) {
    if (state.step != UnlockStep.typing) return;
    if (state.typed.length >= pinLength) return;

    final typed = '${state.typed}$digit';
    emit(state.copyWith(typed: typed));

    if (typed.length == pinLength) unawaited(_submit(typed));
  }

  void deleteDigit() {
    if (state.step != UnlockStep.typing || state.typed.isEmpty) return;

    emit(
      state.copyWith(typed: state.typed.substring(0, state.typed.length - 1)),
    );
  }

  @override
  Future<void> close() {
    _countdown?.cancel();

    return super.close();
  }

  Future<void> _submit(String pin) async {
    emit(state.copyWith(step: UnlockStep.working));

    switch (await session.unlock(state.profile.id, pin)) {
      case Unlocked():
        emit(state.copyWith(step: UnlockStep.open, typed: ''));
      case WrongPin():
        emit(
          state.copyWith(
            step: UnlockStep.typing,
            typed: '',
            message: 'The PIN is wrong.',
          ),
        );
        await _arrive();
      case PinDelayed(:final remaining):
        _delay(remaining);
      case Failed(:final reason):
        emit(
          state.copyWith(
            step: UnlockStep.failed,
            typed: '',
            message: _reasonFor(reason),
          ),
        );
    }
  }

  /// Marks the keypad ready for digits, and rests it when the count says so.
  ///
  /// The delay starts here and not at a stored deadline, so it costs the same
  /// wait after a fresh start of the app as it does after a wrong PIN.
  Future<void> _arrive() async {
    session.arriveAtKeypad();
    final delay = await session.delayLeftFor(state.profile.id);
    if (delay > Duration.zero) _delay(delay);
  }

  void _delay(Duration remaining) {
    emit(state.copyWith(step: UnlockStep.delayed, typed: '', delay: remaining));
    _countdown?.cancel();
    _countdown = Timer.periodic(pinDelayTick, (timer) {
      final left = state.delay - pinDelayTick;
      if (left > Duration.zero) {
        emit(state.copyWith(delay: left));

        return;
      }

      timer.cancel();
      emit(state.copyWith(step: UnlockStep.typing, delay: Duration.zero));
    });
  }

  String _reasonFor(UnlockFailureReason reason) => switch (reason) {
    UnlockFailureReason.dataKeyMissing =>
      'This Profile cannot be opened on this phone.',
    UnlockFailureReason.fileWillNotOpen => 'This Profile cannot be opened.',
    UnlockFailureReason.migrationFailed =>
      'The app could not update what it has stored.',
  };
}
