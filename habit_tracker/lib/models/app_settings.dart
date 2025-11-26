/// App Settings Model Class
///
/// Stores application-wide settings
/// Stores: first launch date (for heatmap), theme preference
class AppSettings {
  /// Fixed identifier 'app_settings_1'
  /// Only one AppSettings object is stored in the database
  final String id;

  /// Date when the app was first launched
  /// Used as the start date for the habit heatmap visualization
  DateTime? firstLaunchDate;

  /// Theme preference
  /// true = dark mode, false = light mode
  bool isDarkMode;

  /// Constructor
  AppSettings({
    required this.id,
    this.firstLaunchDate,
    this.isDarkMode = false,
  });

  /// Convert AppSettings to Map for storing in Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstLaunchDate': firstLaunchDate?.toIso8601String(),
      'isDarkMode': isDarkMode,
    };
  }

  /// Create AppSettings from Map retrieved from Hive
  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      id: map['id'] as String,
      firstLaunchDate: map['firstLaunchDate'] != null
          ? DateTime.parse(map['firstLaunchDate'] as String)
          : null,
      isDarkMode: map['isDarkMode'] as bool? ?? false,
    );
  }
}
