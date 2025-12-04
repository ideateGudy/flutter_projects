/// Habit Model Class
///
/// Represents a single habit with:
/// - id: Unique identifier (UUID)
/// - name: The habit name (e.g., "Morning Exercise")
/// - completedDays: List of dates when completed
/// - isActive: Whether the habit is currently active (stopped habits retain history)
/// - stoppedDate: The date when the habit was stopped (null if never stopped)
class Habit {
  /// Unique identifier for the habit (UUID v4)
  final String id;

  /// Name of the habit (what the user wants to track)
  String name;

  /// List of dates when this habit was completed
  /// Dates are stored as DateTime with only year/month/day (no time)
  List<DateTime> completedDays;

  /// Whether this habit is currently active
  /// When false, habit won't show on next day but retains history and heatmap
  bool isActive;

  /// The date when this habit was stopped (null if still active or never stopped)
  DateTime? stoppedDate;

  /// Repeat days of the week.
/// Values follow DateTime.weekday: 1=Mon, 7=Sun.
/// Empty list = daily (default)
  List<int> repeatDays;

  /// Constructor
  Habit({
    required this.id,
    required this.name,
    this.completedDays = const [],
    this.isActive = true,
    this.stoppedDate,
    this.repeatDays = const [], // means daily by default
  });

  /// Convert Habit to Map for storing in Hive
  /// DateTime objects are converted to ISO 8601 strings
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completedDays': completedDays
          .map((date) => date.toIso8601String())
          .toList(),
      'isActive': isActive,
      'stoppedDate': stoppedDate?.toIso8601String(),
      'repeatDays': repeatDays,
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
      isActive: map['isActive'] as bool? ?? true,
      stoppedDate: map['stoppedDate'] != null
          ? DateTime.parse(map['stoppedDate'] as String)
          : null,
      /// fallback to empty list (daily)
      repeatDays: (map['repeatDays'] as List<dynamic>?)
              ?.map((d) => d as int)
              .toList() ??
          [],
    );
  }
}
