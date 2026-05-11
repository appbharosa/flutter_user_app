import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_order.dart';

abstract class SubscriptionPaymentRepository {
  Future<Either<Failure, SubscriptionOrder>> createOrder(int amount);
  Future<Either<Failure, void>> submitSubscription(String orderId, int subscriptionId);
}