import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../data_sources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans() async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final plans = await remoteDataSource.getSubscriptionPlans();
      return Right(plans);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserSubscription?>> getUserSubscription(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final subscription = await remoteDataSource.getUserSubscription(language);
      return Right(subscription);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}