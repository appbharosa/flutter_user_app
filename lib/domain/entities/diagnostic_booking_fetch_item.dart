import 'package:equatable/equatable.dart';

class DiagnosticBookingFetchItem extends Equatable {
  final String bookingId;
  final String name;
  final String location;
  final String logo;

  const DiagnosticBookingFetchItem({
    required this.bookingId,
    required this.name,
    required this.location,
    required this.logo,
  });

  @override
  List<Object?> get props => [bookingId];
}