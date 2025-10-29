import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  String text;
  VoidCallback onPressed;
  Color buttonColor;
  MyButton({super.key, required this.text, required this.onPressed, required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: buttonColor,
      child: Text(text),
    );
  }
}
