import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  /// Default to system; change to ThemeMode.light if you prefer.
  // ThemeMode _themeMode = ThemeMode.system;
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool useDark) {
    _themeMode = useDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
