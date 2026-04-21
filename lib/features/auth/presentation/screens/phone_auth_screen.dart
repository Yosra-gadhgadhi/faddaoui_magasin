import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _invalid = false;
  bool _submitting = false;

  String get _digitsOnly => _phoneController.text.replaceAll(RegExp(r'\D'), '');
  bool get _canContinue => _digitsOnly.length >= 8;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _goNext() {
    final raw = _digitsOnly;
    if (raw.length < 8) {
      setState(() => _invalid = true);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _submitting = true);
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.phoneOtp,
        arguments: {'phone': '+216 $raw'},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.phone_iphone_rounded, color: AppColors.bordeaux, size: 44),
              const SizedBox(height: 14),
              Text(
                tr3(
                  context,
                  fr: 'Votre numéro de téléphone',
                  en: 'Your phone number',
                  ar: 'رقم هاتفك',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr3(
                  context,
                  fr: 'Entrez votre numéro pour continuer',
                  en: 'Enter your number to continue',
                  ar: 'أدخل رقمك للمتابعة',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _invalid
                        ? AppColors.bordeaux
                        : AppColors.border.withValues(alpha: 0.9),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Text(
                      '+216',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) {
                          if (_invalid || _submitting) {
                            setState(() {
                              _invalid = false;
                              _submitting = false;
                            });
                          } else {
                            setState(() {});
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: tr3(
                            context,
                            fr: 'Votre numéro de téléphone',
                            en: 'Your phone number',
                            ar: 'رقم هاتفك',
                          ),
                          hintStyle: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_invalid)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    tr3(
                      context,
                      fr: 'Numéro invalide',
                      en: 'Invalid number',
                      ar: 'رقم غير صالح',
                    ),
                    style: const TextStyle(
                      color: AppColors.bordeaux,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canContinue ? AppColors.bordeaux : AppColors.bordeaux.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.1,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          tr3(context, fr: 'Continuer', en: 'Continue', ar: 'متابعة'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 8),
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
