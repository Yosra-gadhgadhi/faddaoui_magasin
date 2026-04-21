import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/l10n/product_text_localizer.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/cart/presentation/screens/cart_screen.dart';

import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> with SingleTickerProviderStateMixin {
  final _search = TextEditingController();

  bool _onlyPromo = false;
  bool _onlyBio = false;
  double _minPrice = 0;
  double _maxPrice = 200;
  SortOption _sort = SortOption.recommended;

  String? _subCat;
  late final List<String> _subCategories;

  late final List<Product> _all;
  List<Product> _view = [];

  late final AnimationController _barCtrl;
  late final Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOut);

    _subCategories = _mockSubCategories(widget.categoryName);
    _all = _mockProducts(widget.categoryName);

    _search.addListener(_apply);
    _apply();
  }

  @override
  void dispose() {
    _search.removeListener(_apply);
    _search.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final q = _search.text.trim().toLowerCase();

    final res = _all.where((p) {
      final matchesSearch = q.isEmpty || p.name.toLowerCase().contains(q);
      final matchesSub = _subCat == null || p.subCategory == _subCat;
      final matchesPromo = !_onlyPromo || p.isPromo;
      final matchesBio = !_onlyBio || p.isBio;
      final matchesPrice = p.price >= _minPrice && p.price <= _maxPrice;
      return matchesSearch && matchesSub && matchesPromo && matchesBio && matchesPrice;
    }).toList();

    res.sort((a, b) {
      switch (_sort) {
        case SortOption.priceLow:
          return a.price.compareTo(b.price);
        case SortOption.priceHigh:
          return b.price.compareTo(a.price);
        case SortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case SortOption.top:
          return b.score.compareTo(a.score);
        case SortOption.recommended:
          final sa = a.score + (a.isPromo ? 10 : 0);
          final sb = b.score + (b.isPromo ? 10 : 0);
          return sb.compareTo(sa);
      }
    });

    if (!mounted) return;
    setState(() => _view = res);
  }

  int _cartCountFrom(Map<String, CartLine> cart) {
    return cart.values.fold(0, (sum, line) => sum + line.qty);
  }

  double _cartTotalFrom(Map<String, CartLine> cart) {
    double t = 0;
    for (final line in cart.values) {
      t += line.price * line.qty;
    }
    return t;
  }

  void _add(Product p) {
    HapticFeedback.selectionClick();
    context.read<CartCubit>().add(
      id: p.id,
      name: p.name,
      image: p.image,
      price: p.price,
      qty: 1,
    );
  }

  void _removeOne(Product p) {
    HapticFeedback.selectionClick();
    final cart = context.read<CartCubit>();
    final q = cart.state[p.id]?.qty ?? 0;
    if (q <= 1) {
      cart.remove(p.id);
    } else {
      cart.setQty(p.id, q - 1);
    }
  }

  void _toastPremium(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
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
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Favorites toggle
  void _toggleFav(Product p) {
    HapticFeedback.selectionClick();

    final fav = FavoriteItem(
      id: p.id,
      name: p.name,
      image: p.image,
      price: p.price,
    );

    context.read<FavoritesCubit>().toggle(fav);
    final isFav = context.read<FavoritesCubit>().isFavorite(p.id);

    _toastPremium(
      isFav
          ? tr3(context, fr: "Ajouté aux favoris", en: "Added to favorites", ar: "تمت الإضافة للمفضلة")
          : tr3(context, fr: "Retiré des favoris", en: "Removed from favorites", ar: "تمت الإزالة من المفضلة"),
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        onlyPromo: _onlyPromo,
        onlyBio: _onlyBio,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sort: _sort,
      ),
    );

    if (result == null) return;

    setState(() {
      _onlyPromo = result.onlyPromo;
      _onlyBio = result.onlyBio;
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _sort = result.sort;
    });

    _apply();
  }

  void _openSortQuick() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sort,
        onPick: (s) {
          Navigator.pop(context);
          setState(() => _sort = s);
          _apply();
        },
      ),
    );
  }

  void _goCart() {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final crossAxisCount = w >= 420 ? 3 : 2;
    final promoCount = _view.where((p) => p.isPromo).length;
    final cart = context.watch<CartCubit>().state;
    final cartCount = _cartCountFrom(cart);
    final cartTotal = _cartTotalFrom(cart);

    if (cartCount > 0 && _barCtrl.status == AnimationStatus.dismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _barCtrl.status == AnimationStatus.dismissed) {
          _barCtrl.forward(from: 0);
        }
      });
    } else if (cartCount == 0 && _barCtrl.status != AnimationStatus.dismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _barCtrl.status != AnimationStatus.dismissed) {
          _barCtrl.reverse();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 70,
            centerTitle: true,
            leadingWidth: 52,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.bordeauxDark,
                size: 18,
              ),
            ),
            title: Text(
              widget.categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 0.1,
              ),
            ),
            actions: [
              _IconChip(icon: Icons.tune_rounded, onTap: _openFilters),
              const SizedBox(width: 12),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(66),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: _AnimatedSearchNoShadow(
                      controller: _search,
                      hint: tr3(
                        context,
                        fr: "Rechercher un produit…",
                        en: "Search a product…",
                        ar: "ابحث عن منتج…",
                      ),
                      onClear: () {
                        _search.clear();
                        _apply();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSize.chipHeight + 4,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _subCategories.length + 2,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _Pill(
                      text: tr3(context, fr: "Tout", en: "All", ar: "الكل"),
                      selected: _subCat == null,
                      onTap: () {
                        setState(() => _subCat = null);
                        _apply();
                      },
                    );
                  }
                  if (i == 1) {
                    return _Pill(
                      text: tr3(context, fr: "Tri", en: "Sort", ar: "ترتيب"),
                      selected: false,
                      onTap: _openSortQuick,
                    );
                  }
                  final s = _subCategories[i - 2];
                  return _Pill(
                    text: localizeProductText(context, s),
                    selected: _subCat == s,
                    onTap: () {
                      setState(() => _subCat = s);
                      _apply();
                    },
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _ProductsMiniSummary(
                productsCount: _view.length,
                promoCount: promoCount,
                sortLabel: _sortLabel(context, _sort),
                promoActive: _onlyPromo,
                sortActive: _sort != SortOption.recommended,
                onTapProducts: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _subCat = null;
                  });
                  _apply();
                },
                onTapPromos: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _onlyPromo = !_onlyPromo;
                  });
                  _apply();
                },
                onTapSort: _openSortQuick,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
            sliver: _view.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyStateProducts(
                      onReset: () {
                        setState(() {
                          _subCat = null;
                          _onlyPromo = false;
                          _onlyBio = false;
                          _minPrice = 0;
                          _maxPrice = 200;
                          _sort = SortOption.recommended;
                        });
                        _apply();
                      },
                    ),
                  )
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final p = _view[i];
                        final qty = cart[p.id]?.qty ?? 0;

                        return _ProductCardFine(
                          p: p,
                          qtyInCart: qty,
                          onAdd: () => _add(p),
                          onRemoveOne: () => _removeOne(p),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  productId: p.id,
                                  initialName: p.name,
                                  initialImage: p.image,
                                  initialPrice: p.price,
                                  initialOldPrice: p.oldPrice,
                                  initialCategory: widget.categoryName,
                                ),
                              ),
                            );
                          },
                          onFav: () => _toggleFav(p),
                        );
                      },
                      childCount: _view.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.71,
                    ),
                  ),
          ),
        ],
      ),

      // Cart bar
      bottomNavigationBar: cartCount == 0
          ? null
          : SafeArea(
              top: false,
              child: SizeTransition(
                sizeFactor: _barAnim,
                axisAlignment: -1,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.soft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          "$cartCount",
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${cartTotal.toStringAsFixed(2)} DT",
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.bordeaux),
                        ),
                      ),
                      SizedBox(
                        width: 132,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _goCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bordeaux,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            tr3(context, fr: "Voir panier", en: "View cart", ar: "عرض السلة"),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/* ===================== SEARCH ===================== */

class _AnimatedSearchNoShadow extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onClear;

  const _AnimatedSearchNoShadow({
    required this.controller,
    required this.hint,
    required this.onClear,
  });

  @override
  State<_AnimatedSearchNoShadow> createState() => _AnimatedSearchNoShadowState();
}

class _AnimatedSearchNoShadowState extends State<_AnimatedSearchNoShadow> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (_, v, __) {
            if (v.text.trim().isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: widget.onClear,
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

class _ProductsMiniSummary extends StatelessWidget {
  final int productsCount;
  final int promoCount;
  final String sortLabel;
  final bool promoActive;
  final bool sortActive;
  final VoidCallback onTapProducts;
  final VoidCallback onTapPromos;
  final VoidCallback onTapSort;

  const _ProductsMiniSummary({
    required this.productsCount,
    required this.promoCount,
    required this.sortLabel,
    required this.promoActive,
    required this.sortActive,
    required this.onTapProducts,
    required this.onTapPromos,
    required this.onTapSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.82)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _SummaryPill(
              icon: Icons.inventory_2_rounded,
              text: tr3(
                context,
                fr: '$productsCount produits',
                en: '$productsCount products',
                ar: '$productsCount منتج',
              ),
              onTap: onTapProducts,
            ),
            const SizedBox(width: 8),
            _SummaryPill(
              icon: Icons.local_offer_rounded,
              text: tr3(
                context,
                fr: '$promoCount promos',
                en: '$promoCount promos',
                ar: '$promoCount عروض',
              ),
              onTap: onTapPromos,
              selected: promoActive,
            ),
            const SizedBox(width: 8),
            _SummaryPill(
              icon: Icons.sort_rounded,
              text: sortLabel,
              onTap: onTapSort,
              selected: sortActive,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool selected;

  const _SummaryPill({
    required this.icon,
    required this.text,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.bordeaux.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.bordeaux.withValues(alpha: 0.26)
                : AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.5,
              color: selected ? AppColors.bordeauxDark : AppColors.bordeaux,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                color: selected ? AppColors.bordeauxDark : AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== ACTION ICON ===================== */

class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        ),
        child: Icon(icon, size: 18, color: AppColors.bordeaux),
      ),
    );
  }
}

/* ===================== PILLS ===================== */

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Container(
        height: AppSize.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 13),
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
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? AppColors.bordeaux : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== EMPTY ===================== */

class _EmptyStateProducts extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyStateProducts({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.70)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.muted, size: 34),
          const SizedBox(height: 10),
          Text(
            tr3(
              context,
              fr: "Aucun produit trouvé.",
              en: "No products found.",
              ar: "لم يتم العثور على منتجات.",
            ),
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            tr3(
              context,
              fr: "Essayez de changer les filtres ou la recherche.",
              en: "Try changing filters or search.",
              ar: "جرّب تغيير الفلاتر أو البحث.",
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bordeaux,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                tr3(context, fr: "Réinitialiser", en: "Reset", ar: "إعادة الضبط"),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== PRODUCT CARD ===================== */

class _ProductCardFine extends StatefulWidget {
  final Product p;
  final int qtyInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemoveOne;
  final VoidCallback onTap;
  final VoidCallback onFav;

  const _ProductCardFine({
    required this.p,
    required this.qtyInCart,
    required this.onAdd,
    required this.onRemoveOne,
    required this.onTap,
    required this.onFav,
  });

  @override
  State<_ProductCardFine> createState() => _ProductCardFineState();
}

class _ProductCardFineState extends State<_ProductCardFine> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: "p-img-${p.id}",
                        child: Image.network(
                          p.image,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                          loadingBuilder: (c, w, prog) {
                            if (prog == null) return w;
                            return Container(
                              color: AppColors.soft,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.soft,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.muted),
                          ),
                        ),
                      ),
                      if (p.isPromo)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _MiniBadge(
                            text: tr3(
                              context,
                              fr: "Promo",
                              en: "Promo",
                              ar: "عرض",
                            ),
                          ),
                        ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.93),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.85),
                            ),
                          ),
                          child: Text(
                            "★ ${((p.score / 20).clamp(3.0, 5.0)).toStringAsFixed(1)}",
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: BlocBuilder<FavoritesCubit, Map<String, FavoriteItem>>(
                          builder: (context, favs) {
                            final isFav = favs.containsKey(p.id);
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: widget.onFav,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border.withValues(alpha: 0.95)),
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16.5,
                                  color: AppColors.bordeaux,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeProductText(context, p.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "${p.price.toStringAsFixed(2)} DT",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.6,
                            height: 1.05,
                            color: AppColors.bordeaux,
                          ),
                        ),
                        if (p.oldPrice != null) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "${p.oldPrice!.toStringAsFixed(2)} DT",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 10.2,
                                height: 1.0,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: widget.qtyInCart == 0
                          ? SizedBox(
                              height: 36,
                              child: ElevatedButton.icon(
                                onPressed: widget.onAdd,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: AppColors.bordeaux,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: Text(
                                  tr3(
                                    context,
                                    fr: "Ajouter",
                                    en: "Add",
                                    ar: "إضافة",
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.2,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: AppColors.bordeaux.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: widget.onRemoveOne,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                                    icon: const Icon(Icons.remove_rounded, color: AppColors.bordeaux, size: 16),
                                  ),
                                  Text(
                                    "${widget.qtyInCart}",
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
                                  ),
                                  IconButton(
                                    onPressed: widget.onAdd,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                                    icon: const Icon(Icons.add_rounded, color: AppColors.bordeaux, size: 16),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
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

class _MiniBadge extends StatelessWidget {
  final String text;
  const _MiniBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.bordeaux),
      ),
    );
  }
}

/* ===================== FILTER & SORT ===================== */

enum SortOption { recommended, top, newest, priceLow, priceHigh }

String _sortLabel(BuildContext context, SortOption sort) {
  switch (sort) {
    case SortOption.recommended:
      return tr3(context, fr: 'Recommandé', en: 'Recommended', ar: 'موصى به');
    case SortOption.top:
      return tr3(context, fr: 'Top ventes', en: 'Top sales', ar: 'الأكثر مبيعاً');
    case SortOption.newest:
      return tr3(context, fr: 'Nouveautés', en: 'Newest', ar: 'الأحدث');
    case SortOption.priceLow:
      return tr3(context, fr: 'Prix croissant', en: 'Price low-high', ar: 'السعر من الأقل للأعلى');
    case SortOption.priceHigh:
      return tr3(context, fr: 'Prix décroissant', en: 'Price high-low', ar: 'السعر من الأعلى للأقل');
  }
}

class _FilterResult {
  final bool onlyPromo;
  final bool onlyBio;
  final double minPrice;
  final double maxPrice;
  final SortOption sort;

  _FilterResult({
    required this.onlyPromo,
    required this.onlyBio,
    required this.minPrice,
    required this.maxPrice,
    required this.sort,
  });
}

class _FilterSheet extends StatefulWidget {
  final bool onlyPromo;
  final bool onlyBio;
  final double minPrice;
  final double maxPrice;
  final SortOption sort;

  const _FilterSheet({
    required this.onlyPromo,
    required this.onlyBio,
    required this.minPrice,
    required this.maxPrice,
    required this.sort,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _promo;
  late bool _bio;
  late RangeValues _range;
  late SortOption _sort;

  @override
  void initState() {
    super.initState();
    _promo = widget.onlyPromo;
    _bio = widget.onlyBio;
    _range = RangeValues(widget.minPrice, widget.maxPrice);
    _sort = widget.sort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ProSheetNoShadow(
        title: tr3(context, fr: "Filtres", en: "Filters", ar: "الفلاتر"),
        child: Column(
          children: [
            _SwitchRow(
              title: tr3(context, fr: "Promotions uniquement", en: "Promos only", ar: "العروض فقط"),
              value: _promo,
              onChanged: (v) => setState(() => _promo = v),
            ),
            _SwitchRow(
              title: tr3(context, fr: "Bio uniquement", en: "Bio only", ar: "عضوي فقط"),
              value: _bio,
              onChanged: (v) => setState(() => _bio = v),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr3(context, fr: "Prix", en: "Price", ar: "السعر"),
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            RangeSlider(
              values: _range,
              min: 0,
              max: 200,
              divisions: 20,
              activeColor: AppColors.bordeaux,
              onChanged: (v) => setState(() => _range = v),
            ),
            Row(
              children: [
                Text("${_range.start.toStringAsFixed(0)} DT", style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text("${_range.end.toStringAsFixed(0)} DT", style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr3(context, fr: "Tri", en: "Sort", ar: "ترتيب"),
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            _SortPick(current: _sort, onPick: (s) => setState(() => _sort = s)),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _FilterResult(
                      onlyPromo: _promo,
                      onlyBio: _bio,
                      minPrice: _range.start,
                      maxPrice: _range.end,
                      sort: _sort,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  tr3(context, fr: "Appliquer", en: "Apply", ar: "تطبيق"),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onPick;
  const _SortSheet({required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return _ProSheetNoShadow(
      title: tr3(context, fr: "Trier par", en: "Sort by", ar: "ترتيب حسب"),
      child: Column(
        children: [
          _RadioTile(tr3(context, fr: "Recommandé", en: "Recommended", ar: "موصى به"), SortOption.recommended, current, onPick),
          _RadioTile(tr3(context, fr: "Top ventes", en: "Top sales", ar: "الأكثر مبيعاً"), SortOption.top, current, onPick),
          _RadioTile(tr3(context, fr: "Nouveautés", en: "Newest", ar: "الأحدث"), SortOption.newest, current, onPick),
          _RadioTile(tr3(context, fr: "Prix: bas → haut", en: "Price: low → high", ar: "السعر: من الأقل → الأعلى"), SortOption.priceLow, current, onPick),
          _RadioTile(tr3(context, fr: "Prix: haut → bas", en: "Price: high → low", ar: "السعر: من الأعلى → الأقل"), SortOption.priceHigh, current, onPick),
        ],
      ),
    );
  }
}

class _SortPick extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onPick;
  const _SortPick({required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RadioTile(tr3(context, fr: "Recommandé", en: "Recommended", ar: "موصى به"), SortOption.recommended, current, onPick),
        _RadioTile(tr3(context, fr: "Top ventes", en: "Top sales", ar: "الأكثر مبيعاً"), SortOption.top, current, onPick),
        _RadioTile(tr3(context, fr: "Nouveautés", en: "Newest", ar: "الأحدث"), SortOption.newest, current, onPick),
        _RadioTile(tr3(context, fr: "Prix: bas → haut", en: "Price: low → high", ar: "السعر: من الأقل → الأعلى"), SortOption.priceLow, current, onPick),
        _RadioTile(tr3(context, fr: "Prix: haut → bas", en: "Price: high → low", ar: "السعر: من الأعلى → الأقل"), SortOption.priceHigh, current, onPick),
      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String text;
  final SortOption value;
  final SortOption group;
  final ValueChanged<SortOption> onPick;

  const _RadioTile(this.text, this.value, this.group, this.onPick);

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onPick(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.soft : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.bordeaux : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          // SDK compatibility: keep activeColor for current Flutter version.
          // ignore: deprecated_member_use
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.bordeaux),
        ],
      ),
    );
  }
}

class _ProSheetNoShadow extends StatelessWidget {
  final String title;
  final Widget child;
  const _ProSheetNoShadow({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 46,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800))),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/* ===================== MOCK DATA ===================== */

class Product {
  final String id;
  final String name;
  final String subCategory;
  final String image;
  final double price;
  final double? oldPrice;

  final bool isPromo;
  final bool isBio;
  final bool isNew;
  final bool isPopular;

  final int score;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.subCategory,
    required this.image,
    required this.price,
    this.oldPrice,
    required this.isPromo,
    required this.isBio,
    required this.isNew,
    required this.isPopular,
    required this.score,
    required this.createdAt,
  });
}

List<String> _mockSubCategories(String cat) {
  switch (cat.toLowerCase().trim()) {
    case "electromenager":
    case "électroménager":
      return const ["Frigo", "Ghasala", "Gaz", "Four", "Micro-ondes"];
    case "tv & multimédia":
    case "tv multimedia":
      return const ["Smart TV", "Écrans", "Audio", "Accessoires"];
    case "cuisine & vaisselle":
    case "cuisine vaisselle":
      return const ["Ma3oun", "Plats", "Assiettes", "Casseroles", "Ustensiles"];
    case "maison":
      return const ["Nettoyage", "Lessive", "Hygiène maison", "Rangement"];
    case "fruits & légumes":
      return const ["Tomates", "Agrumes", "Pommes", "Salades", "Légumes"];
    case "produits laitiers":
      return const ["Lait", "Fromage", "Yaourt", "Beurre"];
    case "boulangerie":
      return const ["Pain", "Viennoiseries", "Gâteaux"];
    default:
      return const ["Top", "Classiques", "Nouveaux"];
  }
}

List<Product> _mockProducts(String cat) {
  final r = Random(2);
  final subs = _mockSubCategories(cat);
  final base = _categoryImagesFor(cat);

  return List.generate(18, (i) {
    final sub = subs[r.nextInt(subs.length)];
    final price = (5 + r.nextInt(60)) + r.nextDouble();
    final promo = r.nextBool() && r.nextBool();
    final bio = r.nextBool() && r.nextBool();
    final isNew = i % 5 == 0;
    final pop = i % 4 == 0;

    return Product(
      id: "$cat-$i",
      name: "$sub • Produit ${i + 1}",
      subCategory: sub,
      image: base[i % base.length],
      price: double.parse(price.toStringAsFixed(2)),
      oldPrice: promo ? double.parse((price + 6).toStringAsFixed(2)) : null,
      isPromo: promo,
      isBio: bio,
      isNew: isNew,
      isPopular: pop,
      score: 40 + r.nextInt(60),
      createdAt: DateTime.now().subtract(Duration(days: r.nextInt(30))),
    );
  });
}

List<String> _categoryImagesFor(String cat) {
  final normalized = cat.toLowerCase().trim();

  if (normalized == "electromenager" || normalized == "électroménager") {
    return const [
      "https://images.pexels.com/photos/5825570/pexels-photo-5825570.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/5591838/pexels-photo-5591838.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/6996164/pexels-photo-6996164.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/4108726/pexels-photo-4108726.jpeg?auto=compress&cs=tinysrgb&w=900",
    ];
  }

  if (normalized == "tv & multimédia" || normalized == "tv multimedia") {
    return const [
      "https://images.pexels.com/photos/5825570/pexels-photo-5825570.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/6976095/pexels-photo-6976095.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/1444416/pexels-photo-1444416.jpeg?auto=compress&cs=tinysrgb&w=900",
    ];
  }

  if (normalized == "cuisine & vaisselle" || normalized == "cuisine vaisselle") {
    return const [
      "https://images.pexels.com/photos/4226805/pexels-photo-4226805.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/6996073/pexels-photo-6996073.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/6207734/pexels-photo-6207734.jpeg?auto=compress&cs=tinysrgb&w=900",
    ];
  }

  if (normalized == "fruits & légumes") {
    return const [
      "https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/1132047/pexels-photo-1132047.jpeg?auto=compress&cs=tinysrgb&w=900",
      "https://images.pexels.com/photos/1300972/pexels-photo-1300972.jpeg?auto=compress&cs=tinysrgb&w=900",
    ];
  }

  return const [
    "https://images.pexels.com/photos/4050347/pexels-photo-4050347.jpeg?auto=compress&cs=tinysrgb&w=900",
    "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=900",
    "https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?auto=compress&cs=tinysrgb&w=900",
  ];
}
