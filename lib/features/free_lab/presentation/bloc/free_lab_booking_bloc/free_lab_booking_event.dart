import 'package:equatable/equatable.dart';
abstract class FreeLabBookingEvent extends Equatable {
  const FreeLabBookingEvent();
  @override
  List<Object?> get props => [];
}

class CreateFreeLabOrder extends FreeLabBookingEvent {
  final int amount;
  final String currency;
  const CreateFreeLabOrder({required this.amount, required this.currency});
  @override
  List<Object?> get props => [amount, currency];
}

class SubmitFreeLabBooking extends FreeLabBookingEvent {
  final Map<String, dynamic> bookingData;
  final String language;
  const SubmitFreeLabBooking({required this.bookingData, required this.language});
  @override
  List<Object?> get props => [bookingData, language];
}