import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendo_ui/friendo_ui.dart';

import '../../../core/profiles/pin.dart';
import '../bloc/unlock_cubit.dart';
import '../bloc/unlock_state.dart';

/// The keypad that opens one Profile.
class UnlockPage extends StatelessWidget {
  const UnlockPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<UnlockCubit, UnlockState>(
    builder: (context, state) {
      final cubit = context.read<UnlockCubit>();

      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.profile.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (state.message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                switch (state.step) {
                  UnlockStep.working => const CircularProgressIndicator(),
                  UnlockStep.resting => Text(restingWords(state.rest)),
                  UnlockStep.failed => const SizedBox.shrink(),
                  UnlockStep.typing || UnlockStep.open => Column(
                    children: [
                      PinDots(length: pinLength, filled: state.typed.length),
                      const SizedBox(height: 24),
                      PinKeypad(
                        onDigit: cubit.pressDigit,
                        onDelete: cubit.deleteDigit,
                      ),
                    ],
                  ),
                },
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// What the keypad says while it rests for [left].
String restingWords(Duration left) {
  final seconds = left.inSeconds;
  if (seconds < 60) return 'Too many wrong PINs. Wait $seconds seconds.';

  final minutes = left.inMinutes;

  return 'Too many wrong PINs. Wait $minutes minutes.';
}
