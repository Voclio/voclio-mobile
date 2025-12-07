import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:voclio_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<Either<Failure, DashboardStatsEntity>> call() async {
    return await repository.getDashboardStats();
  }
}
