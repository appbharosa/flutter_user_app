import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;
  MarkAllNotificationsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String language,int notificationId) async {
    return await repository.markAllAsRead(language,notificationId);
  }
}