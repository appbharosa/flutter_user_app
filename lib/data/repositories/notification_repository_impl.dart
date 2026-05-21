import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_sources/notification_remote_datasource.dart';



class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<NotificationItem>>> getNotifications(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final notifications = await remoteDataSource.getNotifications(language);
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final count = await remoteDataSource.getUnreadCount(language);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId, String language) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      await remoteDataSource.markAsRead(notificationId, language);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String language,int notificationId) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      await remoteDataSource.markAllAsRead(language,notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}