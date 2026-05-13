import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class LabTestBookingFetchItem extends Equatable {
  final String bookingId;
  final String name;
  final String location;
  final String logo;
  final String? completedDate; // only for completed

  const LabTestBookingFetchItem({
    required this.bookingId,
    required this.name,
    required this.location,
    required this.logo,
    this.completedDate,
  });

  @override
  List<Object?> get props => [bookingId];
}