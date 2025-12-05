import 'package:flutter/material.dart';
import 'package:habit_tracker/components/notification_settings.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

class ManageHabitsPage extends StatefulWidget {
  const ManageHabitsPage({super.key});

  @override
  State<ManageHabitsPage> createState() => _ManageHabitsPageState();
}

class _ManageHabitsPageState extends State<ManageHabitsPage> {
  final TextEditingController _habitController = TextEditingController();
  final List<String> weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  void _editHabit(Habit habit) {
    _habitController.text = habit.name;
    List<int> tempSelectedDays = List.from(habit.repeatDays);
    int notificationInterval = habit.notificationIntervalMinutes;
    int notificationHour = habit.notificationHour;
    int notificationMinute = habit.notificationMinute;
    bool notificationsEnabled = habit.notificationsEnabled;

    RepeatType repeatType = habit.repeatDays.isEmpty
        ? RepeatType.daily
        : RepeatType.custom;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Habit'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _habitController,
                    decoration: const InputDecoration(hintText: 'Habit name'),
                  ),
                  const SizedBox(height: 20),

                  // Repeat Type
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Repeat",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text("Daily"),
                        selected: repeatType == RepeatType.daily,
                        selectedColor: Colors.blueAccent,
                        onSelected: (_) {
                          setState(() {
                            repeatType = RepeatType.daily;
                            tempSelectedDays.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Custom"),
                        selected: repeatType == RepeatType.custom,
                        selectedColor: Colors.blueAccent,
                        onSelected: (_) {
                          setState(() => repeatType = RepeatType.custom);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Custom Day Selector
                  if (repeatType == RepeatType.custom)
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        final dayNum = i + 1;
                        final selected = tempSelectedDays.contains(dayNum);
                        return ChoiceChip(
                          label: Text(weekDays[i]),
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                tempSelectedDays.add(dayNum);
                              } else {
                                tempSelectedDays.remove(dayNum);
                              }
                            });
                          },
                        );
                      }),
                    ),

                  const SizedBox(height: 16),

                  // Notification Settings
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        NotificationSettings(
                          initialIntervalMinutes: notificationInterval,
                          initialHour: notificationHour,
                          initialMinute: notificationMinute,
                          initialNotificationsEnabled: notificationsEnabled,
                          onSettingsChanged: (interval, hour, minute, enabled) {
                            setState(() {
                              notificationInterval = interval;
                              notificationHour = hour;
                              notificationMinute = minute;
                              notificationsEnabled = enabled;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _habitController.clear();
                },
              ),
              TextButton(
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  final name = _habitController.text;

                  context.read<HabitDatabase>().updateHabit(
                    habit.id,
                    name,
                    repeatType == RepeatType.daily ? [] : tempSelectedDays,
                    notificationIntervalMinutes: notificationInterval,
                    notificationHour: notificationHour,
                    notificationMinute: notificationMinute,
                    notificationsEnabled: notificationsEnabled,
                  );

                  Navigator.pop(context);
                  _habitController.clear();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage All Habits'), centerTitle: true),
      body: Consumer<HabitDatabase>(
        builder: (context, habitDatabase, child) {
          // Get all active habits (not stopped)
          final activeHabits = habitDatabase.habits
              .where((h) => h.isActive)
              .toList();

          if (activeHabits.isEmpty) {
            return Center(
              child: Text(
                'No active habits',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: activeHabits.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final habit = activeHabits[index];
              final now = DateTime.now();
              final shouldAppearToday =
                  habit.repeatDays.isEmpty ||
                  habit.repeatDays.contains(now.weekday);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(habit.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Repeat: ${habit.repeatDays.isEmpty ? "Daily" : "Custom (${habit.repeatDays.length} days)"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Notifications: ${habit.notificationsEnabled ? "Enabled (every ${habit.notificationIntervalMinutes} min)" : "Disabled"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (!shouldAppearToday)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade900,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Not due today',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editHabit(habit),
                  ),
                  onTap: () => _editHabit(habit),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Enum for repeat type
enum RepeatType { daily, custom }
