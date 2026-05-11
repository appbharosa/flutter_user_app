import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/family_member.dart';

abstract class FamilyMemberRepository {
  Future<Either<Failure, List<FamilyMember>>> getFamilyMembers();
}