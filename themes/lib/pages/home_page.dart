import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:themes/components/box.dart';
import 'package:themes/components/button.dart';
import 'package:themes/theme/theme_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: MyBox(
          color: Theme.of(context).colorScheme.primary,
          child: MyButton(
            color: Theme.of(context).colorScheme.secondary,
            onTap: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ),
      ),
    );
  }
}
