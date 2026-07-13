import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/utils/pending_call.dart';          // ← import global var
import '../../../core/utils/navigation.dart';           // ← for navigatorKey
import '../../../data/data_sources/auth_remote_datasource.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../language/pages/language_selection_page.dart';
import '../../video_call_screen.dart';
import 'package:user/core/utils/firebase_notification_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthRemoteDataSource _authRemoteDataSource = di.sl<AuthRemoteDataSource>();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // ✅ Check for pending call data before navigating
    Timer(const Duration(seconds: 2), () async {
      // ✅ Check if there's pending call data (from terminated state)
      if (FirebaseNotificationService.pendingCallData != null) {
        final data = FirebaseNotificationService.pendingCallData!;
        FirebaseNotificationService.pendingCallData = null;

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VideoCallScreen(
                token: data['patient_token']?.toString() ?? '',
                roomId: data['room_id']?.toString() ?? '',
                name: data['doctor_name']?.toString() ?? 'Doctor',
                doctorId: data['doctor_id']?.toString() ?? '',
                playerId: '',
                familyMemberId: '',
                bookingId: data['appointment_id']?.toString() ?? '',
                consultType: 'online',
                mainDataId: data['main_data_id']?.toString() ?? '',
                callId: data['call_id']?.toString() ?? '',
                duration: data['duration']?.toString() ?? '',
              ),
            ),
          );
          return;
        }
      }

      // ✅ Default navigation logic
      final accessToken = await _storage.read(key: 'access_token');
      final isLoggedIn = accessToken != null && accessToken.isNotEmpty;

      if (isLoggedIn) {
        _registerFcmToken();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LanguageSelectionPage(fromSplash: true)),
          );
        }
      }
    });
  }

  Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('📱 FCM Token: $token');
        await _authRemoteDataSource.registerFcmToken(token, _getDeviceType());
        debugPrint('✅ FCM token registered successfully');
      } else {
        debugPrint('⚠️ FCM token is null or empty');
      }
    } catch (e) {
      debugPrint('❌ FCM token registration failed: $e');
    }
  }

  String _getDeviceType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            "assets/app_logo.png",
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}