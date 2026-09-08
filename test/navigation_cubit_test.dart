import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/navigation/app_section.dart';
import 'package:friendo/app/navigation/navigation_cubit.dart';

void main() {
  group('NavigationCubit', () {
    test('starts on the Dial', () {
      expect(NavigationCubit().state, AppSection.dial);
    });

    blocTest<NavigationCubit, AppSection>(
      'emits each selected section in order',
      build: NavigationCubit.new,
      act: (cubit) => cubit
        ..select(AppSection.friends)
        ..select(AppSection.settings),
      expect: () => [AppSection.friends, AppSection.settings],
    );

    blocTest<NavigationCubit, AppSection>(
      'emits nothing for a repeat selection',
      build: NavigationCubit.new,
      act: (cubit) => cubit
        ..select(AppSection.friends)
        ..select(AppSection.friends),
      expect: () => [AppSection.friends],
    );

    blocTest<NavigationCubit, AppSection>(
      'still emits when the first selection is the section already shown',
      build: NavigationCubit.new,
      act: (cubit) => cubit.select(AppSection.dial),
      // bloc only drops a duplicate state after it has emitted once, so this
      // first emit goes through even though it matches the initial state.
      expect: () => [AppSection.dial],
    );
  });
}
