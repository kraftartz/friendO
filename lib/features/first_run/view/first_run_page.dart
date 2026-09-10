import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendo_ui/friendo_ui.dart';

import '../bloc/first_run_cubit.dart';
import '../bloc/first_run_state.dart';

/// The screens that turn a phone with no Profile into a phone with one.
class FirstRunPage extends StatelessWidget {
  const FirstRunPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FirstRunCubit, FirstRunState>(
        builder: (context, state) => Scaffold(
          body: SafeArea(
            child: state.step == FirstRunStep.cost
                ? const _CostView()
                : _CreationView(state: state),
          ),
        ),
      );
}

/// The name, then the PIN, then the same PIN again.
class _CreationView extends StatelessWidget {
  const _CreationView({required this.state});

  final FirstRunState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FirstRunCubit>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            switch (state.step) {
              FirstRunStep.name => 'Name this Profile',
              FirstRunStep.pin => 'Choose a PIN',
              FirstRunStep.confirm => 'Type the PIN again',
              _ => 'Making the Profile',
            },
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          if (state.step == FirstRunStep.name)
            _NameEntry(onSubmitted: cubit.submitName)
          else if (state.step == FirstRunStep.working)
            const CircularProgressIndicator()
          else ...[
            PinDots(
              length: pinLength,
              filled: state.step == FirstRunStep.pin
                  ? state.pin.length
                  : state.confirmation.length,
            ),
            const SizedBox(height: 32),
            PinKeypad(onDigit: cubit.pressDigit, onDelete: cubit.deleteDigit),
          ],
        ],
      ),
    );
  }
}

class _NameEntry extends StatefulWidget {
  const _NameEntry({required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<_NameEntry> createState() => _NameEntryState();
}

class _NameEntryState extends State<_NameEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Profile name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: widget.onSubmitted,
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => widget.onSubmitted(_controller.text),
        child: const Text('Continue'),
      ),
    ],
  );
}

/// The one thing a User cannot learn later by exploring.
///
/// It appears after the Profile exists, so it has no way to fail, and it
/// offers no way back. Going back would offer to make a second Profile.
class _CostView extends StatelessWidget {
  const _CostView();

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Everything stays on this phone',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const SoftCard(
            child: Column(
              children: [
                Text(
                  'friendO keeps your Friends on this phone. Nothing is '
                  'copied anywhere, and nobody else can read it.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'If this phone is lost, what is in it is lost too.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: context.read<FirstRunCubit>().continueToApp,
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
}
