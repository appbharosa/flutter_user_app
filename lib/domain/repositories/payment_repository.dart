import 'package:dartz/dartz.dart';
import 'package:user/domain/entities/cashfree_order.dart';
import '../../core/errors/failures.dart';
import '../entities/payment_status.dart';


abstract class PaymentRepository {
  Future<Either<Failure, CashfreeOrder>> createOrder(int amount);
  Future<Either<Failure, PaymentStatus>> checkStatus(String orderId);
  Future<Either<Failure, double>> getWallet(); // ✅ NEW
}