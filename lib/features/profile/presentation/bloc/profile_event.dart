
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final Map<String, dynamic> updatedData;
  const UpdateProfileEvent(this.updatedData);
  @override
  List<Object> get props => [updatedData];
}