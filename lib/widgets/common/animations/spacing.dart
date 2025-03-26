import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class Spacing extends StatelessWidget {
  final double size;
  final bool isVertical;
  final bool isResponsive;

  const Spacing({
    super.key,
    this.size = AppTheme.spacing16,
    this.isVertical = true,
    this.isResponsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = isResponsive
        ? (AppTheme.isDesktop(context)
            ? size * 2
            : AppTheme.isTablet(context)
                ? size * 1.5
                : size)
        : size;

    return SizedBox(
      width: isVertical ? 0 : spacing,
      height: isVertical ? spacing : 0,
    );
  }
}
