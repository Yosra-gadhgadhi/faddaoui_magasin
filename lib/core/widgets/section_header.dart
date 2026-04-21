import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final IconData actionIcon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.actionIcon = Icons.east_rounded,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final rightWidgets = <Widget>[];
    if (subtitle != null) {
      rightWidgets.add(
        Text(
          subtitle!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
      );
    }
    if (trailing != null) {
      if (rightWidgets.isNotEmpty) rightWidgets.add(const SizedBox(width: 8));
      rightWidgets.add(trailing!);
    }
    if (onTap != null) {
      if (rightWidgets.isNotEmpty) rightWidgets.add(const SizedBox(width: 8));
      rightWidgets.add(
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.bordeaux.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.bordeaux.withValues(alpha: 0.20),
              ),
            ),
            child: Icon(
              actionIcon,
              color: AppColors.bordeauxDark,
              size: 18,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rightMaxWidth = constraints.maxWidth * 0.45;
        return Row(
          children: [
            Container(
              width: 4,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.bordeaux,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            if (rightWidgets.isNotEmpty) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: rightMaxWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.hardEdge,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: rightWidgets,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
