
import 'package:dio/dio.dart';

import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/add_family_member_response.dart';

abstract class FamilyRemoteDataSource {
  Future<AddFamilyMemberResponse> addFamilyMember(Map<String, dynamic> data);
}

class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  final DioClient dioClient;
  FamilyRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AddFamilyMemberResponse> addFamilyMember(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.post(AppUrls.addFamily, data: data);
      if (response.data['status'] == 200) {
        return AddFamilyMemberResponse.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to add family member');
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