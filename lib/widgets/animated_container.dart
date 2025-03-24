import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;

  const CustomAnimatedContainer({
    super.key,
    required this.child,
    this.duration = AppTheme.animationDurationNormal,
    this.curve = AppTheme.easeInOutCurve,
    this.padding,
    this.margin,
    this.decoration,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      padding: padding,
      margin: margin,
      decoration: decoration,
      constraints: constraints,
      child: child,
    );
  }
}
