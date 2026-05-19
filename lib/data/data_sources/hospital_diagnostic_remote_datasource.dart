import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/hospital_diagnostic_booking.dart';

abstract class HospitalDiagnosticRemoteDataSource {
  Future<String> bookDiagnostic(HospitalDiagnosticBooking booking);
}

class HospitalDiagnosticRemoteDataSourceImpl implements HospitalDiagnosticRemoteDataSource {
  final DioClient dioClient;
  HospitalDiagnosticRemoteDataSourceImpl(this.dioClient);

  @override
  Future<String> bookDiagnostic(HospitalDiagnosticBooking booking) async {
    try {
      final formData = FormData.fromMap({
        'main_data_id': booking.mainDataId,
        'address_id': booking.addressId,
        'family_member_id': booking.familyMemberId,
        'language': booking.language,
      });

      for (final path in booking.imagePaths) {
        final file = File(path);
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(file.path),
        ));
      }

      final response = await dioClient.dio.post(
        AppUrls.hospitalDiagnosticBooking,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.data['status'] == 200) {
        return response.data['message'] ?? 'Diagnostic booking successful';
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
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final message = e.response?.data['message'] ?? 'Server error';
    return ServerException(message);
  }
}