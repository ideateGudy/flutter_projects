/// Habit Model Class
///
/// Represents a single habit with:
/// - id: Unique identifier (UUID)
/// - name: The habit name (e.g., "Morning Exercise")
/// - completedDays: List of dates when completed
class Habit {
  /// Unique identifier for the habit (UUID v4)
  final String id;

  /// Name of the habit (what the user wants to track)
  String name;

  /// List of dates when this habit was completed
  /// Dates are stored as DateTime with only year/month/day (no time)
  List<DateTime> completedDays;

  /// Constructor
  Habit({required this.id, required this.name, this.completedDays = const []});

  /// Convert Habit to Map for storing in Hive
  /// DateTime objects are converted to ISO 8601 strings
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completedDays': completedDays
          .map((date) => date.toIso8601String())
          .toList(),
    };
  }

  /// Create Habit from Map retrieved from Hive
  /// ISO 8601 strings are converted back to DateTime
  factory Habit.fromMap(Map<dynamic, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      completedDays:
          (map['completedDays'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date as String))
              .toList() ??
          [],
    );
  }
}
