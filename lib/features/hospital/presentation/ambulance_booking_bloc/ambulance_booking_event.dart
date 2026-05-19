

import 'package:equatable/equatable.dart';

abstract class AmbulanceBookingEvent extends Equatable {
  const AmbulanceBookingEvent();
  @override
  List<Object?> get props => [];
}

class SubmitAmbulanceBooking extends AmbulanceBookingEvent {
  final String language;
  final int mainDataId;
  const SubmitAmbulanceBooking({required this.language, required this.mainDataId});
  @override
  List<Object?> get props => [language, mainDataId];
}

class ResetAmbulanceBooking extends AmbulanceBookingEvent {}