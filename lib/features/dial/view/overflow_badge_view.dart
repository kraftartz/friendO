import 'package:flutter/material.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart' show OverflowBadge;
import 'package:friendo_ui/friendo_ui.dart' show Soft;

/// The last place on a crowded Orbit, holding a count.
///
/// It names no Friend and carries no Avatar, because it stands for several.
/// It takes the place a Bead would have had, which is the only space a
/// crowded Orbit has left to spend.
class OverflowBadgeView extends StatelessWidget {
  const OverflowBadgeView({
    required this.badge,
    required this.width,
    required this.onTap,
    super.key,
  });

  final OverflowBadge badge;

  final double width;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);

    return Semantics(
      label: '${badge.count} more',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: soft.surface,
            border: Border.all(color: soft.glow, width: width / 14),
          ),
          child: Center(
            child: Text(
              '+${badge.count}',
              maxLines: 1,
              style: TextStyle(
                color: soft.glow,
                fontSize: width / 3.5,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
