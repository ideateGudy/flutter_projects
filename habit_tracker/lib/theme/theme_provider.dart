import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/theme/dark_mode.dart';

import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  //initially light mode
  ThemeData _themeData = lightMode;

  //getter: get current theme
  ThemeData get themeData => _themeData;

  //is current theme dark mode?
  bool get isDarkMode => _themeData == darkMode;

  //set theme
  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  //toggle theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
    // Save theme to database
    _saveTheme();
  }

  // Load theme from database
  Future<void> loadTheme() async {
    final isDark = await HabitDatabase.getTheme();
    _themeData = isDark ? darkMode : lightMode;
    notifyListeners();
  }

  // Save theme to database
  Future<void> _saveTheme() async {
    await HabitDatabase.saveTheme(isDarkMode);
  }
}
