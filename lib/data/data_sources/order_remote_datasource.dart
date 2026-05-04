import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required int pharmacyId,
    required String orderType,
    required List<File> prescriptionFiles,
    required String lang,
    required int addressId,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl(this.dioClient);

  @override

  @override
  Future<OrderModel> createOrder({
    required int pharmacyId,
    required String orderType,
    required List<File> prescriptionFiles,
    required String lang,
    required int addressId,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'pharmacy_id': pharmacyId,
        'order_type': orderType,
        'language': lang,
        'address_id': addressId,
      });

      // Add images under the key "image[]" (common for multiple files)
      for (int i = 0; i < prescriptionFiles.length; i++) {
        final file = prescriptionFiles[i];
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(file.path),
        ));
      }

      // Debug output
      print("📤 Order request fields:");
      print("   pharmacy_id: $pharmacyId");
      print("   order_type: $orderType");
      print("   lang: $lang");
      print("   address_id: $addressId");
      print("   number of image files: ${prescriptionFiles.length}");

      final response = await dioClient.dio.post(
        AppUrls.createPharmacyOrder,
        data: formData,
      );
      print("📥 Order response: ${response.data}");

      if (response.data['status'] == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Order failed');
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