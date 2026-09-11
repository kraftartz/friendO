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
  const ScreenCover({
    required this.child,
    this.allowScreenshots = false,
    super.key,
  });

  final Widget child;

  /// Whether the User has asked to see their own screen in the task switcher.
  ///
  /// It defaults to covered, which is the safe reading while the setting that
  /// would say otherwise cannot be read. See ADR-0011 and ADR-0036.
  final bool allowScreenshots;

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
    final covered =
        state != AppLifecycleState.resumed && !widget.allowScreenshots;
    if (covered == _covered) return;

    setState(() => _covered = covered);
  }

  @override
  void didUpdateWidget(ScreenCover old) {
    super.didUpdateWidget(old);
    if (widget.allowScreenshots && _covered) setState(() => _covered = false);
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
