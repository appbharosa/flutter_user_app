import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/repositories/family_member_repository.dart';
import '../data_sources/family_member_remote_datasource.dart';

class FamilyMemberRepositoryImpl implements FamilyMemberRepository {
  final FamilyMemberRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  FamilyMemberRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<FamilyMember>>> getFamilyMembers() async {
    if (!(await networkInfo.isConnected)) return Left(NetworkFailure());
    try {
      final members = await remoteDataSource.getFamilyMembers();
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}