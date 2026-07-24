import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../data_sources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Address>>> getAddresses({required String lang}) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final addresses = await remoteDataSource.getAddresses(lang: lang);
      return Right(addresses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Address>> addAddress(Map<String, dynamic> addressData, {required String lang}) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final address = await remoteDataSource.addAddress(addressData, lang: lang);
      return Right(address);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}