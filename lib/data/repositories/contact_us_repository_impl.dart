import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/contact_us_response.dart';
import '../../domain/repositories/contact_us_repository.dart';
import '../data_sources/contact_us_remote_datasource.dart';

class ContactUsRepositoryImpl implements ContactUsRepository {
  final ContactUsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ContactUsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, ContactUsResponse>> submitContactUs({
    required int userId,
    required String name,
    required String email,
    required String mobile,
    required String message,
  }) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.submitContactUs(
        userId: userId,
        name: name,
        email: email,
        mobile: mobile,
        message: message,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}