import 'package:workmanager/workmanager.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:habit_tracker/models/habit.dart';
import 'dart:developer' as developer;
import 'notification_service.dart';

/// Background task handler for recurring notifications
/// This runs periodically even when the app is not in focus
class BackgroundTaskHandler {
  static const String checkHabitsTaskName = 'checkHabitsTask';
  static const int notificationCheckIntervalMinutes = 15;

  /// Initialize workmanager for background tasks
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Schedule periodic checks for habits
  /// The task will run every [intervalMinutes]
  static Future<void> schedulePeriodicHabitCheck({
    int intervalMinutes = notificationCheckIntervalMinutes,
  }) async {
    await Workmanager().registerPeriodicTask(
      checkHabitsTaskName,
      checkHabitsTaskName,
      frequency: Duration(minutes: intervalMinutes),
      constraints: Constraints(
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      initialDelay: const Duration(minutes: 1),
    );
  }

  /// Cancel the periodic task
  static Future<void> cancelPeriodicCheck() async {
    await Workmanager().cancelByTag(checkHabitsTaskName);
  }

  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}

/// Callback dispatcher for workmanager
/// This must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      developer.log('=== BACKGROUND TASK STARTED ===');
      developer.log('Task Name: $taskName');

      if (taskName == BackgroundTaskHandler.checkHabitsTaskName) {
        developer.log('Executing checkHabitsTask...');

        // Initialize Hive for background execution
        // Get the app documents directory to initialize Hive with a valid path
        final appDocDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocDir.path);
        developer.log('Hive initialized at: ${appDocDir.path}');

        // Open Hive boxes
        if (!Hive.isBoxOpen('habits')) {
          await Hive.openBox('habits');
        }

        if (!Hive.isBoxOpen('settings')) {
          await Hive.openBox('settings');
        }
        developer.log('Hive boxes opened');

        // Check global notification preference
        final settingsBox = Hive.box('settings');
        final settingsMap = settingsBox.get('appSettings');
        bool globalNotificationsEnabled = true;

        if (settingsMap != null) {
          globalNotificationsEnabled =
              settingsMap['notificationsEnabled'] as bool? ?? true;
        }
        developer.log(
          'Global notifications enabled: $globalNotificationsEnabled',
        );

        // If global notifications are disabled, don't send any
        if (!globalNotificationsEnabled) {
          developer.log('Global notifications disabled, skipping task');
          return true;
        }

        // Open the habits box
        final habitsBox = Hive.box('habits');

        // Get active habits for today
        final now = DateTime.now();
        final todayNormalized = DateTime(now.year, now.month, now.day);
        developer.log('Current time: $now');

        List<Habit> todayHabits = [];

        for (var key in habitsBox.keys) {
          final habitMap = habitsBox.get(key);
          if (habitMap != null) {
            final habit = Habit.fromMap(habitMap);

            // Check if habit is active
            if (!habit.isActive) continue;

            // Check if habit's notifications are enabled
            if (!habit.notificationsEnabled) continue;

            // Check if habit should appear today
            final shouldAppearToday =
                habit.repeatDays.isEmpty ||
                habit.repeatDays.contains(now.weekday);
            if (!shouldAppearToday) continue;

            // Check if habit is not completed today
            final isCompletedToday = habit.completedDays.any(
              (date) =>
                  date.year == todayNormalized.year &&
                  date.month == todayNormalized.month &&
                  date.day == todayNormalized.day,
            );

            if (!isCompletedToday) {
              todayHabits.add(habit);
            }
          }
        }

        developer.log('Found ${todayHabits.length} habits to check');

        // Send notifications for incomplete habits whose time has arrived
        if (todayHabits.isNotEmpty) {
          await NotificationService().initialize();
          developer.log('NotificationService initialized');

          for (var habit in todayHabits) {
            developer.log('Checking habit: ${habit.name}');

            // Calculate the start time for notifications today
            final habitNotificationStart = DateTime(
              now.year,
              now.month,
              now.day,
              habit.notificationHour,
              habit.notificationMinute,
            );
            developer.log('Notification start time: $habitNotificationStart');

            // Define end-of-day cutoff at midnight (12:00 AM next day)
            final endOfDay = DateTime(now.year, now.month, now.day + 1, 0, 0);

            // Only send if current time is at or past the start time
            if (now.isBefore(habitNotificationStart)) {
              developer.log('Current time before notification start, skipping');
              continue; // Skip this habit, notification time hasn't arrived yet
            }

            // Stop sending notifications at midnight (end of day)
            if (now.isAfter(endOfDay) || now.isAtSameMomentAs(endOfDay)) {
              developer.log('Current time after end of day, skipping');
              continue; // Skip this habit, it's past midnight (new day)
            }

            // Calculate how many intervals have passed since the start time
            final timeSinceStart = now.difference(habitNotificationStart);
            final intervalMinutes = habit.notificationIntervalMinutes;
            final intervalsPassed = (timeSinceStart.inMinutes / intervalMinutes)
                .floor();
            developer.log('Intervals passed: $intervalsPassed');

            // Calculate when the NEXT notification should be sent (current interval)
            final nextNotificationTime = habitNotificationStart.add(
              Duration(minutes: intervalMinutes * (intervalsPassed + 1)),
            );
            developer.log('Next notification time: $nextNotificationTime');

            // Create a unique ID for this notification that includes the interval count
            // This allows multiple notifications per habit per day
            final notificationId =
                '${habit.id}_${intervalsPassed + 1}'.hashCode;

            // Send notification if current time is at or past the scheduled time
            // Check if we're within the 15-minute check window
            final timeSinceExpectedNotification = now.difference(
              nextNotificationTime,
            );
            developer.log(
              'Time since expected notification: ${timeSinceExpectedNotification.inMinutes} minutes',
            );

            if (timeSinceExpectedNotification.inMinutes >= -15 &&
                timeSinceExpectedNotification.inMinutes <= 0) {
              developer.log('Sending notification for habit: ${habit.name}');

              // Send a notification for this incomplete habit
              await NotificationService().sendImmediateNotification(
                id: notificationId,
                title: 'Habit Reminder',
                body: 'Complete your habit: ${habit.name}',
                payload: habit.id,
              );
              developer.log('Notification sent successfully');
            } else {
              developer.log('Outside 15-minute window, skipping notification');
            }
          }
        } else {
          developer.log('No habits to check');
        }

        developer.log('=== BACKGROUND TASK COMPLETED ===');
        return true;
      }
    } catch (e) {
      developer.log('ERROR in background task: $e');
      return false;
    }

    return false;
  });
}
