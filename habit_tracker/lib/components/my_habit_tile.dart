import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String habitName;
  final bool isCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? editHabit;
  final Function(BuildContext)? deleteHabit;
  const MyHabitTile({
    super.key,
    required this.habitName,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            //edit option
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(8),
            ),

            //delete option
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
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
