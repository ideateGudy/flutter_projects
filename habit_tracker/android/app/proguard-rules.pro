# Keep Flutter engine and dart runtime
-keep class io.flutter.** { *; }
-keep interface io.flutter.** { *; }

# Keep notification classes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class android.app.Notification** { *; }

# Suppress warnings for optional Google Play Core library classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn javax.lang.model.element.Modifier

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


