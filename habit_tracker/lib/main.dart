import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/theme/notification_preference_provider.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/services/background_task_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize the Hive database
  await HabitDatabase.initializeHive();

  // Save first launch date
  final db = HabitDatabase();
  await db.saveFirstLaunchDate();

  // Load saved theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Load notification preference
  final notificationPreferenceProvider = NotificationPreferenceProvider();
  await notificationPreferenceProvider.initialize();

  // Initialize notifications
  try {
    await NotificationService().initialize();
  } catch (e) {
    print('Error initializing notifications: $e');
  }

  // Initialize background tasks for habit reminders
  try {
    await BackgroundTaskHandler.initialize();
    await BackgroundTaskHandler.schedulePeriodicHabitCheck();
  } catch (e) {
    print('Error initializing background tasks: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: notificationPreferenceProvider),
        ChangeNotifierProvider(create: (context) => HabitDatabase()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: context.watch<ThemeProvider>().themeData,
      home: const HomePage(),
    );
  }
}
