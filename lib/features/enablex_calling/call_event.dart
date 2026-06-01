import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();
  @override
  List<Object?> get props => [];
}

class InitializeCallEvent extends CallEvent {
  final Map<String, dynamic> params;
  const InitializeCallEvent(this.params);
}

class AcceptCallEvent extends CallEvent {}
class DeclineCallEvent extends CallEvent {}
class EndCallEvent extends CallEvent {}
class ToggleMuteEvent extends CallEvent {}
class ToggleVideoEvent extends CallEvent {}
class SwitchCameraEvent extends CallEvent {}
class AudioDeviceSelectedEvent extends CallEvent {
  final String device;
  const AudioDeviceSelectedEvent(this.device);
}
class LoadAudioDevicesEvent extends CallEvent {}
class UpdateCallDurationEvent extends CallEvent {
  final int seconds;
  const UpdateCallDurationEvent(this.seconds);
}