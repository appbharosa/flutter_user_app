import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/pending_call.dart';          // ← import global var
import '../../../core/utils/navigation.dart';           // ← for navigatorKey
import '../../home/presentation/pages/home_page.dart';
import '../../language/pages/language_selection_page.dart';
import '../../video_call_screen.dart';

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

    Timer(const Duration(seconds: 2), () async {
      final token = await _storage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        if (mounted) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        //  _checkPendingCall();
        }
      } else {
        if (mounted) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LanguageSelectionPage(fromSplash: true)),
          );
         // _checkPendingCall();
        }
      }
    });
  }

  // void _checkPendingCall() {
  //   if (pendingCallData != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       final ctx = navigatorKey.currentContext;
  //       if (ctx != null) {
  //         final token = pendingCallData!['token'] ?? pendingCallData!['patient_token'] ?? '';
  //         final roomId = pendingCallData!['room_id']?.toString() ?? '';
  //         final bookingId = pendingCallData!['appointment_id']?.toString() ?? pendingCallData!['booking_id']?.toString() ?? '';
  //         final mainDataId = pendingCallData!['main_data_id']?.toString() ?? '';
  //         Navigator.push(
  //           ctx,
  //           MaterialPageRoute(
  //             builder: (_) => VideoCallScreen(
  //               token: token,
  //               roomId: roomId,
  //               name: pendingCallData!['name'] ?? pendingCallData!['doctor_name'] ?? 'Doctor',
  //               doctorId: pendingCallData!['doctor_id']?.toString() ?? '',
  //               playerId: pendingCallData!['player_id']?.toString() ?? '',
  //               familyMemberId: pendingCallData!['family_member_id']?.toString() ?? '',
  //               bookingId: bookingId,
  //               consultType: pendingCallData!['consult_type'] ?? 'online',
  //               mainDataId: mainDataId,
  //             ),
  //           ),
  //         );
  //         pendingCallData = null;
  //       }
  //     });
  //   }
  // }

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