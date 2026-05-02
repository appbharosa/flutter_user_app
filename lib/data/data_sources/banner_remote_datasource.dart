import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/banner_model.dart';

abstract class BannerRemoteDataSource {
  Future<List<BannerModel>> getBanners();
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final DioClient dioClient;

  BannerRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await dioClient.dio.get(AppUrls.banners);
      if (response.data['status'] == true) {
        final bannersJson = response.data['response']['banners'] as List;
        return bannersJson
            .map((json) => BannerModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load banners');
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