import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_order.dart';
import '../repositories/subscription_payment_repository.dart';


class SubmitSubscriptionUseCase {
  final SubscriptionPaymentRepository repository;
  SubmitSubscriptionUseCase(this.repository);
  Future<Either<Failure, void>> call(String orderId, int subscriptionId) async {
    return await repository.submitSubscription(orderId, subscriptionId);
  }
}