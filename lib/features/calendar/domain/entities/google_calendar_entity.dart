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

  const GoogleOAuthUrlEntity({
    required this.authUrl,
    required this.message,
  });

  @override
  List<Object?> get props => [authUrl, message];
}

// ========== Webex Calendar Entities ==========

/// Webex Calendar connection status
class WebexStatusEntity extends Equatable {
  final bool connected;
  final String? email;
  final String? displayName;
  final DateTime? connectedAt;
  final String? errorMessage;

  const WebexStatusEntity({
    required this.connected,
    this.email,
    this.displayName,
    this.connectedAt,
    this.errorMessage,
  });

  /// Convenience getter for checking connection status
  bool get isConnected => connected;

  @override
  List<Object?> get props => [connected, email, displayName, connectedAt, errorMessage];
}

/// Webex meeting entity
class WebexMeetingEntity extends Equatable {
  final String id;
  final String title;
  final String? agenda;
  final DateTime startTime;
  final DateTime endTime;
  final String? timezone;
  final String? webLink;
  final String? sipAddress;
  final String? meetingNumber;
  final String? password;
  final String? hostEmail;
  final bool isRecurring;

  const WebexMeetingEntity({
    required this.id,
    required this.title,
    this.agenda,
    required this.startTime,
    required this.endTime,
    this.timezone,
    this.webLink,
    this.sipAddress,
    this.meetingNumber,
    this.password,
    this.hostEmail,
    this.isRecurring = false,
  });

  /// Check if this meeting is happening now
  bool get isHappeningNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if this meeting has already ended
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Duration of the meeting
  Duration get duration => endTime.difference(startTime);

  @override
  List<Object?> get props => [
    id,
    title,
    agenda,
    startTime,
    endTime,
    timezone,
    webLink,
    sipAddress,
    meetingNumber,
    password,
    hostEmail,
    isRecurring,
  ];
}
