import 'package:equatable/equatable.dart';

abstract class CallState extends Equatable {
  const CallState();
  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class IncomingCallState extends CallState {
  final String callerName;
  const IncomingCallState(this.callerName);
  @override
  List<Object?> get props => [callerName];
}

class ConnectingState extends CallState {}

class InCallState extends CallState {
  final bool isAudioMuted;
  final bool isVideoMuted;
  final bool isFrontCamera;
  final String currentAudioDevice;
  final List<String> availableDevices;
  final String? localStreamId;
  final List<String> remoteStreamIds;
  final int callDurationSeconds;

  const InCallState({
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.isFrontCamera = true,
    this.currentAudioDevice = "Speaker",
    this.availableDevices = const [],
    this.localStreamId,
    this.remoteStreamIds = const [],
    this.callDurationSeconds = 0,
  });

  InCallState copyWith({
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isFrontCamera,
    String? currentAudioDevice,
    List<String>? availableDevices,
    String? localStreamId,
    List<String>? remoteStreamIds,
    int? callDurationSeconds,
  }) {
    return InCallState(
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      currentAudioDevice: currentAudioDevice ?? this.currentAudioDevice,
      availableDevices: availableDevices ?? this.availableDevices,
      localStreamId: localStreamId ?? this.localStreamId,
      remoteStreamIds: remoteStreamIds ?? this.remoteStreamIds,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    isAudioMuted,
    isVideoMuted,
    isFrontCamera,
    currentAudioDevice,
    availableDevices,
    localStreamId,
    remoteStreamIds,
    callDurationSeconds,
  ];
}

class CallErrorState extends CallState {
  final String error;
  const CallErrorState(this.error);
  @override
  List<Object?> get props => [error];
}

class CallEndedState extends CallState {}