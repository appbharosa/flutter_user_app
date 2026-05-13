import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/lab_slots_response_model.dart';



abstract class LabSlotRemoteDataSource {
  Future<LabSlotsResponseModel> getSlots(String date);
}

class LabSlotRemoteDataSourceImpl implements LabSlotRemoteDataSource {
  final DioClient dioClient;
  LabSlotRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LabSlotsResponseModel> getSlots(String date) async {
    try {
      print("🌐 Fetching slots for date: $date");
      final response = await dioClient.dio.get(
        AppUrls.labSlotBooking,
        queryParameters: {'date': date},
      );
      print("📥 Slots response status: ${response.statusCode}, body: ${response.data}");
      if (response.data['status'] == 200) {
        return LabSlotsResponseModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load slots');
      }
    } on DioException catch (e) {
      print("❌ Dio error: ${e.message}");
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