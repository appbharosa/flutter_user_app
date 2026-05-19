
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ecard.dart';

abstract class ECardRepository {
  Future<Either<Failure, ECard>> getECard(String language);
}