import 'dart:async';
import 'package:enx_flutter_plugin/enx_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/network/dio_client.dart';
import '../../../../core/appurls/app_urls.dart';



class VideoCallScreen extends StatefulWidget {
  final String token;
  final String name;
  final String doctorId;
  final String playerId;
  final String familyMemberId;
  final String bookingId;
  final String consultType;

  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.name,
    required this.doctorId,
    required this.playerId,
    required this.familyMemberId,
    required this.bookingId,
    required this.consultType,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isIncomingCall = true;
  bool _isConnecting = false;
  bool _isCallActive = false;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;
  bool _isFrontCamera = true;
  String? _remoteStreamId;
  String? _localStreamId;
  bool _permissionsGranted = false;
  Timer? _timer;
  int _callDurationSeconds = 0;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _checkPermissionsAndSetup();
  }

  Future<void> _checkPermissionsAndSetup() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      if (await Permission.bluetoothConnect.isRestricted) Permission.bluetoothConnect,
      if (await Permission.bluetoothScan.isRestricted) Permission.bluetoothScan,
    ].request();

    bool allGranted = statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
    if (allGranted) {
      setState(() => _permissionsGranted = true);
      _registerCallbacks();
    } else {
      _showErrorAndClose('Camera and microphone permissions are required.');
    }
  }

  void _registerCallbacks() {
    EnxRtc.onRoomConnected = _onRoomConnected;
    EnxRtc.onRoomError = _onRoomError;
    EnxRtc.onRoomDisConnected = _onRoomDisconnected;
    EnxRtc.onUserConnected = _onUserConnected;
    EnxRtc.onUserDisConnected = _onUserDisconnected;
    EnxRtc.onPublishedStream = _onPublishedStream;
    EnxRtc.onStreamAdded = _onStreamAdded;
    EnxRtc.onSubscribedStream = _onSubscribedStream;
    EnxRtc.onAudioEvent = _onAudioEvent;
    EnxRtc.onVideoEvent = _onVideoEvent;
    EnxRtc.onReconnect = _onReconnect;
    EnxRtc.onUserReconnectSuccess = _onUserReconnectSuccess;
  }

  void _onRoomConnected(Map<dynamic, dynamic> map) {
    setState(() {
      _isCallActive = true;
      _isConnecting = false;
    });
    WakelockPlus.enable();
    EnxRtc.publish();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds = _stopwatch.elapsed.inSeconds;
        });
      }
    });
  }

  void _onRoomError(Map<dynamic, dynamic> map) {
    _showErrorAndClose(map['msg'] ?? 'Room error');
  }

  void _onRoomDisconnected(Map<dynamic, dynamic> map) {
    _cleanupAndExit();
  }

  void _onUserConnected(Map<dynamic, dynamic> map) {}
  void _onUserDisconnected(Map<dynamic, dynamic> map) {
    if (_isCallActive) _endCall();
  }

  void _onPublishedStream(Map<dynamic, dynamic> map) {
    setState(() {
      _localStreamId = map['streamId'].toString();
    });
  }

  void _onStreamAdded(Map<dynamic, dynamic> map) {
    EnxRtc.subscribe(map as String);
  }

  void _onSubscribedStream(Map<dynamic, dynamic> map) {
    setState(() {
      _remoteStreamId = map['streamId'].toString();
    });
  }

  void _onAudioEvent(Map<dynamic, dynamic> event) {
    final String? message = event['msg'];
    setState(() {
      _isAudioMuted = (message == 'Audio Off');
    });
  }

  void _onVideoEvent(Map<dynamic, dynamic> event) {
    final String? message = event['msg'];
    setState(() {
      _isVideoMuted = (message == 'Video Off');
    });
  }

  void _onReconnect(String message) {
    debugPrint("Reconnect: $message");
  }

  void _onUserReconnectSuccess(Map<dynamic, dynamic> map) {
    debugPrint("Reconnect success: $map");
  }

  void _acceptCall() async {
    setState(() {
      _isIncomingCall = false;
      _isConnecting = true;
    });
    await _joinRoom();
  }

  void _rejectCall() {
    _sendDisconnectNotification("reject_call");
    _cleanupAndExit();
  }

  Future<void> _joinRoom() async {
    final localInfo = {
      'audio': true,
      'video': true,
      'data': false,
      'audioMuted': false,
      'videoMuted': false,
      'name': widget.name,
      'videoSize': {
        'minWidth': 320,
        'minHeight': 180,
        'maxWidth': 1280,
        'maxHeight': 720,
      },
    };
    final roomInfo = {
      'allow_reconnect': true,
      'number_of_attempts': 3,
      'timeout_interval': 15,
    };
    final advanceOptions = [];

    try {
      await EnxRtc.joinRoom(widget.token, localInfo, roomInfo, advanceOptions);
    } catch (e) {
      _showErrorAndClose("Failed to join room: $e");
    }
  }

  void _toggleMute() {
    if (_localStreamId != null) {
      EnxRtc.muteSelfAudio(!_isAudioMuted);
    }
  }

  void _toggleVideo() {
    if (_localStreamId != null) {
      EnxRtc.muteSelfVideo(!_isVideoMuted);
    }
  }

  void _switchCamera() {
    if (_localStreamId != null) {
      EnxRtc.switchCamera();
      setState(() => _isFrontCamera = !_isFrontCamera);
    }
  }

  void _endCall() {
    _sendDisconnectNotification("hang_up");
    EnxRtc.disconnect();
    _cleanupAndExit();
  }

  Future<void> _sendDisconnectNotification(String action) async {
    final dio = di.sl<DioClient>();
    try {
      await dio.dio.post(
        AppUrls.disconnectCall,
        data: {
          'doctor_id': widget.doctorId,
          'user_id': widget.familyMemberId,
          'status': action,
          'player_id': widget.playerId,
          'consult_type': widget.consultType,
          'family_member_id': widget.familyMemberId,
          'booking_id': widget.bookingId,
        },
      );
    } catch (e) {
      debugPrint("Disconnect notification error: $e");
    }
  }

  void _cleanupAndExit() {
    _timer?.cancel();
    _stopwatch.stop();
    WakelockPlus.disable();
    if (mounted) Navigator.pop(context);
  }

  void _showErrorAndClose(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Remote video (full-screen)
          if (_isCallActive && _remoteStreamId != null)
            Positioned.fill(
              child: EnxPlayerWidget(int.parse(_remoteStreamId!), local: false),
            ),

          // Local preview (top-right) – matches Android 140x200
          if (_isCallActive && _localStreamId != null)
            Positioned(
              top: 40,
              right: 16,
              child: Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.black,
                ),
                child: EnxPlayerWidget(
                  int.parse(_localStreamId!),
                  local: true,
                  width: 140,
                  height: 200,
                ),
              ),
            ),

          // Top-left info (name + timer) – when call active
          if (_isCallActive)
            Positioned(
              top: 40,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_callDurationSeconds),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

          // Incoming call UI (centered)
          if (_isIncomingCall)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder profile image (like Android's ImageView)
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                        image: const DecorationImage(
                          image: AssetImage('assets/default_avatar.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Incoming Call...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decline button
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: "decline",
                              backgroundColor: Colors.red,
                              onPressed: _rejectCall,
                              child: const Icon(Icons.call_end, size: 30),
                            ),
                            const SizedBox(height: 8),
                            const Text('Decline', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        // Accept button
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: "accept",
                              backgroundColor: Colors.green,
                              onPressed: _acceptCall,
                              child: const Icon(Icons.call, size: 30),
                            ),
                            const SizedBox(height: 8),
                            const Text('Accept', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Connecting indicator
          if (_isConnecting && !_isCallActive)
            const Center(child: CircularProgressIndicator()),

          // Bottom control bar (when call active)
          if (_isCallActive)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_isAudioMuted ? Icons.mic_off : Icons.mic),
                      color: Colors.white,
                      onPressed: _toggleMute,
                    ),
                    IconButton(
                      icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam),
                      color: Colors.white,
                      onPressed: _toggleVideo,
                    ),
                    IconButton(
                      icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
                      color: Colors.white,
                      onPressed: _switchCamera,
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end),
                      color: Colors.red,
                      onPressed: _endCall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    EnxRtc.disconnect();
    super.dispose();
  }
}