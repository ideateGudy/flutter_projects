import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.yellow.shade300,
    inversePrimary: Colors.yellow.shade200,
    primary: Colors.yellow,
    secondary: Colors.yellow.shade300,
  ),
);

// red.shade300,
// yellow[200][300] shade300
// red.shade300
// green, red, yellow

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade700,
    secondary: Colors.grey.shade700,
  ),
);

// ThemeData darkMode = ThemeData(
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme.dark(
//     surface: Colors.grey.shade900,
//     primary: Colors.grey.shade800,
//     secondary: Colors.green,
//     inversePrimary: Colors.yellow.shade800,
//     tertiary: Colors.red,
//   ),
// );
