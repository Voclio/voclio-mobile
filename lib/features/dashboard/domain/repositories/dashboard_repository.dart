import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:voclio_app/features/dashboard/domain/entities/quick_stats_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats();
  Future<Either<Failure, QuickStatsEntity>> getQuickStats();
}
