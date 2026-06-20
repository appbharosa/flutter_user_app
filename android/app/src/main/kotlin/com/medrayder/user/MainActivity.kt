package com.medrayder.user

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createVideoCallNotificationChannel()
    }

    private fun createVideoCallNotificationChannel() {
        // Only create the channel on Android 8.0 (API 26) and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "video_call_channel",
                "Video Calls",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "Notifications for incoming video calls"
            channel.enableVibration(true)
            channel.setSound(null, null) // use default sound

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}