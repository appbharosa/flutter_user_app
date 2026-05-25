import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/dashboard_banner.dart';

abstract class BannerRepository {
  Future<Either<Failure, List<DashboardBanner>>> getBanners();
}