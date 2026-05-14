import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cashfree_order.dart';
import '../repositories/lab_cashfree_order_repository.dart'; // your existing entity


class CreateLabCashfreeOrderUseCase {
  final LabCashfreeOrderRepository repository;
  CreateLabCashfreeOrderUseCase(this.repository);
  Future<Either<Failure, CashfreeOrder>> call(double amount) async {
    return await repository.createOrder(amount);
  }
}