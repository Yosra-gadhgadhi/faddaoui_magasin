import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/notifications/push_registration_service.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/utils/validators.dart';
import 'package:elfaddoui_app/core/widgets/app_text_field.dart';
import 'package:elfaddoui_app/core/widgets/primary_button.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';

import '../../../../app/routes.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';
import '../widgets/sign_in_option.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = LocalAuthentication();
  final _tokenStorage = TokenStorage();

  bool _emailError = false;
  bool _passError = false;
  bool _hidePass = true;
  bool _checkingBiometric = true;
  bool _biometricSupported = false;
  bool _biometricConfigured = false;
  bool _canUseBiometric = false;
  bool _isFaceId = false;
  bool _didAutoPromptBiometric = false;

  @override
  void initState() {
    super.initState();
    _bootBiometric();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _bootBiometric() async {
    try {
      final enabled = await _tokenStorage.isBiometricEnabled();
      final savedEmail = await _tokenStorage.readBiometricEmail();
      final savedPassword = await _tokenStorage.readBiometricPassword();
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      final biometrics = await _auth.getAvailableBiometrics();
      final hasFaceId = biometrics.contains(BiometricType.face);

      final canUse =
          enabled && canCheck && supported && (savedEmail?.isNotEmpty ?? false) && (savedPassword?.isNotEmpty ?? false);
      final configured =
          enabled && (savedEmail?.isNotEmpty ?? false) && (savedPassword?.isNotEmpty ?? false);
      final supportedOnDevice = canCheck && supported;

      if (!mounted) return;
      setState(() {
        _biometricSupported = supportedOnDevice;
        _biometricConfigured = configured;
        _canUseBiometric = canUse;
        _isFaceId = hasFaceId;
        _checkingBiometric = false;
      });

      if (canUse && hasFaceId && !_didAutoPromptBiometric && mounted) {
        _didAutoPromptBiometric = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _loginWithBiometric();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _biometricSupported = false;
        _biometricConfigured = false;
        _canUseBiometric = false;
        _isFaceId = false;
        _checkingBiometric = false;
      });
    }
  }

  Future<void> _saveBiometricForNextLogin() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    await _tokenStorage.saveBiometricCredentials(email: email, password: password);
    await _tokenStorage.setBiometricEnabled(true);
  }

  Future<void> _loginWithBiometric() async {
    if (!_biometricSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr3(
              context,
              fr: 'Face ID / Touch ID indisponible sur cet appareil.',
              en: 'Face ID / Touch ID is unavailable on this device.',
              ar: 'Face ID / Touch ID غير متاح على هذا الجهاز.',
            ),
          ),
        ),
      );
      return;
    }

    if (!_biometricConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr3(
              context,
              fr: 'Connectez-vous une fois avec email/mot de passe pour activer Face ID / Touch ID.',
              en: 'Sign in once with email/password to enable Face ID / Touch ID.',
              ar: 'سجّل الدخول مرة واحدة بالبريد وكلمة المرور لتفعيل Face ID / Touch ID.',
            ),
          ),
        ),
      );
      return;
    }

    try {
      final ok = await _auth.authenticate(
        localizedReason: tr3(
          context,
          fr: 'Confirmez votre identité pour vous connecter',
          en: 'Confirm your identity to sign in',
          ar: 'أكد هويتك لتسجيل الدخول',
        ),
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (!ok || !mounted) return;

      final savedEmail = await _tokenStorage.readBiometricEmail();
      final savedPassword = await _tokenStorage.readBiometricPassword();
      if ((savedEmail ?? '').isEmpty || (savedPassword ?? '').isEmpty) return;

      context.read<AuthCubit>().signIn(savedEmail!, savedPassword!);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr3(
              context,
              fr: 'Biométrie indisponible sur cet appareil.',
              en: 'Biometric sign in is unavailable on this device.',
              ar: 'تسجيل الدخول بالبصمة غير متاح على هذا الجهاز.',
            ),
          ),
        ),
      );
    }
  }

  void _submit() {
    final email = _email.text.trim();
    final password = _password.text.trim();

    setState(() {
      _emailError = !Validators.isValidEmail(email);
      _passError = !Validators.isValidPassword(password);
    });

    if (!_emailError && !_passError) {
      context.read<AuthCubit>().signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => previous.error != current.error,
          listener: (context, state) {
            if (state.error != null && state.error!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.token != current.token &&
              current.token != null &&
              current.token!.isNotEmpty,
          listener: (context, state) {
            context.read<CartCubit>().syncFromServer();
            context.read<FavoritesCubit>().syncFromServer();
            context.read<PushRegistrationService>().initAndRegister();
            _saveBiometricForNextLogin();
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
          },
        ),
      ],
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
                    const Icon(Icons.storefront_rounded,
                        color: AppColors.bordeaux, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'ElFaddaoui',
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
                        fr: 'Connexion à votre compte',
                        en: 'Sign in to your account',
                        ar: 'تسجيل الدخول إلى حسابك',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppTextField(
                      label: tr3(context, fr: 'Email', en: 'Email', ar: 'البريد الإلكتروني'),
                      hint: tr3(
                        context,
                        fr: 'Entrez votre email',
                        en: 'Enter your email',
                        ar: 'أدخل بريدك الإلكتروني',
                      ),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded,
                          color: AppColors.muted),
                    ),
                    if (_emailError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tr3(
                            context,
                            fr: 'Email invalide',
                            en: 'Invalid email',
                            ar: 'بريد غير صالح',
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
                      label: tr3(context, fr: 'Mot de passe', en: 'Password', ar: 'كلمة المرور'),
                      hint: tr3(
                        context,
                        fr: 'Entrez votre mot de passe',
                        en: 'Enter your password',
                        ar: 'أدخل كلمة المرور',
                      ),
                      controller: _password,
                      obscureText: _hidePass,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.muted),
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
                    if (_passError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          tr3(
                            context,
                            fr: 'Mot de passe invalide (min 8 caractères)',
                            en: 'Invalid password (min 8 chars)',
                            ar: 'كلمة مرور غير صالحة (8 أحرف على الأقل)',
                          ),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.forgot),
                        child: Text(
                          tr3(
                            context,
                            fr: 'Mot de passe oublié ?',
                            en: 'Forgot password?',
                            ar: 'نسيت كلمة المرور؟',
                          ),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    PrimaryButton(
                      text: tr3(
                        context,
                        fr: 'Se connecter',
                        en: 'Sign in',
                        ar: 'تسجيل الدخول',
                      ),
                      isLoading: state.loading,
                      onPressed: state.loading ? null : _submit,
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
                                      fr: 'Connexion Google bientôt disponible.',
                                      en: 'Google login coming soon.',
                                      ar: 'تسجيل الدخول عبر Google قريبًا.',
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
                                      fr: 'Connexion Apple bientôt disponible.',
                                      en: 'Apple login coming soon.',
                                      ar: 'تسجيل الدخول عبر Apple قريبًا.',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.phoneAuth),
                        icon: const Icon(
                          Icons.phone_iphone_rounded,
                          size: 17,
                          color: AppColors.bordeaux,
                        ),
                        label: Text(
                          tr3(
                            context,
                            fr: 'Se connecter avec téléphone',
                            en: 'Sign in with phone',
                            ar: 'تسجيل الدخول بالهاتف',
                          ),
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (!_checkingBiometric) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: state.loading ? null : _loginWithBiometric,
                          child: Container(
                            height: 66,
                            width: 66,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFAFC),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    AppColors.bordeaux.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Icon(
                              _isFaceId ? Icons.face_rounded : Icons.fingerprint,
                              size: _isFaceId ? 34 : 36,
                              color: AppColors.bordeaux,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SignInOption(
                      textBefore: tr3(
                        context,
                        fr: "Vous n'avez pas de compte ?",
                        en: 'No account yet?',
                        ar: 'ليس لديك حساب؟',
                      ),
                      actionText: tr3(
                        context,
                        fr: "S'inscrire",
                        en: 'Create account',
                        ar: 'إنشاء حساب',
                      ),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.signUp),
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
