import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/calendar_repository.dart';
import '../entities/calendar_month_entity.dart';

class GetCalendarMonthUseCase {
  final CalendarRepository repository;

  GetCalendarMonthUseCase({required this.repository});

  Future<Either<Failure, CalendarMonthEntity>> call(int year, int month) {
    return repository.getCalendarMonth(year, month);
  }
}
