

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/lab_test_booking_fetch_detail.dart';

abstract class LabTestBookingFetchDetailState extends Equatable {
  const LabTestBookingFetchDetailState();
  @override List<Object> get props => [];
}

class LabTestBookingFetchDetailInitial extends LabTestBookingFetchDetailState {}
class LabTestBookingFetchDetailLoading extends LabTestBookingFetchDetailState {}
class LabTestBookingFetchDetailLoaded extends LabTestBookingFetchDetailState {
  final LabTestBookingFetchDetail detail;
  const LabTestBookingFetchDetailLoaded(this.detail);
}
class LabTestBookingFetchDetailError extends LabTestBookingFetchDetailState {
  final String message;
  const LabTestBookingFetchDetailError(this.message);
}