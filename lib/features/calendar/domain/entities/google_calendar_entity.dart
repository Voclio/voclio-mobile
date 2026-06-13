import 'package:equatable/equatable.dart';

/// Google Calendar connection status
class GoogleCalendarStatusEntity extends Equatable {
  final bool connected;
  final bool syncEnabled;
  final String syncStatus;
  final String? calendarName;
  final DateTime? lastSyncAt;
  final String? errorMessage;

  const GoogleCalendarStatusEntity({
    required this.connected,
    required this.syncEnabled,
    required this.syncStatus,
    this.calendarName,
    this.lastSyncAt,
    this.errorMessage,
  });

  /// Convenience getter for checking connection status
  bool get isConnected => connected;

  @override
  List<Object?> get props => [
    connected,
    syncEnabled,
    syncStatus,
    calendarName,
    lastSyncAt,
    errorMessage,
  ];
}

/// Google Calendar event/meeting
class GoogleCalendarEventEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final List<String> attendees;
  final String? htmlLink;
  final String? meetLink;
  final bool isAllDay;
  final String? colorId;

  const GoogleCalendarEventEntity({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.attendees = const [],
    this.htmlLink,
    this.meetLink,
    this.isAllDay = false,
    this.colorId,
  });

  /// Check if this event is happening now
  bool get isHappeningNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if this event has already ended
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Duration of the event
  Duration get duration => endTime.difference(startTime);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
    attendees,
    htmlLink,
    meetLink,
    isAllDay,
    colorId,
  ];
}

/// OAuth URL response
class GoogleOAuthUrlEntity extends Equatable {
  final String authUrl;
  final String message;

  const GoogleOAuthUrlEntity({required this.authUrl, required this.message});

  @override
  List<Object?> get props => [authUrl, message];
}
