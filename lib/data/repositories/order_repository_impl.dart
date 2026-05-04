import 'dart:io';
import 'package:dartz/dartz.dart' hide Order;
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../data_sources/order_remote_datasource.dart';


class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, Order>> createOrder({
    required int pharmacyId,
    required String orderType,
    required List<String> prescriptionPaths,
    required String lang,
    required int addressId,
  }) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final files = prescriptionPaths.map((path) => File(path)).toList();
      final order = await remoteDataSource.createOrder(
        pharmacyId: pharmacyId,
        orderType: orderType,
        prescriptionFiles: files,
        lang: lang,
        addressId: addressId,
      );
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