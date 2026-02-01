import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_month_entity.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final CalendarMonthEntity monthData;

  const CalendarLoaded({required this.monthData});

  @override
  List<Object?> get props => [monthData];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError({required this.message});

  @override
  List<Object?> get props => [message];
}
