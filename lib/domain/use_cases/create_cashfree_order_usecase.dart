import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cashfree_order.dart';
import '../repositories/payment_repository.dart';


class CreateCashfreeOrderUseCase {
  final PaymentRepository repository;
  CreateCashfreeOrderUseCase(this.repository);
  Future<Either<Failure, CashfreeOrder>> call(int amount) async {
    return await repository.createOrder(amount);
  }
}