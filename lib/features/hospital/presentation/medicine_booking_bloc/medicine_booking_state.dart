
import 'package:equatable/equatable.dart';


abstract class MedicineBookingState extends Equatable {
  const MedicineBookingState();
  @override List<Object> get props => [];
}

class MedicineBookingInitial extends MedicineBookingState {}
class MedicineBookingLoading extends MedicineBookingState {}
class MedicineBookingSuccess extends MedicineBookingState {
  final String message;
  const MedicineBookingSuccess(this.message);
}
class MedicineBookingError extends MedicineBookingState {
  final String message;
  const MedicineBookingError(this.message);
}