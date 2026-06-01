import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:user/features/splash/presentation/splash_page.dart';
import 'core/di/injection.dart' as di;
import 'core/utils/push_notification_service.dart';
import 'core/utils/firebase_notification_service.dart'; // Add this import
import 'core/utils/snackbar_utils.dart';
import 'core/utils/translations.dart';
import 'core/utils/pending_call.dart';
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';
import 'core/utils/navigation.dart';
import 'features/video_call_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  );

  await PushNotificationService.initialize();
  await FirebaseNotificationService.initialize(); // Add this
  await di.init();
  await _initOneSignal();
  runApp(MyApp());
}

Future<void> _initOneSignal() async {
  const String oneSignalAppId = "cebaa375-de95-4fb8-9403-71089f304ffe";
  await OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  await OneSignal.User.addTags({"user_type": "MEDRAYDER"});

  OneSignal.Notifications.addClickListener((event) {
    _handleCallData(event.notification.additionalData);
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
  @override

  Widget build(BuildContext context) {
    return BlocProvider(
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
    );
  }
}