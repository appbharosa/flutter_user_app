import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/booking_response_model.dart';

abstract class DiagnosticBookingRemoteDataSource {
  Future<BookingResponseModel> bookDiagnostic({
    required int diagnosticId,
    required List<File> prescriptionFiles,
    required String lang,
    required int familyMemberId,
  });
}

class DiagnosticBookingRemoteDataSourceImpl implements DiagnosticBookingRemoteDataSource {
  final DioClient dioClient;
  DiagnosticBookingRemoteDataSourceImpl(this.dioClient);

  @override

  Future<BookingResponseModel> bookDiagnostic({
    required int diagnosticId,
    required List<File> prescriptionFiles,
    required String lang,
    required int familyMemberId,
  }) async {
    try {
      print("🚀 BOOKING REQUEST:");
      print("   diagnostic_id: $diagnosticId (${diagnosticId.runtimeType})");
      print("   language: $lang");
      print("   family_member_id: $familyMemberId (${familyMemberId.runtimeType})");
      print("   files count: ${prescriptionFiles.length}");

      FormData formData = FormData.fromMap({
        'diagnostic_id': diagnosticId,
        'language': lang,
        'family_member_id': familyMemberId,
      });

      // Send each file under the key "image" (same key for all)
      for (int i = 0; i < prescriptionFiles.length; i++) {
        final file = prescriptionFiles[i];
        formData.files.add(MapEntry(
          'image',  // ✅ as requested: send as 'image'
          await MultipartFile.fromFile(file.path),
        ));
      }

      final response = await dioClient.dio.post(AppUrls.diagnosticBooking, data: formData);
      print("📥 BOOKING RESPONSE:");
      print("   status: ${response.statusCode}");
      print("   body: ${response.data}");

      if (response.data['status'] == 200) {
        return BookingResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Booking failed');
      }
    } on DioException catch (e) {
      print("❌ DIO ERROR: ${e.message}");
      if (e.response != null) {
        print("   response data: ${e.response?.data}");
      }
      throw _handleDioError(e);
    } catch (e) {
      print("❌ UNEXPECTED ERROR: $e");
      rethrow;
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