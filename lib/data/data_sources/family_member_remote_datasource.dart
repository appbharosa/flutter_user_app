import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/family_member_model.dart';

abstract class FamilyMemberRemoteDataSource {
  Future<List<FamilyMemberModel>> getFamilyMembers();
}

class FamilyMemberRemoteDataSourceImpl implements FamilyMemberRemoteDataSource {
  final DioClient dioClient;
  FamilyMemberRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<FamilyMemberModel>> getFamilyMembers() async {
    try {
      final response = await dioClient.dio.get(AppUrls.chooseFamilyMember);
      if (response.data['status'] == 200) {
        final List list = response.data['result'];
        return list.map((json) => FamilyMemberModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load family members');
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