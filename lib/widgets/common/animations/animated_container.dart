import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class CustomAnimatedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final BoxDecoration? decoration;
  final Duration? duration;
  final double? height;

  const CustomAnimatedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.constraints,
    this.decoration,
    this.duration,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration ?? const Duration(milliseconds: 300),
      padding: padding,
      margin: margin,
      constraints: constraints,
      decoration: decoration,
      height: height,
      child: child,
    );
  }
}
