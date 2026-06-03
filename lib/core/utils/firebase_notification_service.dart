import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pending_call.dart';
import 'navigation.dart';
import '../../features/video_call_screen.dart';

// class FirebaseNotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     // Request permissions
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus != AuthorizationStatus.authorized) {
//       debugPrint('Firebase notifications permission denied');
//       return;
//     }
//
//     // Initialize local notifications
//     await _initLocalNotifications();
//
//     // Get FCM token
//     String? token = await _firebaseMessaging.getToken();
//     debugPrint('Firebase FCM Token: $token');
//
//     // Listen to foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
//
//     // Listen to background messages (when app is in background but not terminated)
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
//
//     // Handle initial message (app opened from terminated state)
//     RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleCallData(initialMessage.data);
//     }
//   }
//
//   static Future<void> _initLocalNotifications() async {
//     // Android initialization settings
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // iOS initialization settings
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     // Combined initialization settings
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     // Initialize with settings and callback
//
//   }
//
//   // Separate callback method for notification taps
//   static void _onNotificationResponse(NotificationResponse details) {
//     debugPrint('Notification tapped: ${details.payload}');
//     if (details.payload != null) {
//       try {
//         final Map<String, dynamic> data = jsonDecode(details.payload!);
//         _handleCallData(data);
//       } catch (e) {
//         debugPrint('Error parsing notification payload: $e');
//       }
//     }
//   }
//
//   static Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     debugPrint('Foreground message received: ${message.data}');
//
//     // Show local notification when app is in foreground
//     await _showLocalNotification(message);
//
//     // Handle video call data
//     if (message.data['call_type'] == 'video') {
//       _handleCallData(message.data);
//     }
//   }
//
//   static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
//     debugPrint('Message opened app: ${message.data}');
//     _handleCallData(message.data);
//   }
//
//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     // Generate a unique id
//     int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
//
//     // Create Android notification details
//     AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
//       'video_call_channel',
//       'Video Call Notifications',
//       channelDescription: 'Notifications for incoming video calls',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     // Create iOS notification details
//     DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();
//
//     // Create notification details
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     // Convert data to JSON string for payload
//     String payloadJson = jsonEncode(message.data);
//
//
//   }
//
//   static void _handleCallData(Map<String, dynamic>? data) {
//     if (data == null) return;
//
//     if (data['call_type'] == 'video') {
//       pendingCallData = data;
//       final context = navigatorKey.currentContext;
//       if (context != null) {
//         _navigateToVideoCall(context, data);
//         pendingCallData = null;
//       }
//     }
//   }
//
//   static void _navigateToVideoCall(BuildContext context, Map<String, dynamic> data) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => VideoCallScreen(
//           token: data['token'] ?? '',
//           name: data['name'] ?? 'Doctor',
//           doctorId: data['doctor_id']?.toString() ?? '',
//           playerId: data['player_id']?.toString() ?? '',
//           familyMemberId: data['family_member_id']?.toString() ?? '',
//           bookingId: data['booking_id']?.toString() ?? '',
//           consultType: data['consult_type'] ?? 'online',
//         ),
//       ),
//     );
//   }
//
//   // Helper method to subscribe to topics
//   static Future<void> subscribeToTopic(String topic) async {
//     await _firebaseMessaging.subscribeToTopic(topic);
//   }
//
//   static Future<void> unsubscribeFromTopic(String topic) async {
//     await _firebaseMessaging.unsubscribeFromTopic(topic);
//   }
// }


import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pending_call.dart';
import 'navigation.dart';
import '../../features/video_call_screen.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

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

      // Initialize local notifications (FIXED)
      await _initLocalNotifications();

      // Get FCM token – this will wait for APNS token on iOS (with internal timeout)
      // Wrap in try-catch to prevent crash on simulator or early launch
      String? token;
      try {
        token = await _firebaseMessaging.getToken();
        debugPrint('Firebase FCM Token: $token');
      } catch (e) {
        debugPrint('Could not get FCM token (simulator or no APNS): $e');
        // Continue anyway – the app should not crash
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
      // Do not rethrow – app continues
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
    await _showLocalNotification(message);
    if (message.data['call_type'] == 'video') {
      _handleCallData(message.data);
    }
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

      // ✅ CORRECT: Use named parameters
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
    if (data == null) return;
    if (data['call_type'] == 'video') {
      pendingCallData = data;
      final context = navigatorKey.currentContext;
      if (context != null) {
        _navigateToVideoCall(context, data);
        pendingCallData = null;
      }
    }
  }

  static void _navigateToVideoCall(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          token: data['token'] ?? '',
          name: data['name'] ?? 'Doctor',
          doctorId: data['doctor_id']?.toString() ?? '',
          playerId: data['player_id']?.toString() ?? '',
          familyMemberId: data['family_member_id']?.toString() ?? '',
          bookingId: data['booking_id']?.toString() ?? '',
          consultType: data['consult_type'] ?? 'online',
        ),
      ),
    );
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}