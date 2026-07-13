import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:user/features/splash/presentation/splash_page.dart';
import 'package:user/core/di/injection.dart' as di;
import 'package:upgrader/upgrader.dart';
import 'dart:async';
import 'core/utils/navigation.dart' show navigatorKey;
import 'core/utils/firebase_notification_service.dart';
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';



final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
final AudioPlayer ringtonePlayer = AudioPlayer();

// ─── Main ─────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // ─── Crashlytics Setup ──────────────────────────────────────────────────
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  // Initialize services
  await di.init();
  await _initServices();

  runApp(const MyApp());
}

// ─── Initialize Services ────────────────────────────────────────────────
Future<void> _initServices() async {
  await FirebaseNotificationService.initialize();
}

// ─── MyApp ───────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ValueNotifier<String>('')),
        ChangeNotifierProvider.value(value: ValueNotifier<dynamic>(null)),
      ],
      child: BlocProvider(
        create: (context) => di.sl<LanguageBloc>(),
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return UpgradeAlert(
              showIgnore: false,
              showLater: true,
              upgrader: Upgrader(
                debugLogging: true, // ✅ Prints logs in console

                // ✅ THE FIX: Shows dialog ONLY in debug mode
                debugDisplayAlways: kDebugMode,

                // Prevents showing again immediately if they ignore it (1 day)
                durationUntilAlertAgain: const Duration(days: 1),
                countryCode: 'in',

                // 🧪 (OPTIONAL) UNCOMMENT THIS TO FORCE THE DIALOG IN RELEASE:
                // minAppVersion: '99.0.0',
              ),
              dialogStyle: UpgradeDialogStyle.material,
              child: MaterialApp(
                scaffoldMessengerKey: scaffoldMessengerKey,
                title: 'MEDRAYDER',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  fontFamily: 'Poppins',
                ),
                navigatorKey: navigatorKey, // ✅ Uses the shared key
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