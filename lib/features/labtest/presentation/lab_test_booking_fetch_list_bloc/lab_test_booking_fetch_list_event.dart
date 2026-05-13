

import 'package:equatable/equatable.dart';

abstract class LabTestBookingFetchListEvent extends Equatable {
  const LabTestBookingFetchListEvent();
  @override List<Object> get props => [];
}

class LoadOngoingLabTestBookings extends LabTestBookingFetchListEvent {}
class LoadCompletedLabTestBookings extends LabTestBookingFetchListEvent {}
class LoadMoreOngoingLabTestBookings extends LabTestBookingFetchListEvent {}
class LoadMoreCompletedLabTestBookings extends LabTestBookingFetchListEvent {}
class SelectLabTestBookingTab extends LabTestBookingFetchListEvent {
  final int index;
  const SelectLabTestBookingTab(this.index);
}