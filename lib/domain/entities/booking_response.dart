import 'package:equatable/equatable.dart';

class BookingResponse extends Equatable {
  final String bookingId;
  const BookingResponse(this.bookingId);
  @override List<Object?> get props => [bookingId];
}