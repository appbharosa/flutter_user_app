import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_plan.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPlansUseCase {
  final SubscriptionRepository repository;
  GetSubscriptionPlansUseCase(this.repository);
  Future<Either<Failure, List<SubscriptionPlan>>> call() async {
    return await repository.getSubscriptionPlans();
  }
}