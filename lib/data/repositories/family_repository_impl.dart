import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/add_family_member_request.dart';
import '../../domain/repositories/family_repository.dart';
import '../data_sources/family_remote_datasource.dart';
import '../models/add_family_member_response.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FamilyRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, AddFamilyMemberResponse>> addFamilyMember(AddFamilyMemberRequest request) async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final response = await remoteDataSource.addFamilyMember(request.toJson());
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