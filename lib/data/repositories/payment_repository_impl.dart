import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cashfree_order.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/repositories/payment_repository.dart';
import '../data_sources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, CashfreeOrder>> createOrder(int amount) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final order = await remoteDataSource.createOrder(amount);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentStatus>> checkStatus(String orderId) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final status = await remoteDataSource.checkStatus(orderId);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getWallet() async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final balanceModel = await remoteDataSource.getWallet();
      return Right(balanceModel.walletAmount);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}