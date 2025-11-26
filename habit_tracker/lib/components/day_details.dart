import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';

class DayDetailsDialog extends StatelessWidget {
  final DateTime selectedDate;
  final List<Habit> allHabits;

  const DayDetailsDialog({
    super.key,
    required this.selectedDate,
    required this.allHabits,
  });

  @override
  Widget build(BuildContext context) {
    // Get habits completed on the selected date
    final completedHabits = allHabits.where((habit) {
      return habit.completedDays.any(
        (date) =>
            date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day,
      );
    }).toList();

    // Check if any habit exists for this date or earlier
    // If no habits were created before or on this date, show empty
    final hasAnyHabitOnOrBeforeDate = allHabits.any((habit) {
      return habit.completedDays.any(
        (date) =>
            date.year < selectedDate.year ||
            (date.year == selectedDate.year &&
                date.month < selectedDate.month) ||
            (date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day <= selectedDate.day),
      );
    });

    // Get habits not completed on the selected date (only active habits)
    // Only show if this date is on or after a habit was created
    final notCompletedHabits = (hasAnyHabitOnOrBeforeDate)
        ? allHabits.where((habit) {
            final isCompleted = habit.completedDays.any(
              (date) =>
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day,
            );
            return !isCompleted && habit.isActive;
          }).toList()
        : [];

    final dayOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][selectedDate.weekday - 1];

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateStr =
        '$dayOfWeek, ${monthNames[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateStr,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Show completed habits
            if (completedHabits.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completedHabits.length,
                    itemBuilder: (context, index) {
                      final habit = completedHabits[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                habit.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            // Show not completed habits
            if (notCompletedHabits.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not Completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notCompletedHabits.length,
                    itemBuilder: (context, index) {
                      final habit = notCompletedHabits[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                habit.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            // Show empty state
            if (completedHabits.isEmpty && notCompletedHabits.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No habits for this date',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
