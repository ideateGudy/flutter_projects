import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;
  final _myBox = Hive.box('mybox');

  ThemeProvider() {
    _loadTheme(); // Load saved theme on initialization
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();

    // 🧠 Save current theme mode
    _saveTheme(themeData == darkMode ? 'dark' : 'light');
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  // 🧩 Save the theme mode in Hive
  void _saveTheme(String mode) {
    _myBox.put('THEME_MODE', mode);
  }

  // 🧩 Load the theme mode from Hive
  void _loadTheme() {
    String? savedTheme = _myBox.get('THEME_MODE');

    if (savedTheme == 'dark') {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
  }
}
