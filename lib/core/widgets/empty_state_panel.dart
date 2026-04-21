import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';

class EmptyStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const EmptyStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.82)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 310;
          final iconSize = compact ? 68.0 : 84.0;
          final iconInnerSize = compact ? 30.0 : 36.0;
          final titleSize = compact ? 16.0 : 18.0;
          final subtitleSize = compact ? 13.0 : 14.0;
          final btnHeight = compact ? 42.0 : 46.0;
          final btn2Height = compact ? 40.0 : 44.0;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: iconSize,
                  width: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.bordeaux.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.bordeaux.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.bordeaux, size: iconInnerSize),
                ),
                SizedBox(height: compact ? 9 : 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    height: 1.35,
                    fontSize: subtitleSize,
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                SizedBox(
                  width: double.infinity,
                  height: btnHeight,
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bordeaux,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                if (secondaryLabel != null && onSecondary != null) ...[
                  SizedBox(height: compact ? 8 : 10),
                  SizedBox(
                    width: double.infinity,
                    height: btn2Height,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.bordeaux,
                        side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.9),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        secondaryLabel!,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
