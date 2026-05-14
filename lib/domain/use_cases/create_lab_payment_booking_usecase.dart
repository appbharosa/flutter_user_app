import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_payment_booking_response.dart';
import '../repositories/lab_payment_booking_repository.dart';



class CreateLabPaymentBookingParams {
  final int labTestId;
  final int testId;
  final int addressId;
  final int count;
  final double fee;
  final String date;
  final String time;
  final int familyMemberId;          // ✅ changed from List<int> to int
  final int? couponId;
  final String paymentType;
  final List<String> prescriptionPaths;
  final int slotId;
  final double consultationFee;
  final double flatDiscount;
  final String? orderId;

  CreateLabPaymentBookingParams({
    required this.labTestId,
    required this.testId,
    required this.addressId,
    required this.count,
    required this.fee,
    required this.date,
    required this.time,
    required this.familyMemberId,     // ✅ single integer
    this.couponId,
    required this.paymentType,
    required this.prescriptionPaths,
    required this.slotId,
    this.consultationFee = 0,
    this.flatDiscount = 0,
    this.orderId,
  });
}

class CreateLabPaymentBookingUseCase {
  final LabPaymentBookingRepository repository;
  CreateLabPaymentBookingUseCase(this.repository);
  Future<Either<Failure, LabPaymentBookingResponse>> call(CreateLabPaymentBookingParams params) async {
    return await repository.book(
      labTestId: params.labTestId,
      testId: params.testId,
      addressId: params.addressId,
      count: params.count,
      fee: params.fee,
      date: params.date,
      time: params.time,
      familyMemberId: params.familyMemberId,   // ✅ single integer
      couponId: params.couponId,
      paymentType: params.paymentType,
      prescriptionPaths: params.prescriptionPaths,
      slotId: params.slotId,
      consultationFee: params.consultationFee,
      flatDiscount: params.flatDiscount,
      orderId: params.orderId,
    );
  }
}