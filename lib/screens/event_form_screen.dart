import 'package:flutter/material.dart';
import '../models/event.dart';

class EventFormScreen extends StatefulWidget {
  final DateTime selectedDate;

  const EventFormScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  Color _selectedColor = Colors.blue;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    if (_isAllDay) {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: isStartTime ? _startTime : (_endTime ?? _startTime),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );

      if (date != null) {
        setState(() {
          if (isStartTime) {
            _startTime = date;
          } else {
            _endTime = date;
          }
        });
      }
    } else {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: isStartTime ? _startTime : (_endTime ?? _startTime),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );

      if (date != null) {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
            isStartTime ? _startTime : (_endTime ?? _startTime),
          ),
        );

        if (time != null) {
          setState(() {
            final DateTime dateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            if (isStartTime) {
              _startTime = dateTime;
            } else {
              _endTime = dateTime;
            }
          });
        }
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        isAllDay: _isAllDay,
      );
      Navigator.pop(context, event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
              title: const Text('All Day Event'),
              value: _isAllDay,
              onChanged: (bool value) {
                setState(() {
                  _isAllDay = value;
                  if (value) {
                    _startTime = DateTime(
                      _startTime.year,
                      _startTime.month,
                      _startTime.day,
                    );
                    if (_endTime != null) {
                      _endTime = DateTime(
                        _endTime!.year,
                        _endTime!.month,
                        _endTime!.day,
                      );
                    }
                  }
                });
              },
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_isAllDay
                  ? '${_startTime.year}-${_startTime.month}-${_startTime.day}'
                  : '${_startTime.year}-${_startTime.month}-${_startTime.day} ${_startTime.hour}:${_startTime.minute}'),
              onTap: () => _selectDateTime(context, true),
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_endTime == null
                  ? 'No end time'
                  : _isAllDay
                      ? '${_endTime!.year}-${_endTime!.month}-${_endTime!.day}'
                      : '${_endTime!.year}-${_endTime!.month}-${_endTime!.day} ${_endTime!.hour}:${_endTime!.minute}'),
              onTap: () => _selectDateTime(context, false),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Color>(
              value: _selectedColor,
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
              items: [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.orange,
                Colors.purple,
              ].map((Color color) {
                return DropdownMenuItem<Color>(
                  value: color,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        color: color,
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      Text(color.toString()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Color? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedColor = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}
