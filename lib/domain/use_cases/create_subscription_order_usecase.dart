import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/subscription_order.dart';
import '../repositories/subscription_payment_repository.dart';

class CreateSubscriptionOrderUseCase {
  final SubscriptionPaymentRepository repository;
  CreateSubscriptionOrderUseCase(this.repository);
  Future<Either<Failure, SubscriptionOrder>> call(int amount) async {
    return await repository.createOrder(amount);
  }
}