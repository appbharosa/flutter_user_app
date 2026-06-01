// lib/core/services/push_notification_service.dart
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../features/notifications/presentation/pages/notification_list_screen.dart';
import '../../features/video_call_screen.dart';
import '../utils/navigation.dart'; // your navigatorKey

class PushNotificationService {
  static final GlobalKey<NavigatorState> _navigatorKey = navigatorKey;

  /// Call this once in main() before runApp.
  static Future<void> initialize() async {
    await _initOneSignal();
    _registerHandlers();
  }

  static Future<void> _initOneSignal() async {
    const String appId = "cebaa375-de95-4fb8-9403-71089f304ffe";

    await OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(true);
    await OneSignal.User.addTags({"user_type": "MEDRAYDER"});

    // Optional: enable debug logs (disable in production)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  }

  static void _registerHandlers() {
    // Listens for when a notification is clicked (app in foreground, background, or terminated)
    OneSignal.Notifications.addClickListener(_onNotificationClicked);
  }

  static void _onNotificationClicked(OSNotificationClickEvent event) {
    final Map<String, dynamic>? data = event.notification.additionalData;
    final BuildContext? context = _navigatorKey.currentContext;
    if (context == null) {
      print("PushNotificationService: context not available yet");
      return;
    }

    // Check if this is a video call notification
    if (data != null && data['call_type'] == 'video') {
      _handleVideoCallNotification(context, data);
    } else {
      // Handle other (regular) notifications – navigate to notification list
      _handleRegularNotification(context);
    }
  }

  static void _handleVideoCallNotification(BuildContext context, Map<String, dynamic> data) {
    final String token = data['token'] ?? '';
    final String name = data['name'] ?? 'Doctor';
    final String doctorId = data['doctor_id']?.toString() ?? '';
    final String playerId = data['player_id']?.toString() ?? '';
    final String familyMemberId = data['family_member_id']?.toString() ?? '';
    final String bookingId = data['booking_id']?.toString() ?? '';
    final String consultType = data['consult_type'] ?? 'online';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          token: token,
          name: name,
          doctorId: doctorId,
          playerId: playerId,
          familyMemberId: familyMemberId,
          bookingId: bookingId,
          consultType: consultType,
        ),
      ),
    );
  }

  static void _handleRegularNotification(BuildContext context) {
    // Navigate to the notifications list screen
    // Optionally, you could parse the notification ID and pass it to highlight that item.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationListScreen(),
      ),
    );
  }

  /// Returns the OneSignal player ID (also known as user ID).
  static Future<String?> getPlayerId() async {
    try {
      return await OneSignal.User.getOnesignalId();
    } catch (e) {
      print("Error getting playerId: $e");
      return null;
    }
  }
}