import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(Map<String, dynamic> updatedData) async {
    return await repository.updateProfile(updatedData);
  }
}