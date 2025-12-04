import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/components/day_details.dart';
import 'package:habit_tracker/models/habit.dart';

class MyHeatMap extends StatefulWidget {
  final DateTime startDate;
  final Map<DateTime, int>? datasets;
  final List<Habit> habits;
  final DateTime displayMonth;

  const MyHeatMap({
    super.key,
    required this.startDate,
    required this.datasets,
    required this.habits,
    required this.displayMonth,
  });

  @override
  State<MyHeatMap> createState() => _MyHeatMapState();
}

class _MyHeatMapState extends State<MyHeatMap> {
  void _showDayDetails(DateTime date) {
    showDialog(
      context: context,
      builder: (context) =>
          DayDetailsDialog(selectedDate: date, allHabits: widget.habits),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate start and end dates for display month
    final monthStartDate = DateTime(
      widget.displayMonth.year,
      widget.displayMonth.month,
      1,
    );
    final monthEndDate = DateTime(
      widget.displayMonth.year,
      widget.displayMonth.month + 1,
      0,
    );

    return Column(
      children: [
        // Heat Map - Shows selected month with tap detection
        GestureDetector(
          onTapDown: (details) {
            // Approximate tap position to date
            // This is a simplified approach - we show date details on tap
            _showDayDetailsFromTap(details.globalPosition);
          },
          child: HeatMap(
            startDate: monthStartDate,
            endDate: monthEndDate,
            datasets: widget.datasets,
            colorMode: ColorMode.color,
            defaultColor: Theme.of(context).colorScheme.secondary,
            textColor: Theme.of(context).colorScheme.inversePrimary,
            showColorTip: false,
            showText: true,
            scrollable: true,
            size: 30,
            colorsets: {
              1: Colors.green.shade300,
              2: Colors.green.shade400,
              3: Colors.green.shade500,
              4: Colors.green.shade600,
              5: Colors.green.shade700,
              6: Colors.orange.shade400,
              7: Colors.orange.shade700,
              8: Colors.deepPurpleAccent.shade100,
              9: Colors.deepPurpleAccent.shade200,
              10: Colors.lightBlueAccent.shade400,
            },
            onClick: (value) {
              _showDayDetails(value);
            },
          ),
        ),
      ],
    );
  }

  void _showDayDetailsFromTap(Offset position) {
    // Get the approximate date from tap position
    // This is a simpler implementation - we'll create a date picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a date'),
        content: SizedBox(
          width: double.maxFinite,
          child: CalendarDatePicker(
            initialDate: widget.displayMonth,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onDateChanged: (date) {
              Navigator.pop(context);
              _showDayDetails(date);
            },
          ),
        ),
      ),
    );
  }
}
