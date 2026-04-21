import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppSettingsState {
  final bool darkMode;
  final bool animationsEnabled;
  final bool pushNotifications;
  final bool hapticsEnabled;
  final String languageCode;

  const AppSettingsState({
    this.darkMode = false,
    this.animationsEnabled = true,
    this.pushNotifications = true,
    this.hapticsEnabled = true,
    this.languageCode = 'fr',
  });

  AppSettingsState copyWith({
    bool? darkMode,
    bool? animationsEnabled,
    bool? pushNotifications,
    bool? hapticsEnabled,
    String? languageCode,
  }) {
    return AppSettingsState(
      darkMode: darkMode ?? this.darkMode,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  int get enabledCount {
    var count = 0;
    if (darkMode) count++;
    if (animationsEnabled) count++;
    if (pushNotifications) count++;
    if (hapticsEnabled) count++;
    return count;
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  static const _kDark = 'settings_dark_mode';
  static const _kAnim = 'settings_animations';
  static const _kNotif = 'settings_push_notif';
  static const _kHaptics = 'settings_haptics';
  static const _kLang = 'settings_lang';

  AppSettingsCubit() : super(const AppSettingsState()) {
    _hydrate();
  }

  Future<void> setDarkMode(bool value) async {
    final next = state.copyWith(darkMode: value);
    emit(next);
    await _persist(next);
  }

  Future<void> setAnimations(bool value) async {
    final next = state.copyWith(animationsEnabled: value);
    emit(next);
    await _persist(next);
  }

  Future<void> setPushNotifications(bool value) async {
    final next = state.copyWith(pushNotifications: value);
    emit(next);
    await _persist(next);
  }

  Future<void> setHaptics(bool value) async {
    final next = state.copyWith(hapticsEnabled: value);
    emit(next);
    await _persist(next);
  }

  Future<void> setLanguageCode(String value) async {
    final code = value.trim().toLowerCase();
    if (code.isEmpty || code == state.languageCode) return;
    final next = state.copyWith(languageCode: code);
    emit(next);
    await _persist(next);
  }

  Future<void> resetDefaults() async {
    const next = AppSettingsState();
    emit(next);
    await _persist(next);
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(
        AppSettingsState(
          darkMode: prefs.getBool(_kDark) ?? false,
          animationsEnabled: prefs.getBool(_kAnim) ?? true,
          pushNotifications: prefs.getBool(_kNotif) ?? true,
          hapticsEnabled: prefs.getBool(_kHaptics) ?? true,
          languageCode: prefs.getString(_kLang) ?? 'fr',
        ),
      );
    } catch (_) {
      // keep defaults
    }
  }

  Future<void> _persist(AppSettingsState data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDark, data.darkMode);
      await prefs.setBool(_kAnim, data.animationsEnabled);
      await prefs.setBool(_kNotif, data.pushNotifications);
      await prefs.setBool(_kHaptics, data.hapticsEnabled);
      await prefs.setString(_kLang, data.languageCode);
    } catch (_) {
      // ignore persist errors
    }
  }
}
