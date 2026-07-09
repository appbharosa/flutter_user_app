import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
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
  static Map<String, dynamic>? pendingCallData;

  static Future<void> initialize() async {
    try {
      // Request notification permissions
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

      // Initialize local notifications
      await _initLocalNotifications();

      // Get FCM token
      try {
        final token = await _firebaseMessaging.getToken();
        debugPrint('Firebase FCM Token: $token');
      } catch (e) {
        debugPrint('Could not get FCM token: $e');
      }

      // Set up Firebase Messaging listeners
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle initial message (app launched from terminated state)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        handleCallData(initialMessage.data);
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
        handleCallData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.data}');
    if (message.data.isEmpty) {
      debugPrint('⚠️ Empty FCM data payload');
      return;
    }
    _playRingtone();
    await _showLocalNotification(message);
    handleCallData(message.data);
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Message opened app: ${message.data}');
    handleCallData(message.data);
  }

  static void _playRingtone() {
    _ringtonePlayer.stop();
    _ringtonePlayer.play(
      AssetSource('ringtone.mp3'),
      mode: PlayerMode.mediaPlayer,
      volume: 1.0,
    );
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final androidDetails = AndroidNotificationDetails(
        'video_call_channel',
        'Video Call Notifications',
        channelDescription: 'Incoming video call notifications',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        sound: RawResourceAndroidNotificationSound('ringtone'), // ✅ Use your sound file
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        presentBanner: true,
        presentList: true,
        sound: 'default',
      );

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      final payloadJson = jsonEncode(message.data);

      await _localNotifications.show(
        id: notificationId,
        title: message.notification?.title ?? 'Incoming Call from ${message.data['doctor_name'] ?? 'Doctor'}',
        body: message.notification?.body ?? 'Tap to answer',
        notificationDetails: details,
        payload: payloadJson,
      );
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }

  // ✅ Updated to handle your payload fields
  static void handleCallData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      debugPrint('⚠️ FCM data is null or empty');
      return;
    }

    debugPrint('📩 FULL FCM PAYLOAD:');
    debugPrint('┌─────────────────────────────────────');
    data.forEach((key, value) {
      debugPrint('│ $key: $value');
    });
    debugPrint('└─────────────────────────────────────');

    // ✅ Use 'type' from your payload
    final callType = data['type'];
    if (callType != 'incoming_call') {
      debugPrint('ℹ️ Not an incoming call: $callType');
      return;
    }

    if (_isCallScreenOpen) {
      debugPrint('⚠️ Call screen already open – ignoring new call');
      return;
    }

    // ✅ Extract fields from your payload
    final roomId = data['room_id']?.toString() ?? '';
    final token = data['patient_token']?.toString() ?? '';
    final bookingId = data['appointment_id']?.toString() ?? '';
    final mainDataId = data['main_data_id']?.toString() ?? '';
    final doctorName = data['doctor_name']?.toString() ?? 'Doctor';
    final doctorId = data['doctor_id']?.toString() ?? '';
    final callId = data['call_id']?.toString() ?? '';
    final action = data['action']?.toString() ?? '';
    final duration = data['duration']?.toString() ?? '';

    debugPrint('📱 Room ID: $roomId');
    debugPrint('📱 Booking ID: $bookingId');
    debugPrint('📱 Main Data ID: $mainDataId');
    debugPrint('📱 Doctor Name: $doctorName');
    debugPrint('📱 Token: ${token.isNotEmpty ? token.substring(0, 30) + '...' : 'null'}');

    if (roomId.isEmpty) {
      debugPrint('⚠️ room_id is missing or empty in payload');
      return;
    }
    if (token.isEmpty) {
      debugPrint('⚠️ patient_token is missing or empty in payload');
      return;
    }

    _playRingtone();
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
          final delayedToken = pendingCallData!['patient_token']?.toString() ?? '';
          _showIncomingCallScreen(ctx, pendingCallData!, delayedToken);
          pendingCallData = null;
        }
      });
    }
  }

  static void _showIncomingCallScreen(BuildContext context, Map<String, dynamic> data, String token) {
    final roomId = data['room_id']?.toString() ?? '';
    final doctorName = data['doctor_name']?.toString() ?? 'Doctor';
    final doctorId = data['doctor_id']?.toString() ?? '';
    final bookingId = data['appointment_id']?.toString() ?? '';
    final mainDataId = data['main_data_id']?.toString() ?? '';
    final callId = data['call_id']?.toString() ?? '';
    final duration = data['duration']?.toString() ?? '';

    _isCallScreenOpen = true;
    debugPrint('📱 Showing incoming call screen for $doctorName');

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
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
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    doctorName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Incoming call... (Duration: $duration mins)',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'decline_incoming',
                            backgroundColor: Colors.red,
                            onPressed: () {
                              Navigator.pop(context);
                              _isCallScreenOpen = false;
                              _ringtonePlayer.stop();
                              _sendDisconnectNotification('reject_call', data);
                            },
                            child: const Icon(Icons.call_end, size: 32, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text('Decline', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'accept_incoming',
                            backgroundColor: Colors.green,
                            onPressed: () {
                              Navigator.pop(context);
                              _isCallScreenOpen = false;
                              _ringtonePlayer.stop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoCallScreen(
                                    token: token,
                                    roomId: roomId,
                                    name: doctorName,
                                    doctorId: doctorId,
                                    playerId: '', // Not in your payload, so empty
                                    familyMemberId: '', // Not in your payload, so empty
                                    bookingId: bookingId,
                                    consultType: 'online', // Default, adjust as needed
                                    mainDataId: mainDataId,
                                    callId: callId, // Pass call_id if needed
                                    duration: duration, // Pass duration if needed
                                  ),
                                ),
                              ).then((_) {
                                _isCallScreenOpen = false;
                              });
                            },
                            child: const Icon(Icons.call, size: 32, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text('Accept', style: TextStyle(color: Colors.white)),
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
    debugPrint('📤 Disconnect notification sent: $action for call_id=${data['call_id']}');
    // Implement your API call here to send hang_up/reject_call to the server
  }

  static void stopRingtone() {
    _ringtonePlayer.stop();
  }
}

// ✅ Moved outside the class (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.data}');
  if (message.data.isNotEmpty) {
    await FirebaseNotificationService._showLocalNotification(message);
    FirebaseNotificationService.handleCallData(message.data);
  }
}