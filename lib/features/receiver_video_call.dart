// import 'package:enx_flutter_plugin/enx_player_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class VideoCallReceiverScreen extends StatefulWidget {
//   final String token;          // JWT token from your backend
//   final String callerName;    // Name of the caller (e.g., doctor)
//   final String appointmentId; // Optional appointment/booking ID
//
//   const VideoCallReceiverScreen({
//     super.key,
//     required this.token,
//     required this.callerName,
//     required this.appointmentId,
//   });
//
//   @override
//   State<VideoCallReceiverScreen> createState() => _VideoCallReceiverScreenState();
// }
//
// class _VideoCallReceiverScreenState extends State<VideoCallReceiverScreen> {
//   bool _isIncomingCall = true;
//   bool _isConnecting = false;
//   bool _isCallActive = false;
//   bool _isAudioMuted = false;
//   bool _isVideoMuted = false;
//   bool _isFrontCamera = true;
//
//   // Store the stream data for rendering
//   Map<dynamic, dynamic>? _localStreamData;
//   Map<dynamic, dynamic>? _remoteStreamData;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndSetup();
//   }
//
//   Future<void> _checkPermissionsAndSetup() async {
//     final cameraStatus = await Permission.camera.request();
//     final micStatus = await Permission.microphone.request();
//     if (cameraStatus.isGranted && micStatus.isGranted) {
//       _registerCallbacks();
//       setState(() => _isConnecting = true);
//     } else {
//       _showErrorAndPop('Camera and microphone permissions are required for the call.');
//     }
//   }
//
//   void _registerCallbacks() {
//     // Room connection events
//     EnxRtc.onRoomConnected = _onRoomConnected;
//     EnxRtc.onRoomError = _onRoomError;
//     EnxRtc.onUserConnected = _onUserConnected;
//    // EnxRtc.onUserDisconnected = _onUserDisconnected;
//
//     // Stream events
//     EnxRtc.onPublishedStream = _onPublishedStream;
//     EnxRtc.onStreamAdded = _onStreamAdded;
//     EnxRtc.onSubscribedStream = _onSubscribedStream;
//
//     // Audio/Video mute events
//     EnxRtc.onAudioEvent = _onAudioEvent;
//     EnxRtc.onVideoEvent = _onVideoEvent;
//
//     // Recording/Streaming events (optional - add if needed)
//     // EnxRtc.onRecordingStarted = (map) {};
//     // EnxRtc.onRecordingStopped = (map) {};
//   }
//
//   void _onRoomConnected(Map<dynamic, dynamic> map) {
//     debugPrint("onRoomConnected: $map");
//     setState(() {
//       _isCallActive = true;
//       _isConnecting = false;
//     });
//     // Automatically publish your local stream after room is connected
//     EnxRtc.publish();
//   }
//
//   void _onRoomError(Map<dynamic, dynamic> map) {
//     debugPrint("onRoomError: $map");
//     _showErrorAndPop(map['msg'] ?? 'Unknown room error');
//   }
//
//   void _onUserConnected(Map<dynamic, dynamic> map) {
//     debugPrint("User connected: $map");
//     // A remote user has joined the room
//   }
//
//   void _onUserDisconnected(Map<dynamic, dynamic> map) {
//     debugPrint("User disconnected: $map");
//     // Remote user left; you can end the call if needed
//     _endCall();
//   }
//
//   void _onPublishedStream(Map<dynamic, dynamic> map) {
//     debugPrint("Local stream published: $map");
//     setState(() {
//       _localStreamData = map;
//     });
//   }
//
//   void _onStreamAdded(Map<dynamic, dynamic> map) {
//     debugPrint("Stream added: $map");
//     // A new stream is available (this is the remote user's stream)
//     EnxRtc.subscribe(map as String);
//   }
//
//   void _onSubscribedStream(Map<dynamic, dynamic> map) {
//     debugPrint("Stream subscribed: $map");
//     setState(() {
//       _remoteStreamData = map;
//     });
//   }
//
//   void _onAudioEvent(Map<dynamic, dynamic> event) {
//     debugPrint("Audio event: $event");
//     final String? message = event['msg'];
//     if (message == 'Audio On') {
//       setState(() => _isAudioMuted = false);
//     } else if (message == 'Audio Off') {
//       setState(() => _isAudioMuted = true);
//     }
//   }
//
//   void _onVideoEvent(Map<dynamic, dynamic> event) {
//     debugPrint("Video event: $event");
//     final String? message = event['msg'];
//     if (message == 'Video On') {
//       setState(() => _isVideoMuted = false);
//     } else if (message == 'Video Off') {
//       setState(() => _isVideoMuted = true);
//     }
//   }
//
//   void _acceptCall() async {
//     setState(() {
//       _isIncomingCall = false;
//       _isConnecting = true;
//     });
//     await _setupAndJoinRoom();
//   }
//
//   void _rejectCall() {
//     // Add your backend call to log rejection if needed
//     Navigator.of(context).pop();
//   }
//
//   Future<void> _setupAndJoinRoom() async {
//     try {
//       final Map<String, dynamic> localInfo = {
//         'audio': true,
//         'video': true,
//         'data': false,
//         'audioMuted': false,
//         'videoMuted': false,
//         'name': 'Patient', // You can use a patient name from your app
//         'videoSize': {
//           'minWidth': 320,
//           'minHeight': 180,
//           'maxWidth': 1280,
//           'maxHeight': 720,
//         },
//       };
//
//       final Map<String, dynamic> roomInfo = {
//         'allow_reconnect': true,
//         'number_of_attempts': 3,
//         'timeout_interval': 15,
//       };
//
//       final List<dynamic> advanceOptions = [];
//
//       await EnxRtc.joinRoom(widget.token, localInfo, roomInfo, advanceOptions);
//     } catch (e) {
//       _showErrorAndPop("Failed to join the call: $e");
//     }
//   }
//
//   void _toggleMute() {
//     if (_localStreamData != null) {
//       EnxRtc.muteSelfAudio(!_isAudioMuted);
//     }
//   }
//
//   void _toggleVideo() {
//     if (_localStreamData != null) {
//       EnxRtc.muteSelfVideo(!_isVideoMuted);
//     }
//   }
//
//   void _switchCamera() {
//     if (_localStreamData != null) {
//       EnxRtc.switchCamera();
//       setState(() => _isFrontCamera = !_isFrontCamera);
//     }
//   }
//
//   void _endCall() async {
//     setState(() => _isCallActive = false);
//     await EnxRtc.disconnect();
//     // Add your backend call to log call end if needed
//     _cleanupAndExit();
//   }
//
//   void _cleanupAndExit() {
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//   }
//
//   void _showErrorAndPop(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//       Navigator.of(context).pop();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Main video view (remote stream)
//           if (_isCallActive && _remoteStreamData != null)
//             EnxPlayerWidget(
//               int.parse(_remoteStreamData!['streamId'].toString()),
//               local: false,
//             )
//           else if (_isCallActive)
//             const Center(child: Text('Waiting for remote stream...')),
//
//           // Local preview (small overlay)
//           if (_isCallActive && _localStreamData != null)
//             Positioned(
//               top: 60,
//               right: 16,
//               child: Container(
//                 width: 120,
//                 height: 160,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.black,
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: EnxPlayerWidget(
//                   int.parse(_localStreamData!['streamId'].toString()),
//                   local: true,
//                   width: 120,
//                   height: 160,
//                 ),
//               ),
//             ),
//
//           // Incoming call UI
//           if (_isIncomingCall)
//             Container(
//               color: Colors.black87,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.phone_in_talk, size: 80, color: Colors.white),
//                     const SizedBox(height: 20),
//                     Text(
//                       widget.callerName,
//                       style: const TextStyle(fontSize: 24, color: Colors.white),
//                     ),
//                     const SizedBox(height: 40),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         FloatingActionButton(
//                           heroTag: "accept",
//                           backgroundColor: Colors.green,
//                           onPressed: _acceptCall,
//                           child: const Icon(Icons.call, size: 30),
//                         ),
//                         FloatingActionButton(
//                           heroTag: "decline",
//                           backgroundColor: Colors.red,
//                           onPressed: _rejectCall,
//                           child: const Icon(Icons.call_end, size: 30),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Connecting indicator
//           if (_isConnecting && !_isCallActive)
//             const Center(child: CircularProgressIndicator()),
//
//           // Call controls overlay (bottom)
//           if (_isCallActive)
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     IconButton(
//                       icon: Icon(_isAudioMuted ? Icons.mic_off : Icons.mic),
//                       color: Colors.white,
//                       onPressed: _toggleMute,
//                     ),
//                     IconButton(
//                       icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam),
//                       color: Colors.white,
//                       onPressed: _toggleVideo,
//                     ),
//                     IconButton(
//                       icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
//                       color: Colors.white,
//                       onPressed: _switchCamera,
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.call_end),
//                       color: Colors.red,
//                       onPressed: _endCall,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // Clean up SDK resources
//     EnxRtc.disconnect();
//     super.dispose();
//   }
// }