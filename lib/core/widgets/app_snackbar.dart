import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';

class AppSnackBar {
  static void show(
    BuildContext context,
    String text, {
    int durationMs = 1000,
    double marginBottom = 16,
    IconData icon = Icons.check_circle_rounded,
    Color iconColor = AppColors.bordeaux,
    FontWeight textWeight = FontWeight.w800,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..removeCurrentSnackBar()
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: durationMs),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 0,
          margin: EdgeInsets.fromLTRB(16, 0, 16, marginBottom),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
          ),
          content: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: textWeight,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
