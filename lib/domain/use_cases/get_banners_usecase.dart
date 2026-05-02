import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/banner.dart';
import '../repositories/banner_repository.dart';

class GetBannersUseCase {
  final BannerRepository repository;

  GetBannersUseCase(this.repository);

  Future<Either<Failure, List<Banner>>> call() async {
    return await repository.getBanners();
  }
}