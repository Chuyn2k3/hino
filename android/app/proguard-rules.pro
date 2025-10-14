# --- Giữ lại các class Firebase và Google Play services ---
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# --- Giữ lại Flutter plugins và JNI ---
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# --- Giữ lại các Annotation cần thiết ---
-keepattributes Signature
-keepattributes *Annotation*

# --- Giữ lại các class Google Common cần thiết ---
-keep class com.google.common.reflect.TypeToken
-keep class * extends com.google.common.reflect.TypeToken

# --- Giữ lại AndroidX Window và Sidecar classes (fix Jetpack WindowManager warnings) ---
-dontwarn androidx.window.**
-keep class androidx.window.** { *; }
-keep interface androidx.window.** { *; }

# --- Tùy chọn: tránh cảnh báo Kotlin, JetBrains annotations ---
-dontwarn kotlin.**
-dontwarn org.jetbrains.annotations.**

# --- (Tùy chọn) Nếu dùng Firebase Messaging ---
-keepclassmembers class * {
    @com.google.firebase.messaging.FirebaseMessagingService <methods>;
}

# --- (Tùy chọn) Nếu dùng Awesome Notifications ---
-keep class me.carda.awesome_notifications.** { *; }

# --- (Tùy chọn) Nếu dùng SharedPreferences hoặc JSON parsing ---
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
