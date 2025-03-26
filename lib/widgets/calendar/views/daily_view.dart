import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/event_service.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/common/animations/spacing.dart';
import 'package:calendar_app/widgets/common/animations/animated_container.dart';
import 'package:calendar_app/widgets/calendar/events/event_widget.dart';
import 'dart:async';
import 'dart:math' as math;

enum TimeGranularity {
  hour,
  halfHour,
  quarterHour,
}

class DailyView extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final Function(Event)? onEventTap;

  const DailyView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.onEventTap,
  });

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _timeIndicatorTimer;
  TimeGranularity _timeGranularity = TimeGranularity.hour;
  double _hourHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _scrollToCurrentTime();
    _startTimeIndicatorTimer();
  }

  @override
  void dispose() {
    _timeIndicatorTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimeIndicatorTimer() {
    _timeIndicatorTimer?.cancel();
    _timeIndicatorTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  void _scrollToCurrentTime() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      if (widget.selectedDay.year == now.year &&
          widget.selectedDay.month == now.month &&
          widget.selectedDay.day == now.day) {
        _scrollController.animateTo(
          now.hour * 120.0, // Multiply by container height
          duration: AppTheme.animationDurationNormal,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _toggleTimeGranularity() {
    setState(() {
      switch (_timeGranularity) {
        case TimeGranularity.hour:
          _timeGranularity = TimeGranularity.halfHour;
          _hourHeight = 240.0;
          break;
        case TimeGranularity.halfHour:
          _timeGranularity = TimeGranularity.quarterHour;
          _hourHeight = 480.0;
          break;
        case TimeGranularity.quarterHour:
          _timeGranularity = TimeGranularity.hour;
          _hourHeight = 120.0;
          break;
      }
    });
  }

  double _calculateEventPosition(Event event) {
    if (event.isAllDay) return 0;

    final minutes = event.startDate.minute;
    // Calculate position within the hour based on minutes (0-59)
    return (minutes / 60.0) * _hourHeight;
  }

  double _calculateEventHeight(Event event) {
    if (event.isAllDay) return 40.0;

    final duration = event.endDate.difference(event.startDate);
    final totalMinutes = duration.inMinutes;
    // Convert total minutes to hours with decimal points for partial hours
    return (totalMinutes / 60.0) * _hourHeight;
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

  bool _hasEventAtHour(int index) {
    return _events?.any((event) {
          if (event.isAllDay) return false;
          return event.startDate.hour == index;
        }) ??
        false;
  }

  String _getEventTime(Event event) {
    if (event.isAllDay) return 'All Day';
    return '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeIndicator() {
    final now = DateTime.now();
    if (widget.selectedDay.year != now.year ||
        widget.selectedDay.month != now.month ||
        widget.selectedDay.day != now.day) {
      return const SizedBox.shrink();
    }

    final top = now.hour * 120.0 + (now.minute / 60.0 * 120.0);

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowButton() {
    return Positioned(
      right: AppTheme.spacing16,
      bottom: AppTheme.spacing16,
      child: FloatingActionButton.small(
        onPressed: _scrollToCurrentTime,
        child: const Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildAllDayEvents() {
    final allDayEvents = _events.where((event) => event.isAllDay).toList();
    if (allDayEvents.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
            child: Text(
              'All Day',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Wrap(
            spacing: AppTheme.spacing8,
            runSpacing: AppTheme.spacing8,
            children: allDayEvents
                .map((event) => SizedBox(
                      height: 32,
                      child: EventWidget(
                        event: event,
                        onTap: widget.onEventTap,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Helper method to convert DateTime to minutes since start of day
  int _getMinutesSinceStartOfDay(DateTime time) {
    return time.hour * 60 + time.minute;
  }

  // Helper method to group overlapping events
  List<List<Event>> _groupOverlappingEvents(List<Event> events) {
    if (events.isEmpty) return [];

    // Sort events by start time
    events.sort((a, b) => a.startDate.compareTo(b.startDate));

    List<List<Event>> groups = [];
    for (var event in events) {
      bool addedToGroup = false;
      for (var group in groups) {
        // Check if event overlaps with any event in the group
        bool overlapsWithGroup = group.any((groupEvent) =>
            event.startDate.isBefore(groupEvent.endDate) &&
            event.endDate.isAfter(groupEvent.startDate));

        if (overlapsWithGroup) {
          group.add(event);
          addedToGroup = true;
          break;
        }
      }
      if (!addedToGroup) {
        groups.add([event]);
      }
    }
    return groups;
  }

  Widget _buildHourBlock(BuildContext context, int hour) {
    // Find all events that intersect with this hour
    final hourStart = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      hour,
    );
    final hourEnd = hourStart.add(const Duration(hours: 1));

    final intersectingEvents = _events
        .where((event) =>
            !event.isAllDay &&
            event.startDate.isBefore(hourEnd) &&
            event.endDate.isAfter(hourStart))
        .toList();

    // Group overlapping events
    final eventGroups = _groupOverlappingEvents(intersectingEvents);

    return SizedBox(
      height: _hourHeight,
      child: Stack(
        children: [
          // Hour background
          Positioned.fill(
            child: Row(
              children: [
                // Time label
                SizedBox(
                  width: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                // Hour grid line
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Events
          Positioned.fill(
            left: 60,
            child: Stack(
              children: [
                for (var group in eventGroups)
                  for (int i = 0; i < group.length; i++)
                    _buildEventPosition(
                        context, group[i], i, group.length, hour),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventPosition(BuildContext context, Event event,
      int indexInGroup, int groupSize, int currentHour) {
    final eventStartMinutes = _getMinutesSinceStartOfDay(event.startDate);
    final eventEndMinutes = _getMinutesSinceStartOfDay(event.endDate);
    final hourStartMinutes = currentHour * 60;
    final hourEndMinutes = hourStartMinutes + 60;

    // Calculate position and height
    double topOffset = 0;
    double height = 0;

    if (eventStartMinutes >= hourStartMinutes &&
        eventStartMinutes < hourEndMinutes) {
      // Event starts in this hour
      topOffset = (eventStartMinutes - hourStartMinutes) / 60.0 * _hourHeight;
      height = math.min(
          (eventEndMinutes - eventStartMinutes) / 60.0 * _hourHeight,
          _hourHeight - topOffset);
    } else if (eventStartMinutes < hourStartMinutes &&
        eventEndMinutes > hourStartMinutes) {
      // Event started before this hour
      topOffset = 0;
      height = math.min(
          (eventEndMinutes - hourStartMinutes) / 60.0 * _hourHeight,
          _hourHeight);
    }

    // Calculate width and position for overlapping events
    final width = (MediaQuery.of(context).size.width - 68) / groupSize;
    final left = indexInGroup * width;

    return Positioned(
      top: topOffset,
      left: left,
      height: height,
      width: width - 4,
      child: EventWidget(
        event: event,
        onTap: widget.onEventTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.timeline),
                        onPressed: _toggleTimeGranularity,
                        tooltip: 'Change time granularity',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildAllDayEvents(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: 24,
                itemBuilder: (context, hour) => _buildHourBlock(context, hour),
              ),
            ),
          ],
        ),
        _buildNowButton(),
      ],
    );
  }

  bool _eventsOverlap(Event a, Event b) {
    return a.startDate.isBefore(b.endDate) && a.endDate.isAfter(b.startDate);
  }
}
