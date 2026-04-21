import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/core/widgets/app_skeleton.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 16, double w = double.infinity}) =>
        AppSkeletonBlock(height: h, width: w, radius: 14);

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

class LocationPill extends StatelessWidget {
  final String label;
  final String sub;
  final VoidCallback onTap;

  const LocationPill({
    super.key,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.soft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.bordeaux),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.text, height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, height: 1),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class SearchBarPro extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onScan;
  final VoidCallback onFilter;

  const SearchBarPro({
    super.key,
    required this.hint,
    required this.onTap,
    required this.onScan,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  hint,
                  style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onScan,
            child: Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: AppColors.bordeaux),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onFilter,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: AppColors.bordeaux),
                  SizedBox(width: 6),
                  Text("Filtrer", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.bordeaux)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.bordeaux),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bordeaux.withValues(alpha: 0.12),
              AppColors.soft,
              Colors.white,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -18,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: AppColors.bordeaux.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 26,
              bottom: 16,
              child: Icon(Icons.local_offer_rounded, size: 44, color: AppColors.bordeaux.withValues(alpha: 0.35)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text, height: 1.1)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
                  const Spacer(),
                  Row(
                    children: [
                      Text(cta, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.bordeaux),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                actionText,
                style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
