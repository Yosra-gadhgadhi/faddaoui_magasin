import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_spacing.dart';

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double borderAlpha;
  final Color color;

  const PrimaryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.margin,
    this.radius = AppRadius.lg,
    this.borderAlpha = 0.8,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      decoration: AppSurface.card(
        radius: radius,
        borderAlpha: borderAlpha,
        color: color,
      ),
      child: child,
    );
    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }
    return card;
  }
}

