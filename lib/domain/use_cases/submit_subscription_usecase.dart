import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_order.dart';
import '../repositories/subscription_payment_repository.dart';
class SubmitSubscriptionUseCase {
  final SubscriptionPaymentRepository repository;
  SubmitSubscriptionUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId, int subscriptionId) async {
    debugPrint("🔵 SubmitSubscriptionUseCase - orderId: $orderId, subscriptionId: $subscriptionId");
    if (orderId.isEmpty) {
      return Left(ServerFailure("Order ID is empty"));
    }
    if (subscriptionId == 0) {
      return Left(ServerFailure("Subscription ID is invalid"));
    }
    return await repository.submitSubscription(orderId, subscriptionId);
  }
}