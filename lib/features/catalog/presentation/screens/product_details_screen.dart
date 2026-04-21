import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/l10n/product_text_localizer.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/core/widgets/app_skeleton.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:elfaddoui_app/features/home/presentation/cubit/home_state.dart';
import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String? initialName;
  final String? initialImage;
  final double? initialPrice;
  final double? initialOldPrice;
  final String? initialDescription;
  final String? initialCategory;
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.initialName,
    this.initialImage,
    this.initialPrice,
    this.initialOldPrice,
    this.initialDescription,
    this.initialCategory,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final AiHomeService _homeService = AiHomeService();
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _loading = true;
  String? _error;
  Product? _product;

  static const String _fallbackImage =
      'https://images.pexels.com/photos/4050347/pexels-photo-4050347.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';

  List<String> get productImages {
    final img = _product?.image;
    if (img == null || img.isEmpty) return const [_fallbackImage];
    return [img];
  }

  String get _name => _product?.name ?? "Produit";
  double get _price => _product?.price ?? 0;
  double? get _oldPrice => _product?.oldPrice;
  double? get _discountPct => _product?.discountPct;
  String _unit(BuildContext context) {
    final lower = _name.toLowerCase();
    if (lower.contains('1l') || lower.contains('1.5l')) return '1 L';
    if (lower.contains('1kg')) return '1 kg';
    if (lower.contains('500g')) return '500 g';
    return tr3(context, fr: 'Pièce', en: 'Piece', ar: 'قطعة');
  }

  String get _desc =>
      _product?.description ?? "Description indisponible pour ce produit.";

  String get _discountLabel {
    final pct = _discountPct;
    if (pct == null || pct <= 0) return "";
    return "-${pct.round()}%";
  }

  @override
  void initState() {
    super.initState();
    final hasSeedData = widget.initialName != null ||
        widget.initialImage != null ||
        widget.initialPrice != null ||
        widget.initialDescription != null;

    if (hasSeedData) {
      _product = Product(
        id: widget.productId,
        name: widget.initialName ?? "Produit",
        description: widget.initialDescription,
        category: widget.initialCategory,
        image: widget.initialImage ?? _fallbackImage,
        price: widget.initialPrice ?? 0,
        oldPrice: widget.initialOldPrice,
        discountPctApi: null,
      );
      _loading = false;
    }

    _loadProduct(showLoader: !hasSeedData);
  }

  Future<void> _loadProduct({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    final p = await _homeService.getProductById(widget.productId);
    if (!mounted) return;
    setState(() {
      if (p != null) {
        _product = p;
      } else {
        _product ??= _buildLocalFallbackProduct(widget.productId);
      }
      _loading = false;
    });
  }

  Product _buildLocalFallbackProduct(String rawId) {
    final cleaned = rawId.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final title =
        parts.isEmpty ? "Produit" : parts.map((w) => "${w[0].toUpperCase()}${w.substring(1)}").join(' ');

    final seed = rawId.hashCode.abs();
    final price = 5 + (seed % 60) + ((seed % 100) / 100.0);

    return Product(
      id: rawId,
      name: title,
      description:
          tr3(
            context,
            fr: "Produit disponible localement. Les détails backend ne sont pas encore synchronisés pour cet article.",
            en: "Product available locally. Backend details are not fully synchronized yet for this item.",
            ar: "المنتج متوفر محليًا. تفاصيل الخلفية غير متزامنة بالكامل لهذا العنصر بعد.",
          ),
      category: tr3(context, fr: "Catalogue", en: "Catalog", ar: "الكتالوج"),
      image: _fallbackImage,
      price: double.parse(price.toStringAsFixed(2)),
      oldPrice: null,
      discountPctApi: null,
      rating: 4.4,
      reviews: 42,
    );
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

  void _toggleFav() {
    HapticFeedback.selectionClick();
    final fav = FavoriteItem(
      id: widget.productId,
      name: _name,
      image: productImages.first,
      price: _price,
    );
    context.read<FavoritesCubit>().toggle(fav);
    final isFav = context.read<FavoritesCubit>().isFavorite(widget.productId);
    _toastPremium(
      isFav
          ? tr3(context, fr: "Ajouté aux favoris", en: "Added to favorites", ar: "تمت الإضافة للمفضلة")
          : tr3(context, fr: "Retiré des favoris", en: "Removed from favorites", ar: "تمت الإزالة من المفضلة"),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    final isFav = context.watch<FavoritesCubit>().isFavorite(widget.productId);
    final cartQty =
        context.select<CartCubit, int>((c) => c.state[widget.productId]?.qty ?? 0);
    final effectiveQty = cartQty > 0 ? cartQty : _quantity;
    final totalPrice = _price * effectiveQty;

    if (_loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: _ProductDetailsSkeleton(),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: Text(tr3(context, fr: "Détails", en: "Details", ar: "التفاصيل")),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadProduct,
                child: Text(tr3(context, fr: "Réessayer", en: "Retry", ar: "إعادة المحاولة")),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.text),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Text(
              tr3(context, fr: "Détails", en: "Details", ar: "التفاصيل"),
              style: AppTextStyles.h3
                  .copyWith(fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            actions: [
              _IconChip(
                icon: isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: _toggleFav,
              ),
              const SizedBox(width: 8),
              _IconChip(icon: Icons.ios_share_rounded, onTap: () {}),
              const SizedBox(width: 12),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // HERO (لازم نفس tag في list)
                    Hero(
                      tag: "p-img-${widget.productId}",
                      flightShuttleBuilder: (ctx, anim, dir, from, to) {
                        return FadeTransition(opacity: anim, child: to.widget);
                      },
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 320,
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, _) =>
                              setState(() => _currentImageIndex = index),
                        ),
                        items: productImages.map((url) {
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (c, w, p) {
                              if (p == null) return w;
                              return Container(
                                color: AppColors.soft,
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.soft,
                              child: const Center(
                                child: Icon(Icons.image_not_supported_rounded,
                                    color: AppColors.muted),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: productImages.asMap().entries.map((e) {
                          final active = _currentImageIndex == e.key;
                          return Container(
                            width: active ? 18 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: active ? 0.95 : 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    if (_discountLabel.isNotEmpty)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _SoftBadge(
                          text: _discountLabel,
                          icon: Icons.local_offer_rounded,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          localizeProductText(context, _name),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            height: 1.12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: AppSurface.card(
                          radius: AppRadius.pill,
                          borderAlpha: 0.80,
                        ),
                        child: Text(
                          _unit(context),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${_price.toStringAsFixed(2)} DT",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h3.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.bordeaux),
                              ),
                            ),
                            if (_oldPrice != null) ...[
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "${_oldPrice!.toStringAsFixed(2)} DT",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RatingPill(
                        rating: _product?.rating ?? 0,
                        count: _product?.reviews ?? 0,
                      ),
                    ],
                  ),
                  if (_oldPrice != null && _oldPrice! > _price) ...[
                    const SizedBox(height: 6),
                    Text(
                      tr3(
                        context,
                        fr: "Économie ${(_oldPrice! - _price).toStringAsFixed(2)} DT",
                        en: "Save ${(_oldPrice! - _price).toStringAsFixed(2)} DT",
                        ar: "توفير ${(_oldPrice! - _price).toStringAsFixed(2)} د.ت",
                      ),
                      style: const TextStyle(
                        color: AppColors.bordeaux,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _InfoPill(
                          icon: Icons.local_shipping_outlined,
                          text: tr3(context, fr: "Livraison 24h", en: "24h delivery", ar: "توصيل 24 ساعة")),
                      SizedBox(width: 10),
                      _InfoPill(
                        icon: Icons.verified_outlined,
                        text: tr3(context, fr: "Qualité", en: "Quality", ar: "جودة"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: tr3(context, fr: "Description", en: "Description", ar: "الوصف"),
                    child: Text(
                      localizeProductDescription(
                        context,
                        _desc,
                        productName: _name,
                        category: _product?.category,
                      ),
                      style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: tr3(context, fr: "Quantité", en: "Quantity", ar: "الكمية"),
                    child: Row(
                      children: [
                        Text(
                            tr3(context, fr: "Choisir", en: "Choose", ar: "اختر"),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted)),
                        const Spacer(),
                        _QtyPicker(
                          value: effectiveQty,
                          onMinus: () {
                            if (cartQty > 0) {
                              context
                                  .read<CartCubit>()
                                  .setQty(widget.productId, cartQty - 1);
                              if (cartQty - 1 <= 0) {
                                setState(() => _quantity = 1);
                              }
                            } else {
                              setState(() {
                                if (_quantity > 1) _quantity--;
                              });
                            }
                          },
                          onPlus: () {
                            if (cartQty > 0) {
                              context
                                  .read<CartCubit>()
                                  .setQty(widget.productId, cartQty + 1);
                            } else {
                              setState(() => _quantity++);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr3(context, fr: "Total", en: "Total", ar: "الإجمالي"),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted),
                    ),
                    Text(
                      "${totalPrice.toStringAsFixed(2)} DT",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final p = _product;
                      if (p == null) return;
                      HapticFeedback.selectionClick();
                      if (cartQty > 0) {
                        context
                            .read<CartCubit>()
                            .setQty(p.id, effectiveQty);
                      } else {
                        context.read<CartCubit>().add(
                              id: p.id,
                              name: p.name,
                              image: p.image,
                              price: p.price,
                              qty: _quantity,
                            );
                      }
                      _toastPremium(
                        tr3(
                          context,
                          fr: "Panier mis à jour x$effectiveQty",
                          en: "Cart updated x$effectiveQty",
                          ar: "تم تحديث السلة x$effectiveQty",
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: Text(
                      tr3(
                        context,
                        fr: cartQty > 0
                            ? "Mettre à jour x$effectiveQty"
                            : "Ajouter x$_quantity",
                        en: cartQty > 0
                            ? "Update x$effectiveQty"
                            : "Add x$_quantity",
                        ar: cartQty > 0
                            ? "تحديث x$effectiveQty"
                            : "إضافة x$_quantity",
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bordeaux,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class _ProductDetailsSkeleton extends StatelessWidget {
  const _ProductDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 16, double w = double.infinity}) =>
        AppSkeletonBlock(height: h, width: w, radius: 12);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
      children: [
        box(h: 260),
        const SizedBox(height: 14),
        box(h: 18, w: 180),
        const SizedBox(height: 10),
        box(h: 14, w: 110),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: box(h: 58)),
            const SizedBox(width: 10),
            Expanded(child: box(h: 58)),
          ],
        ),
        const SizedBox(height: 12),
        box(h: 44),
        const SizedBox(height: 8),
        box(h: 44),
        const SizedBox(height: 12),
        box(h: 92),
      ],
    );
  }
}

/* ===================== SMALL UI WIDGETS ===================== */

class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 44,
        decoration: AppSurface.card(radius: 14, borderAlpha: 0.70),
        child: Icon(icon, size: 18, color: AppColors.bordeaux),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SoftBadge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.bordeaux),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.bordeaux,
                fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingPill({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.bordeaux, size: 18),
          const SizedBox(width: 6),
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(width: 6),
          Text("($count)",
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.bordeaux),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  fontSize: 13.5,
                  letterSpacing: 0.1)),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

class _QtyPicker extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyPicker(
      {required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded, color: AppColors.bordeaux),
            splashRadius: 19,
            visualDensity: VisualDensity.compact,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("$value",
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.text)),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded, color: AppColors.bordeaux),
            splashRadius: 19,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
