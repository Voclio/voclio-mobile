import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:voclio_app/features/dashboard/domain/entities/quick_stats_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats() async {
    try {
      final model = await remoteDataSource.getDashboardStats();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, QuickStatsEntity>> getQuickStats() async {
    try {
      final model = await remoteDataSource.getQuickStats();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
