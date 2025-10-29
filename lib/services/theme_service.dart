import 'package:flutter/material.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  ThemeService() : super(ThemeMode.dark);

  void toggleTheme() {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeService = ThemeService();
