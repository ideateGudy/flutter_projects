import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// HabitDatabase
///
/// WHAT IT DOES:
/// - Manages all database operations using Hive (local storage)
/// - Keeps an in-memory list of habits that the UI watches
/// - Syncs database and memory whenever data changes
///
/// HOW IT WORKS:
/// - Uses Hive boxes: 'habits' (for habits) and 'settings' (for app settings)
/// - Extends ChangeNotifier so UI automatically rebuilds when data changes
/// - Each operation: fetch from database → modify → save → notify UI
class HabitDatabase extends ChangeNotifier {
  /// Hive box storing all habits
  /// Key: habit ID (UUID), Value: habit data as Map
  static late Box<dynamic> habitsBox;

  /// Hive box storing app settings
  /// Key: 'appSettings', Value: settings data as Map
  static late Box<dynamic> settingsBox;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize Hive and open the two required boxes
  /// CALL THIS ONCE in main.dart before using the database
  static Future<void> initializeHive() async {
    habitsBox = await Hive.openBox('habits');
    settingsBox = await Hive.openBox('settings');
  }

  /// Save app's first launch date (only once)
  /// This date is used as the start date for the heatmap
  /// Only saves if no settings exist yet
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = settingsBox.get('appSettings');
    if (existingSettings == null) {
      final newSettings = AppSettings(
        id: 'app_settings_1',
        firstLaunchDate: DateTime.now(),
      );
      await settingsBox.put('appSettings', newSettings.toMap());
    }
  }

  /// Get the first launch date
  /// Returns null if not yet saved
  Future<DateTime?> getFirstLaunchDate() async {
    final settingsMap = settingsBox.get('appSettings');
    if (settingsMap != null) {
      final settings = AppSettings.fromMap(settingsMap);
      return settings.firstLaunchDate;
    }
    return null;
  }

  // ============================================================================
  // IN-MEMORY DATA
  // ============================================================================

  /// In-memory list of all habits
  /// This is what the UI displays
  /// Stays in sync with database via readHabits()
  /// When this list changes, UI automatically rebuilds
  final List<Habit> habits = [];

  // ============================================================================
  // CRUD OPERATIONS: CREATE, READ, UPDATE, DELETE
  // ============================================================================

  /// CREATE: Add a new habit
  ///
  /// STEPS:
  /// 1. Create new Habit with unique UUID
  /// 2. Save to Hive database
  /// 3. Reload habits list to sync UI
  Future<void> addHabit(String name) async {
    final newHabit = Habit(
      id: const Uuid().v4(), // Generate unique ID
      name: name,
      completedDays: [],
    );

    await habitsBox.put(newHabit.id, newHabit.toMap());
    await readHabits(); // Sync UI
  }

  /// READ: Load all habits from database into memory
  ///
  /// STEPS:
  /// 1. Clear existing in-memory list
  /// 2. Fetch all habits from Hive
  /// 3. Convert Map → Habit objects
  /// 4. Notify UI to rebuild
  Future<void> readHabits() async {
    habits.clear();

    for (var key in habitsBox.keys) {
      final habitMap = habitsBox.get(key);
      if (habitMap != null) {
        habits.add(Habit.fromMap(habitMap));
      }
    }

    // Tell listeners (UI widgets) that data changed
    notifyListeners();
  }

  /// UPDATE: Mark habit as completed or incomplete for today
  ///
  /// IF COMPLETED:
  /// - Add today's date to completedDays list (if not already there)
  ///
  /// IF NOT COMPLETED:
  /// - Remove today's date from completedDays list
  Future<void> updateHabitCompletion(String id, bool isCompleted) async {
    final habitMap = habitsBox.get(id);
    if (habitMap != null) {
      final habit = Habit.fromMap(habitMap);
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);

      if (isCompleted) {
        // Add today if not already in the list
        if (!habit.completedDays.any(
          (date) =>
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day,
        )) {
          habit.completedDays.add(todayNormalized);
        }
      } else {
        // Remove today from the list
        habit.completedDays.removeWhere(
          (date) =>
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day,
        );
      }

      await habitsBox.put(id, habit.toMap());
    }

    await readHabits(); // Sync UI
  }

  /// UPDATE: Change a habit's name
  Future<void> updateHabitName(String id, String newName) async {
    final habitMap = habitsBox.get(id);
    if (habitMap != null) {
      final habit = Habit.fromMap(habitMap);
      habit.name = newName;
      await habitsBox.put(id, habit.toMap());
    }

    await readHabits(); // Sync UI
  }

  /// DELETE: Remove a habit from the database
  Future<void> deleteHabit(String id) async {
    await habitsBox.delete(id);
    await readHabits(); // Sync UI
  }
}
