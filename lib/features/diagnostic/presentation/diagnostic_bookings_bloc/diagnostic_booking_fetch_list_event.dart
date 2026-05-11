

import 'package:equatable/equatable.dart';

abstract class DiagnosticBookingFetchListEvent extends Equatable {
  const DiagnosticBookingFetchListEvent();
  @override List<Object> get props => [];
}

class LoadOngoingFetchBookings extends DiagnosticBookingFetchListEvent {}
class LoadCompletedFetchBookings extends DiagnosticBookingFetchListEvent {}
class LoadMoreOngoingFetchBookings extends DiagnosticBookingFetchListEvent {}
class LoadMoreCompletedFetchBookings extends DiagnosticBookingFetchListEvent {}
class SelectFetchBookingTab extends DiagnosticBookingFetchListEvent {
  final int index;
  const SelectFetchBookingTab(this.index);
}