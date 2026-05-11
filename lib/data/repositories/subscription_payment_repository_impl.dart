import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/subscription_order.dart';
import '../../domain/repositories/subscription_payment_repository.dart';
import '../data_sources/subscription_payment_remote_datasource.dart';

class SubscriptionPaymentRepositoryImpl implements SubscriptionPaymentRepository {
  final SubscriptionPaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubscriptionPaymentRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, SubscriptionOrder>> createOrder(int amount) async {
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
  Future<Either<Failure, void>> submitSubscription(String orderId, int subscriptionId) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      await remoteDataSource.submitSubscription(orderId, subscriptionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}