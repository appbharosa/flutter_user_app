
import 'package:equatable/equatable.dart';

abstract class LabTestBookingFetchDetailEvent extends Equatable {
  const LabTestBookingFetchDetailEvent();
  @override List<Object> get props => [];
}

class LoadLabTestBookingDetail extends LabTestBookingFetchDetailEvent {
  final String bookingId;
  const LoadLabTestBookingDetail(this.bookingId);
}