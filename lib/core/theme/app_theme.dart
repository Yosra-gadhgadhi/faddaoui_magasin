import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData light({required bool animationsEnabled}) => ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: "Montserrat",
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.bordeauxDark,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 76,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.bordeauxDark,
            letterSpacing: 0.1,
          ),
          iconTheme: IconThemeData(
            color: AppColors.bordeauxDark,
            size: 20,
          ),
          surfaceTintColor: Colors.transparent,
        ),
        pageTransitionsTheme: _transitions(animationsEnabled),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          contentTextStyle: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.85)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: AppColors.bordeaux.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bordeaux,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.2,
            ),
            minimumSize: const Size.fromHeight(AppSize.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.bordeaux,
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: AppColors.bordeaux.withValues(alpha: 0.10),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.85)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          labelStyle: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
          secondaryLabelStyle: const TextStyle(
            color: AppColors.bordeaux,
            fontWeight: FontWeight.w800,
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.border.withValues(alpha: 0.65),
          thickness: 0.8,
          space: 1,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.bordeaux,
          primary: AppColors.bordeaux,
          secondary: const Color(0xFFB5476B),
          tertiary: const Color(0xFFEFF2F6),
          surface: Colors.white,
        ),
      );

  static ThemeData dark({required bool animationsEnabled}) => ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121216),
        fontFamily: "Montserrat",
        splashFactory: InkSparkle.splashFactory,
        pageTransitionsTheme: _transitions(animationsEnabled),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 76,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1B1B22),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.09)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A21),
          hintStyle: const TextStyle(
            color: Color(0xFFB1B1BC),
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: AppColors.bordeaux.withValues(alpha: 0.45),
              width: 1.3,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bordeaux,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(AppSize.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.bordeaux,
          brightness: Brightness.dark,
          primary: AppColors.bordeaux,
          secondary: const Color(0xFFD36A8A),
          tertiary: const Color(0xFF1E1E25),
        ),
      );

  static PageTransitionsTheme _transitions(bool enabled) {
    final builder =
        enabled ? const _SmoothTransitionsBuilder() : const _NoTransitionsBuilder();
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: builder,
        TargetPlatform.iOS: builder,
        TargetPlatform.macOS: builder,
        TargetPlatform.windows: builder,
        TargetPlatform.linux: builder,
        TargetPlatform.fuchsia: builder,
      },
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class _SmoothTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.06, 0.02);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;
    final slide = Tween(begin: begin, end: end).animate(
      CurvedAnimation(parent: animation, curve: curve),
    );
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
