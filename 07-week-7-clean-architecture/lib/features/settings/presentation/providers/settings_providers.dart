import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/local/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

// Provider pengelola Mode Gelap (AsyncNotifier)
class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

// Provider untuk memaksa mode offline pada fitur Posts (Global State)
final forceOfflineProvider = StateProvider<bool>((ref) => false);