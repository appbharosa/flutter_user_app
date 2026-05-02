import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';


class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call() async {
    return await repository.getProfile();
  }
}