import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/profiles/pin.dart';
import '../../../core/profiles/profile.dart';
import '../../../core/profiles/profile_session.dart';
import 'unlock_state.dart';

/// How often the countdown of a resting keypad is drawn again.
const restTick = Duration(seconds: 1);

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
      case Resting(:final remaining):
        _rest(remaining);
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
  /// The rest starts here and not at a stored deadline, so it costs the same
  /// wait after a fresh start of the app as it does after a wrong PIN.
  Future<void> _arrive() async {
    session.arriveAtKeypad();
    final rest = await session.restLeftFor(state.profile.id);
    if (rest > Duration.zero) _rest(rest);
  }

  void _rest(Duration remaining) {
    emit(state.copyWith(step: UnlockStep.resting, typed: '', rest: remaining));
    _countdown?.cancel();
    _countdown = Timer.periodic(restTick, (timer) {
      final left = state.rest - restTick;
      if (left > Duration.zero) {
        emit(state.copyWith(rest: left));

        return;
      }

      timer.cancel();
      emit(state.copyWith(step: UnlockStep.typing, rest: Duration.zero));
    });
  }

  String _reasonFor(UnlockFailure reason) => switch (reason) {
    UnlockFailure.dataKeyMissing =>
      'This Profile cannot be opened on this phone.',
    UnlockFailure.fileWillNotOpen => 'This Profile cannot be opened.',
    UnlockFailure.migrationFailed =>
      'The app could not update what it has stored.',
  };
}
