import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/banner.dart';

abstract class BannerRepository {
  Future<Either<Failure, List<Banner>>> getBanners();
}