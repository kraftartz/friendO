/// Design tokens and dumb widgets for friendO.
///
/// This package depends on Flutter and on nothing else. It holds treatments
/// such as [SoftCard], never concepts such as a Friend or a Bead. A widget here
/// cannot import flutter_bloc, so it cannot read a BLoC, so it stays reusable
/// and previewable.
library;

export 'src/tokens/soft.dart';
export 'src/widgets/soft_card.dart';
