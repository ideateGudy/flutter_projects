import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String habitName;
  final bool isCompleted;
  final List<int> repeatDays;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? editHabit;
  final Function(BuildContext)? deleteHabit;
  final Function(BuildContext)? stopHabit;

  const MyHabitTile({
    super.key,
    required this.habitName,
    required this.isCompleted,
    required this.repeatDays,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
    this.stopHabit,
  });

  @override
  Widget build(BuildContext context) {
      const weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            //edit option
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.blue,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(8),
            ),

            //stop option
            if (stopHabit != null)
              SlidableAction(
                onPressed: stopHabit,
                backgroundColor: Colors.orange,
                icon: Icons.pause,
                borderRadius: BorderRadius.circular(8),
              ),

            //delete option
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => onChanged?.call(!isCompleted),
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                habitName,
                style: TextStyle(
                  fontSize: 18,
                  color: isCompleted
                      ? Colors.white
                      : Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ⭐ Added subtitle showing schedule
              subtitle: Text(
                repeatDays.isEmpty
                    ? "Daily"
                    : repeatDays
                        .map((d) => weekDays[d - 1])
                        .join(" "),
                style: TextStyle(
                  color: isCompleted ? Colors.white70 : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              leading: Checkbox(
                value: isCompleted,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
