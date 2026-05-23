import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';

abstract class CoverageCategoryRemoteDataSource {
  Future<List<Map<String, dynamic>>> getCoverageCategories(String language);
}

class CoverageCategoryRemoteDataSourceImpl implements CoverageCategoryRemoteDataSource {
  final DioClient dioClient;

  CoverageCategoryRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<Map<String, dynamic>>> getCoverageCategories(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.coverageCategory,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        final List<dynamic> result = response.data['result'];
        return result.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load categories');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}