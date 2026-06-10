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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await PushNotificationService.initialize();
  await FirebaseNotificationService.initialize();
  await di.init();
  await initOneSignal();

  final facebookAppEvents = FacebookAppEvents();

  await facebookAppEvents.setAutoLogAppEventsEnabled(true);

  await facebookAppEvents.logEvent(
    name: "medrayder_test_event",
  );
  await facebookAppEvents.setAutoLogAppEventsEnabled(true);

  await facebookAppEvents.logEvent(
    name: "fb_mobile_activate_app",
  );

  facebookAppEvents.logCompletedRegistration();
  facebookAppEvents.logPurchase(
    amount: 99.0,
    currency: "INR",
  );
  facebookAppEvents.logEvent(
    name: "medrayder_care_plan_purchase",
    parameters: {
      "plan_name": "singlecare plan",
      "amount": 1199,
    },
  );
  facebookAppEvents.logEvent(
    name: "doctor_appointment_booked",
  );
  facebookAppEvents.logEvent(
    name: 'medrayder_test_event',
  );
  await facebookAppEvents.setAutoLogAppEventsEnabled(true);

  runApp(MyApp());
}

Future<void> initOneSignal() async {
  const String oneSignalAppId = "c1fa84ce-ef13-43a6-829c-61143b9f113c";

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  await OneSignal.User.addTags({"user_type": "user"});

  //  Corrected: Use bool for subscription status
  bool? isSubscribed = await OneSignal.User.pushSubscription.optedIn;
  print("Device is subscribed: $isSubscribed");

  //  Corrected: Access the 'id' property directly
  String? playerId = OneSignal.User.pushSubscription.id;
  print("Player ID: $playerId");

  OneSignal.Notifications.addClickListener((event) {
    print("Notification clicked: ${event.notification.additionalData}");
  });
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
  // Create notifiers (they will be stable as the widget is built once)
  final ValueNotifier<String> searchNotifier = ValueNotifier('');
  final ValueNotifier<Address?> addressNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: searchNotifier),
        ChangeNotifierProvider.value(value: addressNotifier),
      ],
      child: BlocProvider(
        create: (context) => di.sl<LanguageBloc>(),
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return MaterialApp(
              scaffoldMessengerKey: scaffoldMessengerKey,
              title: AppTranslations.get('app_name'),
              theme: ThemeData(
                primarySwatch: Colors.blue,
                fontFamily: 'Poppins',
              ),
              navigatorKey: navigatorKey,
              home: const SplashPage(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}