import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/widgets/primary_card.dart';
import 'package:elfaddoui_app/core/widgets/section_header.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/categories_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/category_products_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onGoCategories;
  final VoidCallback? onGoProducts;

  const FavoritesScreen({
    super.key,
    this.onGoCategories,
    this.onGoProducts,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _search = TextEditingController();
  int _segment = 0;
  int _sort = 0;

  static const List<String> _segments = ['Tous', 'Petit prix', 'Top'];
  static const List<String> _sortLabels = [
    'Récents',
    'A-Z',
    'Prix +',
    'Prix -',
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _haptic() => HapticFeedback.selectionClick();

  void _toast(BuildContext context, String text) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111111),
          duration: const Duration(milliseconds: 1200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  void _removeWithUndo(BuildContext context, FavoriteItem item) {
    context.read<FavoritesCubit>().remove(item.id);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Text('${item.name} retiré des favoris'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () => context.read<FavoritesCubit>().toggle(item),
          ),
        ),
      );
  }

  Future<bool> _confirmDialog(BuildContext context, String title,
      {String confirmText = 'Confirmer',
      Color confirmColor = Colors.red}) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            fontSize: 18,
          ),
        ),
        content: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return res ?? false;
  }

  void _goCategories(BuildContext context) {
    _haptic();
    if (widget.onGoCategories != null) {
      widget.onGoCategories!.call();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
    );
  }

  void _goProducts(BuildContext context) {
    _haptic();
    if (widget.onGoProducts != null) {
      widget.onGoProducts!.call();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CategoryProductsScreen(categoryName: "Populaires"),
      ),
    );
  }

  void _addToCart(BuildContext context, FavoriteItem item) {
    context.read<CartCubit>().add(
          id: item.id,
          name: item.name,
          image: item.image,
          price: item.price,
          qty: 1,
        );
    _toast(context, '${item.name} ajouté au panier');
  }

  void _addAllToCart(BuildContext context, List<FavoriteItem> items) {
    for (final it in items) {
      context.read<CartCubit>().add(
            id: it.id,
            name: it.name,
            image: it.image,
            price: it.price,
            qty: 1,
          );
    }
    _toast(context, '${items.length} produit(s) ajoutés au panier');
  }

  List<FavoriteItem> _buildView(List<FavoriteItem> src) {
    final q = _search.text.trim().toLowerCase();
    var list = src.where((e) {
      final searchOk = q.isEmpty || e.name.toLowerCase().contains(q);
      final segOk = switch (_segment) {
        1 => e.price < 10,
        2 => e.price >= 10,
        _ => true,
      };
      return searchOk && segOk;
    }).toList();

    switch (_sort) {
      case 1:
        list.sort((a, b) => a.name.compareTo(b.name));
      case 2:
        list.sort((a, b) => a.price.compareTo(b.price));
      case 3:
        list.sort((a, b) => b.price.compareTo(a.price));
      default:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded,
                  size: 16, color: AppColors.bordeauxDark),
              SizedBox(width: 8),
              Text(
                'Favoris',
                style: TextStyle(
                  color: AppColors.bordeauxDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () {
              setState(() {
                _segment = 0;
                _sort = 0;
              });
              _search.clear();
            },
            icon: Container(
              width: 34,
              height: 34,
              decoration: AppSurface.iconContainer(borderAlpha: 0.14),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.bordeaux,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, Map<String, FavoriteItem>>(
        builder: (context, favs) {
          final all = favs.values.toList();
          final items = _buildView(all);
          final cartIds = context.watch<CartCubit>().state.keys.toSet();

          return Column(
            children: [
              _TopPanel(
                controller: _search,
                segment: _segment,
                segments: _segments,
                onSegmentTap: (i) => setState(() => _segment = i),
                sortLabel: _sortLabels[_sort],
                onSelectSort: (i) => setState(() => _sort = i),
                sortLabels: _sortLabels,
                total: all.length,
                visible: items.length,
                onAddAll: all.isEmpty ? null : () => _addAllToCart(context, all),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: SectionHeader(
                  title: 'Produits favoris',
                  subtitle: '${items.length} résultats',
                ),
              ),
              Expanded(
                child: all.isEmpty
                    ? _EmptyFavorites(
                        onGoProducts: () => _goProducts(context),
                        onGoCategories: () => _goCategories(context),
                      )
                    : items.isEmpty
                        ? _NoResult(
                            onReset: () {
                              setState(() {
                                _segment = 0;
                                _sort = 0;
                              });
                              _search.clear();
                            },
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (_, i) {
                              final it = items[i];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, child) => Opacity(
                                  opacity: v,
                                  child: Transform.translate(
                                    offset: Offset(0, 12 * (1 - v)),
                                    child: child,
                                  ),
                                ),
                                child: Dismissible(
                                  key: ValueKey('fav_${it.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 18),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.red.withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: Colors.red.withValues(alpha: 0.24),
                                      ),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/poubelle.png',
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.delete_rounded, color: Colors.red),
                                    ),
                                  ),
                                  confirmDismiss: (_) async => _confirmDialog(
                                    context,
                                    'Retirer ce produit des favoris ?',
                                    confirmText: 'Retirer',
                                  ),
                                  onDismissed: (_) => _removeWithUndo(context, it),
                                  child: _FavoriteCard(
                                    item: it,
                                    inCart: cartIds.contains(it.id),
                                    onOpen: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsScreen(
                                            productId: it.id,
                                            initialName: it.name,
                                            initialImage: it.image,
                                            initialPrice: it.price,
                                          ),
                                        ),
                                      );
                                    },
                                    onToggle: () {
                                      _haptic();
                                      context.read<FavoritesCubit>().toggle(it);
                                      _toast(context, 'Mise à jour des favoris');
                                    },
                                    onAddToCart: () => _addToCart(context, it),
                                    onRemove: () async {
                                      final ok = await _confirmDialog(
                                        context,
                                        'Retirer ce produit des favoris ?',
                                        confirmText: 'Retirer',
                                      );
                                      if (!ok) return;
                                      if (!context.mounted) return;
                                      _removeWithUndo(context, it);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopPanel extends StatelessWidget {
  final TextEditingController controller;
  final int segment;
  final List<String> segments;
  final ValueChanged<int> onSegmentTap;
  final String sortLabel;
  final ValueChanged<int> onSelectSort;
  final List<String> sortLabels;
  final int total;
  final int visible;
  final VoidCallback? onAddAll;

  const _TopPanel({
    required this.controller,
    required this.segment,
    required this.segments,
    required this.onSegmentTap,
    required this.sortLabel,
    required this.onSelectSort,
    required this.sortLabels,
    required this.total,
    required this.visible,
    required this.onAddAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        children: [
          PrimaryCard(
            padding: const EdgeInsets.all(14),
            radius: AppRadius.lg,
            borderAlpha: 0.16,
            color: AppColors.bordeaux.withValues(alpha: 0.06),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 20, color: AppColors.bordeaux),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choisissez un produit favori pour voir les détails.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$visible résultat${visible > 1 ? 's' : ''} / $total favoris',
                        style: TextStyle(
                          color: AppColors.muted.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SearchField(
            controller: controller,
            hint: 'Rechercher un produit favori…',
            onClear: controller.clear,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSize.chipHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: segments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = segment == i;
                      return InkWell(
                        onTap: () => onSegmentTap(i),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.bordeaux.withValues(alpha: 0.10)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: selected
                                  ? AppColors.bordeaux.withValues(alpha: 0.26)
                                  : AppColors.border.withValues(alpha: 0.72),
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              segments[i],
                              style: TextStyle(
                                color: selected
                                    ? AppColors.bordeaux
                                    : AppColors.text.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<int>(
                onSelected: onSelectSort,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.82)),
                ),
                itemBuilder: (_) => List.generate(sortLabels.length, (i) {
                  return PopupMenuItem<int>(
                    value: i,
                    child: Text(
                      sortLabels[i],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
                child: Container(
                  height: AppSize.chipHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: AppSurface.card(
                    radius: AppRadius.pill,
                    borderAlpha: 0.95,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert_rounded,
                          size: 16, color: AppColors.bordeaux),
                      const SizedBox(width: 6),
                      Text(
                        sortLabel,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (onAddAll != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: onAddAll,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text(
                  'Tout ajouter au panier',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.bordeaux,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.bordeaux),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, __) {
            if (v.text.trim().isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: onClear,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.bordeaux,
                size: 18,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final bool inCart;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.item,
    required this.inCart,
    required this.onOpen,
    required this.onToggle,
    required this.onAddToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: PrimaryCard(
        padding: const EdgeInsets.all(12),
        radius: AppRadius.lg,
        borderAlpha: 0.82,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 92,
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.soft,
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _IconAction(
                        icon: inCart
                            ? Icons.check_rounded
                            : Icons.add_shopping_cart_rounded,
                        color: inCart
                            ? const Color(0xFF138A57)
                            : AppColors.bordeauxDark,
                        isActive: inCart,
                        onTap: onAddToCart,
                      ),
                      const SizedBox(width: 6),
                      _IconAction(
                        icon: Icons.favorite_rounded,
                        color: AppColors.bordeaux,
                        onTap: onToggle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toStringAsFixed(2)} DT',
                    style: const TextStyle(
                      color: AppColors.bordeaux,
                      fontSize: 17.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _DetailButton(onTap: onOpen)),
                      const SizedBox(width: 8),
                      _MoreButton(
                        onOpen: onOpen,
                        onRemove: onRemove,
                        onAddToCart: onAddToCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DetailButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bordeaux.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: AppColors.bordeaux.withValues(alpha: 0.24),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.bordeaux),
            SizedBox(width: 6),
            Text(
              'Voir détail',
              style: TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.color,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFEAF8F0)
              : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive
                ? const Color(0xFFBEE6CF)
                : AppColors.lightGrey.withValues(alpha: 0.95),
            width: 0.9,
          ),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  const _MoreButton({
    required this.onOpen,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionTile(
                    icon: Icons.open_in_new_rounded,
                    text: 'Voir détail',
                    onTap: () {
                      Navigator.pop(ctx);
                      onOpen();
                    },
                  ),
                  _ActionTile(
                    icon: Icons.add_shopping_cart_rounded,
                    text: 'Ajouter au panier',
                    onTap: () {
                      Navigator.pop(ctx);
                      onAddToCart();
                    },
                  ),
                  _ActionTile(
                    icon: Icons.delete_outline_rounded,
                    imageAsset: 'assets/icons/poubelle.png',
                    text: 'Retirer des favoris',
                    isDanger: true,
                    onTap: () {
                      Navigator.pop(ctx);
                      onRemove();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 40,
        height: 40,
        decoration: AppSurface.card(radius: 11, borderAlpha: 0.95),
        child: const Icon(Icons.auto_awesome_rounded,
            size: 16, color: AppColors.bordeauxDark),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String? imageAsset;
  final String text;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    this.imageAsset,
    required this.text,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightGrey.withValues(alpha: 0.95),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    size: 18,
                    color: isDanger ? Colors.red : AppColors.bordeauxDark,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18,
                  color: isDanger ? Colors.red : AppColors.bordeauxDark,
                ),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: isDanger ? Colors.red : AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResult extends StatelessWidget {
  final VoidCallback onReset;
  const _NoResult({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.82),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 34, color: AppColors.muted),
              const SizedBox(height: 10),
              const Text(
                'Aucun résultat',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.bordeaux,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Réinitialiser'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final VoidCallback onGoProducts;
  final VoidCallback onGoCategories;

  const _EmptyFavorites({
    required this.onGoProducts,
    required this.onGoCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.82),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.bordeaux.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.lightGrey.withValues(alpha: 0.95)),
                ),
                child: const Icon(Icons.favorite_border_rounded,
                    color: AppColors.bordeaux, size: 26),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aucun produit favori pour le moment',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ajoutez vos produits préférés en cliquant sur le cœur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: onGoProducts,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.bordeaux,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Découvrir des produits',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: onGoCategories,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bordeaux,
                    side:
                        BorderSide(color: AppColors.border.withValues(alpha: 0.86)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Voir les catégories',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
