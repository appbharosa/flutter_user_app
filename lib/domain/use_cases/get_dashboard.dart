import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository repository;
  GetDashboardUseCase(this.repository);

  Future<Either<Failure, Dashboard>> call(String language) async {
    return await repository.getDashboard(language);
  }
}