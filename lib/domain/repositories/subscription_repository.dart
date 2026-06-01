import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_plan.dart';
import '../entities/user_subscription.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans();
  Future<Either<Failure, UserSubscription?>> getUserSubscription(String language);

}