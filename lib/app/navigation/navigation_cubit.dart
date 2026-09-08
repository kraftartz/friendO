import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_section.dart';

/// Hold the section the app currently shows.
///
/// A Cubit rather than a Bloc: the state is one enum value, and there is no
/// event worth naming beyond "go here". There is no loading state and no
/// failure state, because switching a tab cannot fail.
class NavigationCubit extends Cubit<AppSection> {
  /// Start on the Dial.
  NavigationCubit() : super(AppSection.dial);

  /// Show [section].
  ///
  /// Selecting the section already shown emits nothing, because a Cubit drops
  /// a state equal to the current one.
  ///
  /// The first call is the exception. bloc guards that check with an `_emitted`
  /// flag (bloc_base.dart, `state == _state && _emitted`), so the first emit
  /// always goes through, even when it matches the initial state.
  void select(AppSection section) => emit(section);
}
