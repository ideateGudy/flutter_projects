import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/services/exact_alarm_scheduler.dart';
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

  /// Save the theme preference
  /// true = dark mode, false = light mode
  static Future<void> saveTheme(bool isDarkMode) async {
    final settingsMap = settingsBox.get('appSettings');
    if (settingsMap != null) {
      final settings = AppSettings.fromMap(settingsMap);
      settings.isDarkMode = isDarkMode;
      await settingsBox.put('appSettings', settings.toMap());
    }
  }

  /// Get the saved theme preference
  /// Returns false (light mode) if not saved
  static Future<bool> getTheme() async {
    final settingsMap = settingsBox.get('appSettings');
    if (settingsMap != null) {
      final settings = AppSettings.fromMap(settingsMap);
      return settings.isDarkMode;
    }
    return false;
  }

  /// Save the global notification preference
  /// true = notifications enabled, false = notifications disabled
  static Future<void> saveNotificationPreference(bool isEnabled) async {
    final settingsMap = settingsBox.get('appSettings');
    if (settingsMap != null) {
      final settings = AppSettings.fromMap(settingsMap);
      settings.notificationsEnabled = isEnabled;
      await settingsBox.put('appSettings', settings.toMap());
    }
  }

  /// Get the saved global notification preference
  /// Returns true (notifications enabled) by default
  static Future<bool> getNotificationPreference() async {
    final settingsMap = settingsBox.get('appSettings');
    if (settingsMap != null) {
      final settings = AppSettings.fromMap(settingsMap);
      return settings.notificationsEnabled;
    }
    return true;
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

  Future<void> addHabitWithRepeat(
    String name,
    List<int> repeatDays, {
    int notificationIntervalMinutes = 60,
    int notificationHour = 9,
    int notificationMinute = 0,
    bool notificationsEnabled = true,
  }) async {
    final newHabit = Habit(
      id: const Uuid().v4(),
      name: name,
      completedDays: [],
      repeatDays: repeatDays,
      notificationIntervalMinutes: notificationIntervalMinutes,
      notificationHour: notificationHour,
      notificationMinute: notificationMinute,
      notificationsEnabled: notificationsEnabled,
    );

    await habitsBox.put(newHabit.id, newHabit.toMap());

    // Schedule exact alarms for this new habit
    await ExactAlarmScheduler.scheduleHabitNotifications(newHabit);

    await readHabits();
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
  /// - Cancel notifications for this habit
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

          // Cancel notifications for this habit when completed
          await NotificationService().cancelHabitNotification(id);
          await ExactAlarmScheduler.onHabitCompleted(id);
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

  /// UPDATE: Change a habit's name and repeat days
  Future<void> updateHabit(
    String id,
    String newName,
    List<int> repeatDays, {
    int notificationIntervalMinutes = 60,
    int notificationHour = 9,
    int notificationMinute = 0,
    bool notificationsEnabled = true,
  }) async {
    final habitMap = habitsBox.get(id);

    if (habitMap != null) {
      final habit = Habit.fromMap(habitMap);

      habit.name = newName;
      habit.repeatDays = repeatDays;
      habit.notificationIntervalMinutes = notificationIntervalMinutes;
      habit.notificationHour = notificationHour;
      habit.notificationMinute = notificationMinute;
      habit.notificationsEnabled = notificationsEnabled;

      await habitsBox.put(id, habit.toMap());

      // Reschedule alarms with new settings
      await ExactAlarmScheduler.cancelHabitAlarms(id);
      await ExactAlarmScheduler.scheduleHabitNotifications(habit);
    }

    await readHabits(); // Sync UI
  }

  /// UPDATE: Stop a habit (hide from today's list but retain history)
  /// When a habit is stopped, it won't appear in tomorrow's checklist
  /// but its completion history and heatmap are preserved
  Future<void> stopHabit(String id) async {
    final habitMap = habitsBox.get(id);
    if (habitMap != null) {
      final habit = Habit.fromMap(habitMap);
      habit.isActive = false;
      habit.stoppedDate = DateTime.now();
      await habitsBox.put(id, habit.toMap());

      // Cancel alarms when habit is stopped
      await ExactAlarmScheduler.cancelHabitAlarms(id);
    }

    await readHabits(); // Sync UI
  }

  /// UPDATE: Resume a stopped habit
  Future<void> resumeHabit(String id) async {
    final habitMap = habitsBox.get(id);
    if (habitMap != null) {
      final habit = Habit.fromMap(habitMap);
      habit.isActive = true;
      habit.stoppedDate = null;
      await habitsBox.put(id, habit.toMap());

      // Reschedule alarms when habit is resumed
      await ExactAlarmScheduler.scheduleHabitNotifications(habit);
    }

    await readHabits(); // Sync UI
  }

  /// DELETE: Remove a habit from the database
  Future<void> deleteHabit(String id) async {
    // Cancel notifications for this habit
    await NotificationService().cancelHabitNotification(id);
    await ExactAlarmScheduler.cancelHabitAlarms(id);

    await habitsBox.delete(id);
    await readHabits(); // Sync UI
  }

  /// Send notifications for all incomplete active habits today
  /// Used by background tasks to remind user of pending habits
  Future<void> sendReminderNotificationsForToday() async {
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final notificationService = NotificationService();

    for (var key in habitsBox.keys) {
      final habitMap = habitsBox.get(key);
      if (habitMap != null) {
        final habit = Habit.fromMap(habitMap);

        // Only notify for active habits
        if (!habit.isActive) continue;

        // Check if habit should appear today
        final shouldAppearToday =
            habit.repeatDays.isEmpty || habit.repeatDays.contains(now.weekday);
        if (!shouldAppearToday) continue;

        // Check if habit is not completed today
        final isCompletedToday = habit.completedDays.any(
          (date) =>
              date.year == todayNormalized.year &&
              date.month == todayNormalized.month &&
              date.day == todayNormalized.day,
        );

        if (!isCompletedToday) {
          // Send notification
          await notificationService.sendImmediateNotification(
            id: habit.id.hashCode,
            title: 'Habit Reminder',
            body: 'Complete your habit: ${habit.name}',
            payload: habit.id,
          );
        }
      }
    }
  }
}
