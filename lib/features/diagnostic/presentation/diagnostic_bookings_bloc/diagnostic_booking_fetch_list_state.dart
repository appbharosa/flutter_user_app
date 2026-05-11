



import 'package:equatable/equatable.dart';

import '../../../../domain/entities/diagnostic_booking_fetch_item.dart';

abstract class DiagnosticBookingFetchListState extends Equatable {
  const DiagnosticBookingFetchListState();
  @override List<Object> get props => [];
}

class DiagnosticBookingFetchListInitial extends DiagnosticBookingFetchListState {}
class DiagnosticBookingFetchListLoading extends DiagnosticBookingFetchListState {}
class DiagnosticBookingFetchListLoaded extends DiagnosticBookingFetchListState {
  final List<DiagnosticBookingFetchItem> ongoingList;
  final List<DiagnosticBookingFetchItem> completedList;
  final int selectedTab;
  final bool hasMoreOngoing;
  final bool hasMoreCompleted;
  const DiagnosticBookingFetchListLoaded({
    required this.ongoingList,
    required this.completedList,
    required this.selectedTab,
    this.hasMoreOngoing = true,
    this.hasMoreCompleted = true,
  });
}
class DiagnosticBookingFetchListError extends DiagnosticBookingFetchListState {
  final String message;
  const DiagnosticBookingFetchListError(this.message);
}