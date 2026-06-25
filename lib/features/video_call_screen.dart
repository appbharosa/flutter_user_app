import 'dart:async';
import 'package:enx_flutter_plugin/base.dart';
import 'package:enx_flutter_plugin/enx_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/network/dio_client.dart';
import '../../../../core/appurls/app_urls.dart';
import '../main.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';


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
  bool _isDisposed = false;
  bool _isEnding = false;

  final AudioPlayer _ringtonePlayer = ringtonePlayer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _checkPermissionsAndSetup();
    WakelockPlus.enable();
  }

  Future<void> _checkPermissionsAndSetup() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final allGranted = statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
    if (allGranted) {
      setState(() => _permissionsGranted = true);
      _registerCallbacks();
      _ringtonePlayer.stop();
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
    EnxRtc.onActiveTalkerList = _onActiveTalkerList;
  }

  void _onRoomConnected(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    setState(() {
      _isCallActive = true;
      _isConnecting = false;
    });
    WakelockPlus.enable();
    EnxRtc.publish();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _callDurationSeconds = _stopwatch.elapsed.inSeconds;
        });
      }
    });
  }

  void _onRoomError(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    _showErrorAndClose(map['msg'] ?? 'Room error');
  }

  void _onRoomDisconnected(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    _cleanupAndExit();
  }

  void _onUserConnected(Map<dynamic, dynamic> map) {}
  void _onUserDisconnected(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    if (_isCallActive) _endCall();
  }

  void _onPublishedStream(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    final streamId = map['streamId']?.toString();
    if (streamId != null) {
      setState(() => _localStreamId = streamId);
    }
  }

  void _onStreamAdded(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    final streamId = map['streamId']?.toString();
    final hasVideo = map['video'] ?? true;
    if (streamId == null || !hasVideo) return;
    if (streamId == _localStreamId) return;

    debugPrint("📥 Stream added: $streamId");
    EnxRtc.subscribe(streamId);
  }

  void _onSubscribedStream(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    final streamId = map['streamId']?.toString();
    if (streamId == null) return;
    if (streamId == _localStreamId) return;
    if (_remoteStreamId == null) {
      setState(() => _remoteStreamId = streamId);
    }
  }

  void _onActiveTalkerList(Map<dynamic, dynamic> map) {
    if (_isDisposed) return;
    final list = map['activeList'] as List?;
    if (list == null || list.isEmpty) return;
    for (final item in list) {
      final streamId = item['streamId']?.toString();
      if (streamId != null && streamId != _localStreamId) {
        if (_remoteStreamId != streamId) {
          setState(() => _remoteStreamId = streamId);
        }
        break;
      }
    }
  }

  void _onAudioEvent(Map<dynamic, dynamic> event) {
    if (_isDisposed) return;
    final message = event['msg']?.toString();
    setState(() => _isAudioMuted = (message == 'Audio Off'));
  }

  void _onVideoEvent(Map<dynamic, dynamic> event) {
    if (_isDisposed) return;
    final message = event['msg']?.toString();
    setState(() => _isVideoMuted = (message == 'Video Off'));
  }

  void _acceptCall() async {
    if (_isDisposed) return;
    setState(() {
      _isIncomingCall = false;
      _isConnecting = true;
    });
    await _joinRoom();
  }

  void _rejectCall() {
    if (_isDisposed) return;
    _sendDisconnectNotification("reject_call");
    _cleanupAndExit();
  }

  Future<void> _joinRoom() async {
    if (_isDisposed) return;
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
    try {
      await EnxRtc.joinRoom(widget.token, localInfo, roomInfo, []);
    } catch (e) {
      if (mounted && !_isDisposed) {
        _showErrorAndClose("Failed to join room: $e");
      }
    }
  }

  void _toggleMute() {
    if (_isDisposed || _localStreamId == null) return;
    final newMute = !_isAudioMuted;
    EnxRtc.muteSelfAudio(newMute);
    setState(() => _isAudioMuted = newMute);
  }

  void _toggleVideo() {
    if (_isDisposed || _localStreamId == null) return;
    final newMute = !_isVideoMuted;
    EnxRtc.muteSelfVideo(newMute);
    setState(() => _isVideoMuted = newMute);
  }

  void _switchCamera() {
    if (_isDisposed || _localStreamId == null) return;
    EnxRtc.switchCamera();
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  void _endCall() {
    if (_isEnding) return;
    _isEnding = true;
    _sendDisconnectNotification("hang_up");
    try { EnxRtc.disconnect(); } catch (_) {}
    _cleanupAndExit();
  }

  Future<void> _sendDisconnectNotification(String action) async {
    final dio = di.sl<DioClient>().dio;
    try {
      await dio.post(
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
      debugPrint('✅ Disconnect notification sent: $action');
    } catch (e) {
      debugPrint('❌ Disconnect notification error: $e');
    }
  }

  void _cleanupAndExit() {
    if (_isDisposed) return;
    _isDisposed = true;
    _timer?.cancel();
    _stopwatch.stop();
    WakelockPlus.disable();
    _ringtonePlayer.stop();
    if (mounted) Navigator.pop(context);
  }

  void _showErrorAndClose(String message) {
    if (_isDisposed) return;
    _isDisposed = true;
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
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isCallActive) {
          _endCall();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              // ─── Remote video (full screen) ────────────────────
              if (_remoteStreamId != null)
                Positioned.fill(
                  child: EnxPlayerWidget(
                    int.parse(_remoteStreamId!),
                    local: false,
                    width: MediaQuery.of(context).size.width.toInt(),
                    height: MediaQuery.of(context).size.height.toInt(),
                    mScalingType: ScalingType.SCALE_ASPECT_FILL, // ✅ Fill full screen
                  ),
                )
              else
                const Center(
                  child: Text(
                    'Waiting for doctor...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

              // ─── Local preview ────────────────────────────────
              if (_isCallActive)
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
                      0,
                      local: true,
                      width: 140,
                      height: 200,
                      mScalingType: ScalingType.SCALE_ASPECT_BALANCED,
                    ),
                  ),
                ),

              // ─── Top-left info ─────────────────────────────────
              if (_isCallActive)
                Positioned(
                  top: 40,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_callDurationSeconds),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

              // ─── Incoming call UI ─────────────────────────────
              if (_isIncomingCall)
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(Icons.person, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Incoming Call...', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                FloatingActionButton(
                                  heroTag: ObjectKey('decline'),
                                  backgroundColor: Colors.red,
                                  onPressed: _rejectCall,
                                  child: const Icon(Icons.call_end, size: 30),
                                ),
                                const SizedBox(height: 8),
                                const Text('Decline', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Column(
                              children: [
                                FloatingActionButton(
                                  heroTag: ObjectKey('accept'),
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

              // ─── Connecting indicator ─────────────────────────
              if (_isConnecting && !_isCallActive)
                const Center(child: CircularProgressIndicator()),

              // ─── Bottom control bar ───────────────────────────
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    EnxRtc.disconnect();
    WakelockPlus.disable();
    _ringtonePlayer.stop();
    super.dispose();
  }
}