import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/event_service.dart';
import 'package:calendar_app/services/logging_service.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'package:calendar_app/theme/app_theme.dart';

class EventFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final bool isLoggedIn;

  const EventFormScreen({
    super.key,
    required this.selectedDate,
    required this.isLoggedIn,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventService = EventService();
  final _log = LoggingService.getLogger('EventFormScreen');
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _log.info('Initializing EventFormScreen for date: ${widget.selectedDate}');
    _startDate = widget.selectedDate;
    _endDate = widget.selectedDate.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _log.fine('Disposing EventFormScreen');
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_endDate.isBefore(_startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date must be after start date')),
        );
        return;
      }

      _log.info('Saving new event: ${_titleController.text}');
      final event = Event(
        id: const Uuid().v4(), // Generate a new UUID for the event
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        isAllDay: _isAllDay,
        color: Colors.blue,
        userId: widget.isLoggedIn
            ? const Uuid().v4()
            : null, // Generate a new UUID for the user
      );

      try {
        await _eventService.insertEvent(event);
        _log.info('Event saved successfully');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e, stackTrace) {
        _log.severe('Failed to save event', e, stackTrace);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save event')),
          );
        }
      }
    } else {
      _log.warning('Form validation failed');
    }
  }

  Future<void> _selectDateTime(bool isStartDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(isStartDate ? _startDate : _endDate),
      );

      if (time != null) {
        setState(() {
          final DateTime newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isStartDate) {
            _startDate = newDateTime;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            if (newDateTime.isBefore(_startDate)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('End date must be after start date')),
              );
              return;
            }
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.fine('Building EventFormScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('All Day'),
              value: _isAllDay,
              onChanged: (value) {
                _log.info('All day event toggled: $value');
                setState(() {
                  _isAllDay = value;
                  if (value) {
                    _startDate = DateTime(
                        _startDate.year, _startDate.month, _startDate.day);
                    _endDate =
                        DateTime(_endDate.year, _endDate.month, _endDate.day);
                  }
                });
              },
            ),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate.toString()),
              onTap: () async {
                _log.fine('Opening start date picker');
                await _selectDateTime(true);
              },
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_startDate.toString()),
              enabled: !_isAllDay,
              onTap: () async {
                _log.fine('Opening start time picker');
                await _selectDateTime(true);
              },
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_endDate.toString()),
              onTap: () async {
                _log.fine('Opening end date picker');
                await _selectDateTime(false);
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_endDate.toString()),
              enabled: !_isAllDay,
              onTap: () async {
                _log.fine('Opening end time picker');
                await _selectDateTime(false);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEvent,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
