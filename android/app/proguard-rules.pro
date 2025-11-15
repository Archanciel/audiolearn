# Keep Flutter SharedPreferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep all Pigeon-generated classes (very important)
-keep class * implements io.flutter.plugins.sharedpreferences.SharedPreferencesApi { *; }
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
