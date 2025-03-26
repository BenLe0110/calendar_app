import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:uuid/uuid.dart';

class EventForm extends StatefulWidget {
  final Event? event;
  final Function(Event) onSubmit;
  final VoidCallback? onCancel;

  const EventForm({
    Key? key,
    this.event,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAllDay;
  Color? _color;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title);
    _descriptionController =
        TextEditingController(text: widget.event?.description);
    _startDate = widget.event?.startDate ?? DateTime.now();
    _endDate =
        widget.event?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    _isAllDay = widget.event?.isAllDay ?? false;
    _color = widget.event?.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              textInputAction: TextInputAction.next,
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
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_formatDateTime(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(true),
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_formatDateTime(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(false),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text(
                      widget.event == null ? 'Create Event' : 'Edit Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        isAllDay: _isAllDay,
        color: _color,
        userId: widget.event?.userId ?? const Uuid().v4(),
      );
      widget.onSubmit(event);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
