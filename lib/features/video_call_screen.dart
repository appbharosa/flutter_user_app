import 'dart:async';
import 'package:dio/dio.dart';
import 'package:enx_flutter_plugin/base.dart';
import 'package:enx_flutter_plugin/enx_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/features/rating_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/network/dio_client.dart';
import '../../../../core/appurls/app_urls.dart';
import '../main.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class VideoCallScreen extends StatefulWidget {
  final String token;
  final String roomId;
  final String name;
  final String doctorId;
  final String playerId;
  final String familyMemberId;
  final String bookingId;
  final String consultType;
  final String mainDataId;

  const VideoCallScreen({
    Key? key,
    required this.token,
    required this.roomId,
    required this.name,
    required this.doctorId,
    required this.playerId,
    required this.familyMemberId,
    required this.bookingId,
    required this.consultType,
    this.mainDataId = '',
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
  bool _isCleaningUp = false;

  final AudioPlayer _ringtonePlayer = ringtonePlayer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _registerCallbacks();
    _ringtonePlayer.stop();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isCleaningUp = true;
    _timer?.cancel();
    _stopwatch.stop();
    EnxRtc.disconnect();
    WakelockPlus.disable();
    _ringtonePlayer.stop();
    super.dispose();
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
    if (_isDisposed || _isCleaningUp) return;
    _isCleaningUp = true;
    _cleanupAndExit(map['msg'] ?? 'Room error');
  }

  void _onRoomDisconnected(Map<dynamic, dynamic> map) {
    if (_isDisposed || _isCleaningUp) return;
    _isCleaningUp = true;
    _cleanupAndExit('Call ended');
  }

  void _onUserConnected(Map<dynamic, dynamic> map) {}
  void _onUserDisconnected(Map<dynamic, dynamic> map) {
    if (_isDisposed || _isCleaningUp) return;
    if (_isCallActive) {
      _isCleaningUp = true;
      _cleanupAndExit('User disconnected');
    }
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
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    final cameraGranted = statuses[Permission.camera]!.isGranted;
    final micGranted = statuses[Permission.microphone]!.isGranted;
    if (!cameraGranted || !micGranted) {
      _showPermissionDialog();
      return;
    }
    setState(() {
      _permissionsGranted = true;
      _isIncomingCall = false;
      _isConnecting = true;
    });
    await _joinRoom();
  }

  void _showPermissionDialog() {
    if (_isDisposed) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Camera and microphone permissions are needed for video calls.\n\n'
              'Please grant them in your device settings and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _rejectCall() {
    if (_isDisposed || _isCleaningUp) return;
    _isCleaningUp = true;
    _ringtonePlayer.stop();
    _sendDisconnectNotification("reject_call");
    _cleanupAndExit('Call rejected');
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

  // ✅ End call with rating dialog
  void _endCall() {
    if (_isEnding || _isCleaningUp) return;
    _isEnding = true;
    _isCleaningUp = true;
    _ringtonePlayer.stop();
    _sendDisconnectNotification("hang_up");
    _callEndRoomApi();
    try { EnxRtc.disconnect(); } catch (_) {}
    // Show rating dialog before cleanup
    _showRatingDialog();
  }

// ✅ Rating Dialog with proper UI
  void _showRatingDialog() {
    if (_isDisposed) return;
    int rating = 0;
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              'Rate Your Consultation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Star rating row - better spacing and sizing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 38,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              // Show rating text
              if (rating > 0)
                Text(
                  _getRatingText(rating),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber,
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Share your feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
                minLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cleanupAndExit();
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                      content: Text('Please select a rating'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }
                // Submit rating
                await _submitRating(rating, messageController.text.trim());
                Navigator.pop(context);
                // Show success toast after dialog closes
                _showSuccessToast(context);
                _cleanupAndExit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ✅ Helper to get rating text
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

// ✅ Show success toast
  void _showSuccessToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

// Helper to show custom snackbar with rounded corners
  void _showCustomSnackbar(BuildContext context, String message, {Color backgroundColor = Colors.green}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ✅ Submit Rating API
  Future<void> _submitRating(int rating, String message) async {
    try {
      final dio = di.sl<DioClient>().dio;
      final response = await dio.post(
        AppUrls.userRating,
        data: {
          'doctor_id': widget.doctorId,
          'booking_id': widget.bookingId,
          'main_data_id': widget.mainDataId,
          'rating': rating,
          'message': message,
        },
      );
      if (response.data['status'] == 200) {
        debugPrint('✅ Rating submitted successfully');
      } else {
        debugPrint('❌ Rating submission failed: ${response.data['message']}');
        // If submission fails, show error toast
        if (mounted) {
          _showCustomSnackbar(
            context,
            'Failed to submit rating: ${response.data['message']}',
            backgroundColor: Colors.red,
          );
          // Still exit the call after showing error
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _cleanupAndExit();
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Rating submission error: $e');
      if (mounted) {
        _showCustomSnackbar(
          context,
          'Error submitting rating',
          backgroundColor: Colors.red,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _cleanupAndExit();
        });
      }
    }
  }

  Future<void> _callEndRoomApi() async {
    try {
      final dio = di.sl<DioClient>().dio;
      final response = await dio.delete(
        '${AppUrls.endCall}/${widget.roomId}',
      );
      debugPrint('✅ End-room API called: ${response.data}');
    } catch (e) {
      debugPrint('❌ End-room API failed: $e');
    }
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
          'main_data_id': widget.mainDataId,
        },
      );
      debugPrint('✅ Disconnect notification sent: $action');
    } catch (e) {
      debugPrint('❌ Disconnect notification error: $e');
    }
  }

  void _cleanupAndExit([String? reason]) {
    if (_isDisposed) return;
    _isDisposed = true;
    _timer?.cancel();
    _stopwatch.stop();
    EnxRtc.disconnect();
    WakelockPlus.disable();
    _ringtonePlayer.stop();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
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
              if (_remoteStreamId != null)
                Positioned.fill(
                  child: EnxPlayerWidget(
                    int.parse(_remoteStreamId!),
                    local: false,
                    width: MediaQuery.of(context).size.width.toInt(),
                    height: MediaQuery.of(context).size.height.toInt(),
                    mScalingType: ScalingType.SCALE_ASPECT_FILL,
                  ),
                )
              else
                const Center(
                  child: Text(
                    'Waiting for doctor...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
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
              if (_isConnecting && !_isCallActive)
                const Center(child: CircularProgressIndicator()),
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
}