import 'package:equatable/equatable.dart';

/// Where First Run has reached.
enum FirstRunStep {
  /// The Profile has no name yet.
  name,

  /// The first PIN entry.
  pin,

  /// The second PIN entry, which catches a typo.
  confirm,

  /// The keys, the file and the row are being made.
  working,

  /// The Profile exists, and the screen states what friendO does not keep.
  cost,

  /// First Run is over.
  done;

  /// Whether this step belongs to the screen that creates the Profile.
  bool get isCreation => this == name || this == pin || this == confirm;
}

/// Everything the three screens draw, and the PIN while it is needed.
class FirstRunState extends Equatable {
  const FirstRunState({
    this.step = FirstRunStep.name,
    this.name = '',
    this.pin = '',
    this.confirmation = '',
    this.message,
  });

  final FirstRunStep step;

  /// The name as it was typed. It is trimmed when the Profile is made.
  final String name;

  /// The first PIN entry. It is empty from the moment the Profile is made.
  final String pin;

  /// The second PIN entry.
  final String confirmation;

  /// What went wrong, for the User to read. It is null while nothing has.
  final String? message;

  FirstRunState copyWith({
    FirstRunStep? step,
    String? name,
    String? pin,
    String? confirmation,
    String? message,
  }) => FirstRunState(
    step: step ?? this.step,
    name: name ?? this.name,
    pin: pin ?? this.pin,
    confirmation: confirmation ?? this.confirmation,
    message: message,
  );

  @override
  List<Object?> get props => [step, name, pin, confirmation, message];
}
