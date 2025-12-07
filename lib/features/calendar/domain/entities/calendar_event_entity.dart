import 'package:equatable/equatable.dart';

class CalendarEventEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String color;
  final bool isAllDay;

  const CalendarEventEntity({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.color,
    required this.isAllDay,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
    color,
    isAllDay,
  ];
}
