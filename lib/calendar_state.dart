import 'package:flutter/material.dart';

import 'data/event_repository.dart';
import 'models/calendar_event.dart';
import 'utils/date_time_utils.dart';

class CalendarState {
  CalendarState() {
    _today = DateUtils.dateOnly(DateTime.now());
    _selectedDate = _today;
    _displayedMonth = DateTime(_today.year, _today.month);
  }

  final _repository = EventRepository();
  int _nextId = 1;
  late DateTime _today;
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  DateTime get today => _today;
  DateTime get selectedDate => _selectedDate;
  DateTime get displayedMonth => _displayedMonth;

  List<CalendarEvent> get selectedEvents {
    final events = _repository.events
        .where((event) => DateUtils.isSameDay(event.date, _selectedDate))
        .toList();
    events.sort((a, b) {
      final startA = timeInMinutes(a.startTime);
      final startB = timeInMinutes(b.startTime);
      final order = startA.compareTo(startB);
      if (order != 0) {
        return order;
      }
      return a.id.compareTo(b.id);
    });
    return events;
  }

  Set<EventCategory> categoriesForDate(DateTime date) {
    final categories = <EventCategory>{};
    for (final event in _repository.events) {
      if (DateUtils.isSameDay(event.date, date)) {
        categories.add(event.category);
      }
    }
    return categories;
  }

  void refreshToday() {
    _today = DateUtils.dateOnly(DateTime.now());
  }

  void selectDate(DateTime date) {
    if (!isCalendarDateSupported(date) ||
        DateUtils.isSameDay(date, _selectedDate)) {
      return;
    }
    _selectedDate = DateUtils.dateOnly(date);
    _displayedMonth = DateTime(date.year, date.month);
  }

  bool canChangeMonth(int step) {
    final month = DateTime(_displayedMonth.year, _displayedMonth.month + step);
    return isCalendarDateSupported(month);
  }

  void changeMonth(int step) {
    if (!canChangeMonth(step)) return;
    final month = DateTime(_displayedMonth.year, _displayedMonth.month + step);
    final lastDay = DateUtils.getDaysInMonth(month.year, month.month);
    final day = _selectedDate.day > lastDay ? lastDay : _selectedDate.day;
    selectDate(DateTime(month.year, month.month, day));
  }

  void add({
    required String title,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay? endTime,
    required EventCategory category,
  }) {
    final event = _createEvent(
      id: _nextId,
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      category: category,
    );
    _repository.add(event);
    _nextId++;
  }

  void update(
    CalendarEvent event, {
    required String title,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay? endTime,
    required EventCategory category,
  }) {
    final updatedEvent = _createEvent(
      id: event.id,
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      category: category,
    );
    _repository.update(updatedEvent);
  }

  void remove(CalendarEvent event) {
    _repository.remove(event.id);
  }

  static CalendarEvent _createEvent({
    required int id,
    required String title,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay? endTime,
    required EventCategory category,
  }) {
    final name = title.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Название не может быть пустым');
    }
    if (!isCalendarDateSupported(date)) {
      throw ArgumentError.value(date, 'date', 'Дата вне диапазона календаря');
    }
    if (!hasValidTimeRange(startTime, endTime)) {
      throw ArgumentError.value(
        endTime,
        'endTime',
        'Окончание должно быть позже начала',
      );
    }

    return CalendarEvent(
      id: id,
      title: name,
      date: DateUtils.dateOnly(date),
      startTime: startTime,
      endTime: endTime,
      category: category,
    );
  }
}
