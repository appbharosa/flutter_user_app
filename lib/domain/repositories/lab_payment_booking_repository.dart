import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/lab_payment_booking_response.dart';



abstract class LabPaymentBookingRepository {
  Future<Either<Failure, LabPaymentBookingResponse>> book({
    required int labTestId,
    required int testId,
    required int addressId,
    required int count,
    required double fee,
    required String date,
    required String time,
    required int familyMemberId,   // ✅ single integer
    int? couponId,
    required String paymentType,
    required List<String> prescriptionPaths,
    required int slotId,
    double consultationFee,
    double flatDiscount,
    String? orderId,
  });
}