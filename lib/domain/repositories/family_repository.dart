
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/add_family_member_response.dart';
import '../entities/add_family_member_request.dart';

abstract class FamilyRepository {
  Future<Either<Failure, AddFamilyMemberResponse>> addFamilyMember(AddFamilyMemberRequest request);
}