import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import 'spacing.dart';
import 'animated_container.dart';

class DailyView extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const DailyView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  final EventService _eventService = EventService();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didUpdateWidget(DailyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    final events = await _eventService.getEventsForDay(widget.selectedDay);
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAnimatedContainer(
          padding: AppTheme.standardPadding(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.selectedDay.day}/${widget.selectedDay.month}/${widget.selectedDay.year}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                '${widget.selectedDay.hour.toString().padLeft(2, '0')}:${widget.selectedDay.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              final hour = DateTime(
                widget.selectedDay.year,
                widget.selectedDay.month,
                widget.selectedDay.day,
                index,
              );
              final hourEvents = _events.where((event) {
                if (event.isAllDay) return true;
                return event.startTime.hour == index;
              }).toList();

              return CustomAnimatedContainer(
                duration: AppTheme.animationDurationFast,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.textLightColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${index.toString().padLeft(2, '0')}:00',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Spacing(isVertical: false),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: hourEvents.length,
                          itemBuilder: (context, eventIndex) {
                            final event = hourEvents[eventIndex];
                            final eventColor = event.color ??
                                AppTheme.eventColors[
                                    eventIndex % AppTheme.eventColors.length];
                            return CustomAnimatedContainer(
                              duration: AppTheme.animationDurationNormal,
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing4,
                                vertical: AppTheme.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: eventColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: eventColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.spacing12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: eventColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (event.description != null &&
                                        event.description!.isNotEmpty) ...[
                                      const Spacing(size: AppTheme.spacing4),
                                      Text(
                                        event.description!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (!event.isAllDay) ...[
                                      const Spacing(size: AppTheme.spacing4),
                                      Text(
                                        '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textLightColor,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
