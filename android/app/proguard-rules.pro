# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep classes for reflection (needed by Firebase and others)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep your main activity
-keep class com.agrita.app.MainActivity { *; }

# (Optional) keep models used with Gson, Retrofit, or JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
# --- Fix for missing Play Core classes ---
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Flutter embedding and deferred component managers
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Optional: suppress warnings about annotations and generics
-keepattributes *Annotation*
-keepattributes Signature

