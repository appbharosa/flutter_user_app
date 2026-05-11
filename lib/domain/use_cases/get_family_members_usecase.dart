import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/family_member.dart';
import '../repositories/family_member_repository.dart';

class GetFamilyMembersUseCase {
  final FamilyMemberRepository repository;
  GetFamilyMembersUseCase(this.repository);
  Future<Either<Failure, List<FamilyMember>>> call() async {
    return await repository.getFamilyMembers();
  }
}