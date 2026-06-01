import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_subscription.dart';
import '../repositories/subscription_repository.dart';

class GetUserSubscriptionUseCase {
  final SubscriptionRepository repository;
  GetUserSubscriptionUseCase(this.repository);

  Future<Either<Failure, UserSubscription?>> call(String language) async {
    return await repository.getUserSubscription(language);
  }
}