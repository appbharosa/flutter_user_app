import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';



abstract class MedicineBookingRemoteDataSource {
  Future<String> bookMedicine({
    required int mainDataId,
    required String orderType,
    required int addressId,
    required List<String> imagePaths,
  });
}

class MedicineBookingRemoteDataSourceImpl implements MedicineBookingRemoteDataSource {
  final DioClient dioClient;
  MedicineBookingRemoteDataSourceImpl(this.dioClient);

  @override
  Future<String> bookMedicine({
    required int mainDataId,
    required String orderType,
    required int addressId,
    required List<String> imagePaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        'main_data_id': mainDataId,
        'order_type': orderType,
        'address_id': addressId,
        'language':"en"
      });

      // 🔹 Add each prescription image with the key 'image' (singular)
      for (final path in imagePaths) {
        final file = File(path);
        formData.files.add(MapEntry(
          'image',   // ✅ use 'image' (singular) – change to 'image[]' if backend expects array
          await MultipartFile.fromFile(file.path),
        ));
      }

      final response = await dioClient.dio.post(
        AppUrls.hospitalMedicineBooking,
        data: formData,
      );

      if (response.data['status'] == 200) {
        return response.data['message'] ?? 'Booking successful';
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