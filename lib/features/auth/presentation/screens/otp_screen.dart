import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../app/routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool otpError = false;

  @override
  void dispose() {
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpCtrls.map((c) => c.text.trim()).join();

  void _onOtpChanged(int i, String v) {
    if (v.length > 1) {
      _otpCtrls[i].text = v.characters.last;
      _otpCtrls[i].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpCtrls[i].text.length),
      );
    }
    if (v.isNotEmpty && i < 5) {
      _otpFocus[i + 1].requestFocus();
    }
    if (v.isEmpty && i > 0) {
      _otpFocus[i - 1].requestFocus();
    }
  }

  void _verify(String email, String resetToken) {
    setState(() => otpError = _otp.length != 6);

    if (!otpError) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.resetPassword,
        arguments: {
          'email': email,
          'otp': _otp,
          'resetToken': resetToken,
        },
      );
    }
  }

  void _resend() {
    setState(() {
      otpError = false;
      for (final c in _otpCtrls) {
        c.clear();
      }
    });
    _otpFocus.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final email = (args['email'] ?? '') as String;
    final resetToken = (args['resetToken'] ?? '') as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.bordeaux),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          tr3(context, fr: "Code OTP", en: "OTP Code", ar: "رمز OTP"),
          style: TextStyle(
            color: AppColors.bordeaux,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ✅ Header
                          Row(
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.soft,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(Icons.verified_user_rounded, color: AppColors.bordeaux, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tr3(context, fr: "Vérification", en: "Verification", ar: "التحقق"),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tr3(context, fr: "Code envoyé à $email", en: "Code sent to $email", ar: "تم إرسال الرمز إلى $email"),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ✅ Card
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  tr3(context, fr: "Entrez le code à 6 chiffres", en: "Enter the 6-digit code", ar: "أدخل الرمز المكوّن من 6 أرقام"),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    6,
                                    (i) => _OtpBox(
                                      controller: _otpCtrls[i],
                                      focusNode: _otpFocus[i],
                                      onChanged: (v) => _onOtpChanged(i, v),
                                    ),
                                  ),
                                ),

                                if (otpError)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      tr3(context, fr: "Code invalide. Vérifiez les 6 chiffres.", en: "Invalid code. Check the 6 digits.", ar: "رمز غير صالح. تحقق من الأرقام الستة."),
                                      style: TextStyle(
                                        color: AppColors.bordeaux,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                PrimaryButton(
                                  text: tr3(context, fr: "Vérifier", en: "Verify", ar: "تحقق"),
                                  onPressed: () => _verify(email, resetToken),
                                  height: 48,
                                  radius: 16,
                                ),

                                const SizedBox(height: 12),

                                Center(
                                  child: GestureDetector(
                                    onTap: _resend,
                                    child: Text(
                                      tr3(context, fr: "Renvoyer le code", en: "Resend code", ar: "إعادة إرسال الرمز"),
                                      style: TextStyle(
                                        color: AppColors.bordeaux,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.bordeaux, width: 1.2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
