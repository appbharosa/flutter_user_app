import 'dart:convert';
import 'dart:typed_data';
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
  static final AudioPlayer _ringtonePlayer = AudioPlayer();
  static bool _isCallScreenOpen = false;

  static Future<void> initialize() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Firebase notifications permission denied');
        return;
      }

      await _initLocalNotifications();

      try {
        final token = await _firebaseMessaging.getToken();
        debugPrint('Firebase FCM Token: $token');
      } catch (e) {
        debugPrint('Could not get FCM token: $e');
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleCallData(initialMessage.data);
      }
    } catch (e) {
      debugPrint('FirebaseNotificationService initialization failed: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  static void _onNotificationResponse(NotificationResponse details) {
    debugPrint('Notification tapped: ${details.payload}');
    if (details.payload != null) {
      try {
        final data = jsonDecode(details.payload!) as Map<String, dynamic>;
        _handleCallData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.data}');
    // Play ringtone immediately
    _playRingtone();
    // Show full-screen incoming call UI (overlay)
    _handleCallData(message.data);
    // Also show local notification for background fallback
    await _showLocalNotification(message);
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Message opened app: ${message.data}');
    _handleCallData(message.data);
  }

  static void _playRingtone() {
    _ringtonePlayer.stop();
    _ringtonePlayer.play(
      AssetSource('ringtone.mp3'),
      mode: PlayerMode.mediaPlayer,

    );
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final androidDetails = AndroidNotificationDetails(
        'video_call_channel',
        'Video Call Notifications',
        channelDescription: 'Incoming video call notifications',
        importance: Importance.max, // High priority for heads-up
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        sound: const RawResourceAndroidNotificationSound('default_ringtone'),
        // Add actions for Accept/Decline (optional)
        // But we handle navigation via `onDidReceiveNotificationResponse`
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        presentBanner: true,
        presentList: true,
      //  interruptionLevel: 'critical',
        sound: 'default',
      );

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      final payloadJson = jsonEncode(message.data);

      await _localNotifications.show(
        id: notificationId,
        title: message.notification?.title ?? 'Incoming Video Call',
        body: message.notification?.body ?? 'Doctor is calling...',
        notificationDetails: details,
        payload: payloadJson,
      );
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }

  static void _handleCallData(Map<String, dynamic>? data) {
    if (data == null) {
      debugPrint('⚠️ FCM data is null');
      return;
    }

    // ✅ DEBUG: Print the entire payload
    debugPrint('📩 FULL FCM PAYLOAD:');
    debugPrint('┌─────────────────────────────────────');
    data.forEach((key, value) {
      debugPrint('│ $key: $value');
    });
    debugPrint('└─────────────────────────────────────');

    // ✅ Check for specific fields
    final callType = data['call_type'] ?? data['type'];
    if (callType != 'video' && callType != 'incoming_call') {
      debugPrint('ℹ️ Not a video call: $callType');
      return;
    }

    if (_isCallScreenOpen) {
      debugPrint('⚠️ Call screen already open – ignoring new call');
      return;
    }

    final roomId = data['room_id']?.toString() ?? '';
    final token = data['token'] ?? data['patient_token'];
    final bookingId = data['appointment_id']?.toString() ?? data['booking_id']?.toString() ?? '';
    final mainDataId = data['main_data_id']?.toString() ?? '';

    debugPrint('📱 Room ID: $roomId');
    debugPrint('📱 Booking ID: $bookingId');
    debugPrint('📱 Main Data ID: $mainDataId');
    debugPrint('📱 Token: ${token != null ? token.substring(0, 30) + '...' : 'null'}');

    if (bookingId.isEmpty) {
      debugPrint('⚠️ booking_id is missing or empty in payload');
    }
    if (mainDataId.isEmpty) {
      debugPrint('⚠️ main_data_id is missing or empty in payload');
    }

    // Play ringtone
    _playRingtone();

    if (token == null || token.isEmpty) {
      debugPrint('⚠️ Token missing – patient cannot join');
    }

    pendingCallData = data;
    final context = navigatorKey.currentContext;
    if (context != null) {
      _showIncomingCallScreen(context, data, token);
      pendingCallData = null;
    } else {
      debugPrint('⏳ Waiting for navigator context...');
      Future.delayed(const Duration(milliseconds: 500), () {
        final ctx = navigatorKey.currentContext;
        if (ctx != null && pendingCallData != null) {
          final delayedToken = pendingCallData!['token'] ?? pendingCallData!['patient_token'];
          _showIncomingCallScreen(ctx, pendingCallData!, delayedToken);
          pendingCallData = null;
        }
      });
    }
  }

  // ✅ Shows a full-screen incoming call UI (overlay) instead of directly navigating
  static void _showIncomingCallScreen(BuildContext context, Map<String, dynamic> data, String? token) {
    final callToken = token ?? data['token'] ?? data['patient_token'] ?? '';
    final roomId = data['room_id']?.toString() ?? '';
    final name = data['name'] ?? data['doctor_name'] ?? 'Doctor';
    final doctorId = data['doctor_id']?.toString() ?? '';
    final playerId = data['player_id']?.toString() ?? '';
    final familyMemberId = data['family_member_id']?.toString() ?? '';
    final bookingId = data['booking_id']?.toString() ?? '';
    final consultType = data['consult_type'] ?? 'online';
    final mainDataId = data['main_data_id']?.toString() ?? ''; // ✅ NEW: extract main_data_id

    _isCallScreenOpen = true;
    debugPrint('📱 booking_id: $bookingId, main_data_id: $mainDataId');

    debugPrint('✅ Disconnect notification sent: $mainDataId');
    // Show a dialog-like overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back press
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[800],
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Incoming call...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'decline_incoming',
                            backgroundColor: Colors.red,
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              _isCallScreenOpen = false;
                              _ringtonePlayer.stop();
                              // Send reject notification
                              _sendDisconnectNotification('reject_call', data);
                            },
                            child: Icon(Icons.call_end, size: 32, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text('Decline', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      // Accept
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'accept_incoming',
                            backgroundColor: Colors.green,
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              _isCallScreenOpen = false;
                              _ringtonePlayer.stop();
                              // Navigate to VideoCallScreen with all parameters including main_data_id
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoCallScreen(
                                    token: callToken,
                                    roomId: roomId,
                                    name: name,
                                    doctorId: doctorId,
                                    playerId: playerId,
                                    familyMemberId: familyMemberId,
                                    bookingId: bookingId,
                                    consultType: consultType,
                                    mainDataId: mainDataId, // ✅ NEW: pass main_data_id
                                  ),
                                ),
                              ).then((_) {
                                _isCallScreenOpen = false;
                              });
                            },
                            child: Icon(Icons.call, size: 32, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text('Accept', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  static void _sendDisconnectNotification(String action, Map<String, dynamic> data) async {
    // Implement your disconnect notification logic here
  }

  static void stopRingtone() {
    _ringtonePlayer.stop();
  }
}