import 'package:flutter/material.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart' show DialBead;
import 'package:friendo_ui/friendo_ui.dart' show AvatarHalo, initialOf;

/// One Friend, drawn on their Orbit.
///
/// A Bead carries no name. A label is wider than the Bead it belongs to and
/// the clear space beside it is four units, so on a full Orbit the labels
/// would cover each other and the Beads on both sides. The name arrives on a
/// tap.
///
/// [isEmphasised] lights the Bead and never moves it. Position on the Dial
/// means Phase and nothing else, so a Bead that moved to say it was next would
/// be telling one truth by hiding another.
class BeadView extends StatelessWidget {
  const BeadView({
    required this.bead,
    required this.colour,
    required this.width,
    required this.onTap,
    this.isEmphasised = false,
    super.key,
  });

  final DialBead bead;

  /// The Avatar's colour. This widget draws the colour it is given and works
  /// none out: telling two Beads apart is a fact about a roster, and a Bead
  /// holds only itself.
  final Color colour;

  final double width;

  final VoidCallback onTap;

  final bool isEmphasised;

  @override
  Widget build(BuildContext context) => Semantics(
    label: bead.name,
    button: true,
    child: GestureDetector(
      onTap: onTap,
      child: AvatarHalo(
        label: initialOf(bead.name),
        colour: colour,
        size: width,
        isLit: isEmphasised,
      ),
    ),
  );
}
