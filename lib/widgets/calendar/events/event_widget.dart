import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/common/animations/spacing.dart';
import 'package:calendar_app/widgets/common/animations/animated_container.dart';

class EventWidget extends StatelessWidget {
  final Event event;
  final Function(Event)? onTap;

  const EventWidget({
    super.key,
    required this.event,
    this.onTap,
  });

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = event.color ?? AppTheme.eventColors[0];

    return GestureDetector(
      onTap: () => onTap?.call(event),
      child: Container(
        decoration: BoxDecoration(
          color: eventColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: eventColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showTime = constraints.maxHeight > 24;
              final showDescription = constraints.maxHeight > 50;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: eventColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showTime)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${_formatTime(event.startDate)} - ${_formatTime(event.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: eventColor.withOpacity(0.8),
                              fontSize: 9,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (showDescription && event.description != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          event.description!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: eventColor.withOpacity(0.8),
                                    fontSize: 9,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
