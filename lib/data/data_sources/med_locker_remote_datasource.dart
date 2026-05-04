import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/med_locker_model.dart';

abstract class MedLockerRemoteDataSource {
  Future<List<MedLockerModel>> getMedLockers();
  Future<MedLockerModel> getMedLockerDetail(int id);
  Future<MedLockerModel> addMedLocker(String name, List<File> images);
}

class MedLockerRemoteDataSourceImpl implements MedLockerRemoteDataSource {
  final DioClient dioClient;

  MedLockerRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<MedLockerModel>> getMedLockers() async {
    try {
      final response = await dioClient.dio.get(AppUrls.medLockerList);
      if (response.data['status'] == 200) {
        final resultData = response.data['result'];
        if (resultData is! List || resultData.isEmpty) return [];
        return resultData.map((json) => MedLockerModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load med lockers');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MedLockerModel> getMedLockerDetail(int id) async {
    try {
      final response = await dioClient.dio.get('${AppUrls.medLockerShow}$id');
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        return MedLockerModel.fromJson(result);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load detail');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<MedLockerModel> addMedLocker(String name, List<File> images) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'images[]': images.map((file) => MultipartFile.fromFileSync(file.path)).toList(),
      });
      final response = await dioClient.dio.post(AppUrls.medLockerAdd, data: formData);
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        return MedLockerModel.fromJson(result);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to add med locker');
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