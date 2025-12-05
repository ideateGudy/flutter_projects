import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_database.dart';

/// Provider for managing global notification preferences
/// This provider persists the user's notification on/off setting across app sessions
/// Uses ChangeNotifier for reactive state management with Provider package
class NotificationPreferenceProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;

  /// Get the current global notification preference
  bool get notificationsEnabled => _notificationsEnabled;

  /// Initialize the provider by loading saved preference from database
  Future<void> initialize() async {
    _notificationsEnabled = await HabitDatabase.getNotificationPreference();
    notifyListeners();
  }

  /// Toggle global notification preference
  /// When disabled, cancels all notifications
  /// This preference is persisted to the database
  Future<void> setNotificationPreference(bool value) async {
    _notificationsEnabled = value;
    await HabitDatabase.saveNotificationPreference(value);
    notifyListeners();
  }
}
