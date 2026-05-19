
import 'package:equatable/equatable.dart';

abstract class MedicineBookingEvent extends Equatable {
  const MedicineBookingEvent();
  @override List<Object> get props => [];
}

class SubmitMedicineBooking extends MedicineBookingEvent {
  final int mainDataId;
  final String orderType;
  final int addressId;
  final List<String> imagePaths;
  const SubmitMedicineBooking({
    required this.mainDataId,
    required this.orderType,
    required this.addressId,
    required this.imagePaths,
  });
}