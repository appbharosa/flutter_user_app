import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/lab_payment_booking_response_model.dart';




abstract class LabPaymentBookingRemoteDataSource {
  Future<LabPaymentBookingResponseModel> book({
    required int labTestId,
    required int testId,
    required int addressId,
    required int count,
    required double fee,
    required String date,
    required String time,
    required int familyMemberId,
    int? couponId,
    required String paymentType,
    required List<File> prescriptionFiles,
    required int slotId,
    double consultationFee,
    double flatDiscount,
    String? orderId,
  });
}

class LabPaymentBookingRemoteDataSourceImpl implements LabPaymentBookingRemoteDataSource {
  final DioClient dioClient;
  LabPaymentBookingRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LabPaymentBookingResponseModel> book({
    required int labTestId,
    required int testId,
    required int addressId,
    required int count,
    required double fee,
    required String date,
    required String time,
    required int familyMemberId,
    int? couponId,
    required String paymentType,
    required List<File> prescriptionFiles,
    required int slotId,
    double consultationFee = 0,
    double flatDiscount = 0,
    String? orderId,
  }) async {
    try {
      // Build form data fields
      final Map<String, dynamic> fields = {
        'lab_test_id': labTestId,
        'test_id': testId,
        'address_id': addressId,
        'count': count,
        'fee': fee,
        'date': date,
        'time': time,
        'family_member_id': familyMemberId,   // ✅ single integer
        'payment_type': paymentType,
        'slot_id': slotId,
        'consultation_fee': consultationFee,
        'flat_discount': flatDiscount,
      };
      if (orderId != null && orderId.isNotEmpty) fields['order_id'] = orderId;
      if (couponId != null) fields['coupon_id'] = couponId;

      FormData formData = FormData.fromMap(fields);

      // Add prescription files as multipart files
      for (final file in prescriptionFiles) {
        formData.files.add(MapEntry(
          'image',                     // ✅ single field name 'image'
          await MultipartFile.fromFile(file.path),
        ));
      }

      // Debug prints
      print("📤 Booking request fields:");
      for (var field in formData.fields) {
        print("  ${field.key}: ${field.value} (${field.value.runtimeType})");
      }
      print("📤 Files:");
      for (var fileEntry in formData.files) {
        print("  ${fileEntry.key}: ${fileEntry.value.filename}");
      }

      final response = await dioClient.dio.post(
        AppUrls.labTestBookingWithPayment,
        data: formData,
      );
      print("📥 Booking response: ${response.data}");

      if (response.data['status'] == 200) {
        return LabPaymentBookingResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Booking failed');
      }
    } on DioException catch (e) {
      print("❌ Dio error: ${e.message}");
      if (e.response?.data != null) print("   Response data: ${e.response?.data}");
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final message = e.response?.data['message'] ?? 'Server error';
    return ServerException(message);
  }
}