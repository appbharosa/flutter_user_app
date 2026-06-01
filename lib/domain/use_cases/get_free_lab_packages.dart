import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/free_lab_package.dart';
import '../repositories/free_lab_repository.dart';

class GetFreeLabPackagesUseCase {
  final FreeLabRepository repository;
  GetFreeLabPackagesUseCase(this.repository);

  Future<Either<Failure, List<FreeLabPackage>>> call(String language) async {
    return await repository.getFreeLabPackages(language);
  }
}