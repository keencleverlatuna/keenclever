import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider =
NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();

    final savedTheme = preferences.getString(themeKey);

    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
//keen
