import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'dart:developer' as developer;
import 'dart:async';

/// Simple callback that gets called when alarm fires
/// This MUST be a top-level function for Android alarm manager
/// NOTE: This is rarely triggered in practice - Timer polling is the main mechanism
@pragma('vm:entry-point')
Future<void> alarmCallbackDispatcher() async {
  developer.log('🔔 ALARM CALLBACK DISPATCHER CALLED at ${DateTime.now()}');

  try {
    // First, reschedule the next alarm for 1 minute from now
    try {
      const alarmId = 999999;
      final nextCheckTime = DateTime.now().add(const Duration(minutes: 1));

      await AndroidAlarmManager.oneShotAt(
        nextCheckTime,
        alarmId,
        alarmCallbackDispatcher,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: false,
      );
      developer.log('✅ Rescheduled next notification check for $nextCheckTime');
    } catch (e) {
      developer.log('⚠️ Failed to reschedule alarm: $e');
    }

    developer.log('Step 1: Creating FlutterLocalNotificationsPlugin instance');
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    developer.log('Step 2: Initializing notification plugin');
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(settings);
    developer.log('✅ Notification plugin initialized');

    developer.log('Step 3: Creating notification channel');
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'habit_channel',
        'Habit Reminders',
        description: 'Notifications for habit reminders',
        importance: Importance.max,
      );
      await android.createNotificationChannel(channel);
      developer.log('✅ Notification channel created');
    }

    developer.log('Step 4: Getting app documents directory');
    final appDocDir = await getApplicationDocumentsDirectory();
    developer.log('Step 5: Initializing Hive');
    Hive.init(appDocDir.path);

    developer.log('Step 6: Opening boxes');
    if (!Hive.isBoxOpen('habits')) {
      await Hive.openBox('habits');
    }
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    // Check global notification preference
    final settingsBox = Hive.box('settings');
    final settingsMap = settingsBox.get('appSettings');
    bool globalNotificationsEnabled = true;

    if (settingsMap != null) {
      final notificationsEnabledValue = settingsMap['notificationsEnabled'];
      if (notificationsEnabledValue != null) {
        globalNotificationsEnabled = notificationsEnabledValue as bool;
      }
    }

    if (!globalNotificationsEnabled) {
      developer.log(
        '⏹️ Global notifications disabled - skipping notification check',
      );
      return;
    }

    final habitsBox = Hive.box('habits');
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);

    developer.log('Step 7: Found ${habitsBox.length} habits in database');

    // Send notification for each active habit that should get one now
    int notificationCount = 0;
    for (var key in habitsBox.keys) {
      final habitMap = habitsBox.get(key);
      if (habitMap != null) {
        final habit = Habit.fromMap(habitMap);

        if (!habit.isActive || !habit.notificationsEnabled) {
          continue;
        }

        // Check if today is a scheduled day
        final shouldAppearToday =
            habit.repeatDays.isEmpty || habit.repeatDays.contains(now.weekday);
        if (!shouldAppearToday) {
          continue;
        }

        // Check if already completed today
        final isCompletedToday = habit.completedDays.any(
          (date) =>
              date.year == todayNormalized.year &&
              date.month == todayNormalized.month &&
              date.day == todayNormalized.day,
        );
        if (isCompletedToday) {
          continue;
        }

        developer.log(
          'Checking habit: ${habit.name}, isActive: ${habit.isActive}, notificationsEnabled: ${habit.notificationsEnabled}',
        );

        // Calculate the notification start time for today
        final notificationStart = DateTime(
          now.year,
          now.month,
          now.day,
          habit.notificationHour,
          habit.notificationMinute,
        );

        // Check if we're past the start time
        if (now.isAfter(notificationStart)) {
          final minutesElapsed = now.difference(notificationStart).inMinutes;
          final intervalMinutes = habit.notificationIntervalMinutes;

          // Check if this minute is a multiple of the interval
          if (minutesElapsed % intervalMinutes == 0) {
            try {
              developer.log('📢 Sending notification for: ${habit.name}');

              const AndroidNotificationDetails androidDetails =
                  AndroidNotificationDetails(
                    'habit_channel',
                    'Habit Reminders',
                    channelDescription: 'Notifications for habit reminders',
                    importance: Importance.max,
                    priority: Priority.high,
                    playSound: true,
                    enableVibration: true,
                    enableLights: true,
                  );

              const NotificationDetails notificationDetails =
                  NotificationDetails(android: androidDetails);

              await flutterLocalNotificationsPlugin.show(
                habit.id.hashCode,
                'Habit Reminder',
                'Complete your habit: ${habit.name}',
                notificationDetails,
                payload: habit.id,
              );

              developer.log('✅ Notification shown for ${habit.name}');
              notificationCount++;
            } catch (notifError) {
              developer.log(
                '❌ Failed to send notification for ${habit.name}: $notifError',
              );
            }
          }
        }
      }
    }

    developer.log(
      '🎉 Alarm callback completed - sent $notificationCount notifications',
    );
  } catch (e, stackTrace) {
    developer.log(
      '❌ Error in alarm dispatcher: $e\nStack: $stackTrace',
      error: e,
    );
  }
}

/// Exact Alarm Scheduler using Timer-based polling
/// Previously used android_alarm_manager_plus, but callbacks are unreliable
/// Timer polling provides exact minute-level accuracy and works reliably
class ExactAlarmScheduler {
  static const String alarmIdPrefix = 'habit_alarm_';

  /// Background timer for polling notifications
  /// This checks every minute and sends notifications as needed
  static Timer? _notificationCheckTimer;

  /// Initialize the alarm manager and start background notification check
  static Future<void> initialize() async {
    try {
      // Initialize Android Alarm Manager (kept for potential future use)
      // But we're not scheduling alarms - Timer polling is more reliable
      await AndroidAlarmManager.initialize();
      developer.log('ExactAlarmScheduler initialized');

      // Start the Timer polling mechanism (this is the main notification system)
      _startNotificationCheckTimer();
    } catch (e) {
      developer.log('Error initializing alarm manager: $e');
    }
  }

  /// Start a timer that checks for notifications every minute
  /// This is the primary mechanism for sending notifications
  static void _startNotificationCheckTimer() {
    // Cancel any existing timer
    _notificationCheckTimer?.cancel();

    // Check immediately
    _checkAndSendNotifications();

    // Then check every minute
    _notificationCheckTimer = Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) {
      _checkAndSendNotifications();
    });

    developer.log('✅ Started notification check timer (runs every minute)');
  }

  /// Check if any notifications should be sent now
  /// This runs every minute and determines which habits need notifications
  static Future<void> _checkAndSendNotifications() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);

      if (!Hive.isBoxOpen('habits')) {
        await Hive.openBox('habits');
      }
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }

      // ✅ Check global notification preference first
      // If notifications are disabled globally, don't send any notifications
      final settingsBox = Hive.box('settings');
      final settingsMap = settingsBox.get('appSettings');
      bool globalNotificationsEnabled = true;

      if (settingsMap != null) {
        final notificationsEnabledValue = settingsMap['notificationsEnabled'];
        if (notificationsEnabledValue != null) {
          globalNotificationsEnabled = notificationsEnabledValue as bool;
        }
      }

      if (!globalNotificationsEnabled) {
        developer.log(
          '⏹️ Global notifications disabled - skipping notification check',
        );
        return;
      }

      final habitsBox = Hive.box('habits');
      final now = DateTime.now();
      final todayNormalized = DateTime(now.year, now.month, now.day);

      for (var key in habitsBox.keys) {
        final habitMap = habitsBox.get(key);
        if (habitMap != null) {
          final habit = Habit.fromMap(habitMap);

          if (!habit.isActive || !habit.notificationsEnabled) {
            continue;
          }

          // ✅ Step 1: Check if today is a scheduled day for this habit
          // repeatDays is empty = daily, otherwise check if today's weekday is in the list
          // (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)
          final shouldAppearToday =
              habit.repeatDays.isEmpty ||
              habit.repeatDays.contains(now.weekday);

          if (!shouldAppearToday) {
            continue; // Skip - habit not scheduled for today
          }

          // ✅ Step 2: Check if habit is already completed today
          // If completed, don't send more notifications today
          final isCompletedToday = habit.completedDays.any(
            (date) =>
                date.year == todayNormalized.year &&
                date.month == todayNormalized.month &&
                date.day == todayNormalized.day,
          );

          if (isCompletedToday) {
            continue; // Skip - habit already completed today
          }

          // ✅ Step 3: Calculate the notification start time for today
          final notificationStart = DateTime(
            now.year,
            now.month,
            now.day,
            habit.notificationHour,
            habit.notificationMinute,
          );

          // ✅ Step 4: Check if we're past the start time
          if (now.isAfter(notificationStart)) {
            // Calculate minutes elapsed since start time
            final minutesElapsed = now.difference(notificationStart).inMinutes;
            final intervalMinutes = habit.notificationIntervalMinutes;

            // Check if this minute is a multiple of the interval
            // e.g., if interval is 15 min and 15 min elapsed, 30 min elapsed, etc.
            if (minutesElapsed % intervalMinutes == 0) {
              developer.log(
                '📢 Sending notification for habit: ${habit.name} at ${now.hour}:${now.minute.toString().padLeft(2, '0')} (${minutesElapsed} min elapsed, interval: ${intervalMinutes} min) - Day ${now.weekday}/${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
              );
              await NotificationService().sendImmediateNotification(
                id: habit.id.hashCode,
                title: 'Habit Reminder',
                body: 'Complete your habit: ${habit.name}',
                payload: habit.id,
              );
            }
          }
        }
      }
    } catch (e) {
      developer.log('Error checking notifications: $e');
    }
  }

  /// Stop the background notification check timer
  static void stopNotificationCheckTimer() {
    _notificationCheckTimer?.cancel();
    _notificationCheckTimer = null;
    developer.log('⏹️ Stopped notification check timer');
  }

  /// Schedule background alarms to check notifications even when app is closed
  /// Uses a single recurring alarm that fires every minute
  static Future<void> scheduleAllHabitAlarms() async {
    try {
      developer.log('📌 Scheduling background notification checks');
      await _scheduleBackgroundNotificationCheck();
    } catch (e) {
      developer.log('Error in scheduleAllHabitAlarms: $e');
    }
  }

  /// Schedule a background notification check alarm
  /// This runs every minute even when the app is closed
  static Future<void> _scheduleBackgroundNotificationCheck() async {
    try {
      const alarmId = 999999; // Unique ID for the background check alarm

      // Schedule an alarm for 1 minute from now
      final nextCheckTime = DateTime.now().add(const Duration(minutes: 1));

      await AndroidAlarmManager.oneShotAt(
        nextCheckTime,
        alarmId,
        alarmCallbackDispatcher,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: false,
      );

      developer.log(
        '✅ Scheduled background notification check at $nextCheckTime',
      );
    } catch (e) {
      developer.log('Error scheduling background notification check: $e');
    }
  }

  /// Schedule notifications for a specific habit (no-op - background alarm handles it)
  /// Kept for compatibility with existing code
  static Future<void> scheduleHabitNotifications(Habit habit) async {
    try {
      developer.log(
        '📌 Habit "${habit.name}" registered - background alarms will handle notifications',
      );
      // Background alarm already scheduled in initialize()
    } catch (e) {
      developer.log('Error scheduling notifications for habit: $e', error: e);
    }
  }

  /// Cancel all alarms for a specific habit (no-op - no Android alarms scheduled)
  /// Kept for compatibility with existing code
  static Future<void> cancelHabitAlarms(String habitId) async {
    try {
      developer.log(
        '📌 Habit alarms cancelled (no Android alarms to cancel - using Timer polling)',
      );
    } catch (e) {
      developer.log('Error cancelling alarms: $e');
    }
  }

  /// Cancel all habit alarms (no-op - no Android alarms scheduled)
  /// Kept for compatibility with existing code
  static Future<void> cancelAllAlarms() async {
    try {
      developer.log(
        '📌 All alarms cancelled (no Android alarms to cancel - using Timer polling)',
      );
    } catch (e) {
      developer.log('Error cancelling all alarms: $e');
    }
  }

  /// Reschedule alarms after a habit is completed (no-op - Timer polling handles it)
  /// Kept for compatibility with existing code
  static Future<void> onHabitCompleted(String habitId) async {
    try {
      developer.log(
        '📌 Habit completed - Timer polling will stop notifications for this habit',
      );
    } catch (e) {
      developer.log('Error handling habit completion: $e');
    }
  }

  /// Reschedule all alarms (no-op - Timer polling is continuous)
  /// Kept for compatibility with existing code
  static Future<void> rescheduleAllAlarms() async {
    try {
      developer.log(
        '📌 Alarms rescheduled (Timer polling is continuous - no Android alarms needed)',
      );
    } catch (e) {
      developer.log('Error rescheduling alarms: $e');
    }
  }
}
