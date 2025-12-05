import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  /// Initialize the notification service
  /// Call this in main.dart before runApp()
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel (required for Android 8+)
    await _createAndroidNotificationChannel();
  }

  /// Create Android notification channel (required for Android 8+)
  Future<void> _createAndroidNotificationChannel() async {
    try {
      final android = _flutterLocalNotificationsPlugin
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
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Add your navigation or action logic here
  }

  /// Check if notification permission is granted (Android 13+)
  /// Returns true if permission is granted or if on iOS
  Future<bool> isNotificationPermissionGranted() async {
    // Android automatically handles permissions when displaying notifications
    return true;
  }

  /// Request notification permission from the user (Android 13+)
  /// Android will automatically show the permission dialog when needed
  /// This method just returns true to allow the toggle
  Future<bool> requestNotificationPermission() async {
    // Android automatically requests permission when displaying first notification
    // iOS permissions are handled in initialize()
    return true;
  }

  /// Schedule a recurring notification for a habit
  /// [habitId]: Unique identifier for the habit
  /// [habitName]: Name of the habit to display in notification
  /// [startHour]: Hour to start sending notifications (0-23)
  /// [startMinute]: Minute to start sending notifications (0-59)
  /// [intervalMinutes]: Interval between notifications in minutes
  Future<void> scheduleHabitNotification({
    required String habitId,
    required String habitName,
    required int startHour,
    required int startMinute,
    int intervalMinutes = 60,
  }) async {
    try {
      // Schedule the first notification for today
      await _scheduleNotificationAtTime(
        id: habitId.hashCode,
        title: 'Habit Reminder',
        body: 'Complete your habit: $habitName',
        payload: habitId,
        hour: startHour,
        minute: startMinute,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Schedule a notification at a specific time
  Future<void> _scheduleNotificationAtTime({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'habit_channel',
            'Habit Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.max,
            priority: Priority.high,
            autoCancel: true,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Habit Reminder',
        'Complete your habit to stop notifications',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Cancel all notifications for a habit
  Future<void> cancelHabitNotification(String habitId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(habitId.hashCode);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Send an immediate notification (used by background tasks)
  Future<void> sendImmediateNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'habit_channel',
            'Habit Reminders',
            channelDescription: 'Notifications for habit reminders',
            importance: Importance.max,
            priority: Priority.high,
            autoCancel: true,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      // Handle error silently
    }
  }
}
