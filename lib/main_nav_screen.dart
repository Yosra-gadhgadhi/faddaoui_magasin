import 'dart:ui';

import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:elfaddoui_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';

// Screens
import 'package:elfaddoui_app/features/home/presentation/screens/home_screen.dart';
import 'package:elfaddoui_app/features/home/presentation/screens/chatbot_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/categories_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/category_products_screen.dart';
import 'package:elfaddoui_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:elfaddoui_app/features/favorites/presentation/screens/favorites_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  void _goToTab(int i) {
    if (i < 0 || i > 3) return;
    setState(() => _index = i);
  }

  void _openChatbot() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => HomeCubit(AiHomeService())..init(),
          child: const ChatbotScreen(),
        ),
      ),
    );
  }

  void _openProductsFromCategories() {
    _goToTab(1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CategoryProductsScreen(categoryName: t.tr('popular_category')),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = <({String label, IconData icon, IconData activeIcon})>[
      (
        label: t.tr('nav_home'),
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded
      ),
      (
        label: t.tr('nav_categories'),
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded
      ),
      (
        label: t.tr('nav_favorites'),
        icon: Icons.favorite_outline_rounded,
        activeIcon: Icons.favorite_rounded
      ),
      (
        label: t.tr('nav_cart'),
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart_rounded
      ),
    ];

    final pages = <Widget>[
      const HomeScreen(),
      const CategoriesScreen(),
      FavoritesScreen(
        onGoCategories: () => _goToTab(1),
        onGoProducts: _openProductsFromCategories,
      ),
      CartScreen(
        onGoCategories: () => _goToTab(1),
        onGoProducts: _openProductsFromCategories,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        for (final i in [0, 1])
                          Expanded(
                            child: _NavItemTile(
                              index: i,
                              currentIndex: _index,
                              item: items[i],
                              onTap: () => _goToTab(i),
                            ),
                          ),
                        const SizedBox(width: 56),
                        for (final i in [2, 3])
                          Expanded(
                            child: _NavItemTile(
                              index: i,
                              currentIndex: _index,
                              item: items[i],
                              onTap: () => _goToTab(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -14,
                child: _ChatbotCenterButton(onTap: _openChatbot),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final int index;
  final int currentIndex;
  final ({String label, IconData icon, IconData activeIcon}) item;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.index,
    required this.currentIndex,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final count = index == 2
        ? context.watch<FavoritesCubit>().state.length
        : index == 3
            ? context
                .watch<CartCubit>()
                .state
                .values
                .fold(0, (sum, e) => sum + e.qty)
            : 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.bordeaux.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavBadgeIcon(
              icon: selected ? item.activeIcon : item.icon,
              count: count,
              active: selected,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? AppColors.bordeaux : AppColors.muted,
                  fontSize: selected ? 10.8 : 10.2,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatbotCenterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ChatbotCenterButton({required this.onTap});

  @override
  State<_ChatbotCenterButton> createState() => _ChatbotCenterButtonState();
}

class _ChatbotCenterButtonState extends State<_ChatbotCenterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1450),
  )..repeat(reverse: true);

  bool _pressed = false;

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_floatCtrl.value);
        final dy = -2.0 * t;
        final shadowAlpha = 0.15 + (0.08 * t);

        return Transform.translate(
          offset: Offset(0, dy),
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              onTap: widget.onTap,
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: AppColors.bordeaux.withValues(alpha: 0.40)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bordeaux.withValues(alpha: shadowAlpha),
                      blurRadius: 16 + (2 * t),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 21,
                  color: AppColors.bordeaux,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  const _NavBadgeIcon(
      {required this.icon, required this.count, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: active ? AppColors.bordeaux : AppColors.muted),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: Text(
                  "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
