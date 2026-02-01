import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/api/api_client.dart';
import '../datasources/calendar_remote_datasource.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../domain/entities/calendar_month_entity.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource remoteDataSource;

  CalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CalendarMonthEntity>> getCalendarMonth(
    int year,
    int month,
  ) async {
    try {
      final result = await remoteDataSource.getCalendarMonth(year, month);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
