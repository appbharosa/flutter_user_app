import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/free_lab_package_model.dart';
import '../models/free_lab_slot_model.dart';

abstract class FreeLabRemoteDataSource {
  Future<List<FreeLabPackageModel>> getFreeLabPackages(String language);

  Future<FreeLabSlotResponseModel> getFreeLabSlots(
      String language,
      int packageId, {
        String? date, // optional named parameter
      });

  Future<List<FreeLabPackageModel>> getPackagesByCategoryId({
    required int categoryId,
    required String language,
  });
}

class FreeLabRemoteDataSourceImpl implements FreeLabRemoteDataSource {
  final DioClient dioClient;
  FreeLabRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<FreeLabPackageModel>> getFreeLabPackages(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.freeLab,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        final resultList = response.data['result'] as List;
        if (resultList.isNotEmpty) {
          final dataList = resultList[0]['data'] as List;
          // ✅ Return ALL packages (including id:1 and id:14)
          return dataList.map((json) => FreeLabPackageModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load packages');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FreeLabSlotResponseModel> getFreeLabSlots(
      String language,
      int packageId, {
        String? date,
      }) async {
    try {
      final queryParams = {
        'lang': language,
        'package_id': packageId,
      };
      // Add date only if provided
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final response = await dioClient.dio.get(
        AppUrls.freeLabBooking,
        queryParameters: queryParams,
      );
      if (response.data['status'] == 200) {
        return FreeLabSlotResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load slots');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<FreeLabPackageModel>> getPackagesByCategoryId({
    required int categoryId,
    required String language,
  }) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.freeLabSubCategory,
        queryParameters: {
          'lang': language,
          'category_id': categoryId,
        },
      );
      if (response.data['status'] == 200) {
        final result = response.data['result'];
        // If result is not a List (e.g., empty object), return empty list
        if (result is! List || result.isEmpty) {
          return [];
        }
        final paginationMap = result[0] as Map<String, dynamic>;
        final dataList = paginationMap['data'] as List? ?? [];
        return dataList.map((json) => FreeLabPackageModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load packages');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
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