import 'package:equatable/equatable.dart';


abstract class LabPaymentBookingEvent extends Equatable {
  const LabPaymentBookingEvent();
  @override List<Object> get props => [];
}



class BookLabTestPayment extends LabPaymentBookingEvent {
  final int labTestId;
  final int testId;
  final int addressId;
  final int count;
  final double fee;
  final String date;
  final String time;
  final int familyMemberId;          // ✅ single integer
  final int? couponId;
  final String paymentType;
  final List<String> prescriptionPaths;
  final int slotId;
  final double consultationFee;
  final double flatDiscount;
  final String? orderId;

  const BookLabTestPayment({
    required this.labTestId,
    required this.testId,
    required this.addressId,
    required this.count,
    required this.fee,
    required this.date,
    required this.time,
    required this.familyMemberId,
    this.couponId,
    required this.paymentType,
    required this.prescriptionPaths,
    required this.slotId,
    this.consultationFee = 0,
    this.flatDiscount = 0,
    this.orderId,
  });
}