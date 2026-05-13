

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/lab_test_booking_fetch_item.dart';



abstract class LabTestBookingFetchListState extends Equatable {
  const LabTestBookingFetchListState();
  @override List<Object> get props => [];
}

class LabTestBookingFetchListInitial extends LabTestBookingFetchListState {}
class LabTestBookingFetchListLoading extends LabTestBookingFetchListState {}

class LabTestBookingFetchListLoaded extends LabTestBookingFetchListState {
  final List<LabTestBookingFetchItem> ongoingList;
  final List<LabTestBookingFetchItem> completedList;
  final int selectedTab;
  final bool hasMoreOngoing;
  final bool hasMoreCompleted;

  const LabTestBookingFetchListLoaded({
    required this.ongoingList,
    required this.completedList,
    required this.selectedTab,
    this.hasMoreOngoing = true,
    this.hasMoreCompleted = true,
  });

  LabTestBookingFetchListLoaded copyWith({
    List<LabTestBookingFetchItem>? ongoingList,
    List<LabTestBookingFetchItem>? completedList,
    int? selectedTab,
    bool? hasMoreOngoing,
    bool? hasMoreCompleted,
  }) {
    return LabTestBookingFetchListLoaded(
      ongoingList: ongoingList ?? this.ongoingList,
      completedList: completedList ?? this.completedList,
      selectedTab: selectedTab ?? this.selectedTab,
      hasMoreOngoing: hasMoreOngoing ?? this.hasMoreOngoing,
      hasMoreCompleted: hasMoreCompleted ?? this.hasMoreCompleted,
    );
  }

  @override
  List<Object> get props => [
    ongoingList,
    completedList,
    selectedTab,
    hasMoreOngoing,
    hasMoreCompleted,
  ];
}

class LabTestBookingFetchListError extends LabTestBookingFetchListState {
  final String message;
  const LabTestBookingFetchListError(this.message);
  @override List<Object> get props => [message];
}