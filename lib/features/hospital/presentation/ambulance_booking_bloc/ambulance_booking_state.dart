

import 'package:equatable/equatable.dart';

abstract class AmbulanceBookingState extends Equatable {
  const AmbulanceBookingState();
  @override
  List<Object?> get props => [];
}

class AmbulanceBookingInitial extends AmbulanceBookingState {}

class AmbulanceBookingLoading extends AmbulanceBookingState {}

class AmbulanceBookingSuccess extends AmbulanceBookingState {
  final String bookingId;
  const AmbulanceBookingSuccess(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class AmbulanceBookingFailure extends AmbulanceBookingState {
  final String message;
  const AmbulanceBookingFailure(this.message);
  @override
  List<Object?> get props => [message];
}