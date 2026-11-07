import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../calendar_state.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';

// день = индекс ячейки - смещение + 1

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key, required this.state, required this.onSelect});

  // Месяц может занимать до шести строк. Оставляем их всегда,
  // чтобы список событий не сдвигался при переключении месяцев.
  static const _weekCount = 6;
  static const _daysInWeek = 7;
  static const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  final CalendarState state;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final month = state.displayedMonth;
    final firstDay = DateTime(month.year, month.month);
    final offset = firstDay.weekday - DateTime.monday;
    final textHeight = MediaQuery.textScalerOf(context).scale(16);
    final cellHeight = math.max(44.0, textHeight + 16);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / _daysInWeek;
        final circleSize = math.max(
          0.0,
          math.min(cellWidth - 6, cellHeight - 8),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWeekdays(),
            GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _daysInWeek,
                mainAxisExtent: cellHeight,
              ),
              itemCount: _weekCount * _daysInWeek,
              itemBuilder: (context, index) {
                final date = DateTime(
                  month.year,
                  month.month,
                  index - offset + 1,
                );
                return _buildDay(date, circleSize);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekdays() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          for (final weekday in _weekdays)
            Expanded(
              child: Text(
                weekday,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDay(DateTime date, double circleSize) {
    if (!isCalendarDateSupported(date)) return const SizedBox.shrink();

    final month = state.displayedMonth;
    final isSelected = DateUtils.isSameDay(date, state.selectedDate);
    final isToday = DateUtils.isSameDay(date, state.today);
    final isCurrentMonth = date.year == month.year && date.month == month.month;
    final categories = state.categoriesForDate(date);

    Color textColor;
    if (isSelected) {
      textColor = AppColors.background;
    } else if (isToday) {
      textColor = AppColors.accent;
    } else if (isCurrentMonth) {
      textColor = AppColors.text;
    } else {
      textColor = const Color(0xFF5F6470);
    }

    var label = formatDate(date);
    if (isToday) label += ', сегодня';
    if (categories.isNotEmpty) {
      final categoryNames = categories
          .map((category) => category.label)
          .join(', ');
      label += ', события: $categoryNames';
    }

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      excludeSemantics: true,
      onTap: () => onSelect(date),
      child: InkWell(
        onTap: () => onSelect(date),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: circleSize,
              width: circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isToday && !isSelected
                      ? AppColors.accent
                      : Colors.transparent,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      height: 1,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            _buildCategoryMarkers(categories),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryMarkers(Set<EventCategory> categories) {
    return SizedBox(
      height: 4,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final category in EventCategory.values)
              if (categories.contains(category))
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
