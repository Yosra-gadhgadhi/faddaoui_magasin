import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/app_text_field.dart';
import 'package:elfaddoui_app/core/widgets/primary_button.dart';

import '../../../../app/routes.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';
import '../widgets/sign_in_option.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;

  bool _nameError = false;
  bool _emailError = false;
  bool _passError = false;
  bool _confirmError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  int _passwordScore(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score;
  }

  String _strengthLabel(BuildContext context, int score) {
    if (score <= 1) {
      return tr3(context, fr: 'Faible', en: 'Weak', ar: 'ضعيفة');
    }
    if (score <= 2) {
      return tr3(context, fr: 'Moyenne', en: 'Medium', ar: 'متوسطة');
    }
    if (score == 3) {
      return tr3(context, fr: 'Bonne', en: 'Good', ar: 'جيدة');
    }
    return tr3(context, fr: 'Forte', en: 'Strong', ar: 'قوية');
  }

  Color _strengthColor(int score) {
    if (score <= 1) return const Color(0xFFDE5753);
    if (score <= 2) return const Color(0xFFE5A93D);
    if (score == 3) return const Color(0xFF6AAE57);
    return const Color(0xFF2C9D6C);
  }

  void _register() {
    final n = _name.text.trim();
    final e = _email.text.trim();
    final p = _password.text.trim();
    final c = _confirmPassword.text.trim();

    setState(() {
      _nameError = n.length < 3;
      _emailError = e.isEmpty || !e.contains('@');
      _passError = p.length < 8;
      _confirmError = c != p;
    });

    if (!_nameError && !_emailError && !_passError && !_confirmError) {
      context.read<AuthCubit>().signUp(n, e, p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = _passwordScore(_password.text.trim());
    final strength = _strengthLabel(context, score);
    final strengthColor = _strengthColor(score);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }

        if (state.token != null && state.token!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 1200),
              content: Text(
                tr3(
                  context,
                  fr: 'Compte créé, connectez-vous.',
                  en: 'Account created, please sign in.',
                  ar: 'تم إنشاء الحساب، يرجى تسجيل الدخول.',
                ),
              ),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.person_add_alt_1_rounded,
                        color: AppColors.bordeaux, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      tr3(
                        context,
                        fr: 'Créer un compte',
                        en: 'Create account',
                        ar: 'إنشاء حساب',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr3(
                        context,
                        fr: 'Rejoignez ElFaddaoui',
                        en: 'Join ElFaddaoui',
                        ar: 'انضم إلى ElFaddaoui',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppTextField(
                      label: tr3(context, fr: 'Nom complet', en: 'Full name', ar: 'الاسم الكامل'),
                      hint: tr3(context, fr: 'Entrez votre nom', en: 'Enter your name', ar: 'أدخل اسمك'),
                      controller: _name,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.muted),
                    ),
                    if (_nameError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tr3(
                            context,
                            fr: 'Nom invalide (min 3 caractères)',
                            en: 'Invalid name (min 3 chars)',
                            ar: 'اسم غير صالح (3 أحرف على الأقل)',
                          ),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: tr3(context, fr: 'Email', en: 'Email', ar: 'البريد الإلكتروني'),
                      hint: tr3(context, fr: 'Entrez votre email', en: 'Enter your email', ar: 'أدخل بريدك الإلكتروني'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.muted),
                    ),
                    if (_emailError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tr3(context, fr: 'Email invalide', en: 'Invalid email', ar: 'بريد غير صالح'),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: tr3(context, fr: 'Mot de passe', en: 'Password', ar: 'كلمة المرور'),
                      hint: tr3(context, fr: 'Créez un mot de passe', en: 'Create a password', ar: 'أنشئ كلمة مرور'),
                      controller: _password,
                      onChanged: (_) => setState(() {}),
                      obscureText: _hidePass,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hidePass = !_hidePass),
                        icon: Icon(
                          _hidePass
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (i) {
                        final active = i < score;
                        return Expanded(
                          child: Container(
                            height: 5,
                            margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                            decoration: BoxDecoration(
                              color: active
                                  ? strengthColor
                                  : AppColors.border.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${tr3(context, fr: 'Force du mot de passe', en: 'Password strength', ar: 'قوة كلمة المرور')}: $strength",
                      style: TextStyle(
                        color: strengthColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    if (_passError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tr3(
                            context,
                            fr: 'Minimum 8 caractères',
                            en: 'Minimum 8 characters',
                            ar: 'الحد الأدنى 8 أحرف',
                          ),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: tr3(context, fr: 'Confirmer le mot de passe', en: 'Confirm password', ar: 'تأكيد كلمة المرور'),
                      hint: tr3(context, fr: 'Retapez le mot de passe', en: 'Re-enter password', ar: 'أعد إدخال كلمة المرور'),
                      controller: _confirmPassword,
                      onChanged: (_) => setState(() {}),
                      obscureText: _hideConfirm,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                        icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    if (_confirmError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tr3(
                            context,
                            fr: 'Les mots de passe ne correspondent pas',
                            en: 'Passwords do not match',
                            ar: 'كلمتا المرور غير متطابقتين',
                          ),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: tr3(
                        context,
                        fr: 'Créer mon compte',
                        en: 'Create account',
                        ar: 'إنشاء الحساب',
                      ),
                      isLoading: state.loading,
                      onPressed: state.loading ? null : _register,
                      height: 50,
                      radius: 14,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.border.withValues(alpha: 0.9),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            tr3(context, fr: 'ou', en: 'or', ar: 'أو'),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.border.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialLoginButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 1100),
                                  content: Text(
                                    tr3(
                                      context,
                                      fr: 'Inscription Google bientôt disponible.',
                                      en: 'Google sign up coming soon.',
                                      ar: 'التسجيل عبر Google قريبًا.',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SocialLoginButton(
                            icon: Icons.apple_rounded,
                            label: 'Apple',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 1100),
                                  content: Text(
                                    tr3(
                                      context,
                                      fr: 'Inscription Apple bientôt disponible.',
                                      en: 'Apple sign up coming soon.',
                                      ar: 'التسجيل عبر Apple قريبًا.',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SignInOption(
                      textBefore: tr3(
                        context,
                        fr: 'Vous avez déjà un compte ?',
                        en: 'Already have an account?',
                        ar: 'لديك حساب بالفعل؟',
                      ),
                      actionText: tr3(
                        context,
                        fr: 'Se connecter',
                        en: 'Sign in',
                        ar: 'تسجيل الدخول',
                      ),
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signIn),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: AppColors.text),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
