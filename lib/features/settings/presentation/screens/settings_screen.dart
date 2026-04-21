import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/features/settings/presentation/cubit/app_settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_rounded,
                size: 16, color: AppColors.bordeauxDark),
            const SizedBox(width: 8),
            Text(
              t.tr('settings_title'),
              style: TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, s) {
          String languageLabel(String code) {
            switch (code) {
              case 'en':
                return t.tr('lang_en');
              case 'ar':
                return t.tr('lang_ar');
              default:
                return t.tr('lang_fr');
            }
          }

          Future<void> pickLanguage() async {
            final selected = await showModalBottomSheet<String>(
              context: context,
              backgroundColor: Theme.of(context).colorScheme.surface,
              showDragHandle: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              builder: (sheetContext) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(t.tr('lang_fr')),
                      trailing: s.languageCode == 'fr'
                          ? const Icon(Icons.check_rounded, color: AppColors.bordeaux)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, 'fr'),
                    ),
                    ListTile(
                      title: Text(t.tr('lang_en')),
                      trailing: s.languageCode == 'en'
                          ? const Icon(Icons.check_rounded, color: AppColors.bordeaux)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, 'en'),
                    ),
                    ListTile(
                      title: Text(t.tr('lang_ar')),
                      trailing: s.languageCode == 'ar'
                          ? const Icon(Icons.check_rounded, color: AppColors.bordeaux)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, 'ar'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
            if (selected == null || !context.mounted) return;
            await context.read<AppSettingsCubit>().setLanguageCode(selected);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  t.tr('lang_changed', params: {
                    'language': languageLabel(selected),
                  }),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 900),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bordeaux.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
                ),
                child: Text(
                  t.tr('settings_intro'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsOverviewCard(enabledCount: s.enabledCount),
              const SizedBox(height: 12),
              _SectionTitle(title: t.tr('preferences_section')),
              _SettingSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: t.tr('dark_mode'),
                subtitle: t.tr('dark_mode_subtitle'),
                value: s.darkMode,
                onChanged: (v) =>
                    context.read<AppSettingsCubit>().setDarkMode(v),
              ),
              _SettingSwitchTile(
                icon: Icons.auto_awesome_motion_rounded,
                title: t.tr('animations'),
                subtitle: t.tr('animations_subtitle'),
                value: s.animationsEnabled,
                onChanged: (v) =>
                    context.read<AppSettingsCubit>().setAnimations(v),
              ),
              _SettingSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: t.tr('push_notifications'),
                subtitle: t.tr('push_notifications_subtitle'),
                value: s.pushNotifications,
                onChanged: (v) async {
                  await context.read<AppSettingsCubit>().setPushNotifications(v);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(v ? t.tr('push_enabled') : t.tr('push_disabled')),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
                },
              ),
              _SettingSwitchTile(
                icon: Icons.vibration_rounded,
                title: t.tr('vibrations'),
                subtitle: t.tr('vibrations_subtitle'),
                value: s.hapticsEnabled,
                onChanged: (v) async {
                  await context.read<AppSettingsCubit>().setHaptics(v);
                  if (!context.mounted) return;
                  if (v) {
                    HapticFeedback.lightImpact();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        v ? t.tr('vibrations_enabled') : t.tr('vibrations_disabled'),
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              _SectionTitle(title: t.tr('account_security_section')),
              _SettingInfoTile(
                icon: Icons.language_rounded,
                title: t.tr('language'),
                subtitle: languageLabel(s.languageCode),
                isDark: isDark,
                onTap: pickLanguage,
              ),
              _SettingInfoTile(
                icon: Icons.lock_outline_rounded,
                title: t.tr('privacy'),
                subtitle: t.tr('privacy_subtitle'),
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.tr('privacy_soon')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _SettingInfoTile(
                icon: Icons.help_outline_rounded,
                title: t.tr('help'),
                subtitle: t.tr('help_subtitle'),
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.tr('help_soon')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<AppSettingsCubit>().resetDefaults(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bordeaux,
                    side: BorderSide(
                      color: AppColors.bordeaux.withValues(alpha: 0.28),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: Text(
                    t.tr('reset_settings'),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A20) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 17, color: AppColors.bordeaux),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.bordeaux,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsOverviewCard extends StatelessWidget {
  final int enabledCount;

  const _SettingsOverviewCard({required this.enabledCount});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A20) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.bordeaux.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.bordeaux.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.bordeaux,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.tr('current_status'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.tr('enabled_options', params: {'count': '$enabledCount'}),
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          fontSize: 14.5,
        ),
      ),
    );
  }
}

class _SettingInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A20) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, size: 17, color: AppColors.bordeaux),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
