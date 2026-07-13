import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:user/core/utils/navigation.dart';
import 'package:user/features/video_call_screen.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  static final AudioPlayer _ringtonePlayer = AudioPlayer();
  static bool _isCallScreenOpen = false;
  static Map<String, dynamic>? pendingCallData;

  // Deduplication variables
  static String? _lastProcessedCallId;
  static DateTime? _lastProcessedTime;

  // ─── Initialization ────────────────────────────────────────────────────
  static Future<void> initialize() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('⚠️ Firebase notifications permission denied');
        return;
      }

      await _initLocalNotifications();

      try {
        final token = await _firebaseMessaging.getToken();
        debugPrint('✅ Firebase FCM Token: $token');
      } catch (e) {
        debugPrint('⚠️ Could not get FCM token: $e');
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        handleCallData(initialMessage.data);
      }
    } catch (e) {
      debugPrint('❌ FirebaseNotificationService initialization failed: $e');
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
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  // ─── Listeners ─────────────────────────────────────────────────────
  static void _onNotificationResponse(NotificationResponse details) {
    debugPrint('🔔 Notification tapped: ${details.payload}');
    if (details.payload != null) {
      try {
        final data = jsonDecode(details.payload!) as Map<String, dynamic>;
        handleCallData(data);
      } catch (e) {
        debugPrint('⚠️ Error parsing notification payload: $e');
      }
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📲 Foreground message received: ${message.data}');
    if (message.data.isEmpty) return;

    if (message.data['type'] == 'incoming_call') {
      _playRingtone();
    }

    await _showLocalNotification(message);
    handleCallData(message.data);
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('📲 Message opened app: ${message.data}');
    handleCallData(message.data);
  }

  // ─── Ringtone ──────────────────────────────────────────────────────
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
      final data = message.data;
      final isVideoCall = data['type'] == 'incoming_call';
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      String title = data['title']?.toString() ?? 'MEDRAYDER';
      String body = data['message']?.toString() ?? data['body']?.toString() ?? 'You have a new notification';

      if (isVideoCall) {
        final doctorName = data['doctor_name']?.toString() ?? 'Doctor';
        title = 'Incoming Call from $doctorName';
        body = 'Tap to answer';
      }

      AndroidNotificationDetails androidDetails;
      if (isVideoCall) {
        androidDetails = AndroidNotificationDetails(
          'video_call_channel',
          'Video Call Notifications',
          channelDescription: 'Incoming video call notifications',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
          fullScreenIntent: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          sound: RawResourceAndroidNotificationSound('ringtone'),
        );
      } else {
        androidDetails = AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          sound: null, // System default
        );
      }

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        presentBanner: true,
        presentList: true,
        sound: 'default',
      );

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      final payloadJson = jsonEncode(data);

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payloadJson,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to show local notification: $e');
    }
  }

  // ─── Main Entry Point ──────────────────────────────────────────────
  static void handleCallData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      debugPrint('⚠️ FCM data is null or empty');
      return;
    }

    debugPrint('📩 FULL FCM PAYLOAD:');
    debugPrint('┌─────────────────────────────────────');
    data.forEach((key, value) => debugPrint('│ $key: $value'));
    debugPrint('└─────────────────────────────────────');

    final type = data['type']?.toString() ?? '';
    if (type == 'incoming_call') {
      _handleVideoCall(data);
    } else {
      _handleNormalNotification(data);
    }
  }

  // ─── Video Call Handler ────────────────────────────────────────────
  static void _handleVideoCall(Map<String, dynamic> data) {
    final callId = data['call_id']?.toString() ?? '';
    if (callId.isNotEmpty) {
      final now = DateTime.now();
      if (_lastProcessedCallId == callId &&
          _lastProcessedTime != null &&
          now.difference(_lastProcessedTime!).inSeconds < 5) {
        debugPrint('⚠️ Duplicate call $callId ignored (received within 5s)');
        return;
      }
      _lastProcessedCallId = callId;
      _lastProcessedTime = now;
    }

    if (_isCallScreenOpen) {
      debugPrint('⚠️ Call screen already open – ignoring duplicate');
      return;
    }

    final roomId = data['room_id']?.toString() ?? '';
    final token = data['patient_token']?.toString() ?? '';
    final bookingId = data['appointment_id']?.toString() ?? '';
    final mainDataId = data['main_data_id']?.toString() ?? '';
    final doctorName = data['doctor_name']?.toString() ?? 'Doctor';
    final doctorId = data['doctor_id']?.toString() ?? '';
    final duration = data['duration']?.toString() ?? '';

    if (roomId.isEmpty || token.isEmpty) {
      debugPrint('⚠️ Missing room_id or token – cannot show call');
      return;
    }

    _isCallScreenOpen = true;
    pendingCallData = data;
    _playRingtone();

    _showCallScreenWhenReady(data, token);
  }

  // ─── Improved: Wait for context with multiple retries ────────────────
  static void _showCallScreenWhenReady(Map<String, dynamic> data, String token) {
    int attempt = 0;
    const maxAttempts = 5;
    const baseDelay = Duration(milliseconds: 200);

    void tryShow() {
      attempt++;
      final context = navigatorKey.currentContext;
      if (context != null) {
        _showIncomingCallScreen(context, data, token);
        pendingCallData = null;
        return;
      }

      if (attempt >= maxAttempts) {
        debugPrint('❌ Could not get context after $maxAttempts attempts – call screen not shown');
        _isCallScreenOpen = false;
        return;
      }

      debugPrint('⏳ Context not ready (attempt $attempt/$maxAttempts), retrying...');
      Future.delayed(baseDelay * attempt, tryShow);
    }

    // Try immediately, then fallback to retries
    final immediateContext = navigatorKey.currentContext;
    if (immediateContext != null) {
      _showIncomingCallScreen(immediateContext, data, token);
      pendingCallData = null;
    } else {
      // Use post‑frame callback as the first retry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tryShow();
      });
    }
  }

  // ─── Incoming Call Dialog ──────────────────────────────────────────────
  static void _showIncomingCallScreen(BuildContext context, Map<String, dynamic> data, String token) {
    final roomId = data['room_id']?.toString() ?? '';
    final doctorName = data['doctor_name']?.toString() ?? 'Doctor';
    final doctorId = data['doctor_id']?.toString() ?? '';
    final bookingId = data['appointment_id']?.toString() ?? '';
    final mainDataId = data['main_data_id']?.toString() ?? '';
    final callId = data['call_id']?.toString() ?? '';
    final duration = data['duration']?.toString() ?? '';

    debugPrint('📱 Showing incoming call screen for $doctorName');

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (dialogContext) => WillPopScope(
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
                  const CircleAvatar(radius: 60, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 70, color: Colors.white)),
                  const SizedBox(height: 24),
                  Text(doctorName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Incoming call... (Duration: $duration mins)', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        label: 'Decline',
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _isCallScreenOpen = false;
                          _ringtonePlayer.stop();
                          _sendDisconnectNotification('reject_call', data);
                        },
                      ),
                      _buildButton(
                        icon: Icons.call,
                        color: Colors.green,
                        label: 'Accept',
                        onTap: () {
                          Navigator.pop(dialogContext);
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
                                playerId: '',
                                familyMemberId: '',
                                bookingId: bookingId,
                                consultType: 'online',
                                mainDataId: mainDataId,
                                callId: callId,
                                duration: duration,
                              ),
                            ),
                          ).then((_) => _isCallScreenOpen = false);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      _isCallScreenOpen = false;
    });
  }

  static Widget _buildButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  static void _sendDisconnectNotification(String action, Map<String, dynamic> data) async {
    debugPrint('📤 Disconnect notification sent: $action for call_id=${data['call_id']}');
    // TODO: Implement API call
  }

  static void stopRingtone() => _ringtonePlayer.stop();

  // ─── Normal Notification Handler ──────────────────────────────────────
  static void _handleNormalNotification(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? 'MEDRAYDER';
    final body = data['message']?.toString() ?? data['body']?.toString() ?? 'You have a new notification';

    debugPrint('📩 Normal notification: $title - $body');

    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(body),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      debugPrint('⏳ Context not available for normal notification – will open on tap');
    }
  }
}

// ─── BACKGROUND HANDLER ──────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📲 Background message received: ${message.data}');
  if (message.data.isNotEmpty) {
    await FirebaseNotificationService._showLocalNotification(message);
    // Do NOT call handleCallData – UI cannot be shown in background.
  }
}



