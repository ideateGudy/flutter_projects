import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/components/notification_settings.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utils/habit_util.dart';
import 'package:habit_tracker/services/exact_alarm_scheduler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime displayMonth;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    displayMonth = DateTime.now();
    //read the database when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitDatabase>().readHabits();
      // Reschedule alarms when app resumes to ensure they're still scheduled
      ExactAlarmScheduler.rescheduleAllAlarms();
    });
  }

  void _previousMonth() {
    setState(() {
      displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
    });
    // Refresh habits when navigating months to ensure stopped habits display
    context.read<HabitDatabase>().readHabits();
  }

  void _nextMonth() {
    // Don't allow navigating to future months
    final now = DateTime.now();
    if (displayMonth.year < now.year ||
        (displayMonth.year == now.year && displayMonth.month < now.month)) {
      setState(() {
        displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
      });
      // Refresh habits when navigating months to ensure stopped habits display
      context.read<HabitDatabase>().readHabits();
    }
  }

  //text controller
  final TextEditingController _habitController = .new();
  final List<String> weekDays = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];
  List<int> selectedDays = []; // 1-7

  //create a new habit
  void createNewHabit() {
    List<int> tempSelectedDays = [];
    RepeatType repeatType = RepeatType.daily;
    int notificationInterval = 60;
    int notificationHour = 9;
    int notificationMinute = 0;
    bool notificationsEnabled = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Create New Habit'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _habitController,
                    decoration: const InputDecoration(hintText: 'Habit name'),
                  ),
                  const SizedBox(height: 20),

                  // 1️⃣ Repeat Type
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
                        backgroundColor: Colors.blueAccent,
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

                  // 2️⃣ Custom Day Selector
                  if (repeatType == RepeatType.custom)
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (i) {
                        final dayNumber = i + 1;
                        final isSelected = tempSelectedDays.contains(dayNumber);

                        return ChoiceChip(
                          label: Text(weekDays[i]),
                          selected: isSelected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                tempSelectedDays.add(dayNumber);
                              } else {
                                tempSelectedDays.remove(dayNumber);
                              }
                            });
                          },
                        );
                      }),
                    ),

                  const SizedBox(height: 16),

                  // 3️⃣ Notification Settings
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
                child: const Text('Save', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  final name = _habitController.text;

                  context.read<HabitDatabase>().addHabitWithRepeat(
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

  //check habit on/off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update the habit completion status in database
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit
  void editHabit(Habit habit) {
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
                        backgroundColor: Colors.blueAccent,
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

                  // custom weekday selector
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

  //delete habit
  void deleteHabit(Habit habit) {
    //show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          MaterialButton(
            onPressed: () {
              //delete the habit from database
              context.read<HabitDatabase>().deleteHabit(habit.id);

              //close the dialog
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  //stop/resume habit
  void toggleHabitStatus(Habit habit) {
    if (habit.isActive) {
      //show confirmation to stop
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stop Habit'),
          content: const Text(
            'Stop this habit? It will hide from daily list but retain history.',
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            MaterialButton(
              onPressed: () {
                context.read<HabitDatabase>().stopHabit(habit.id);
                Navigator.pop(context);
              },
              child: const Text('Stop', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    } else {
      //resume the habit
      context.read<HabitDatabase>().resumeHabit(habit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get month abbreviations for display
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthYear =
        '${monthNames[displayMonth.month - 1]} ${displayMonth.year}';

    // Check if we're on the current month
    final now = DateTime.now();
    final isCurrentMonth =
        displayMonth.year == now.year && displayMonth.month == now.month;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(monthYear),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousMonth,
          ),
          isCurrentMonth
              ? const SizedBox(width: 56)
              : IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextMonth,
                ),
          isCurrentMonth
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: createNewHabit,
                )
              : const SizedBox(width: 48),
        ],
      ),
      drawer: const MyDrawer(),
      body: ListView(
        children: [
          //HEAT MAP
          _buildHeatMap(),

          //HABIT LIST
          _buildHabitList(),

          //STOPPED HABITS SECTION
          _buildStoppedHabitsSection(),
        ],
      ),
    );
  }

  //build heat map
  Widget _buildHeatMap() {
    //get the habit database
    final habitDatabase = context.watch<HabitDatabase>();

    //get all habits
    List<Habit> habits = habitDatabase.habits;

    //return the heat map ui
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //once data is available build the heat map
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepareHeatMapDatasets(habits),
            habits: habits,
            displayMonth: displayMonth,
          );
        }
        //handle case where no data is returned
        else {
          return Container();
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //get the habit database
    final habitDatabase = context.watch<HabitDatabase>();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final displayedMonth = DateTime(displayMonth.year, displayMonth.month);

    // Filter active habits based on displayed month
    List<Habit> habits = habitDatabase.habits.where((h) => h.isActive).where((
      h,
    ) {
      final shouldAppearToday =
          h.repeatDays.isEmpty || h.repeatDays.contains(now.weekday);

      if (!shouldAppearToday) return false;

      // If viewing current month, show all active habits
      if (displayedMonth.year == currentMonth.year &&
          displayedMonth.month == currentMonth.month) {
        return true;
      }

      // If viewing past months, only show habits with completion history in that month
      return h.completedDays.any((date) {
        return date.year == displayMonth.year &&
            date.month == displayMonth.month;
      });
    }).toList();

    // Show placeholder if viewing previous month with no habits
    final isPreviousMonth =
        displayedMonth.year < currentMonth.year ||
        (displayedMonth.year == currentMonth.year &&
            displayedMonth.month < currentMonth.month);

    if (habits.isEmpty && isPreviousMonth) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'No habits were tracked this month',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    //return a list for habits ui
    return ListView.builder(
      itemCount: habits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //get each habit
        final habit = habits[index];

        //check if the habit is completed today
        bool isCompleted = isHabitCompletedToday(habit.completedDays);

        //return a list tile for each habit
        return MyHabitTile(
          habitName: habit.name,
          isCompleted: isCompleted,
          repeatDays: habit.repeatDays,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabit(habit),
          deleteHabit: (context) => deleteHabit(habit),
          stopHabit: (context) => toggleHabitStatus(habit),
        );
      },
    );
  }

  //build stopped habits section
  Widget _buildStoppedHabitsSection() {
    final habitDatabase = context.watch<HabitDatabase>();

    // Get stopped habits that were stopped in the displayed month
    List<Habit> stoppedHabits = habitDatabase.habits
        .where((h) => !h.isActive && h.stoppedDate != null)
        .where((h) {
          // Show stopped habits only if they were stopped in the displayed month
          return h.stoppedDate!.year == displayMonth.year &&
              h.stoppedDate!.month == displayMonth.month;
        })
        .toList();

    if (stoppedHabits.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stopped Habits',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...stoppedHabits.map((habit) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => toggleHabitStatus(habit),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Tap to resume',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
