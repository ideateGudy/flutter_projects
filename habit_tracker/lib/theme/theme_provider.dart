import 'package:flutter/material.dart';
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
  }
}
