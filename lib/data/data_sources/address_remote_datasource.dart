import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses({required String lang});
  Future<AddressModel> addAddress(Map<String, dynamic> addressData, {required String lang});
// Future<void> setDefaultAddress(int addressId, {required String lang});
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioClient dioClient;

  AddressRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<AddressModel>> getAddresses({required String lang}) async {
    try {
      final queryParams = {'lang': lang}; // Add language to query params
      final response = await dioClient.dio.get(
        AppUrls.addressList,
        queryParameters: queryParams,
      );
      if (response.data['status'] == 200) {
        final List list = response.data['result'];
        return list.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load addresses');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AddressModel> addAddress(Map<String, dynamic> addressData, {required String lang}) async {
    try {
      // Add lang to the request body or as query param – here we add to query params
      final queryParams = {'lang': lang};
      final response = await dioClient.dio.post(
        AppUrls.postAddress,
        data: addressData,
        queryParameters: queryParams,
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        if (result == null || result is! Map<String, dynamic> || result.isEmpty) {
          return AddressModel(
            id: DateTime.now().millisecondsSinceEpoch,
            address: addressData['address'] ?? '',
            hno: addressData['hno'],
            buildingNo: addressData['building_no'],
            landmark: addressData['landmark'],
            lat: addressData['lat'] ?? '0.0',
            lon: addressData['lon'] ?? '0.0',
            addressType: addressData['address_type'] ?? '',
            pincode: addressData['pincode'] ?? '',
            state: addressData['state'] ?? '',
            city: addressData['city'] ?? '',
            isDefault: false,
          );
        }
        return AddressModel.fromJson(result);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to add address');
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