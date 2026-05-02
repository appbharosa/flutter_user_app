import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/about.dart';
import '../repositories/about_repository.dart';

class GetAboutUseCase {
  final AboutRepository repository;

  GetAboutUseCase(this.repository);

  Future<Either<Failure, About>> call() async {
    return await repository.getAbout();
  }
}