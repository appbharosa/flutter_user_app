import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';
import 'pending_call.dart';
import 'navigation.dart' hide navigatorKey;
import '../../features/video_call_screen.dart';


class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Global ringtone player (assumes declared in main.dart)
  static final AudioPlayer _ringtonePlayer = AudioPlayer();

  static Future<void> initialize() async {
    try {
      // Request permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Firebase notifications permission denied');
        return;
      }

      // Initialize local notifications
      await _initLocalNotifications();

      // Get FCM token
      try {
        String? token = await _firebaseMessaging.getToken();
        debugPrint('Firebase FCM Token: $token');
      } catch (e) {
        debugPrint('Could not get FCM token (simulator or no APNS): $e');
      }

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen to background messages (when app is in background but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message (app opened from terminated state)
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleCallData(initialMessage.data);
      }
    } catch (e) {
      debugPrint('FirebaseNotificationService initialization failed: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static void _onNotificationResponse(NotificationResponse details) {
    debugPrint('Notification tapped: ${details.payload}');
    if (details.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(details.payload!);
        _handleCallData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.data}');
    // Show local notification
    await _showLocalNotification(message);
    // Always handle the call data
    _handleCallData(message.data);
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Message opened app: ${message.data}');
    _handleCallData(message.data);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'video_call_channel',
        'Video Call Notifications',
        channelDescription: 'Notifications for incoming video calls',
        importance: Importance.high,
        priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      String payloadJson = jsonEncode(message.data);

      await _localNotifications.show(
        id: notificationId,
        title: message.notification?.title ?? 'MedRayder',
        body: message.notification?.body ?? 'You have a new notification',
        notificationDetails: notificationDetails,
        payload: payloadJson,
      );
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }

  static void _handleCallData(Map<String, dynamic>? data) {
    if (data == null) {
      debugPrint('⚠️ No data in FCM message');
      return;
    }

    debugPrint('🔍 Handling call data: $data');

    // Check for both 'call_type' and 'type' fields
    final callType = data['call_type'] ?? data['type'];
    if (callType == 'video' || callType == 'incoming_call') {
      // ✅ Play ringtone
      _ringtonePlayer.stop();
      _ringtonePlayer.play(
        AssetSource('ringtone.mp3'),
        mode: PlayerMode.mediaPlayer,

      );

      // ✅ Extract token – try 'token' first, then 'patient_token'
      final String? token = data['token'] ?? data['patient_token'];
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ Token is missing in the payload – patient cannot join!');
      }

      pendingCallData = data;
      final context = navigatorKey.currentContext;
      if (context != null) {
        _navigateToVideoCall(context, data, token); // pass token separately
        pendingCallData = null;
      } else {
        debugPrint('⏳ Waiting for navigator context...');
        Future.delayed(const Duration(milliseconds: 500), () {
          final ctx = navigatorKey.currentContext;
          if (ctx != null && pendingCallData != null) {
            final String? delayedToken = pendingCallData!['token'] ?? pendingCallData!['patient_token'];
            _navigateToVideoCall(ctx, pendingCallData!, delayedToken);
            pendingCallData = null;
          }
        });
      }
    } else {
      debugPrint('ℹ️ Not a video call: $callType');
    }
  }

  static void _navigateToVideoCall(BuildContext context, Map<String, dynamic> data, String? token) {
    // Use the token extracted, or fallback to data['token'] / data['patient_token']
    final String callToken = token ?? data['token'] ?? data['patient_token'] ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          token: callToken,
          name: data['name'] ?? data['doctor_name'] ?? 'Doctor',
          doctorId: data['doctor_id']?.toString() ?? '',
          playerId: data['player_id']?.toString() ?? '',
          familyMemberId: data['family_member_id']?.toString() ?? '',
          bookingId: data['booking_id']?.toString() ?? '',
          consultType: data['consult_type'] ?? 'online',
        ),
      ),
    );
  }
  // Stop the ringtone when call is accepted or rejected
  static void stopRingtone() {
    _ringtonePlayer.stop();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}