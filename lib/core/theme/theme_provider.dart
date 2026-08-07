import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/progress_repository.dart';

/// Key for storing theme mode preference in SharedPreferences.
const String _themeModeKey = 'app_theme_mode';

/// StateNotifier to manage user theme preference (System, Light, Dark).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _loadTheme();
  }

  final Ref _ref;

  void _loadTheme() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final savedTheme = prefs.getString(_themeModeKey);
    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  /// Change theme mode and persist to SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = _ref.read(sharedPreferencesProvider);
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_themeModeKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_themeModeKey, 'dark');
        break;
      case ThemeMode.system:
        await prefs.setString(_themeModeKey, 'system');
        break;
    }
  }
}

/// Provider for user theme mode state.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});
