import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user/features/splash/presentation/splash_page.dart';
import 'core/di/injection.dart' as di;
import 'core/utils/push_notification_service.dart';
import 'core/utils/firebase_notification_service.dart';
import 'core/utils/snackbar_utils.dart';
import 'core/utils/translations.dart';
import 'core/utils/pending_call.dart';
import 'domain/entities/address.dart';
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';
import 'core/utils/navigation.dart';
import 'features/video_call_screen.dart';
import 'package:upgrader/upgrader.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
Map<String, dynamic>? pendingCallData;

// ValueNotifier to expose OneSignal player ID
final ValueNotifier<String?> oneSignalPlayerIdNotifier = ValueNotifier(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Your custom services
  await PushNotificationService.initialize();
  await FirebaseNotificationService.initialize();
  await di.init();

  // OneSignal initialisation (waits for ID)
  await initOneSignal();

  // Facebook events
  final facebookAppEvents = FacebookAppEvents();
  await facebookAppEvents.setAutoLogAppEventsEnabled(true);
  await facebookAppEvents.logEvent(name: "medrayder_test_event");
  await facebookAppEvents.logEvent(name: "fb_mobile_activate_app");
  facebookAppEvents.logCompletedRegistration();
  facebookAppEvents.logPurchase(amount: 99.0, currency: "INR");
  facebookAppEvents.logEvent(
    name: "medrayder_care_plan_purchase",
    parameters: {"plan_name": "singlecare plan", "amount": 1199},
  );
  facebookAppEvents.logEvent(name: "doctor_appointment_booked");
  await facebookAppEvents.setAutoLogAppEventsEnabled(true);

  runApp(const MyApp());
}

Future<void> initOneSignal() async {
  const String oneSignalAppId = "c1fa84ce-ef13-43a6-829c-61143b9f113c";

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  await OneSignal.User.addTags({"user_type": "MEDRAYDER"});

  // Listen to subscription changes
  OneSignal.User.pushSubscription.addObserver((state) {
    final id = state.current.id;
    if (id != null && id.isNotEmpty) {
      oneSignalPlayerIdNotifier.value = id;
      debugPrint("OneSignal player ID updated: $id");
    }
  });

  // Try to get ID immediately, otherwise poll for a short time
  String? playerId = OneSignal.User.pushSubscription.id;
  if (playerId != null && playerId.isNotEmpty) {
    oneSignalPlayerIdNotifier.value = playerId;
    debugPrint("OneSignal player ID: $playerId");
  } else {
    debugPrint("Waiting for OneSignal player ID...");
    await _waitForOneSignalId(timeout: const Duration(seconds: 3));
  }

  bool? isSubscribed = await OneSignal.User.pushSubscription.optedIn;
  debugPrint("Device subscribed: $isSubscribed");

  OneSignal.Notifications.addClickListener((event) {
    debugPrint("Notification clicked: ${event.notification.additionalData}");
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

void _navigateToVideoCall(BuildContext context, Map<String, dynamic> data) {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create notifiers (stable because MyApp is built once)
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
            // Wrap MaterialApp with UpgradeAlert to show update prompt
            return UpgradeAlert(
              showIgnore: false,
              showLater: true,
              upgrader: Upgrader(
                debugLogging: true,
                durationUntilAlertAgain: const Duration(days: 1),
              ),
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