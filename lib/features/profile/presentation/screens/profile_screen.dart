import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/utils/validators.dart';
import 'package:elfaddoui_app/core/widgets/app_text_field.dart';
import 'package:elfaddoui_app/core/widgets/primary_button.dart';
import 'package:elfaddoui_app/features/auth/presentation/state/auth_cubit.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';
import 'package:elfaddoui_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:elfaddoui_app/features/profile/presentation/screens/order_history_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  static const _tnDialCode = '+216';
  static const _initialName = "Nom d'utilisateur";
  static const _initialEmail = "utilisateur@example.com";
  final _tokenStorage = TokenStorage();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  final _name = TextEditingController(text: _initialName);
  final _email = TextEditingController(text: _initialEmail);
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool hidePass = true;
  bool hideConfirm = true;

  bool nameError = false;
  bool emailError = false;
  bool phoneError = false;
  bool passError = false;
  bool confirmError = false;

  String? _avatarUrl;
  late String _savedName;
  late String _savedEmail;
  String _savedPhone = "";
  String _savedAddress = "";
  String? _savedAvatarUrl;
  DateTime? _lastUpdatedAt;
  late final AnimationController _servicesPulseController;
  late final Animation<double> _servicesPulse;
  bool _saving = false;

  void _haptic() => HapticFeedback.selectionClick();

  bool get _hasChanges =>
      _name.text.trim() != _savedName ||
      _email.text.trim() != _savedEmail ||
      _phone.text.trim() != _savedPhone ||
      _address.text.trim() != _savedAddress ||
      _password.text.trim().isNotEmpty ||
      _confirm.text.trim().isNotEmpty ||
      _avatarUrl != _savedAvatarUrl;

  String get _passwordStrengthKey {
    final p = _password.text.trim();
    if (p.isEmpty) return "";
    if (p.length < 8) return "weak";
    if (RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(p)) {
      if (RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{10,}$')
          .hasMatch(p)) {
        return "strong";
      }
      return "medium";
    }
    return "weak";
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrengthKey) {
      case "strong":
        return const Color(0xFF2E7D32);
      case "medium":
        return const Color(0xFFAF7E00);
      case "weak":
        return Colors.red;
      default:
        return AppColors.muted;
    }
  }

  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  String _toApiPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return "";
    }
    return '$_tnDialCode $digits';
  }

  String _formatLocalPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final clipped = digits.length > 8 ? digits.substring(0, 8) : digits;
    if (clipped.length <= 2) return clipped;
    if (clipped.length <= 5) {
      return '${clipped.substring(0, 2)} ${clipped.substring(2)}';
    }
    return '${clipped.substring(0, 2)} ${clipped.substring(2, 5)} ${clipped.substring(5)}';
  }

  void _onPhoneChanged(String value) {
    final formatted = _formatLocalPhone(value);
    if (formatted == value) return;
    _phone.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _toInputPhone(String? apiPhone) {
    if (apiPhone == null || apiPhone.trim().isEmpty) {
      return '';
    }
    var digits = apiPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('216')) {
      digits = digits.substring(3);
    }
    return digits;
  }

  @override
  void initState() {
    super.initState();
    _savedName = _initialName;
    _savedEmail = _initialEmail;
    _savedAvatarUrl = _avatarUrl;
    _name.addListener(_onFieldChanged);
    _email.addListener(_onFieldChanged);
    _phone.addListener(_onFieldChanged);
    _address.addListener(_onFieldChanged);
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
    _loadProfile();
  }

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.readToken();
    return Options(
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
    );
  }

  Future<void> _loadProfile() async {
    try {
      final r = await _dio.get('/api/profile/me', options: await _authOptions());
      if (!mounted) return;
      if ((r.statusCode ?? 500) == 401) {
        await context.read<AuthCubit>().logout();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if ((r.statusCode ?? 500) == 200 && r.data is Map) {
        final m = Map<String, dynamic>.from(r.data as Map);
        final fullName = (m['fullName'] ?? '').toString().trim();
        final email = (m['email'] ?? '').toString().trim();
        final phone = (m['phone'] ?? '').toString().trim();
        final address = (m['address'] ?? '').toString().trim();
        final avatarUrl = (m['avatarUrl'] ?? '').toString().trim();
        setState(() {
          _name.text = fullName.isEmpty ? _initialName : fullName;
          _email.text = email.isEmpty ? _initialEmail : email;
          _phone.text = _formatLocalPhone(_toInputPhone(phone));
          _address.text = address;
          _avatarUrl = avatarUrl.isEmpty ? null : avatarUrl;
          _savedName = _name.text.trim();
          _savedEmail = _email.text.trim();
          _savedPhone = _phone.text.trim();
          _savedAddress = _address.text.trim();
          _savedAvatarUrl = _avatarUrl;
        });
      }
    } catch (_) {
      // Keep screen usable with local defaults.
    }
  }

  Future<String?> _askCurrentPassword() async {
    final t = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    bool hide = true;
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(t.tr('profile_password_optional')),
            content: TextField(
              controller: ctrl,
              obscureText: hide,
              decoration: InputDecoration(
                hintText: t.tr('profile_retype_password'),
                suffixIcon: IconButton(
                  onPressed: () => setDialogState(() => hide = !hide),
                  icon: Icon(hide
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(t.tr('common_cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
                child: Text(t.tr('common_confirm')),
              ),
            ],
          ),
        );
      },
    );
    ctrl.dispose();
    return res;
  }

  void _toastPremium(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1100),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.surface,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
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

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    _haptic();

    final n = _name.text.trim();
    final e = _email.text.trim();
    final phone = _phone.text.trim();
    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    final address = _address.text.trim();
    final p = _password.text.trim();
    final c = _confirm.text.trim();

    setState(() {
      nameError = n.isEmpty || n.length < 3;
      emailError = !Validators.isValidEmail(e);
      phoneError = phone.isNotEmpty && phoneDigits.length != 8;

      final wantsPasswordChange = p.isNotEmpty || c.isNotEmpty;
      passError = wantsPasswordChange ? !Validators.isValidPassword(p) : false;
      confirmError = wantsPasswordChange ? (c != p) : false;
    });

    if (nameError || emailError || phoneError || passError || confirmError) {
      _toastPremium(t.tr('profile_check_fields'));
      return;
    }

    try {
      setState(() => _saving = true);
      final updateBody = <String, dynamic>{
        "fullName": n,
        "email": e,
        "phone": _toApiPhone(phone),
        "avatarUrl": _avatarUrl ?? "",
        "address": address,
      };
      final updateResp = await _dio.put(
        '/api/profile/me',
        data: updateBody,
        options: await _authOptions(),
      );
      if ((updateResp.statusCode ?? 500) == 401) {
        await context.read<AuthCubit>().logout();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if ((updateResp.statusCode ?? 500) >= 400) {
        _toastPremium(t.tr('profile_check_fields'));
        return;
      }

      final wantsPasswordChange = p.isNotEmpty;
      if (wantsPasswordChange) {
        final currentPassword = await _askCurrentPassword();
        if (currentPassword == null || currentPassword.isEmpty) {
          _toastPremium(t.tr('profile_check_fields'));
          return;
        }
        final passResp = await _dio.put(
          '/api/profile/password',
          data: {
            "currentPassword": currentPassword,
            "newPassword": p,
          },
          options: await _authOptions(),
        );
        if ((passResp.statusCode ?? 500) >= 400) {
          _toastPremium(t.tr('profile_check_fields'));
          return;
        }
      }

      setState(() {
        _savedName = n;
        _savedEmail = e;
        _savedPhone = phone;
        _savedAddress = address;
        _savedAvatarUrl = _avatarUrl;
        _lastUpdatedAt = DateTime.now();
        _password.clear();
        _confirm.clear();
      });
      _toastPremium(t.tr('profile_saved'));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _changeAvatar() async {
    final t = AppLocalizations.of(context);
    _haptic();

    const a1 =
        "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=300";
    const a2 =
        "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=300";

    final ok = await _confirmDialog(
      title: t.tr('profile_change_photo_confirm'),
      confirmText: t.tr('common_change'),
      cancelText: t.tr('common_cancel'),
      confirmColor: AppColors.bordeaux,
    );
    if (!ok) return;

    setState(() {
      _avatarUrl = (_avatarUrl == null || _avatarUrl == a2) ? a1 : a2;
    });

    _toastPremium(t.tr('profile_photo_updated'));
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context);
    _haptic();
    final ok = await _confirmDialog(
      title: t.tr('profile_logout_confirm'),
      confirmText: t.tr('profile_logout'),
      cancelText: t.tr('common_cancel'),
      confirmColor: Colors.red,
    );
    if (!ok) return;
    if (!mounted) return;

    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);

    _toastPremium(t.tr('profile_logged_out'));
  }

  void _openServicesSheet() {
    final t = AppLocalizations.of(context);
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
                        Text(
                          t.tr('profile_services'),
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
                                title: t.tr('notif_title'),
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
                                title: t.tr('cart_tracking'),
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const DeliveryTrackingScreen(),
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
                          title: t.tr('notif_title'),
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
                          title: t.tr('cart_tracking'),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DeliveryTrackingScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ServiceTile(
                          icon: Icons.receipt_long_rounded,
                          title: "Historique commandes",
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OrderHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _ServiceTile(
                          icon: Icons.settings_rounded,
                          title: t.tr('settings_title'),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).pushNamed(AppRoutes.settings);
                          },
                        ),
                        const SizedBox(height: 8),
                        _ServiceTile(
                          icon: Icons.info_outline_rounded,
                          title: t.tr('profile_contact_about'),
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
    _phone.removeListener(_onFieldChanged);
    _address.removeListener(_onFieldChanged);
    _password.removeListener(_onFieldChanged);
    _confirm.removeListener(_onFieldChanged);
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bg = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.bordeauxDark,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_rounded, size: 16, color: AppColors.bordeauxDark),
              SizedBox(width: 8),
              Text(
                t.tr('nav_profile'),
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
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: AppColors.bordeaux.withValues(alpha: 0.18),
                  ),
                ),
                icon: const Icon(
                  Icons.widgets_rounded,
                  color: AppColors.bordeaux,
                  size: 20,
                ),
                tooltip: t.tr('profile_services'),
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
                  text: t.tr('common_save'),
                  onPressed: (_hasChanges && !_saving) ? _save : null,
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
                            t.tr(
                              'profile_last_update',
                              params: {
                                'time':
                                    "${_lastUpdatedAt!.hour.toString().padLeft(2, '0')}:${_lastUpdatedAt!.minute.toString().padLeft(2, '0')}",
                              },
                            ),
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
                          Text(
                            t.tr('profile_account_info'),
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.tr('profile_edit_hint'),
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
              _ProfileSectionTitle(t.tr('profile_account_section')),
              const SizedBox(height: 8),

              // ✅ info box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                decoration: AppSurface.softCard(),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.bordeaux),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.tr('profile_password_optional_hint'),
                        style: const TextStyle(
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
                      label: t.tr('profile_full_name'),
                      hint: t.tr('profile_enter_name'),
                      controller: _name,
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.muted),
                    ),
                    if (nameError) _FieldError(t.tr('profile_name_invalid')),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: t.tr('profile_email'),
                      hint: t.tr('profile_enter_email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded,
                          color: AppColors.muted),
                    ),
                    if (emailError) _FieldError(t.tr('profile_email_invalid')),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Téléphone (optionnel)',
                      hint: 'XX XXX XXX',
                      controller: _phone,
                      onChanged: _onPhoneChanged,
                      keyboardType: TextInputType.phone,
                      prefixText: '$_tnDialCode ',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: AppColors.muted),
                    ),
                    if (phoneError) const _FieldError('Téléphone invalide'),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Adresse (optionnel)',
                      hint: 'Votre adresse',
                      controller: _address,
                      keyboardType: TextInputType.streetAddress,
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          color: AppColors.muted),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: t.tr('profile_password_optional'),
                      hint: t.tr('profile_new_password'),
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
                    if (passError) _FieldError(t.tr('profile_password_invalid')),
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
                            t.tr(
                              'profile_password_strength',
                              params: {
                                'level': switch (_passwordStrengthKey) {
                                  'strong' => t.tr('common_strong'),
                                  'medium' => t.tr('common_medium'),
                                  _ => t.tr('common_weak'),
                                },
                              },
                            ),
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
                      label: t.tr('profile_confirm_password'),
                      hint: t.tr('profile_retype_password'),
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
                    if (confirmError) _FieldError(t.tr('profile_password_mismatch')),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                  label: Text(
                    t.tr('profile_logout'),
                    style: const TextStyle(
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
