import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';

class LoyaltyScannerScreen extends StatefulWidget {
  const LoyaltyScannerScreen({super.key});

  @override
  State<LoyaltyScannerScreen> createState() => _LoyaltyScannerScreenState();
}

class _LoyaltyScannerScreenState extends State<LoyaltyScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr3(context, fr: 'Scanner', en: 'Scanner', ar: 'ماسح ضوئي'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) {
                        final y = 18 + (_controller.value * 220);
                        return Positioned(
                          left: 18,
                          right: 18,
                          top: y,
                          child: Container(
                            height: 2.4,
                            decoration: BoxDecoration(
                              color: AppColors.bordeaux,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.bordeaux.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 132,
            child: Text(
              tr3(
                context,
                fr: 'Placez le code-barres dans le cadre',
                en: 'Place the barcode inside the frame',
                ar: 'ضع الرمز داخل الإطار',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 64,
            child: SizedBox(
              height: AppSize.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 1000),
                      content: Text(
                        tr3(
                          context,
                          fr: 'Produit détecté: 6190001234567',
                          en: 'Product detected: 6190001234567',
                          ar: 'تم اكتشاف المنتج: 6190001234567',
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  tr3(
                    context,
                    fr: 'Simuler scan',
                    en: 'Simulate scan',
                    ar: 'محاكاة المسح',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
