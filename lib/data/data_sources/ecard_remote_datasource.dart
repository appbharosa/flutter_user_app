import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ecard_model.dart';

abstract class ECardRemoteDataSource {
  Future<ECardModel> getECard(String language);
}

class ECardRemoteDataSourceImpl implements ECardRemoteDataSource {
  final DioClient dioClient;
  ECardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ECardModel> getECard(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.eCard,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        return ECardModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load eCard');
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