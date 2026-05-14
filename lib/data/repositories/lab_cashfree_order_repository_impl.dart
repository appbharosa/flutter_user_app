import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cashfree_order.dart';
import '../../domain/repositories/lab_cashfree_order_repository.dart';
import '../data_sources/lab_cashfree_order_remote_datasource.dart';

class LabCashfreeOrderRepositoryImpl implements LabCashfreeOrderRepository {
  final LabCashfreeOrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  LabCashfreeOrderRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, CashfreeOrder>> createOrder(double amount) async {
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
}