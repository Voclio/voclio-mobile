import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/calendar_month_entity.dart';

abstract class CalendarRepository {
  Future<Either<Failure, CalendarMonthEntity>> getCalendarMonth(
    int year,
    int month,
  );
}
