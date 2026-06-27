import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:user/features/splash/presentation/splash_page.dart';
import 'package:user/core/di/injection.dart' as di;
import 'package:user/core/utils/navigation.dart';
import 'package:user/features/video_call_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'dart:convert';
import 'dart:async';

import 'core/utils/firebase_notification_service.dart';
import 'core/utils/pending_call.dart';
import 'core/utils/translations.dart';
import 'domain/entities/address.dart';
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final AudioPlayer ringtonePlayer = AudioPlayer();
final ValueNotifier<String?> oneSignalPlayerIdNotifier = ValueNotifier(null);
bool _isCallScreenOpen = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  await _initServices();
  runApp(const MyApp());
}

Future<void> _initServices() async {
  await FirebaseNotificationService.initialize();
  await initOneSignal();
  _setupFcmListeners();
}

void _setupFcmListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 FCM onMessage: ${message.data}');
    _handleCallData(message.data);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📩 FCM onMessageOpenedApp: ${message.data}');
    _handleCallData(message.data);
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      debugPrint('📩 FCM getInitialMessage: ${message.data}');
      _handleCallData(message.data);
    }
  });
}

Future<void> initOneSignal() async {
  const String oneSignalAppId = "cebaa375-de95-4fb8-9403-71089f304ffe";
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  await OneSignal.User.addTags({"user_type": "MEDRAYDER"});

  OneSignal.User.pushSubscription.addObserver((state) {
    final id = state.current.id;
    if (id != null && id.isNotEmpty) {
      oneSignalPlayerIdNotifier.value = id;
      debugPrint("OneSignal player ID updated: $id");
    }
  });

  String? playerId = OneSignal.User.pushSubscription.id;
  if (playerId != null && playerId.isNotEmpty) {
    oneSignalPlayerIdNotifier.value = playerId;
    debugPrint("OneSignal player ID: $playerId");
  } else {
    debugPrint("Waiting for OneSignal player ID...");
    await _waitForOneSignalId(timeout: const Duration(seconds: 3));
  }

  OneSignal.Notifications.addClickListener((event) {
    debugPrint("OneSignal notification clicked: ${event.notification.additionalData}");
    _handleCallData(event.notification.additionalData);
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    debugPrint("OneSignal foreground notification: ${event.notification.additionalData}");
    _handleCallData(event.notification.additionalData);
  });
}

Future<void> _waitForOneSignalId({required Duration timeout}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    final id = OneSignal.User.pushSubscription.id;
    if (id != null && id.isNotEmpty) {
      oneSignalPlayerIdNotifier.value = id;
      debugPrint("Player ID obtained after ${stopwatch.elapsedMilliseconds}ms: $id");
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
  debugPrint("Player ID not available within $timeout – continuing without it");
}

void _handleCallData(Map<String, dynamic>? data) {
  if (data == null) {
    debugPrint('⚠️ No data in call payload');
    return;
  }

  debugPrint('🔥 Incoming call data: $data');

  // Check for both 'call_type' and 'type' fields
  final callType = data['call_type'] ?? data['type'];
  if (callType != 'video' && callType != 'incoming_call') {
    debugPrint('ℹ️ Not a video call: $callType');
    return;
  }

  // Prevent duplicate call screens
  if (_isCallScreenOpen) {
    debugPrint('⚠️ Call screen is already open. Ignoring new call.');
    return;
  }

  // ✅ Extract token – try 'token' first, then 'patient_token'
  final String? token = data['token'] ?? data['patient_token'];
  if (token == null || token.isEmpty) {
    debugPrint('⚠️ Token is missing in the payload – patient cannot join!');
  } else {
    debugPrint('✅ Token extracted: ${token.substring(0, 20)}...');
  }

  // Play ringtone
  ringtonePlayer.stop();
  ringtonePlayer.play(
    AssetSource('ringtone.mp3'),
    mode: PlayerMode.mediaPlayer,
    volume: 1.0,
  );

  // Store pending call data
  pendingCallData = data;

  // Navigate to VideoCallScreen
  _navigateToVideoCall(data, token);
}

void _navigateToVideoCall(Map<String, dynamic> data, [String? token]) {
  // Use provided token or fallback to data fields
  final String callToken = token ?? data['token'] ?? data['patient_token'] ?? '';

  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint('⏳ Navigator context not ready, retrying...');
    Future.delayed(const Duration(milliseconds: 500), () {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        _doNavigate(ctx, data, callToken);
      } else {
        debugPrint('❌ Navigator context still not available');
      }
    });
    return;
  }

  _doNavigate(context, data, callToken);
}

void _doNavigate(BuildContext context, Map<String, dynamic> data, String token) {
  final roomId = data['room_id']?.toString() ?? '';
  // ✅ Extract booking_id from appointment_id (or fallback to booking_id)
  final bookingId = data['appointment_id']?.toString() ?? data['booking_id']?.toString() ?? '';
  final mainDataId = data['main_data_id']?.toString() ?? '';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoCallScreen(
        token: token,
        roomId: roomId,
        name: data['name'] ?? data['doctor_name'] ?? 'Doctor',
        doctorId: data['doctor_id']?.toString() ?? '',
        playerId: data['player_id']?.toString() ?? '',
        familyMemberId: data['family_member_id']?.toString() ?? '',
        bookingId: bookingId,        // ✅ Now gets appointment_id
        consultType: data['consult_type'] ?? 'online',
        mainDataId: mainDataId,      // ✅ Pass main_data_id
      ),
    ),
  );
}

void _checkPendingCall() {
  if (pendingCallData != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        final token = pendingCallData!['token'] ?? pendingCallData!['patient_token'] ?? '';
        final roomId = pendingCallData!['room_id']?.toString() ?? '';
        final bookingId = pendingCallData!['appointment_id']?.toString() ?? pendingCallData!['booking_id']?.toString() ?? '';
        final mainDataId = pendingCallData!['main_data_id']?.toString() ?? '';
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => VideoCallScreen(
              token: token,
              roomId: roomId,
              name: pendingCallData!['name'] ?? pendingCallData!['doctor_name'] ?? 'Doctor',
              doctorId: pendingCallData!['doctor_id']?.toString() ?? '',
              playerId: pendingCallData!['player_id']?.toString() ?? '',
              familyMemberId: pendingCallData!['family_member_id']?.toString() ?? '',
              bookingId: bookingId,
              consultType: pendingCallData!['consult_type'] ?? 'online',
              mainDataId: mainDataId,
            ),
          ),
        );
        pendingCallData = null;
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final searchNotifier = ValueNotifier<String>('');
    final addressNotifier = ValueNotifier<Address?>(null);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: searchNotifier),
        ChangeNotifierProvider.value(value: addressNotifier),
        ChangeNotifierProvider.value(value: oneSignalPlayerIdNotifier),
      ],
      child: BlocProvider(
        create: (context) => di.sl<LanguageBloc>(),
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return UpgradeAlert(
              showIgnore: false,
              showLater: true,
              upgrader: Upgrader(
                debugLogging: true,                    // logs to console
                debugDisplayAlways: false,             // only when update available
                durationUntilAlertAgain: const Duration(days: 1), // wait 1 day after "Later"
                countryCode: 'in',
              ),
              dialogStyle: UpgradeDialogStyle.material,
              child: MaterialApp(
                scaffoldMessengerKey: scaffoldMessengerKey,
                title: AppTranslations.get('MEDRAYDER'),
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  fontFamily: 'Poppins',
                ),
                navigatorKey: navigatorKey,
                home: const SplashPage(),
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}