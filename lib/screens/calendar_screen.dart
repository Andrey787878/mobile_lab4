import 'package:flutter/material.dart';

import '../calendar_state.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';
import '../widgets/month_calendar.dart';
import 'event_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _state = CalendarState();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    setState(() => _state.selectDate(date));
  }

  void _goToToday() {
    setState(() {
      _state.refreshToday();
      _state.selectDate(_state.today);
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _changeMonth(int step) {
    setState(() => _state.changeMonth(step));
  }

  Future<void> _openEventForm([CalendarEvent? event]) async {
    final date = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(
          state: _state,
          event: event,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      if (date != null) _state.selectDate(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _state.selectedEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            tooltip: 'Сегодня',
            onPressed: _goToToday,
            icon: const Icon(Icons.today_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _buildCalendar(),
                  ),
                  const Divider(),
                  _buildDayHeader(),
                ],
              ),
            ),
            SliverPadding(
              // Оставляем место для плавающей кнопки добавления.
              padding: EdgeInsets.only(
                bottom: 88 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: events.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyDay())
                  : SliverList.builder(
                      itemCount: events.length,
                      itemBuilder: (_, index) => _buildEventTile(events[index]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEventForm(),
        tooltip: 'Добавить событие',
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    final month = _state.displayedMonth;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${monthNames[month.month - 1]} ${month.year}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Предыдущий месяц',
              onPressed: _state.canChangeMonth(-1) ? () => _changeMonth(-1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Следующий месяц',
              onPressed: _state.canChangeMonth(1) ? () => _changeMonth(1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MonthCalendar(
          state: _state,
          onSelect: _selectDate,
        ),
      ],
    );
  }

  Widget _buildDayHeader() {
    final date = _state.selectedDate;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        '${date.day} ${monthNamesGenitive[date.month - 1]}, '
        '${weekdayNames[date.weekday - 1].toLowerCase()}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildEmptyDay() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Text(
        'Нет событий',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }

  Widget _buildEventTile(CalendarEvent event) {
    var time = formatTime(event.startTime);
    if (event.endTime != null) {
      time += ' – ${formatTime(event.endTime!)}';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 16,
      leading: Icon(Icons.circle, size: 10, color: event.category.color),
      title: Text(event.title),
      subtitle: Text('$time · ${event.category.label}'),
      onTap: () => _openEventForm(event),
    );
  }
}
