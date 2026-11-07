import 'package:flutter/material.dart';

enum EventCategory {
  study('Учёба', Color(0xFFFFA000)),
  work('Работа', Color(0xFF7EA9F8)),
  personal('Личное', Color(0xFF9DCEAE)),
  other('Другое', Color(0xFFB8A0DA));

  const EventCategory(this.label, this.color);

  final String label;
  final Color color;
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.category,
    this.endTime,
  });

  final int id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final EventCategory category;
}
