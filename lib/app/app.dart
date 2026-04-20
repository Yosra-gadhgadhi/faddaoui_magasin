import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class ElFaddaouiApp extends StatelessWidget {
  const ElFaddaouiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ElFaddaoui',
      theme: AppTheme.light(animationsEnabled: true),
      initialRoute: AppRoutes.home, // Changed to home for direct access to the main app
      routes: AppRoutes.routes,
    );
  }
}
