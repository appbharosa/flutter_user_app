import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/booking_response_model.dart';
// lib/data/datasources/lab_test_booking_remote_datasource.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/booking_response_model.dart';

abstract class LabTestBookingRemoteDataSource {
  Future<BookingResponseModel> bookLabTest({
    required int labTestId,
    required List<File> prescriptionFiles,
    required String lang,
    required int familyMemberId,
    // required int slotId,
    // required int packageId,
    // required int personsCount,
  });
}

class LabTestBookingRemoteDataSourceImpl implements LabTestBookingRemoteDataSource {
  final DioClient dioClient;
  LabTestBookingRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BookingResponseModel> bookLabTest({
    required int labTestId,
    required List<File> prescriptionFiles,
    required String lang,
    required int familyMemberId,
    // required int slotId,
    // required int packageId,
    // required int personsCount,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'lab_test_id': labTestId,
        'language': lang,
        'family_member_id': familyMemberId,
        // 'slot_id': slotId,
        // 'package_id': packageId,
        // 'persons_count': personsCount,
      });
      for (int i = 0; i < prescriptionFiles.length; i++) {
        final file = prescriptionFiles[i];
        formData.files.add(MapEntry(
          'image', // or 'prescription[]' – adjust as needed
          await MultipartFile.fromFile(file.path),
        ));
      }
      final response = await dioClient.dio.post(AppUrls.bookingLabTest, data: formData);
      if (response.data['status'] == 200) {
        return BookingResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Booking failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) return NetworkException();
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final message = e.response?.data['message'] ?? 'Server error';
    return ServerException(message);
  }
}