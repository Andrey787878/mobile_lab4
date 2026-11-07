import 'package:flutter/material.dart';

final firstCalendarDate = DateTime(1);
final lastCalendarDate = DateTime(9999, 12, 31);

bool isCalendarDateSupported(DateTime date) {
  final day = DateUtils.dateOnly(date);
  return !day.isBefore(firstCalendarDate) && !day.isAfter(lastCalendarDate);
}

// Начало и окончание относятся к одному дню, поэтому окончание должно быть
// позже начала. Если окончание не указано, проверять длительность не нужно.
bool hasValidTimeRange(TimeOfDay start, TimeOfDay? end) =>
    end == null || timeInMinutes(end) > timeInMinutes(start);

int timeInMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

String formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

String formatDate(DateTime date) =>
    '${date.day} ${monthNamesGenitive[date.month - 1]} ${date.year}';

const monthNames = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
];

const monthNamesGenitive = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
];

const weekdayNames = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];
