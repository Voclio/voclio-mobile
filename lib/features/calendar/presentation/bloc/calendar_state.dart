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
  final WebexStatusEntity? webexStatus;
  final List<GoogleCalendarEventEntity> todayMeetings;
  final List<WebexMeetingEntity> todayWebexMeetings;

  const CalendarLoaded({
    required this.monthData,
    this.googleStatus,
    this.webexStatus,
    this.todayMeetings = const [],
    this.todayWebexMeetings = const [],
  });

  @override
  List<Object?> get props => [monthData, googleStatus, webexStatus, todayMeetings, todayWebexMeetings];
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

// Webex specific states
class WebexConnecting extends CalendarState {}

class WebexConnected extends CalendarState {
  final String message;
  
  const WebexConnected({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class WebexDisconnected extends CalendarState {}
