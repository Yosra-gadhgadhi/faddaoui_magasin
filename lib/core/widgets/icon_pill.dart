import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';

class IconPill extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color backgroundColor;
  final double radius;
  final double borderAlpha;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  const IconPill({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.backgroundColor = Colors.white,
    this.radius = AppRadius.pill,
    this.borderAlpha = 0.8,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: AppSurface.card(
        radius: radius,
        borderAlpha: borderAlpha,
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor ?? AppColors.bordeaux),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: TextStyle(
                color: textColor ?? AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}

