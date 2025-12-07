import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/dashboard/domain/entities/quick_stats_entity.dart';
import 'package:voclio_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetQuickStatsUseCase {
  final DashboardRepository repository;

  GetQuickStatsUseCase(this.repository);

  Future<Either<Failure, QuickStatsEntity>> call() async {
    return await repository.getQuickStats();
  }
}
