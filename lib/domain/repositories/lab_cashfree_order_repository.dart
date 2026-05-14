import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cashfree_order.dart';


abstract class LabCashfreeOrderRepository {
  Future<Either<Failure, CashfreeOrder>> createOrder(double amount);
}
