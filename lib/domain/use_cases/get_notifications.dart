import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_item.dart';
import '../repositories/notification_repository.dart';


class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationItem>>> call(String language) async {
    return await repository.getNotifications(language);
  }
}