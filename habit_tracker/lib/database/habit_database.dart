import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /*
  SETUP METHODS
  */

  // Initialize the Isar database
  static Future<void> initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
      inspector: true,
    );
  }

  // save first launch date (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final newSettings = AppSettings()..firstLaunchDate = DateTime.now();

      await isar.writeTxn(() => isar.appSettings.put(newSettings));
    }
  }

  // get first launch date
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*
  CRUD METHODS FOR HABITS
  */

  // list of habits
  final List<Habit> habits = [];

  // create a new habit
  Future<void> addHabit(String name) async {
    // create a new habit object
    final newHabit = Habit()..name = name;

    // save to database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re-read habits from database
    await readHabits();
  }

  // read a habit from database
  Future<void> readHabits() async {
    //fetch all habits from database
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //get current habits
    habits.clear();
    habits.addAll(fetchedHabits);

    //notify listeners about the change to update UI
    notifyListeners();
  }

  //update: check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the habit by id
    final habit = await isar.habits.get(id);
    //today
    final today = DateTime.now();

    // update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit is completed => add current date to completedDays list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          // add current date if not already present
          habit.completedDays.add(DateTime(today.year, today.month, today.day));
        }
        //if habit is uncompleted => remove current date from completedDays list
        else {
          //remove current date if habit is uncompleted
          habit.completedDays.removeWhere(
            (date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day,
          );
        }
        //save the updated habit back to database
        await isar.habits.put(habit);
      });
    }
    //re-read habits from database
    await readHabits();
  }

  // update a habit name
  Future<void> updateHabitName(int id, String newName) async {
    //find the habit by id
    final habit = await isar.habits.get(id);

    // update name
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        //save the updated habit back to database
        await isar.habits.put(habit);
      });
    }
    //re-read habits from database
    await readHabits();
  }

  // delete a habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() => isar.habits.delete(id));
    //re-read habits from database
    await readHabits();
  }
}
