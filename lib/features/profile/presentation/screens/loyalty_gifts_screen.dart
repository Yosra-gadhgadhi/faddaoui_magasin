import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class LoyaltyGiftsScreen extends StatelessWidget {
  const LoyaltyGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gifts = [
      (
        title: tr3(context, fr: 'Café gratuit', en: 'Free coffee', ar: 'قهوة مجانية'),
        points: 800,
        unlocked: true,
      ),
      (
        title: tr3(context, fr: 'Sac shopping', en: 'Shopping bag', ar: 'حقيبة تسوق'),
        points: 1200,
        unlocked: true,
      ),
      (
        title: tr3(context, fr: 'Box petit-déj', en: 'Breakfast box', ar: 'علبة فطور'),
        points: 2500,
        unlocked: false,
      ),
      (
        title: tr3(context, fr: 'Pack famille', en: 'Family pack', ar: 'باقة العائلة'),
        points: 3200,
        unlocked: false,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr3(context, fr: 'Mes cadeaux', en: 'My gifts', ar: 'هداياي'),
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: gifts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (_, i) {
          final g = gifts[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: g.unlocked
                  ? Colors.white
                  : AppColors.soft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: g.unlocked
                        ? AppColors.bordeaux.withValues(alpha: 0.10)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    g.unlocked ? Icons.card_giftcard_rounded : Icons.lock_rounded,
                    size: 18,
                    color: g.unlocked ? AppColors.bordeaux : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  g.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${g.points} pts',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: g.unlocked
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 900),
                                content: Text(
                                  tr3(
                                    context,
                                    fr: 'Cadeau réclamé.',
                                    en: 'Gift claimed.',
                                    ar: 'تم استلام الهدية.',
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: g.unlocked
                          ? AppColors.bordeaux
                          : AppColors.lightGrey,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: Text(
                      g.unlocked
                          ? tr3(context, fr: 'Réclamer', en: 'Claim', ar: 'استلام')
                          : tr3(context, fr: 'Verrouillé', en: 'Locked', ar: 'مغلق'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
