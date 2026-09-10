import 'package:flutter/material.dart';

import '../tokens/soft.dart';

/// The ten digits and a way to drop the last one.
///
/// It shows no confirm key. A caller that submits on the last digit needs
/// none, and one key less is one thing less to reach one-handed.
class PinKeypad extends StatelessWidget {
  const PinKeypad({required this.onDigit, required this.onDelete, super.key});

  /// Called with the digit that was pressed.
  final ValueChanged<int> onDigit;

  /// Called when the last digit is to be dropped.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rows = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final digit in row) _Key(digit: digit, onDigit: onDigit),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 88, height: 72),
            _Key(digit: 0, onDigit: onDigit),
            SizedBox(
              width: 88,
              height: 72,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.backspace_outlined),
                tooltip: 'Delete the last digit',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.digit, required this.onDigit});

  final int digit;

  final ValueChanged<int> onDigit;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 88,
    height: 72,
    child: TextButton(
      onPressed: () => onDigit(digit),
      child: Text('$digit', style: const TextStyle(fontSize: 26)),
    ),
  );
}

/// One place in a PIN, filled or empty.
class PinDot extends StatelessWidget {
  const PinDot({required this.filled, super.key});

  /// Whether a digit has been typed in this place.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);

    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? soft.glow : Colors.transparent,
        border: Border.all(color: soft.glow, width: 1.5),
      ),
    );
  }
}

/// How much of a PIN is typed, without showing what was typed.
///
/// A person beside the User learns how many digits are in and nothing else.
class PinDots extends StatelessWidget {
  const PinDots({required this.length, required this.filled, super.key});

  /// The number of places the PIN holds.
  final int length;

  /// The number of places that hold a digit.
  final int filled;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var place = 0; place < length; place++)
        PinDot(filled: place < filled),
    ],
  );
}
