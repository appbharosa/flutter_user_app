import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> call(int notificationId, String language) async {
    return await repository.markAsRead(notificationId, language);
  }
}

