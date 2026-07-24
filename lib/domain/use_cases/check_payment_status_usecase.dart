import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/payment_status.dart';
import '../repositories/payment_repository.dart';


class CheckPaymentStatusUseCase {
  final PaymentRepository repository;
  CheckPaymentStatusUseCase(this.repository);
  Future<Either<Failure, PaymentStatus>> call(String orderId) async {
    return await repository.checkStatus(orderId);
  }
}

class GetWalletBalanceUseCase {
  final PaymentRepository repository;

  GetWalletBalanceUseCase(this.repository);

  Future<Either<Failure, double>> call() async {
    return await repository.getWallet();
  }
}