import 'package:flutter/material.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final _slides = const <_OnboardingSlide>[
    _OnboardingSlide(
      icon: Icons.local_shipping_rounded,
      titleFr: 'Courses rapides, sans stress',
      titleEn: 'Groceries fast, stress free',
      titleAr: 'مشتريات سريعة بدون ضغط',
      subtitleFr: 'Livraison ou retrait magasin selon votre besoin.',
      subtitleEn: 'Delivery or store pickup based on your need.',
      subtitleAr: 'توصيل أو استلام من المتجر حسب حاجتك.',
      tone: _SlideTone.delivery,
    ),
    _OnboardingSlide(
      icon: Icons.workspace_premium_rounded,
      titleFr: 'Votre carte fidélité digitale',
      titleEn: 'Your digital loyalty card',
      titleAr: 'بطاقة الولاء الرقمية',
      subtitleFr: 'Points, avantages et remises dans une seule place.',
      subtitleEn: 'Points, perks and discounts in one place.',
      subtitleAr: 'النقاط والمزايا والخصومات في مكان واحد.',
      tone: _SlideTone.loyalty,
    ),
    _OnboardingSlide(
      icon: Icons.card_giftcard_rounded,
      titleFr: 'Bons et cadeaux personnalisés',
      titleEn: 'Personal vouchers and gifts',
      titleAr: 'قسائم وهدايا مخصصة',
      subtitleFr: 'Des offres utiles chaque jour, adaptées à vos achats.',
      subtitleEn: 'Useful daily offers tailored to your shopping.',
      subtitleAr: 'عروض يومية مفيدة مناسبة لمشترياتك.',
      tone: _SlideTone.gifts,
    ),
  ];

  Future<void> _finish() async {
    await TokenStorage().setOnboardingSeen(true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    tr3(context, fr: 'Passer', en: 'Skip', ar: 'تخطي'),
                    style: const TextStyle(
                      color: AppColors.bordeaux,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (v) => setState(() => _index = v),
                  itemBuilder: (_, i) {
                    final s = _slides[i];
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        _OnboardingIllustration(tone: s.tone, icon: s.icon),
                        const SizedBox(height: 24),
                        Text(
                          tr3(context, fr: s.titleFr, en: s.titleEn, ar: s.titleAr),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 31,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr3(context, fr: s.subtitleFr, en: s.subtitleEn, ar: s.subtitleAr),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _index == i
                          ? AppColors.bordeaux
                          : AppColors.bordeaux.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bordeaux,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLast
                        ? tr3(context, fr: 'Commencer', en: 'Get started', ar: 'ابدأ')
                        : tr3(context, fr: 'Suivant', en: 'Next', ar: 'التالي'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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

enum _SlideTone { delivery, loyalty, gifts }

class _OnboardingSlide {
  final IconData icon;
  final String titleFr;
  final String titleEn;
  final String titleAr;
  final String subtitleFr;
  final String subtitleEn;
  final String subtitleAr;
  final _SlideTone tone;

  const _OnboardingSlide({
    required this.icon,
    required this.titleFr,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleFr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.tone,
  });
}

class _OnboardingIllustration extends StatelessWidget {
  final _SlideTone tone;
  final IconData icon;

  const _OnboardingIllustration({required this.tone, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cardColor = switch (tone) {
      _SlideTone.delivery => const Color(0xFFFFF5F8),
      _SlideTone.loyalty => const Color(0xFFF8F5FF),
      _SlideTone.gifts => const Color(0xFFFFF8F1),
    };

    final line1 = switch (tone) {
      _SlideTone.delivery => tr3(
          context,
          fr: 'Livraison express',
          en: 'Express delivery',
          ar: 'توصيل سريع',
        ),
      _SlideTone.loyalty => tr3(
          context,
          fr: 'Carte fidélité',
          en: 'Loyalty card',
          ar: 'بطاقة ولاء',
        ),
      _SlideTone.gifts => tr3(
          context,
          fr: 'Cadeaux du jour',
          en: 'Daily gifts',
          ar: 'هدايا يومية',
        ),
    };

    final line2 = switch (tone) {
      _SlideTone.delivery => tr3(
          context,
          fr: 'Retrait en magasin disponible',
          en: 'Store pickup available',
          ar: 'الاستلام من المتجر متاح',
        ),
      _SlideTone.loyalty => tr3(
          context,
          fr: 'Points + bons d’achat',
          en: 'Points + vouchers',
          ar: 'نقاط + قسائم شراء',
        ),
      _SlideTone.gifts => tr3(
          context,
          fr: 'Offres personnalisées',
          en: 'Personalized offers',
          ar: 'عروض مخصصة',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.bordeaux.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(icon, size: 42, color: AppColors.bordeaux),
          ),
          const SizedBox(height: 14),
          _InfoLine(text: line1),
          const SizedBox(height: 8),
          _InfoLine(text: line2),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String text;
  const _InfoLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: AppColors.bordeaux,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
