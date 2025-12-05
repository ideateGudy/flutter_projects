# Workmanager background task rules - CRITICAL for notifications
-keep class dev.fluttercommunity.plus.workmanager.** { *; }
-keep interface dev.fluttercommunity.plus.workmanager.** { *; }
-keep class androidx.work.** { *; }
-keep interface androidx.work.** { *; }

# Keep Flutter engine and dart runtime
-keep class io.flutter.** { *; }
-keep interface io.flutter.** { *; }

# Keep notification classes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class android.app.Notification** { *; }

# Keep Hive and serialization
-keep class com.example.habit_tracker.** { *; }
-keepclassmembers class * {
  *** *;
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep constructors that are called from JNI
-keepclasseswithmembers class * {
    *** *(...);
}


