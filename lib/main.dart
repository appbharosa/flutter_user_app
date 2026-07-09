import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'features/language/bloc/language_bloc.dart';
import 'features/language/bloc/language_state.dart';


// ─── Global Keys ──────────────────────────────────────────────────────────
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
final AudioPlayer ringtonePlayer = AudioPlayer();

// ─── Main ─────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // ─── Crashlytics Setup ──────────────────────────────────────────────────
  // Enable Crashlytics collection
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Automatically capture Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Capture all Dart errors (including async)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true; // Prevents default error handling (still logs to console)
  };

  // Initialize dependency injection and services
  await di.init();
  await _initServices();

  runApp(const MyApp());
}

// ─── Initialize Services ────────────────────────────────────────────────
Future<void> _initServices() async {
  // Firebase Notification Service (handles FCM notifications)
  await FirebaseNotificationService.initialize();
}

// ─── MyApp ───────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Keep any other providers you need – OneSignal provider removed
        ChangeNotifierProvider.value(value: ValueNotifier<String>('')),
        ChangeNotifierProvider.value(value: ValueNotifier<dynamic>(null)),
        // ❌ Removed: oneSignalPlayerIdNotifier provider
      ],
      child: BlocProvider(
        create: (context) => di.sl<LanguageBloc>(),
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return UpgradeAlert(
              showIgnore: false,
              showLater: true,
              upgrader: Upgrader(
                debugLogging: true,
                debugDisplayAlways: false,
                durationUntilAlertAgain: const Duration(days: 1),
                countryCode: 'in',
              ),
              dialogStyle: UpgradeDialogStyle.material,
              child: MaterialApp(
                scaffoldMessengerKey: scaffoldMessengerKey,
                title: 'MEDRAYDER',
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