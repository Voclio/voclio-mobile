import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/entities/google_calendar_entity.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final CalendarMonthEntity monthData;
  final GoogleCalendarStatusEntity? googleStatus;
  final List<GoogleCalendarEventEntity> todayMeetings;

  const CalendarLoaded({
    required this.monthData,
    this.googleStatus,
    this.todayMeetings = const [],
  });

  @override
  List<Object?> get props => [monthData, googleStatus, todayMeetings];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Google Calendar specific states
class GoogleCalendarConnecting extends CalendarState {}

class GoogleCalendarConnected extends CalendarState {
  final String message;

  const GoogleCalendarConnected({required this.message});

  @override
  List<Object?> get props => [message];
}

class GoogleCalendarDisconnected extends CalendarState {}

class GoogleOAuthUrlLoaded extends CalendarState {
  final GoogleOAuthUrlEntity oauthUrl;

  const GoogleOAuthUrlLoaded({required this.oauthUrl});

  @override
  List<Object?> get props => [oauthUrl];
}
