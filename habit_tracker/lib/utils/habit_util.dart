//given a habit list of completion days
//is the habit completed today?
import 'package:habit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day,
  );
}

//prepare heat map datasets from habit list
Map<DateTime, int> prepareHeatMapDatasets(List<Habit> habits) {
  Map<DateTime, int> datasets = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      //normalize date to avoid time mismatches
      final key = DateTime(date.year, date.month, date.day);

      //if date already exists in datasets, increment count
      if (datasets.containsKey(key)) {
        datasets[key] = datasets[key]! + 1;
      } else {
        datasets[key] = 1;
      }
    }
  }

  return datasets;
}