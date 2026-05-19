
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ecard.dart';
import '../repositories/ecard_repository.dart';

class GetECardUseCase {
  final ECardRepository repository;
  GetECardUseCase(this.repository);

  Future<Either<Failure, ECard>> call(String language) async {
    return await repository.getECard(language);
  }
}