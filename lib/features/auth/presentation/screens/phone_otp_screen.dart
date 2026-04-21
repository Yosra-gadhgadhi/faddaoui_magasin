import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _resendIn = 30;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _resendIn = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendIn <= 1) {
        setState(() => _resendIn = 0);
        t.cancel();
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  String get _otp => _controllers.map((e) => e.text.trim()).join();

  Future<void> _completeAuth() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }

  void _onChanged(int i, String v) {
    if (v.length > 1) {
      _controllers[i].text = v.characters.last;
      _controllers[i].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[i].text.length),
      );
    }

    if (v.isNotEmpty && i < 3) {
      _nodes[i + 1].requestFocus();
    }
    if (v.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }

    if (_otp.length == 4) {
      FocusScope.of(context).unfocus();
      _completeAuth();
    }
  }

  void _resend() {
    if (_resendIn > 0) return;
    HapticFeedback.selectionClick();
    for (final c in _controllers) {
      c.clear();
    }
    _nodes.first.requestFocus();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final phone = (args['phone'] ?? '+216').toString();

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
              const Icon(Icons.verified_user_rounded, color: AppColors.bordeaux, size: 46),
              const SizedBox(height: 14),
              Text(
                tr3(context, fr: 'Code d’activation', en: 'Activation code', ar: 'رمز التفعيل'),
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
                  fr: 'Entrez le code reçu sur $phone',
                  en: 'Enter the code sent to $phone',
                  ar: 'أدخل الرمز المرسل إلى $phone',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (i) {
                  return SizedBox(
                    width: 64,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => _onChanged(i, v),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.95),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.95),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.bordeaux),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: _resendIn == 0 ? _resend : null,
                  child: Text(
                    _resendIn == 0
                        ? tr3(
                            context,
                            fr: 'Renvoyer le code',
                            en: 'Resend code',
                            ar: 'إعادة إرسال الرمز',
                          )
                        : tr3(
                            context,
                            fr: 'Renvoyer dans ${_resendIn}s',
                            en: 'Resend in ${_resendIn}s',
                            ar: 'إعادة الإرسال خلال ${_resendIn}ث',
                          ),
                    style: TextStyle(
                      color: _resendIn == 0 ? AppColors.bordeaux : AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting || _otp.length < 4 ? null : _completeAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _otp.length < 4
                        ? AppColors.bordeaux.withValues(alpha: 0.35)
                        : AppColors.bordeaux,
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
            ],
          ),
        ),
      ),
    );
  }
}
