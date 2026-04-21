import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const AppLoadingIndicator({
    super.key,
    this.size = 18,
    this.strokeWidth = 2,
    this.color = AppColors.bordeaux,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

class AppButtonLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppButtonLoadingIndicator({
    super.key,
    this.size = 20,
    this.strokeWidth = 2.1,
  });

  @override
  Widget build(BuildContext context) {
    return AppLoadingIndicator(
      size: size,
      strokeWidth: strokeWidth,
      color: Colors.white,
    );
  }
}
