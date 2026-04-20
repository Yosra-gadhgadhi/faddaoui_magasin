import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/utils/validators.dart';
import 'package:elfaddoui_app/core/widgets/app_text_field.dart';
import 'package:elfaddoui_app/core/widgets/primary_button.dart';
import 'package:elfaddoui_app/features/auth/presentation/state/auth_cubit.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';
import 'package:elfaddoui_app/features/notifications/presentation/screens/notifications_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  static const _initialName = "Nom d'utilisateur";
  static const _initialEmail = "utilisateur@example.com";

  final _name = TextEditingController(text: _initialName);
  final _email = TextEditingController(text: _initialEmail);
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool hidePass = true;
  bool hideConfirm = true;

  bool nameError = false;
  bool emailError = false;
  bool passError = false;
  bool confirmError = false;

  String? _avatarUrl;
  late String _savedName;
  late String _savedEmail;
  String? _savedAvatarUrl;
  DateTime? _lastUpdatedAt;
  late final AnimationController _servicesPulseController;
  late final Animation<double> _servicesPulse;

  void _haptic() => HapticFeedback.selectionClick();

  bool get _hasChanges =>
      _name.text.trim() != _savedName ||
      _email.text.trim() != _savedEmail ||
      _password.text.trim().isNotEmpty ||
      _confirm.text.trim().isNotEmpty ||
      _avatarUrl != _savedAvatarUrl;

  String get _passwordStrengthLabel {
    final p = _password.text.trim();
    if (p.isEmpty) return "";
    if (p.length < 8) return "Faible";
    if (RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(p)) {
      if (RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{10,}$')
          .hasMatch(p)) {
        return "Fort";
      }
      return "Moyen";
    }
    return "Faible";
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrengthLabel) {
      case "Fort":
        return const Color(0xFF2E7D32);
      case "Moyen":
        return const Color(0xFFAF7E00);
      case "Faible":
        return Colors.red;
      default:
        return AppColors.muted;
    }
  }

  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _savedName = _initialName;
    _savedEmail = _initialEmail;
    _savedAvatarUrl = _avatarUrl;
    _name.addListener(_onFieldChanged);
    _email.addListener(_onFieldChanged);
    _password.addListener(_onFieldChanged);
    _confirm.addListener(_onFieldChanged);
    _servicesPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _servicesPulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _servicesPulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _toastPremium(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1100),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.bordeaux),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDialog({
    required String title,
    required String confirmText,
    String cancelText = "Annuler",
    Color confirmColor = Colors.red,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.text),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  void _save() {
    _haptic();

    final n = _name.text.trim();
    final e = _email.text.trim();
    final p = _password.text.trim();
    final c = _confirm.text.trim();

    setState(() {
      nameError = n.isEmpty || n.length < 3;
      emailError = !Validators.isValidEmail(e);

      final wantsPasswordChange = p.isNotEmpty || c.isNotEmpty;
      passError = wantsPasswordChange ? !Validators.isValidPassword(p) : false;
      confirmError = wantsPasswordChange ? (c != p) : false;
    });

    if (!nameError && !emailError && !passError && !confirmError) {
      setState(() {
        _savedName = n;
        _savedEmail = e;
        _savedAvatarUrl = _avatarUrl;
        _lastUpdatedAt = DateTime.now();
        _password.clear();
        _confirm.clear();
      });
      _toastPremium("Profil mis à jour ✅");
    } else {
      _toastPremium("Vérifiez vos champs ⚠️");
    }
  }

  Future<void> _changeAvatar() async {
    _haptic();

    const a1 =
        "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=300";
    const a2 =
        "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=300";

    final ok = await _confirmDialog(
      title: "Changer la photo de profil ?",
      confirmText: "Changer",
      confirmColor: AppColors.bordeaux,
    );
    if (!ok) return;

    setState(() {
      _avatarUrl = (_avatarUrl == null || _avatarUrl == a2) ? a1 : a2;
    });

    _toastPremium("Photo mise à jour ✅");
  }

  Future<void> _logout() async {
    _haptic();
    final ok = await _confirmDialog(
      title: "Se déconnecter ?",
      confirmText: "Déconnexion",
      confirmColor: Colors.red,
    );
    if (!ok) return;
    if (!mounted) return;

    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);

    _toastPremium("Déconnecté ✅");
  }

  void _openServicesSheet() {
    _haptic();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 10, 6),
                    child: Row(
                      children: [
                        const Text(
                          "Services",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ServiceQuickCard(
                                icon: Icons.notifications_rounded,
                                title: "Notifications",
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const NotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ServiceQuickCard(
                                icon: Icons.local_shipping_rounded,
                                title: "Suivi",
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const DeliveryTrackingScreen(
                                        orderId: "ELF-1024",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ServiceTile(
                          icon: Icons.notifications_rounded,
                          title: "Notifications",
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ServiceTile(
                          icon: Icons.local_shipping_rounded,
                          title: "Suivi",
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DeliveryTrackingScreen(
                                  orderId: "ELF-1024",
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ServiceTile(
                          icon: Icons.settings_rounded,
                          title: "Paramètres",
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).pushNamed(AppRoutes.settings);
                          },
                        ),
                        const SizedBox(height: 8),
                        _ServiceTile(
                          icon: Icons.info_outline_rounded,
                          title: "Contact & À propos",
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).pushNamed(AppRoutes.aboutStore);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _servicesPulseController.dispose();
    _name.removeListener(_onFieldChanged);
    _email.removeListener(_onFieldChanged);
    _password.removeListener(_onFieldChanged);
    _confirm.removeListener(_onFieldChanged);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: AppSurface.iconContainer(borderAlpha: 0.14),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.bordeaux,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_rounded, size: 16, color: AppColors.bordeauxDark),
              SizedBox(width: 8),
              Text(
                "Profil",
                style: TextStyle(
                  color: AppColors.bordeauxDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.5,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedBuilder(
              animation: _servicesPulse,
              builder: (context, child) => Transform.scale(
                scale: _servicesPulse.value,
                child: child,
              ),
              child: IconButton(
                onPressed: _openServicesSheet,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.bordeaux.withValues(alpha: 0.18),
                  ),
                ),
                icon: const Icon(
                  Icons.widgets_rounded,
                  color: AppColors.bordeaux,
                  size: 20,
                ),
                tooltip: "Services",
              ),
            ),
          ),
        ],
      ),

      // ✅ نفس ستايل باقي الواجهات: PrimaryButton Bordeaux
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  text: "Enregistrer",
                  onPressed: _hasChanges ? _save : null,
                  height: 50,
                  radius: 16,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 14,
                  child: Center(
                    child: _lastUpdatedAt == null
                        ? const SizedBox.shrink()
                        : Text(
                            "Dernière mise à jour: ${_lastUpdatedAt!.hour.toString().padLeft(2, '0')}:${_lastUpdatedAt!.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ header card
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: AppSurface.card(radius: 22, borderAlpha: 0.75),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _changeAvatar,
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.soft,
                              border: Border.all(color: AppColors.border),
                              image: _avatarUrl == null
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(_avatarUrl!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            child: _avatarUrl == null
                                ? const Icon(Icons.person_rounded,
                                    color: AppColors.bordeaux, size: 30)
                                : null,
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  size: 14, color: AppColors.bordeaux),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Informations du compte",
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Modifiez seulement ce que vous voulez.",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const _ProfileSectionTitle("Compte"),
              const SizedBox(height: 8),

              // ✅ info box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                decoration: AppSurface.softCard(),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.bordeaux),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Laissez le mot de passe vide si vous ne souhaitez pas le changer.",
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ✅ fields card (بدون Divider/ligne)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: AppSurface.card(radius: 22, borderAlpha: 0.75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: "Nom complet",
                      hint: "Entrer votre nom",
                      controller: _name,
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.muted),
                    ),
                    if (nameError)
                      const _FieldError("Nom invalide (min 3 caractères)"),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: "Email",
                      hint: "Entrer votre email",
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded,
                          color: AppColors.muted),
                    ),
                    if (emailError) const _FieldError("Email invalide"),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: "Mot de passe (optionnel)",
                      hint: "Nouveau mot de passe",
                      controller: _password,
                      obscureText: hidePass,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.muted),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => hidePass = !hidePass),
                        icon: Icon(
                          hidePass
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    if (passError)
                      const _FieldError(
                          "Mot de passe invalide (min 8 caractères)"),
                    if (_password.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.security_rounded,
                            size: 14,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Force du mot de passe: $_passwordStrengthLabel",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _passwordStrengthColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    AppTextField(
                      label: "Confirmer le mot de passe",
                      hint: "Retaper le mot de passe",
                      controller: _confirm,
                      obscureText: hideConfirm,
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.muted),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => hideConfirm = !hideConfirm),
                        icon: Icon(
                          hideConfirm
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    if (confirmError)
                      const _FieldError(
                          "Les mots de passe ne correspondent pas"),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                  label: const Text(
                    "Se déconnecter",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _FieldError extends StatelessWidget {
  final String text;
  const _FieldError(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.bordeaux,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.bordeaux),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _ServiceQuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceQuickCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bordeaux.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.bordeaux.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.bordeaux),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;
  const _ProfileSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
