import 'package:flutter/material.dart';

import '../calendar_state.dart';
import '../models/calendar_event.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({
    super.key,
    required this.state,
    this.event,
  });

  final CalendarState state;
  final CalendarEvent? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late DateTime _eventDate;
  late TimeOfDay _startTime;
  TimeOfDay? _endTime;
  late EventCategory _category;
  bool _hasSubmitted = false;
  bool _isSaving = false;

  bool get _isTimeRangeInvalid => !hasValidTimeRange(_startTime, _endTime);

  bool get _canSetEndTime => timeInMinutes(_startTime) < 24 * 60 - 1;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _eventDate = event?.date ?? widget.state.selectedDate;
    _startTime = event?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = event == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : event.endTime;
    _category = event?.category ?? EventCategory.study;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_isSaving) return;
    final validTitle = _formKey.currentState!.validate();
    if (!validTitle || _isTimeRangeInvalid) {
      setState(() => _hasSubmitted = true);
      return;
    }
    setState(() => _isSaving = true);
    final title = _titleController.text;
    final event = widget.event;
    if (event == null) {
      widget.state.add(
        title: title,
        date: _eventDate,
        startTime: _startTime,
        endTime: _endTime,
        category: _category,
      );
    } else {
      widget.state.update(
        event,
        title: title,
        date: _eventDate,
        startTime: _startTime,
        endTime: _endTime,
        category: _category,
      );
    }
    Navigator.pop(context, _eventDate);
  }

  Future<void> _chooseDate() async {
    FocusScope.of(context).unfocus();
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: firstCalendarDate,
      lastDate: lastCalendarDate,
      helpText: 'Дата события',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );
    if (date != null && mounted) setState(() => _eventDate = date);
  }

  Future<void> _chooseTime({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : (_endTime ?? _startTime),
      orientation: Orientation.portrait,
      initialEntryMode: MediaQuery.sizeOf(context).height < 500
          ? TimePickerEntryMode.inputOnly
          : TimePickerEntryMode.dial,
      helpText: isStart ? 'Время начала' : 'Время окончания',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = time;
        if (!_canSetEndTime) _endTime = null;
      } else {
        _endTime = time;
      }
    });
  }

  Future<void> _delete() async {
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить событие?'),
        content: const Text('Событие исчезнет из календаря.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    widget.state.remove(widget.event!);
    Navigator.pop(context);
  }

  void _setEndTimeEnabled(bool enabled) {
    if (enabled && !_canSetEndTime) return;
    setState(() {
      if (!enabled) {
        _endTime = null;
        return;
      }
      _endTime = _startTime.hour < 23
          ? TimeOfDay(hour: _startTime.hour + 1, minute: _startTime.minute)
          : const TimeOfDay(hour: 23, minute: 59);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Событие' : 'Новое событие'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Сохранить'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _hasSubmitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildDateAndTimeFields(),
                const Divider(),
                _buildCategoryField(),
                if (isEditing) _buildDeleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _titleController,
        minLines: 1,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(labelText: 'Название'),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Введите название события';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateAndTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPickerTile(
          'Дата',
          formatDate(_eventDate),
          Icons.calendar_today_outlined,
          _chooseDate,
        ),
        _buildPickerTile(
          'Начало',
          formatTime(_startTime),
          Icons.schedule_outlined,
          () => _chooseTime(isStart: true),
        ),
        SwitchListTile(
          title: const Text('Время окончания'),
          subtitle: _canSetEndTime
              ? null
              : const Text('Для начала в 23:59 окончание недоступно.'),
          value: _endTime != null,
          onChanged: _canSetEndTime ? _setEndTimeEnabled : null,
        ),
        if (_endTime != null)
          _buildPickerTile(
            'Окончание',
            formatTime(_endTime!),
            Icons.schedule_outlined,
            () => _chooseTime(isStart: false),
          ),
        if (_isTimeRangeInvalid)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                'Окончание должно быть позже начала.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<EventCategory>(
        initialValue: _category,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Категория'),
        items: [
          for (final category in EventCategory.values)
            DropdownMenuItem(
              value: category,
              child: Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (category) {
          if (category != null) {
            setState(() => _category = category);
          }
        },
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _delete,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Удалить событие'),
        ),
      ),
    );
  }

  Widget _buildPickerTile(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      onTap: onTap,
    );
  }
}
