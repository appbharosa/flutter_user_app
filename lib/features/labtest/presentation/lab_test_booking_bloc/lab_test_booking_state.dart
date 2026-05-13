
import 'package:equatable/equatable.dart';

abstract class LabTestBookingState extends Equatable {
  const LabTestBookingState();
  @override List<Object> get props => [];
}

class LabTestBookingInitial extends LabTestBookingState {}
class LabTestBookingLoading extends LabTestBookingState {}
class LabTestBookingSuccess extends LabTestBookingState {
  final String bookingId;
  const LabTestBookingSuccess(this.bookingId);
}
class LabTestBookingError extends LabTestBookingState {
  final String message;
  const LabTestBookingError(this.message);
}