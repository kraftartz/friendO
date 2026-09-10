import 'package:flutter/material.dart';

/// The key of the cover the app draws over itself.
const screenCoverKey = ValueKey<String>('screen-cover');

/// Covers the app while it is not in front, so that no preview is readable.
///
/// The cover goes up as soon as the app becomes inactive, because the system
/// takes its snapshot of the app before the app is told that it is paused.
/// Android blocks the preview at the window instead, and the cover there is a
/// second answer to the same question.
class ScreenCover extends StatefulWidget {
  const ScreenCover({required this.child, super.key});

  final Widget child;

  @override
  State<ScreenCover> createState() => _ScreenCoverState();
}

class _ScreenCoverState extends State<ScreenCover> with WidgetsBindingObserver {
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final covered = state != AppLifecycleState.resumed;
    if (covered == _covered) return;

    setState(() => _covered = covered);
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (_covered)
        Positioned.fill(
          key: screenCoverKey,
          child: ColoredBox(color: Theme.of(context).colorScheme.surface),
        ),
    ],
  );
}
