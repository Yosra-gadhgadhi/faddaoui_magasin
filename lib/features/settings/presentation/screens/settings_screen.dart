import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/features/settings/presentation/cubit/app_settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings_rounded,
                size: 16, color: AppColors.bordeauxDark),
            SizedBox(width: 8),
            Text(
              "Paramètres",
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bordeaux.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
                ),
                child: const Text(
                  "Réglez votre app pour une expérience douce, simple et fluide.",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SettingSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: "Mode sombre",
                subtitle: "Basculer entre thème clair/sombre",
                value: s.darkMode,
                onChanged: (v) =>
                    context.read<AppSettingsCubit>().setDarkMode(v),
              ),
              _SettingSwitchTile(
                icon: Icons.auto_awesome_motion_rounded,
                title: "Animations",
                subtitle: "Transitions fluides entre interfaces",
                value: s.animationsEnabled,
                onChanged: (v) =>
                    context.read<AppSettingsCubit>().setAnimations(v),
              ),
              _SettingSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: "Notifications push",
                subtitle: "Promos, suivi commande, nouveautés",
                value: s.pushNotifications,
                onChanged: (v) =>
                    context.read<AppSettingsCubit>().setPushNotifications(v),
              ),
              _SettingSwitchTile(
                icon: Icons.vibration_rounded,
                title: "Vibrations",
                subtitle: "Feedback tactile sur les actions",
                value: s.hapticsEnabled,
                onChanged: (v) =>
                    context.read<AppSettingsCubit>().setHaptics(v),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
