import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/registration.dart';
import '../repositories/auth_repository.dart';

class RegisterUserParams {
  final Map<String, dynamic> userData;
  RegisterUserParams(this.userData);
}

class RegisterUserUseCase {
  final AuthRepository repository;
  RegisterUserUseCase(this.repository);
  Future<Either<Failure, Registration>> call(RegisterUserParams params) async {
    return await repository.registerUser(params.userData);
  }
}