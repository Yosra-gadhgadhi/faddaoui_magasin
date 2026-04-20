import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';

import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:elfaddoui_app/features/checkout/presentation/screens/checkout_step1_personal.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';

// Navigation targets
import 'package:elfaddoui_app/features/catalog/presentation/screens/categories_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/category_products_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onGoCategories;
  final VoidCallback? onGoProducts;

  const CartScreen({
    super.key,
    this.onGoCategories,
    this.onGoProducts,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const double delivery = 4.0;

  List<_CartItem> _itemsFromCart(Map<String, CartLine> cart) {
    return cart.values
        .map(
          (e) => _CartItem(
            id: e.id,
            name: e.name,
            unit: "Quantité: ${e.qty}",
            price: e.price,
            oldPrice: null,
            qty: e.qty,
            tag: "Panier",
            image: e.image,
          ),
        )
        .toList();
  }

  double _subtotal(List<_CartItem> items) => items.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.qty.toDouble()),
      );

  double _total(List<_CartItem> items) =>
      items.isEmpty ? 0.0 : _subtotal(items) + delivery;

  void _haptic() => HapticFeedback.selectionClick();

  Future<bool> _confirmDialog({
    required BuildContext context,
    required String title,
    required String confirmText,
    String cancelText = "Annuler",
    Color confirmColor = AppColors.bordeaux,
  }) async {
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
                child: Text(
                  cancelText,
                  style: const TextStyle(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return res ?? false;
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

  void _goToCheckout(double total) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutStep1Personal(total: total),
      ),
    );
  }

  // Go to categories screen
  void _goToCategories() {
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

  // Go to products screen (default category)
  void _goToProducts() {
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
              Icon(Icons.shopping_cart_checkout_rounded,
                  size: 16, color: AppColors.bordeauxDark),
              SizedBox(width: 8),
              Text(
                "Panier",
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
          IconButton(
            tooltip: "Suivi",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeliveryTrackingScreen(),
                ),
              );
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: AppSurface.iconContainer(borderAlpha: 0.14),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: AppColors.bordeaux,
                size: 18,
              ),
            ),
          ),
          BlocBuilder<CartCubit, Map<String, CartLine>>(
            builder: (context, cart) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: "Vider",
                onPressed: () async {
                  final ok = await _confirmDialog(
                    context: context,
                    title: "Vider tout le panier ?",
                    confirmText: "Vider",
                    confirmColor: Colors.red,
                  );
                  if (!ok) return;
                  if (!context.mounted) return;
                  context.read<CartCubit>().clear();
                  _toastPremium("Panier vidé");
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: AppSurface.iconContainer(borderAlpha: 0.14),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/icons/poubelle.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.bordeaux,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, Map<String, CartLine>>(
        builder: (context, cart) {
          final items = _itemsFromCart(cart);
          final subtotal = _subtotal(items);
          final total = _total(items);
          return SafeArea(
            top: false,
            child: _CheckoutBar(
              enabled: items.isNotEmpty,
              subtotal: subtotal,
              delivery: items.isEmpty ? 0.0 : delivery,
              total: total,
              onCheckout: items.isEmpty ? null : () => _goToCheckout(total),
            ),
          );
        },
      ),
      body: BlocBuilder<CartCubit, Map<String, CartLine>>(
        builder: (context, cart) {
          final items = _itemsFromCart(cart);
          return Column(
            children: [
              const _InfoBar(),
              Expanded(
                child: items.isEmpty
                    ? _EmptyCartPremium(
                        onGoProducts: _goToProducts,
                        onGoCategories: _goToCategories,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final it = items[i];

                          return _CartCard(
                            item: it,
                            onMinus: () {
                              _haptic();
                              context
                                  .read<CartCubit>()
                                  .setQty(it.id, it.qty - 1);
                            },
                            onPlus: () {
                              _haptic();
                              context
                                  .read<CartCubit>()
                                  .setQty(it.id, it.qty + 1);
                            },
                            onRemove: () async {
                              _haptic();
                              final ok = await _confirmDialog(
                                context: context,
                                title: "Supprimer ce produit ?",
                                confirmText: "Supprimer",
                                confirmColor: Colors.red,
                              );
                              if (!ok) return;
                              if (!context.mounted) return;
                              context.read<CartCubit>().remove(it.id);
                              _toastPremium("Produit supprimé");
                            },
                            onToggleFavorite: () {
                              _haptic();
                              context.read<FavoritesCubit>().toggle(
                                    FavoriteItem(
                                      id: it.id,
                                      name: it.name,
                                      image: it.image,
                                      price: it.price,
                                    ),
                                  );

                              final isFav = context
                                  .read<FavoritesCubit>()
                                  .isFavorite(it.id);
                              _toastPremium(
                                isFav ? "Ajouté aux favoris" : "Retiré des favoris",
                              );
                            },
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

/* ================= UI ================= */

class _InfoBar extends StatelessWidget {
  const _InfoBar();

  @override
  Widget build(BuildContext context) {
    final softBordeaux = AppColors.bordeaux.withValues(alpha: 0.06);
    final softBorder = AppColors.bordeaux.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xxs,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppSurface.softCard(
          radius: AppRadius.lg,
          tintAlpha: 0.06,
          borderAlpha: 0.18,
        ).copyWith(color: softBordeaux, border: Border.all(color: softBorder)),
        child: const Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: AppColors.bordeaux),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Livraison estimée : 45–60 min • Paiement à la livraison ou par carte",
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartCard extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;
  final VoidCallback onToggleFavorite;

  const _CartCard({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = (item.price * item.qty.toDouble()).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: AppSurface.card(radius: AppRadius.xl, borderAlpha: 1),
      child: Stack(
        children: [
          Positioned(
            top: -6,
            right: -6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<FavoritesCubit, Map<String, FavoriteItem>>(
                  builder: (context, favs) {
                    final isFav = favs.containsKey(item.id);
                    return InkWell(
                      onTap: onToggleFavorite,
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            color: AppColors.bordeaux,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: "",
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onSelected: (v) {
                    if (v == "fav") onToggleFavorite();
                    if (v == "remove") onRemove();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: "fav",
                      height: 42,
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 20),
                          SizedBox(width: 12),
                          Text("Favoris",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 8),
                    PopupMenuItem(
                      value: "remove",
                      height: 42,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              'assets/icons/poubelle.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.delete_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Supprimer",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: const SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(
                        child: Icon(Icons.more_vert_rounded,
                            color: AppColors.muted)),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  item.image,
                  height: 78,
                  width: 78,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Container(
                    height: 78,
                    width: 78,
                    color: AppColors.soft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Tag(text: item.tag),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item.unit,
                        style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "${item.price.toStringAsFixed(2)} DT",
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.bordeaux),
                        ),
                        if (item.oldPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            "${item.oldPrice!.toStringAsFixed(2)} DT",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QtyBtn(icon: Icons.remove_rounded, onTap: onMinus),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("${item.qty}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        _QtyBtn(icon: Icons.add_rounded, onTap: onPlus),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            "$lineTotal DT",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.bordeaux),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AppColors.bordeaux),
      ),
    );
  }
}

/* ================= CHECKOUT BAR ================= */

class _CheckoutBar extends StatelessWidget {
  final bool enabled;
  final double subtotal;
  final double delivery;
  final double total;
  final VoidCallback? onCheckout;

  const _CheckoutBar({
    required this.enabled,
    required this.subtotal,
    required this.delivery,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    const freeDeliveryThreshold = 40.0;
    final missingForFree =
        (freeDeliveryThreshold - subtotal).clamp(0.0, freeDeliveryThreshold);
    final progress = (subtotal / freeDeliveryThreshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enabled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missingForFree <= 0
                        ? "Livraison gratuite débloquée"
                        : "Ajoutez ${missingForFree.toStringAsFixed(2)} DT pour la livraison gratuite",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: progress,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.bordeaux),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _Line(label: "Sous-total", value: subtotal),
          _Line(label: "Livraison", value: delivery),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text("Total",
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
              ),
              Text(
                "${total.toStringAsFixed(2)} DT",
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: AppColors.bordeaux),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bordeaux,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.muted,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                enabled ? "Passer la commande" : "Ajoutez des produits",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final double value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(label, style: const TextStyle(color: AppColors.muted))),
          Text("${value.toStringAsFixed(2)} DT",
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/* ================= EMPTY PREMIUM ================= */

class _EmptyCartPremium extends StatelessWidget {
  final VoidCallback onGoProducts;
  final VoidCallback onGoCategories;

  const _EmptyCartPremium({
    required this.onGoProducts,
    required this.onGoCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: AppSurface.card(radius: 22, borderAlpha: 0.80),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: AppColors.bordeaux.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.bordeaux.withValues(alpha: 0.18)),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: AppColors.bordeaux, size: 42),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Votre panier est vide",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.text),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Ajoutez quelques produits et profitez des promos du jour.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      height: 1.35),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 46,
                  width: double.infinity,
                    child: ElevatedButton(
                    onPressed: onGoProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bordeaux,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Découvrir des produits",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onGoCategories,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.bordeaux,
                      side:
                          BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Voir les catégories",
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= MODEL ================= */

class _CartItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  final double? oldPrice;
  int qty;
  final String tag;
  final String image;

  _CartItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.oldPrice,
    required this.qty,
    required this.tag,
    required this.image,
  });
}
