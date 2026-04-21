import 'package:flutter/material.dart';

import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Keep intro flow visible every launch for now.
  static const bool _forceIntroFlow = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 1650));
    if (!mounted) return;

    if (_forceIntroFlow) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.local_grocery_store_rounded,
              size: 78,
              color: AppColors.bordeaux,
            ),
            SizedBox(height: 16),
            Text(
              'ElFaddaoui',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 18),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.bordeaux,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'v2.0',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
