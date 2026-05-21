import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_item.dart';



abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationItem>>> getNotifications(String language);
  Future<Either<Failure, int>> getUnreadCount(String language);
  Future<Either<Failure, void>> markAsRead(int notificationId, String language);
  Future<Either<Failure, void>> markAllAsRead(String language,int notificationId);
}