import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/add_family_member_response.dart';
import '../entities/add_family_member_request.dart';
import '../repositories/family_repository.dart';

class AddFamilyMemberUseCase {
  final FamilyRepository repository;
  AddFamilyMemberUseCase(this.repository);

  Future<Either<Failure, AddFamilyMemberResponse>> call(AddFamilyMemberRequest request) async => await repository.addFamilyMember(request);
}