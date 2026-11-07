import '../models/calendar_event.dart';

class EventRepository {
  final List<CalendarEvent> _events = [];

  List<CalendarEvent> get events => List.unmodifiable(_events);

  void add(CalendarEvent event) {
    _events.add(event);
  }

  void update(CalendarEvent event) {
    final index = _events.indexWhere((item) => item.id == event.id);
    if (index == -1) return;
    _events[index] = event;
  }

  void remove(int id) {
    _events.removeWhere((event) => event.id == id);
  }
}
