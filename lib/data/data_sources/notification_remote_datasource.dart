import 'package:dio/dio.dart';
import '../../../../core/appurls/app_urls.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_item_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationItemModel>> getNotifications(String language);
  Future<int> getUnreadCount(String language);
  Future<void> markAsRead(int notificationId, String language);
  Future<void> markAllAsRead(String language,int notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;
  NotificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<NotificationItemModel>> getNotifications(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.notificationList,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        final List<dynamic> list = response.data['result']['notifications'] ?? [];
        return list.map((json) => NotificationItemModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> getUnreadCount(String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.notificationList,
        queryParameters: {'lang': language},
      );
      if (response.data['status'] == 200) {
        return response.data['result']['unread_count'] ?? 0;
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(int notificationId, String language) async {
    try {
      final response = await dioClient.dio.get(
        AppUrls.readNotifications,
        queryParameters: {
          'id': notificationId,
          'lang': language,
        },
      );
      if (response.data['status'] != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to mark as read');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAllAsRead(String language,int notificationId) async {
    try {
      final response = await dioClient.dio.post(
        AppUrls.readNotifications,
        queryParameters: {'lang': language},
        data: {'id': notificationId},
      );
      if (response.data['status'] != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to mark all as read');
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