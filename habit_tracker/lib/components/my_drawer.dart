import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/manage_habits_page.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/theme/notification_preference_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Habit Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Theme Toggle
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                CupertinoSwitch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          // Notifications Toggle
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(fontSize: 16)),
                CupertinoSwitch(
                  value: context
                      .watch<NotificationPreferenceProvider>()
                      .notificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      // Enable notifications
                      await context
                          .read<NotificationPreferenceProvider>()
                          .setNotificationPreference(true);
                    } else {
                      // Disable notifications
                      await context
                          .read<NotificationPreferenceProvider>()
                          .setNotificationPreference(false);

                      // Cancel all pending notifications
                      await NotificationService().cancelAllNotifications();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          // Manage Habits
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage All Habits'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageHabitsPage(),
                ),
              );
            },
          ),
          const Divider(height: 24),
          // Test Notification Button
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Test Notification'),
            onTap: () async {
              await NotificationService().sendImmediateNotification(
                id: 9999,
                title: 'Test Notification',
                body:
                    'This is a test notification to verify the notification system is working!',
                payload: 'test_notification',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
