import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans();
}