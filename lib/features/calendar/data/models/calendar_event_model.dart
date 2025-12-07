import '../../domain/entities/calendar_event_entity.dart';

class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String color;
  final bool isAllDay;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.color,
    required this.isAllDay,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['event_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : DateTime.now(),
      endTime:
          json['end_time'] != null
              ? DateTime.parse(json['end_time'])
              : DateTime.now(),
      location: json['location'],
      color: json['color'] ?? '#3498db',
      isAllDay: json['is_all_day'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      if (location != null) 'location': location,
      'color': color,
      'is_all_day': isAllDay,
    };
  }

  CalendarEventEntity toEntity() {
    return CalendarEventEntity(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      color: color,
      isAllDay: isAllDay,
    );
  }
}
