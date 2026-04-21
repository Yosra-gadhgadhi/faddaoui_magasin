import 'package:flutter/material.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.local_grocery_store_rounded,
                size: 78,
                color: AppColors.bordeaux,
              ),
              const SizedBox(height: 20),
              Text(
                tr3(
                  context,
                  fr: 'Votre magasin préféré, à portée de main.',
                  en: 'Your favorite store, always within reach.',
                  ar: 'متجرك المفضل في متناول يدك.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tr3(
                  context,
                  fr: 'Promos, livraison rapide et carte fidélité dans une seule app.',
                  en: 'Deals, fast delivery and loyalty card in one app.',
                  ar: 'عروض وتوصيل سريع وبطاقة ولاء في تطبيق واحد.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 26),
              _BenefitRow(
                icon: Icons.discount_rounded,
                text: tr3(
                  context,
                  fr: 'Remises personnalisées',
                  en: 'Personalized discounts',
                  ar: 'خصومات مخصصة',
                ),
              ),
              const SizedBox(height: 10),
              _BenefitRow(
                icon: Icons.workspace_premium_rounded,
                text: tr3(
                  context,
                  fr: 'Carte fidélité digitale',
                  en: 'Digital loyalty card',
                  ar: 'بطاقة ولاء رقمية',
                ),
              ),
              const SizedBox(height: 10),
              _BenefitRow(
                icon: Icons.local_shipping_rounded,
                text: tr3(
                  context,
                  fr: 'Livraison et retrait magasin',
                  en: 'Delivery and store pickup',
                  ar: 'توصيل أو استلام من المتجر',
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneAuth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bordeaux,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    tr3(context, fr: 'S’identifier', en: 'Sign in', ar: 'تسجيل الدخول'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bordeaux,
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.95)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    tr3(
                      context,
                      fr: 'Continuer en mode invité',
                      en: 'Continue as guest',
                      ar: 'المتابعة كضيف',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.signIn),
                child: Text(
                  tr3(
                    context,
                    fr: 'Connexion email classique',
                    en: 'Use email login instead',
                    ar: 'استخدام تسجيل البريد الإلكتروني',
                  ),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.bordeaux.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: AppColors.bordeaux),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
