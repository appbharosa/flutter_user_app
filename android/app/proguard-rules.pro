# =============================================================
# 1. Firebase (FCM, Analytics, Crashlytics)
# =============================================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }

# =============================================================
# 2. EnableX / WebRTC (video call SDK)
# =============================================================
-keep class enx_rtc_android.** { *; }
-keep class com.enablex.** { *; }
-keep class org.webrtc.** { *; }
# Keep WebRTC native methods
-keepclasseswithmembers class * {
    native <methods>;
}
# Keep WebRTC inner classes (optional but safe)
-keepclassmembers class org.webrtc.** { *; }

# =============================================================
# 3. Networking (OkHttp, Dio, Retrofit)
# =============================================================
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class javax.annotation.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# =============================================================
# 4. Your app's own classes (if any use reflection)
# =============================================================
-keep class com.medrayder.user.** { *; }

# =============================================================
# 5. AudioPlayers (used for ringtone)
# =============================================================
-keep class com.audioplayers.** { *; }
-keep class xyz.luan.audioplayers.** { *; }

# =============================================================
# 6. Flutter Local Notifications (used for incoming call UI)
# =============================================================
-keep class com.dexterous.** { *; }

# =============================================================
# 7. General Flutter & Android framework
# =============================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
# Keep all native method names (for JNI)
-keepclasseswithmembernames class * {
    native <methods>;
}

# =============================================================
# 8. Glide & Google Play Core (used by EnableX / Firebase)
# =============================================================
-keep class com.bumptech.glide.** { *; }
-keep class com.bumptech.glide.load.** { *; }
-keep class com.bumptech.glide.request.** { *; }
-keep class com.bumptech.glide.request.target.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.bumptech.glide.**
-dontwarn com.bumptech.glide.load.**
-dontwarn com.bumptech.glide.request.**
-dontwarn com.bumptech.glide.request.target.**

# =============================================================
# 9. Annotations & line numbers for debugging
# =============================================================
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# =============================================================
# 10. Suppress warnings for missing classes (harmless)
# =============================================================
-dontwarn javax.xml.stream.**
-dontwarn org.apache.tika.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**