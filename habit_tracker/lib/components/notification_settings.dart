import 'package:flutter/material.dart';

/// Widget for configuring notification settings for habits
class NotificationSettings extends StatefulWidget {
  final int initialIntervalMinutes;
  final int initialHour;
  final int initialMinute;
  final bool initialNotificationsEnabled;
  final Function(int, int, int, bool) onSettingsChanged;

  const NotificationSettings({
    super.key,
    required this.initialIntervalMinutes,
    required this.initialHour,
    required this.initialMinute,
    required this.initialNotificationsEnabled,
    required this.onSettingsChanged,
  });

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late int selectedInterval;
  late int selectedHour;
  late int selectedMinute;
  late bool notificationsEnabled;

  @override
  void initState() {
    super.initState();
    selectedInterval = widget.initialIntervalMinutes;
    selectedHour = widget.initialHour;
    selectedMinute = widget.initialMinute;
    notificationsEnabled = widget.initialNotificationsEnabled;
  }

  void _updateSettings() {
    widget.onSettingsChanged(
      selectedInterval,
      selectedHour,
      selectedMinute,
      notificationsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notifications Enable/Disable Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enable Notifications',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                  _updateSettings();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Show time and interval settings only if enabled
        if (notificationsEnabled) ...[
          // Start Time
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start Time',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Hour
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedHour,
                        isExpanded: true,
                        items: List.generate(
                          24,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text('${i.toString().padLeft(2, '0')}:00'),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedHour = value;
                              _updateSettings();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Minute
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedMinute,
                        isExpanded: true,
                        items: [0, 15, 30, 45]
                            .map(
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString().padLeft(2, '0')),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedMinute = value;
                              _updateSettings();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notification Interval
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reminder Interval',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$selectedInterval min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: selectedInterval.toDouble(),
                  min: 15,
                  max: 480, // 8 hours
                  divisions: 31, // (480-15)/15 = 31
                  label: '$selectedInterval min',
                  onChanged: (value) {
                    setState(() {
                      selectedInterval = value.toInt();
                      _updateSettings();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickButton('15m', 15),
                    _buildQuickButton('30m', 30),
                    _buildQuickButton('1h', 60),
                    _buildQuickButton('2h', 120),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickButton(String label, int minutes) {
    final isSelected = selectedInterval == minutes;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInterval = minutes;
          _updateSettings();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.blue, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
