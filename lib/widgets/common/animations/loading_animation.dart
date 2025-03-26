import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class LoadingAnimation extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const LoadingAnimation({
    super.key,
    this.color,
    this.size = 24.0,
    this.duration = AppTheme.animationDurationNormal,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: Icon(
            Icons.refresh,
            color: widget.color ?? AppTheme.accentColor,
            size: widget.size,
          ),
        );
      },
    );
  }
}
