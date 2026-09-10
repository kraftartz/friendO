import 'package:flutter/material.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show DialBead, DialState;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo/features/dial/view/dial_view.dart' show DialView;
import 'package:friendo_domain/friendo_domain.dart' show DialCounts, Orbit;
import 'package:friendo_ui/friendo_ui.dart' show Soft;

/// The Dial, the three counts beside it, and the one button under it.
///
/// It draws a reading and reports taps. It writes nothing, so a test of what
/// the screen says needs a reading and no store.
///
/// Locked and empty are drawn differently. A locked Dial says nothing at all,
/// because there is nothing to say until the Profile is open. An empty one
/// invites the User to add their first Friend, which is the normal state after
/// First Run and wants a way on rather than a control that refuses.
class DialBody extends StatelessWidget {
  const DialBody({
    required this.reading,
    required this.onLogMeeting,
    this.onAddFriend,
    this.onOpenFriend,
    this.onShowOrbit,
    this.geometry = const DialGeometry(),
    super.key,
  });

  final DialState reading;

  /// Writes a Meeting with the named Friend, dated today.
  final void Function(String friendId) onLogMeeting;

  final VoidCallback? onAddFriend;

  final void Function(String friendId)? onOpenFriend;

  /// Asks for the Friends List, filtered to one Orbit.
  final void Function(Orbit orbit)? onShowOrbit;

  final DialGeometry geometry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!reading.isLocked) _CountsRow(reading.counts),
        const SizedBox(height: 16),
        Flexible(
          child: DialView(
            reading: reading,
            geometry: geometry,
            onTapBead: (bead) => _nameThatFriend(context, bead),
            onTapBadge: (orbit) => onShowOrbit?.call(orbit),
          ),
        ),
        const SizedBox(height: 24),
        if (!reading.isLocked) _button(context),
      ],
    ),
  );

  Widget _button(BuildContext context) {
    final emphasised = _emphasised;

    if (emphasised == null) {
      return FilledButton(
        key: const Key('dial-add-first-friend'),
        onPressed: onAddFriend,
        child: const Text('Add your first Friend'),
      );
    }

    return FilledButton(
      key: const Key('dial-log-meeting'),
      onPressed: () => onLogMeeting(emphasised.id),
      child: Text('Log a Meeting with ${emphasised.name}'),
    );
  }

  /// The Bead the Priority Order puts first, or null when there is nobody to
  /// name. A tap never writes a Meeting for a Friend the screen did not name.
  DialBead? get _emphasised {
    for (final orbit in reading.orbits) {
      for (final bead in orbit.beads) {
        if (bead.id == reading.emphasisedId) return bead;
      }
    }

    return null;
  }

  void _nameThatFriend(BuildContext context, DialBead bead) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(bead.name)),
              ListTile(
                key: const Key('dial-sheet-log-meeting'),
                leading: const Icon(Icons.check_circle_outline),
                title: Text('Log a Meeting with ${bead.name}'),
                onTap: () {
                  Navigator.of(sheet).pop();
                  onLogMeeting(bead.id);
                },
              ),
              ListTile(
                key: const Key('dial-sheet-open-friend'),
                leading: const Icon(Icons.person_outline),
                title: Text('Open ${bead.name}'),
                onTap: () {
                  Navigator.of(sheet).pop();
                  onOpenFriend?.call(bead.id);
                },
              ),
            ],
          ),
        ),
      );
}

/// The three counts the screen shows.
///
/// The fourth needs no chip. The Overdue Friends are the Beads Queue resting
/// at the top of the Orbits, and the User is looking straight at them.
class _CountsRow extends StatelessWidget {
  const _CountsRow(this.counts);

  final DialCounts counts;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: [
      _Count(label: 'Nearing', held: counts.nearing),
      _Count(label: 'In Orbit', held: counts.inOrbit),
      _Count(label: 'Freshly Reset', held: counts.freshlyReset),
    ],
  );
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.held});

  final String label;

  final int held;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: soft.well,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$held $label',
        style: TextStyle(color: soft.glow, letterSpacing: 0.05 * 12),
      ),
    );
  }
}
