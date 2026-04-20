import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 16, double w = double.infinity}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        box(h: 18, w: 140),
        const SizedBox(height: 12),
        box(h: 56),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: box(h: 110)),
            const SizedBox(width: 12),
            Expanded(child: box(h: 110)),
          ],
        ),
        const SizedBox(height: 16),
        box(h: 18, w: 180),
        const SizedBox(height: 10),
        box(h: 120),
      ],
    );
  }
}
