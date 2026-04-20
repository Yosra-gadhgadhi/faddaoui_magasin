import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppSpacing {
  static const double xxs = 6;
  static const double xs = 10;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

class AppSize {
  static const double chipHeight = 40;
  static const double controlHeight = 40;
  static const double buttonHeight = 48;
}

class AppSurface {
  static BoxDecoration card({
    double radius = AppRadius.xl,
    double borderAlpha = 0.78,
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border.withValues(alpha: borderAlpha)),
    );
  }

  static BoxDecoration softCard({
    double radius = AppRadius.lg,
    double tintAlpha = 0.06,
    double borderAlpha = 0.16,
  }) {
    return BoxDecoration(
      color: AppColors.bordeaux.withValues(alpha: tintAlpha),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.bordeaux.withValues(alpha: borderAlpha)),
    );
  }

  static BoxDecoration iconContainer({
    double radius = AppRadius.md,
    double borderAlpha = 0.18,
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.bordeaux.withValues(alpha: borderAlpha),
      ),
    );
  }
}
