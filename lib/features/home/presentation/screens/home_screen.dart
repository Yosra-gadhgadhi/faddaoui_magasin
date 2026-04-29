import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/l10n/product_text_localizer.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/core/widgets/app_skeleton.dart';
import 'package:elfaddoui_app/core/widgets/app_snackbar.dart';
import 'package:elfaddoui_app/core/widgets/section_header.dart' as core_widgets;
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/search_screen.dart';
import 'package:elfaddoui_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:elfaddoui_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/categories_screen.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/category_products_screen.dart'
    show CategoryProductsScreen;
import 'package:elfaddoui_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:elfaddoui_app/features/profile/presentation/screens/loyalty_card_screen.dart';

import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

String _htr(
  BuildContext context, {
  required String fr,
  required String en,
  required String ar,
}) {
  final code = AppLocalizations.of(context).locale.languageCode;
  switch (code) {
    case 'en':
      return en;
    case 'ar':
      return ar;
    default:
      return fr;
  }
}

/* ===================== DEBOUNCER ===================== */

class _Debouncer {
  _Debouncer({required this.ms});
  final int ms;
  Timer? _t;

  void run(VoidCallback action) {
    _t?.cancel();
    _t = Timer(Duration(milliseconds: ms), action);
  }

  void dispose() => _t?.cancel();
}

class _EntranceReveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _EntranceReveal({required this.child, this.delayMs = 0});

  @override
  State<_EntranceReveal> createState() => _EntranceRevealState();
}

class _EntranceRevealState extends State<_EntranceReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: _UiTokens.slow,
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: _UiTokens.slow,
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.035),
        child: widget.child,
      ),
    );
  }
}

class _UiTokens {
  static const Duration slow = Duration(milliseconds: 220);
}

/* ===================== HOME SCREEN ===================== */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = <String>[
    "Tous",
    "Épicerie",
    "Boissons",
    "Snacks",
    "Fruits",
    "Maison",
  ];

  late final HomeCubit _cubit;
  final AiHomeService _homeApi = AiHomeService();
  List<_Cat> _dynamicHomeCategories = const [];

  final ScrollController _scroll = ScrollController();
  final GlobalKey _dealsKey = GlobalKey();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = "Tous";
  String _selectedSort = "Popularité";
  String _searchQuery = "";
  bool _isDeliveryMode = true;
  bool _promoOnly = false;
  bool _showAdvancedFilters = false;
  double _maxPrice = 100;
  int _visibleCount = 6;
  int _lastPrecacheSignature = -1;
  Timer? _flashTimer;
  late final _Debouncer _searchDebouncer;
  late DateTime _flashEndsAt;

  String _localizedCategoryLabel(BuildContext context, String category) {
    final t = AppLocalizations.of(context);
    switch (category) {
      case 'Tous':
        return t.tr('common_all');
      case 'Épicerie':
        return t.tr('category_grocery');
      case 'Boissons':
        return t.tr('category_drinks');
      case 'Snacks':
        return t.tr('category_snacks');
      case 'Fruits':
        return t.tr('category_fruits');
      case 'Maison':
        return t.tr('category_home');
      default:
        return category;
    }
  }

  String _localizedSortLabel(BuildContext context, String sort) {
    switch (sort) {
      case "Popularité":
        return _htr(
          context,
          fr: "Popularité",
          en: "Popularity",
          ar: "الأكثر رواجًا",
        );
      case "Prix ↑":
        return _htr(context, fr: "Prix ↑", en: "Price ↑", ar: "السعر ↑");
      case "Prix ↓":
        return _htr(context, fr: "Prix ↓", en: "Price ↓", ar: "السعر ↓");
      case "Promo":
        return AppLocalizations.of(context).tr('common_promo');
      case "Note":
        return _htr(context, fr: "Note", en: "Rating", ar: "التقييم");
      default:
        return sort;
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit(AiHomeService())..init();
    _loadHomeCategories();
    _searchDebouncer = _Debouncer(ms: 150);
    _flashEndsAt = DateTime.now().add(const Duration(hours: 2, minutes: 14));
    _flashTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (DateTime.now().isAfter(_flashEndsAt)) {
        _flashEndsAt =
            DateTime.now().add(const Duration(hours: 2, minutes: 14));
      }
      setState(() {});
    });
    _scroll.addListener(_onScroll);
  }

  Future<void> _loadHomeCategories() async {
    try {
      final categories = await _homeApi.getPublicCategories();
      if (!mounted) return;
      final list = categories.map((c) {
        final title = (c['name'] ?? '').toString().trim();
        final key = (c['key'] ?? '').toString().trim();
        final imageUrl = (c['imageUrl'] ?? '').toString().trim();
        return _Cat(
          title.isEmpty ? key : title,
          Icons.shopping_bag_rounded,
          key: key,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        );
      }).where((e) => e.title.trim().isNotEmpty).take(6).toList(growable: false);
      setState(() => _dynamicHomeCategories = list);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dynamicHomeCategories = const []);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _flashTimer?.cancel();
    _searchDebouncer.dispose();
    _searchCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  String get _flashLeftLabel {
    final left = _flashEndsAt.difference(DateTime.now());
    final safe = left.isNegative ? Duration.zero : left;
    final h = safe.inHours.toString().padLeft(2, '0');
    final m = (safe.inMinutes % 60).toString().padLeft(2, '0');
    final s = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('&', ' ')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\\s+'), ' ')
        .trim();
  }

  void _openProduct(BuildContext context, Product p) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: p.id,
          initialName: p.name,
          initialImage: p.image,
          initialPrice: p.price,
          initialOldPrice: p.oldPrice,
          initialDescription: p.description,
          initialCategory: p.category,
        ),
      ),
    );
  }

  void _openAllCategories() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
    );
  }

  void _openLoyaltyCard() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
    );
  }

  void _openCategoryProducts(String categoryName, {String? categoryKey}) {
    HapticFeedback.lightImpact();
    final key = (categoryKey != null && categoryKey.trim().isNotEmpty)
        ? categoryKey.trim()
        : _normalize(categoryName).replaceAll(' ', '-');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryName: categoryName,
          categoryKey: key,
        ),
      ),
    );
  }

  void _scrollToDeals() {
    HapticFeedback.lightImpact();
    final ctx = _dealsKey.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 420) {
      setState(() => _visibleCount += 4);
    }
  }

  String _categoryFor(Product p) {
    final lower = p.name.toLowerCase();
    if (lower.contains("lait") || lower.contains("boisson")) return "Boissons";
    if (lower.contains("pomme") || lower.contains("fruit")) return "Fruits";
    if (lower.contains("pain") || lower.contains("pâtes")) return "Épicerie";
    if (lower.contains("snack") || lower.contains("chips")) return "Snacks";
    final bucket = p.id.codeUnits.fold<int>(0, (a, b) => a + b) % 5;
    return _categories[bucket + 1];
  }

  List<Product> _applyFilters(List<Product> products) {
    var list = products.where((p) {
      final categoryMatch =
          _selectedCategory == "Tous" || _categoryFor(p) == _selectedCategory;
      final promoMatch = !_promoOnly || (p.discountPct ?? 0) > 0;
      final priceMatch = p.price <= _maxPrice;
      final q = _searchQuery.trim().toLowerCase();
      final searchMatch =
          q.isEmpty || p.name.toLowerCase().contains(q) || p.id.toLowerCase().contains(q);
      return categoryMatch && promoMatch && priceMatch && searchMatch;
    }).toList();

    switch (_selectedSort) {
      case "Prix ↑":
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case "Prix ↓":
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case "Promo":
        list.sort((a, b) => (b.discountPct ?? 0).compareTo(a.discountPct ?? 0));
        break;
      case "Note":
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
    }
    return list;
  }

  Future<void> _precacheTopImages(List<Product> list) async {
    if (!mounted || list.isEmpty) return;
    final signature = list.map((e) => e.image).join("|").hashCode;
    if (signature == _lastPrecacheSignature) return;
    _lastPrecacheSignature = signature;
    final top = list.take(8);
    for (final p in top) {
      if (!mounted) return;
      final imageUrl = ApiConstants.resolveAssetUrl(p.image);
      final uri = Uri.tryParse(imageUrl);
      final isValidNetworkImage = uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
      if (!isValidNetworkImage) continue;
      await precacheImage(NetworkImage(imageUrl), context);
    }
  }

  Future<void> _pickCategory() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _categories
            .map(
              (c) => ListTile(
                title: Text(_localizedCategoryLabel(context, c)),
                trailing: c == _selectedCategory
                    ? const Icon(Icons.check_rounded, color: AppColors.bordeaux)
                    : null,
                onTap: () => Navigator.pop(context, c),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedCategory = selected;
        _visibleCount = 6;
      });
    }
  }

  Future<void> _pickSort() async {
    const options = ["Popularité", "Prix ↑", "Prix ↓", "Promo", "Note"];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: options
            .map(
              (o) => ListTile(
                title: Text(_localizedSortLabel(context, o)),
                trailing: o == _selectedSort
                    ? const Icon(Icons.check_rounded, color: AppColors.bordeaux)
                    : null,
                onTap: () => Navigator.pop(context, o),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedSort = selected;
        _visibleCount = 6;
      });
    }
  }

  Future<void> _pickPrice() async {
    double draft = _maxPrice;
    final selected = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _htr(
                    context,
                    fr: "Prix max: ${draft.toStringAsFixed(0)} DT",
                    en: "Max price: ${draft.toStringAsFixed(0)} DT",
                    ar: "أقصى سعر: ${draft.toStringAsFixed(0)} د.ت",
                  ),
                ),
                Slider(
                  value: draft,
                  min: 5,
                  max: 100,
                  divisions: 19,
                  activeColor: AppColors.bordeaux,
                  onChanged: (v) => setModalState(() => draft = v),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, draft),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bordeaux,
                    ),
                    child: Text(
                      _htr(
                        context,
                        fr: "Appliquer",
                        en: "Apply",
                        ar: "تطبيق",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (selected != null) {
      setState(() {
        _maxPrice = selected;
        _visibleCount = 6;
      });
    }
  }

  // =================== IA sheets ===================

  void _openRecipes(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RecipesSheetFine(),
    );
  }

  void _openBudget(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BudgetSheetFine(),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = "Tous";
      _selectedSort = "Popularité";
      _promoOnly = false;
      _maxPrice = 100;
      _searchQuery = "";
      _searchCtrl.clear();
      _visibleCount = 6;
    });
  }

  void _applyQuickBundle(String bundle) {
    setState(() {
      switch (bundle) {
        case "Petit déjeuner":
          _selectedCategory = "Épicerie";
          _selectedSort = "Popularité";
          _promoOnly = false;
          break;
        case "Déjeuner":
          _selectedCategory = "Fruits";
          _selectedSort = "Note";
          _promoOnly = false;
          break;
        case "Goûter":
          _selectedCategory = "Snacks";
          _selectedSort = "Promo";
          _promoOnly = true;
          break;
        case "Ménage":
          _selectedCategory = "Maison";
          _selectedSort = "Prix ↑";
          _promoOnly = false;
          break;
        default:
          _selectedCategory = "Tous";
          _selectedSort = "Popularité";
          _promoOnly = false;
      }
      _visibleCount = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, s) {
            if (s.loading) return const _HomeSkeletonFine();
            if (s.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 42, color: AppColors.bordeaux),
                      const SizedBox(height: 10),
                      Text(
                        s.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().init(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bordeaux,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _htr(
                            context,
                            fr: "Réessayer",
                            en: "Retry",
                            ar: "إعادة المحاولة",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final shopProducts = <Product>[
              ...s.deals,
              ...s.forYou,
              ...s.recent,
            ];
            final filteredProducts = _applyFilters(shopProducts);
            final t = AppLocalizations.of(context);
            final promoResultsCount =
                filteredProducts.where((p) => (p.discountPct ?? 0) > 0).length;
            final activeFiltersCount = (_selectedCategory != "Tous" ? 1 : 0) +
                (_promoOnly ? 1 : 0) +
                (_maxPrice < 100 ? 1 : 0) +
                (_selectedSort != "Popularité" ? 1 : 0);
            final visibleProducts = filteredProducts
                .take(math.min(_visibleCount, filteredProducts.length))
                .toList();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _precacheTopImages(filteredProducts);
            });

            return Stack(
              children: [
                const Positioned.fill(child: IgnorePointer(child: _HomeBackdrop())),
                RefreshIndicator(
                  onRefresh: () async {
                    await context.read<HomeCubit>().init();
                    setState(() => _visibleCount = 6);
                  },
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                  const _HomeSliverAppBar(),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _EntranceReveal(
                          delayMs: 40,
                          child: _SearchBarFine(
                          hint: t.tr('home_search_hint'),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SearchScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _LocationEtaPill(
                        locationLabel: s.locationLabel,
                        etaLabel: s.etaLabel,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          AppSnackBar.show(
                            context,
                            t.tr('home_location_change_soon'),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _ShoppingModeSegment(
                        isDelivery: _isDeliveryMode,
                        onChanged: (value) =>
                            setState(() => _isDeliveryMode = value),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                      child: _QuickAccessCards(
                        onTapLoyalty: _openLoyaltyCard,
                        onTapScan: () => _openCategoryProducts(
                          _htr(
                            context,
                            fr: "Épicerie",
                            en: "Grocery",
                            ar: "بقالة",
                          ),
                        ),
                        onTapCoupons: _scrollToDeals,
                        onTapGifts: () => _openAllCategories(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _SectionHeader(
                        title: _htr(
                          context,
                          fr: "En ce moment",
                          en: "Right now",
                          ar: "الآن",
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _NowPromoStrip(
                        onTapBanner: _scrollToDeals,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _SectionHeader(
                        title: _htr(
                          context,
                          fr: "Catalogues",
                          en: "Catalogs",
                          ar: "الكتالوجات",
                        ),
                        onTap: _openAllCategories,
                        actionIcon: Icons.menu_book_rounded,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _CatalogCardsStrip(
                        onTapCard: _openAllCategories,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                      child: _MoodHeroPanel(
                        category: _localizedCategoryLabel(
                          context,
                          _selectedCategory,
                        ),
                        flashLeft: _flashLeftLabel,
                        onTapPrimary: _scrollToDeals,
                        onTapSecondary: _pickCategory,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _QuickBundlesRow(
                        onTapBundle: _applyQuickBundle,
                        onTapBudget: () => _openBudget(context),
                        onTapRecipes: () => _openRecipes(context),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyFilterDelegate(
                      child: _StoreFilterBar(
                        selectedCategory: _selectedCategory,
                        selectedSort: _selectedSort,
                        promoOnly: _promoOnly,
                        activeCount: activeFiltersCount,
                        maxPrice: _maxPrice,
                        onTapCategory: _pickCategory,
                        onTapPrice: _pickPrice,
                        onTapPromo: () =>
                            setState(() => _promoOnly = !_promoOnly),
                        onTapSort: _pickSort,
                        onTapClear: _resetFilters,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _AdvancedFiltersSection(
                        visible: _showAdvancedFilters,
                        queryController: _searchCtrl,
                        promoOnly: _promoOnly,
                        selectedCategory: _selectedCategory,
                        selectedSort: _selectedSort,
                        maxPrice: _maxPrice,
                        onToggle: () => setState(
                          () => _showAdvancedFilters = !_showAdvancedFilters,
                        ),
                        onQueryChanged: (value) {
                          _searchDebouncer.run(() {
                            if (!mounted) return;
                            setState(() {
                              _searchQuery = value;
                              _visibleCount = 6;
                            });
                          });
                        },
                        onTapCategory: _pickCategory,
                        onTapSort: _pickSort,
                        onTapPromo: () =>
                            setState(() => _promoOnly = !_promoOnly),
                        onPriceChanged: (v) => setState(() {
                          _maxPrice = v;
                          _visibleCount = 6;
                        }),
                        onClearQuery: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = "";
                            _visibleCount = 6;
                          });
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _HomeMiniSummary(
                        productsCount: filteredProducts.length,
                        promoCount: promoResultsCount,
                        category: _localizedCategoryLabel(
                          context,
                          _selectedCategory,
                        ),
                        sortLabel: _localizedSortLabel(context, _selectedSort),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(
                        title: t.tr('home_popular_categories'),
                        onTap: _openAllCategories,
                        actionIcon: Icons.grid_view_rounded,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _CategoryRowFine(
                      items: _dynamicHomeCategories,
                      onCategoryTap: (c) =>
                          _openCategoryProducts(c.title, categoryKey: c.key),
                    ),
                  ),
                  if (s.recent.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: _RecentProductsStrip(
                          products: s.recent.take(8).toList(),
                          onOpen: (p) => _openProduct(context, p),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    key: _dealsKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(
                        title: t.tr('home_products'),
                        subtitle: t.tr(
                          'common_results_count',
                          params: {'count': '${filteredProducts.length}'},
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (filteredProducts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SmartEmptyProducts(
                          onClearFilters: _resetFilters,
                        ),
                      ),
                    ),
                  if (filteredProducts.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: .58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final p = visibleProducts[i];
                            return RepaintBoundary(
                              child: _ShopProductCardFine(
                                p: p,
                                stock: _stockFromProduct(p),
                                unitLabel: _unitLabelFor(p),
                                promoEndsIn: _promoEndsIn(p),
                                onOpen: () => _openProduct(context, p),
                              ),
                            );
                          },
                          childCount: visibleProducts.length,
                        ),
                      ),
                    ),
                  if (visibleProducts.length < filteredProducts.length)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: OutlinedButton(
                          onPressed: () => setState(() => _visibleCount += 4),
                          child: Text(t.tr('common_load_more')),
                        ),
                      ),
                    ),
                      const SliverToBoxAdapter(child: SizedBox(height: 110)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeMiniSummary extends StatelessWidget {
  final int productsCount;
  final int promoCount;
  final String category;
  final String sortLabel;

  const _HomeMiniSummary({
    required this.productsCount,
    required this.promoCount,
    required this.category,
    required this.sortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
            _HomeStatPill(
              icon: Icons.inventory_2_rounded,
              text: t.tr(
                'common_results_count',
                params: {'count': '$productsCount'},
              ),
            ),
            const SizedBox(width: 8),
            _HomeStatPill(
              icon: Icons.local_offer_rounded,
              text: t.tr(
                'common_promos_count',
                params: {'count': '$promoCount'},
              ),
            ),
            const SizedBox(width: 8),
            _HomeStatPill(
              icon: Icons.category_rounded,
              text: category,
            ),
            const SizedBox(width: 8),
            _HomeStatPill(
              icon: Icons.sort_rounded,
              text: sortLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeStatPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HomeStatPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.5, color: AppColors.bordeaux),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _WelcomeCardFine extends StatelessWidget {
  final String locationLabel;
  final String etaLabel;
  final VoidCallback onLocationTap;

  const _WelcomeCardFine({
    required this.locationLabel,
    required this.etaLabel,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _htr(
                    context,
                    fr: "Bonjour 👋",
                    en: "Hello 👋",
                    ar: "مرحبًا 👋",
                  ),
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _htr(
                    context,
                    fr: "Que voulez-vous cuisiner aujourd’hui ?",
                    en: "What would you like to cook today?",
                    ar: "ماذا تريد أن تطبخ اليوم؟",
                  ),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _LocationPillFine(
            label: locationLabel,
            sub: etaLabel,
            onTap: onLocationTap,
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _StoreHeroCarousel extends StatefulWidget {
  final VoidCallback onPrimaryTap;
  final VoidCallback onFilterTap;
  final VoidCallback onExpressTap;
  final String selectedCategory;
  final int promoCount;
  const _StoreHeroCarousel({
    required this.onPrimaryTap,
    required this.onFilterTap,
    required this.onExpressTap,
    required this.selectedCategory,
    required this.promoCount,
  });

  @override
  State<_StoreHeroCarousel> createState() => _StoreHeroCarouselState();
}

class _StoreHeroCarouselState extends State<_StoreHeroCarousel>
    with SingleTickerProviderStateMixin {
  final _controller = PageController(viewportFraction: 1);
  static const _heroImages = [
    "https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?auto=compress&cs=tinysrgb&w=1600&h=900&dpr=2",
    "https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=1600&h=900&dpr=2",
    "https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg?auto=compress&cs=tinysrgb&w=1600&h=900&dpr=2",
  ];
  int _index = 0;
  bool _userDragging = false;
  static const int _loopBasePage = 3000;
  late final AnimationController _progressController;

  int get _loopInitialPage => _loopBasePage - (_loopBasePage % _slides.length);

  List<(String, String, String)> get _slides {
    final context = this.context;
    final hour = DateTime.now().hour;
    final timeLabel = hour < 12
        ? _htr(context, fr: "matin", en: "morning", ar: "الصباح")
        : hour < 18
            ? _htr(context, fr: "après-midi", en: "afternoon", ar: "بعد الظهر")
            : _htr(context, fr: "soir", en: "evening", ar: "المساء");
    final catLabel = widget.selectedCategory == "Tous"
        ? _htr(context, fr: "nos catégories", en: "our categories", ar: "فئاتنا")
        : widget.selectedCategory.toLowerCase();
    return [
      (
        _htr(
          context,
          fr: "Sélection $timeLabel",
          en: "$timeLabel selection",
          ar: "اختيار $timeLabel",
        ),
        _htr(
          context,
          fr: "${widget.promoCount} promos actives sur $catLabel",
          en: "${widget.promoCount} active promos on $catLabel",
          ar: "${widget.promoCount} عروض مفعلة على $catLabel",
        ),
        _htr(context, fr: "Voir les offres", en: "View offers", ar: "عرض العروض")
      ),
      (
        _htr(context, fr: "Prix malins", en: "Smart prices", ar: "أسعار ذكية"),
        _htr(
          context,
          fr: "Tri intelligent: promo, prix, note",
          en: "Smart sorting: promo, price, rating",
          ar: "ترتيب ذكي: عرض، سعر، تقييم",
        ),
        _htr(context, fr: "Filtrer", en: "Filter", ar: "فلترة"),
      ),
      (
        _htr(
          context,
          fr: "Livraison express",
          en: "Express delivery",
          ar: "توصيل سريع",
        ),
        _htr(
          context,
          fr: "Commande fluide et rapide",
          en: "Smooth and fast ordering",
          ar: "طلب سريع وسلس",
        ),
        _htr(context, fr: "Commander", en: "Order", ar: "اطلب"),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_userDragging) {
          if (_controller.hasClients) {
            _controller.nextPage(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOutCubic,
            );
          }
          _progressController.forward(from: 0);
        }
      });

    _controller.addListener(_syncIndexFromScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients || _slides.isEmpty) return;
      _controller.jumpToPage(_loopInitialPage);
      _progressController.forward(from: 0);
    });
  }

  void _syncIndexFromScroll() {
    if (!_controller.hasClients || _slides.isEmpty) return;
    final currentPage = _controller.page;
    if (currentPage == null) return;
    final nextIndex = currentPage.round() % _slides.length;
    if (nextIndex != _index && mounted) {
      setState(() => _index = nextIndex);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_syncIndexFromScroll);
    _progressController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _userDragging = true;
                _progressController.stop();
              }
              if (notification is ScrollEndNotification && _userDragging) {
                _userDragging = false;
                _progressController.forward(from: 0);
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemBuilder: (context, i) {
                final slide = _slides[i % _slides.length];
                void onSlideTap() {
                  if (i % _slides.length == 1) return widget.onFilterTap();
                  if (i % _slides.length == 2) return widget.onExpressTap();
                  widget.onPrimaryTap();
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onSlideTap,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.9)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: _FadeInNetworkImage(
                                url: _heroImages[i % _heroImages.length],
                                height: double.infinity,
                                width: double.infinity,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.20),
                                    Colors.white.withValues(alpha: 0.88),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -25,
                            top: -20,
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: AppColors.bordeaux.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 14,
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              size: 44,
                              color: AppColors.bordeaux.withValues(alpha: 0.12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slide.$1,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 210,
                                  child: Text(
                                    slide.$2,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: onSlideTap,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.soft,
                                      borderRadius: BorderRadius.circular(999),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      slide.$3,
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 26,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) {
                    final fill = i < _index
                        ? 1.0
                        : i > _index
                            ? 0.0
                            : _progressController.value;
                    return FractionallySizedBox(
                      widthFactor: fill.clamp(0.0, 1.0),
                      alignment: Alignment.centerLeft,
                      child: Container(
                          color: AppColors.bordeaux.withValues(alpha: 0.55)),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => false;
}

class _LocationEtaPill extends StatelessWidget {
  final String locationLabel;
  final String etaLabel;
  final VoidCallback onTap;
  const _LocationEtaPill({
    required this.locationLabel,
    required this.etaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: AppSurface.card(radius: AppRadius.md, borderAlpha: 0.8),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.bordeaux),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                locationLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.bordeaux,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              etaLabel,
              style: const TextStyle(
                color: AppColors.bordeaux,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingModeSegment extends StatelessWidget {
  final bool isDelivery;
  final ValueChanged<bool> onChanged;

  const _ShoppingModeSegment({
    required this.isDelivery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget item({
      required bool selected,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.bordeaux.withValues(alpha: 0.11)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.bordeaux.withValues(alpha: 0.25)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.bordeauxDark : AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 13.4,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: AppSurface.card(radius: 14, borderAlpha: 0.85),
      child: Row(
        children: [
          item(
            selected: isDelivery,
            label: _htr(
              context,
              fr: "Drive & Livraison",
              en: "Pickup & Delivery",
              ar: "استلام وتوصيل",
            ),
            onTap: () => onChanged(true),
          ),
          item(
            selected: !isDelivery,
            label: _htr(
              context,
              fr: "Magasin",
              en: "Store",
              ar: "المتجر",
            ),
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCards extends StatelessWidget {
  final VoidCallback onTapLoyalty;
  final VoidCallback onTapScan;
  final VoidCallback onTapCoupons;
  final VoidCallback onTapGifts;

  const _QuickAccessCards({
    required this.onTapLoyalty,
    required this.onTapScan,
    required this.onTapCoupons,
    required this.onTapGifts,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.workspace_premium_rounded,
        label: _htr(context, fr: "Ma carte", en: "My card", ar: "بطاقتي"),
        onTap: onTapLoyalty,
      ),
      (
        icon: Icons.qr_code_scanner_rounded,
        label: _htr(context, fr: "Scan prix", en: "Scan price", ar: "مسح السعر"),
        onTap: onTapScan,
      ),
      (
        icon: Icons.receipt_long_rounded,
        label: _htr(context, fr: "Mes bons", en: "My vouchers", ar: "قسائمي"),
        onTap: onTapCoupons,
      ),
      (
        icon: Icons.card_giftcard_rounded,
        label: _htr(context, fr: "Mes cadeaux", en: "My gifts", ar: "هداياي"),
        onTap: onTapGifts,
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: item.onTap,
            child: Container(
              width: 122,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: AppSurface.card(radius: 14, borderAlpha: 0.86),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: AppColors.bordeaux.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.icon, size: 18, color: AppColors.bordeaux),
                  ),
                  const Spacer(),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NowPromoStrip extends StatelessWidget {
  final VoidCallback onTapBanner;
  const _NowPromoStrip({required this.onTapBanner});

  static const _banners = <String>[
    "https://images.pexels.com/photos/616401/pexels-photo-616401.jpeg?auto=compress&cs=tinysrgb&w=1200",
    "https://images.pexels.com/photos/4198019/pexels-photo-4198019.jpeg?auto=compress&cs=tinysrgb&w=1200",
    "https://images.pexels.com/photos/3373739/pexels-photo-3373739.jpeg?auto=compress&cs=tinysrgb&w=1200",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTapBanner,
            child: SizedBox(
              width: 270,
              child: _FadeInNetworkImage(
                url: _banners[i],
                width: 270,
                height: 132,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogCardsStrip extends StatelessWidget {
  final VoidCallback onTapCard;
  const _CatalogCardsStrip({required this.onTapCard});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        title: _htr(
          context,
          fr: "Spécial Épicerie",
          en: "Grocery specials",
          ar: "عروض البقالة",
        ),
        subtitle: _htr(context, fr: "Jusqu’à -35%", en: "Up to -35%", ar: "حتى -35%"),
        image:
            "https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg?auto=compress&cs=tinysrgb&w=1200",
      ),
      (
        title: _htr(
          context,
          fr: "Fruits & Légumes",
          en: "Fruits & Vegetables",
          ar: "فواكه وخضر",
        ),
        subtitle: _htr(context, fr: "Arrivage frais", en: "Fresh arrivals", ar: "وصولات طازجة"),
        image:
            "https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=1200",
      ),
    ];

    return SizedBox(
      height: 182,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = cards[i];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTapCard,
            child: Container(
              width: 206,
              decoration: AppSurface.card(radius: 14, borderAlpha: 0.86),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FadeInNetworkImage(
                    url: c.image,
                    width: 206,
                    height: 116,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                    child: Text(
                      c.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoodHeroPanel extends StatelessWidget {
  final String category;
  final String flashLeft;
  final VoidCallback onTapPrimary;
  final VoidCallback onTapSecondary;
  const _MoodHeroPanel({
    required this.category,
    required this.flashLeft,
    required this.onTapPrimary,
    required this.onTapSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cat = category == t.tr('common_all')
        ? t.tr('home_personal_selection')
        : category;
    return Container(
      height: 132,
      decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          14,
          AppSpacing.md,
          14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.tr('home_offers_today'),
              style: AppTextStyles.h2.copyWith(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.tr('home_offer_line', params: {'category': cat, 'time': flashLeft}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _HeroPillBtn(
                  label: t.tr('home_view_deals'),
                  icon: Icons.bolt_rounded,
                  onTap: onTapPrimary,
                  filled: true,
                ),
                const SizedBox(width: 8),
                _HeroPillBtn(
                  label: t.tr('nav_categories'),
                  icon: Icons.grid_view_rounded,
                  onTap: onTapSecondary,
                  filled: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPillBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _HeroPillBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: filled ? AppColors.bordeaux : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: filled ? AppColors.bordeaux : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? Colors.white : AppColors.bordeauxDark,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBundlesRow extends StatelessWidget {
  final ValueChanged<String> onTapBundle;
  final VoidCallback onTapBudget;
  final VoidCallback onTapRecipes;
  const _QuickBundlesRow({
    required this.onTapBundle,
    required this.onTapBudget,
    required this.onTapRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = [
      t.tr('home_quick_breakfast'),
      t.tr('home_quick_lunch'),
      t.tr('home_quick_snack'),
      t.tr('home_quick_household'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.tr('home_quick_shopping'),
          style: TextStyle(
            color: AppColors.text,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _QuickChip(
                    label: item,
                    icon: Icons.bolt_rounded,
                    onTap: () => onTapBundle(item),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _QuickChip(
                  label: t.tr('home_recipes'),
                  icon: Icons.menu_book_rounded,
                  onTap: onTapRecipes,
                ),
              ),
              _QuickChip(
                label: t.tr('home_budget'),
                icon: Icons.savings_rounded,
                onTap: onTapBudget,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.bordeauxDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12.5,
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

class _StoreFilterBar extends StatelessWidget {
  final String selectedCategory;
  final String selectedSort;
  final bool promoOnly;
  final int activeCount;
  final double maxPrice;
  final VoidCallback onTapCategory;
  final VoidCallback onTapPrice;
  final VoidCallback onTapPromo;
  final VoidCallback onTapSort;
  final VoidCallback onTapClear;

  const _StoreFilterBar({
    required this.selectedCategory,
    required this.selectedSort,
    required this.promoOnly,
    required this.activeCount,
    required this.maxPrice,
    required this.onTapCategory,
    required this.onTapPrice,
    required this.onTapPromo,
    required this.onTapSort,
    required this.onTapClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final catLabel = selectedCategory == "Tous"
        ? t.tr('common_all')
        : selectedCategory;
    final filters = [
      (
        catLabel,
        Icons.grid_view_rounded,
        onTapCategory,
        selectedCategory != "Tous"
      ),
      (
        "${t.tr('common_price')} ${maxPrice.toStringAsFixed(0)}",
        Icons.tune_rounded,
        onTapPrice,
        maxPrice < 100
      ),
      (t.tr('common_promo'), Icons.local_offer_rounded, onTapPromo, promoOnly),
      (
        t.tr('common_sort'),
        Icons.swap_vert_rounded,
        onTapSort,
        selectedSort != "Popularité"
      ),
    ];

    return SizedBox(
      height: AppSize.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length + (activeCount > 0 ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (activeCount > 0 && i == 0) {
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: onTapClear,
              child: Container(
                height: AppSize.chipHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bordeaux.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.bordeaux.withValues(alpha: 0.26),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.clear_all_rounded,
                        size: 16, color: AppColors.bordeauxDark),
                    const SizedBox(width: 6),
                    Text(
                      t.tr('common_clear'),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final idx = activeCount > 0 ? i - 1 : i;
          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: filters[idx].$3,
            child: Container(
              height: AppSize.chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: filters[idx].$4
                    ? AppColors.bordeaux.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: filters[idx].$4
                      ? AppColors.bordeaux.withValues(alpha: 0.26)
                      : AppColors.border.withValues(alpha: 0.50),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filters[idx].$2,
                    size: 16,
                    color: filters[idx].$4
                        ? AppColors.bordeaux
                        : AppColors.bordeauxDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filters[idx].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: filters[idx].$4
                          ? AppColors.bordeaux
                          : AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final IconData actionIcon;
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onTap,
    this.actionIcon = Icons.east_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return core_widgets.SectionHeader(
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      actionIcon: actionIcon,
    );
  }
}

class _AdvancedFiltersSection extends StatelessWidget {
  final bool visible;
  final TextEditingController queryController;
  final bool promoOnly;
  final String selectedCategory;
  final String selectedSort;
  final double maxPrice;
  final VoidCallback onToggle;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onTapCategory;
  final VoidCallback onTapSort;
  final VoidCallback onTapPromo;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onClearQuery;

  const _AdvancedFiltersSection({
    required this.visible,
    required this.queryController,
    required this.promoOnly,
    required this.selectedCategory,
    required this.selectedSort,
    required this.maxPrice,
    required this.onToggle,
    required this.onQueryChanged,
    required this.onTapCategory,
    required this.onTapSort,
    required this.onTapPromo,
    required this.onPriceChanged,
    required this.onClearQuery,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final sortLabelUi = switch (selectedSort) {
      "Popularité" => _htr(
          context,
          fr: "Popularité",
          en: "Popularity",
          ar: "الأكثر رواجًا",
        ),
      "Prix ↑" => _htr(context, fr: "Prix ↑", en: "Price ↑", ar: "السعر ↑"),
      "Prix ↓" => _htr(context, fr: "Prix ↓", en: "Price ↓", ar: "السعر ↓"),
      "Promo" => t.tr('common_promo'),
      "Note" => _htr(context, fr: "Note", en: "Rating", ar: "التقييم"),
      _ => selectedSort,
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: visible
          ? Container(
              key: const ValueKey("advanced-open"),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.78)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 17,
                        color: AppColors.bordeaux,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.tr('home_advanced_filters'),
                        style: TextStyle(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onToggle,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.bordeauxDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: queryController,
                    onChanged: onQueryChanged,
                    decoration: InputDecoration(
                      hintText: t.tr('home_search_product_hint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: queryController.text.isNotEmpty
                          ? IconButton(
                              onPressed: onClearQuery,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.fieldFill,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _AdvancedActionChip(
                          icon: Icons.grid_view_rounded,
                          label: selectedCategory == "Tous"
                              ? t.tr('nav_categories')
                              : selectedCategory,
                          onTap: onTapCategory,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AdvancedActionChip(
                          icon: Icons.swap_vert_rounded,
                          label: "${t.tr('common_sort')}: $sortLabelUi",
                          onTap: onTapSort,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.sell_rounded,
                        size: 17,
                        color: AppColors.bordeauxDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.tr('home_promos_only'),
                        style: const TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: promoOnly,
                        activeColor: AppColors.bordeaux,
                        onChanged: (_) => onTapPromo(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.tr(
                      'home_max_price',
                      params: {'price': maxPrice.toStringAsFixed(0)},
                    ),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: maxPrice,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    activeColor: AppColors.bordeaux,
                    onChanged: onPriceChanged,
                  ),
                ],
              ),
            )
          : Align(
              key: const ValueKey("advanced-closed"),
              alignment: Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onToggle,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bordeaux.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.bordeaux.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: AppColors.bordeauxDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.tr('home_advanced_filters'),
                        style: const TextStyle(
                          fontSize: 12.6,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
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

class _AdvancedActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AdvancedActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 9),
        decoration: AppSurface.card(
          radius: AppRadius.md,
          color: AppColors.soft,
          borderAlpha: 1,
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.bordeauxDark),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeInNetworkImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  const _FadeInNetworkImage({
    required this.url,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = ApiConstants.resolveAssetUrl(url);
    final uri = Uri.tryParse(normalizedUrl);
    final isValidNetworkImage = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (normalizedUrl.isEmpty || !isValidNetworkImage) {
      return _ImageFallback(
        height: height,
        width: width,
        borderRadius: borderRadius,
      );
    }

    final dpr = MediaQuery.of(context).devicePixelRatio.clamp(1.0, 3.0);
    final cacheW = width.isFinite ? math.max(1, (width * dpr).round()) : null;
    final cacheH = height.isFinite ? math.max(1, (height * dpr).round()) : null;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        normalizedUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        cacheWidth: cacheW,
        cacheHeight: cacheH,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return AppSkeletonBlock(height: height, width: width, radius: 12);
        },
        errorBuilder: (_, __, ___) => _ImageFallback(
          height: height,
          width: width,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  const _ImageFallback({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.soft,
            AppColors.border.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.local_grocery_store_rounded,
          color: AppColors.muted,
          size: 20,
        ),
      ),
    );
  }
}

class _ShopProductCardFine extends StatefulWidget {
  final Product p;
  final int stock;
  final String unitLabel;
  final String? promoEndsIn;
  final VoidCallback onOpen;
  const _ShopProductCardFine({
    required this.p,
    required this.stock,
    required this.unitLabel,
    required this.promoEndsIn,
    required this.onOpen,
  });

  @override
  State<_ShopProductCardFine> createState() => _ShopProductCardFineState();
}

class _ShopProductCardFineState extends State<_ShopProductCardFine> {
  bool _pressed = false;
  bool _adding = false;

  Future<void> _addToCart(Product p) async {
    if (_adding) return;
    final cart = context.read<CartCubit>();
    setState(() => _adding = true);
    HapticFeedback.lightImpact();
    cart.add(
      id: p.id,
      name: p.name,
      image: p.image,
      price: p.price,
    );
    AppSnackBar.show(
      context,
      _htr(
        context,
        fr: "${localizeProductText(context, p.name)} ajouté au panier",
        en: "${localizeProductText(context, p.name)} added to cart",
        ar: "تمت إضافة ${localizeProductText(context, p.name)} إلى السلة",
      ),
      durationMs: 950,
    );
    await Future.delayed(_UiTokens.slow);
    if (mounted) setState(() => _adding = false);
  }

  void _incCartQty(Product p, int currentQty) {
    final cart = context.read<CartCubit>();
    if (currentQty <= 0) {
      _addToCart(p);
      return;
    }
    HapticFeedback.selectionClick();
    cart.setQty(p.id, currentQty + 1);
  }

  void _decCartQty(Product p, int currentQty) {
    final cart = context.read<CartCubit>();
    if (currentQty <= 0) return;
    HapticFeedback.selectionClick();
    cart.setQty(p.id, currentQty - 1);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final discount = p.discountPct?.round();
    final cartQty =
        context.select<CartCubit, int>((c) => c.state[p.id]?.qty ?? 0);
    final isFav =
        context.select<FavoritesCubit, bool>((c) => c.isFavorite(p.id));
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onOpen,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _FadeInNetworkImage(
                          url: p.image,
                          height: 200,
                          width: double.infinity,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                      ),
                      if (discount != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.bordeaux.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              "-$discount%",
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            final nowFav = await context.read<FavoritesCubit>().toggle(
                              FavoriteItem(
                                id: p.id,
                                name: p.name,
                                image: p.image,
                                price: p.price,
                              ),
                            );
                            AppSnackBar.show(
                              context,
                              nowFav
                                  ? AppLocalizations.of(context).tr('favorites_added')
                                  : AppLocalizations.of(context).tr('favorites_removed'),
                              durationMs: 750,
                            );
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.90),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.bordeaux.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isFav ? Colors.redAccent : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeProductText(context, p.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.6,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "${p.price.toStringAsFixed(2)} DT",
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (p.oldPrice != null)
                            Text(
                              p.oldPrice!.toStringAsFixed(2),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _htr(
                          context,
                          fr: "⭐ ${p.rating.toStringAsFixed(1)} (${p.reviews})",
                          en: "⭐ ${p.rating.toStringAsFixed(1)} (${p.reviews})",
                          ar: "⭐ ${p.rating.toStringAsFixed(1)} (${p.reviews})",
                        ),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            widget.unitLabel,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.stock <= 4
                                ? _htr(
                                    context,
                                    fr: "Stock faible",
                                    en: "Low stock",
                                    ar: "مخزون منخفض",
                                  )
                                : _htr(
                                    context,
                                    fr: "Stock: ${widget.stock}",
                                    en: "Stock: ${widget.stock}",
                                    ar: "المخزون: ${widget.stock}",
                                  ),
                            style: TextStyle(
                              color: widget.stock <= 4
                                  ? Colors.orange.shade700
                                  : AppColors.muted,
                              fontSize: 10.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (widget.promoEndsIn != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.promoEndsIn!,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 10.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      AnimatedScale(
                        scale: _adding ? 1.02 : 1,
                        duration: const Duration(milliseconds: 140),
                        child: cartQty == 0
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _addToCart(p),
                                  icon: Icon(
                                    _adding
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _adding
                                        ? _htr(
                                            context,
                                            fr: "Ajouté",
                                            en: "Added",
                                            ar: "تمت الإضافة",
                                          )
                                        : _htr(
                                            context,
                                            fr: "Ajouter",
                                            en: "Add",
                                            ar: "أضف",
                                          ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(34),
                                    elevation: 0,
                                    backgroundColor: _adding
                                        ? AppColors.bordeaux
                                        : AppColors.bordeaux
                                            .withValues(alpha: 0.10),
                                    foregroundColor: _adding
                                        ? Colors.white
                                        : AppColors.bordeauxDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      side: BorderSide(
                                        color: AppColors.bordeaux
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.bordeaux.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: AppColors.bordeaux
                                        .withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _QtyEdgeButton(
                                      icon: Icons.remove_rounded,
                                      onTap: () => _decCartQty(p, cartQty),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "$cartQty",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.8,
                                        ),
                                      ),
                                    ),
                                    _QtyEdgeButton(
                                      icon: Icons.add_rounded,
                                      onTap: () => _incCartQty(p, cartQty),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}

class _QtyEdgeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyEdgeButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          size: 16,
          color: AppColors.bordeauxDark,
        ),
      ),
    );
  }
}

/* ===================== SLIVER APPBAR ===================== */

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Theme.of(context).colorScheme.surface);
  }
}

class _HomeSliverAppBar extends StatelessWidget {
  const _HomeSliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 78,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.bordeaux.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.80)),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: AppColors.bordeaux, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ElFaddaoui",
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _htr(
                    context,
                    fr: "Votre marché, au meilleur prix",
                    en: "Your market, at the best price",
                    ar: "متجرك بأفضل الأسعار",
                  ),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      height: 1),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, notifState) {
            return _TopIconBtnFine(
              icon: Icons.notifications_rounded,
              semanticLabel: AppLocalizations.of(context).tr('notif_title'),
              badgeCount: notifState.unreadCount,
              onTap: () async {
                HapticFeedback.lightImpact();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
                if (!context.mounted) return;
                context.read<NotificationsCubit>().refreshUnreadCount();
              },
            );
          },
        ),
        const SizedBox(width: 8),
        _TopIconBtnFine(
          icon: Icons.person_rounded,
          semanticLabel: AppLocalizations.of(context).tr('nav_profile'),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            );
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _TopIconBtnFine extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final String semanticLabel;
  final VoidCallback onTap;
  const _TopIconBtnFine({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.80)),
              ),
              child: Icon(icon, color: AppColors.bordeauxDark, size: 20),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -2,
                top: -3,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  key: ValueKey(badgeCount),
                  builder: (_, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? "99+" : "$badgeCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ===================== LOCATION PILL ===================== */

class _LocationPillFine extends StatelessWidget {
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _LocationPillFine(
      {required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 16, color: AppColors.bordeaux),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                      height: 1),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/* ===================== SEARCH BAR ===================== */

class _SearchBarFine extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const _SearchBarFine({
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _htr(
        context,
        fr: "Ouvrir la recherche produit",
        en: "Open product search",
        ar: "فتح بحث المنتجات",
      ),
      child: TextField(
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.bordeaux),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.90),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.bordeaux.withValues(alpha: 0.16),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.bordeaux.withValues(alpha: 0.34),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _TrustBadgesRow extends StatefulWidget {
  const _TrustBadgesRow();

  @override
  State<_TrustBadgesRow> createState() => _TrustBadgesRowState();
}

class _TrustBadgesRowState extends State<_TrustBadgesRow> {
  final _controller = ScrollController();
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    if (_started || !_controller.hasClients) return;
    _started = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || !_controller.hasClients) return;
      const step = 120.0;
      final max = _controller.position.maxScrollExtent;
      final current = _controller.offset;
      final target = current + step;
      if (target >= max - 2) {
        await _controller.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
        if (!mounted || !_controller.hasClients) return;
        _controller.jumpTo(0);
      } else {
        await _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _TrustPill(
            icon: Icons.bolt_rounded,
            text: _htr(
              context,
              fr: "Livraison 45 min",
              en: "45 min delivery",
              ar: "توصيل 45 دقيقة",
            ),
          ),
          const SizedBox(width: 8),
          _TrustPill(
            icon: Icons.lock_rounded,
            text: _htr(
              context,
              fr: "Paiement sécurisé",
              en: "Secure payment",
              ar: "دفع آمن",
            ),
          ),
          const SizedBox(width: 8),
          _TrustPill(
            icon: Icons.replay_rounded,
            text: _htr(
              context,
              fr: "Retour facile",
              en: "Easy return",
              ar: "إرجاع سهل",
            ),
          ),
          const SizedBox(width: 8),
          _TrustPill(
            icon: Icons.support_agent_rounded,
            text: _htr(
              context,
              fr: "Support 7j/7",
              en: "Support 7/7",
              ar: "دعم 7/7",
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartEmptyProducts extends StatelessWidget {
  final VoidCallback onClearFilters;
  const _SmartEmptyProducts({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _htr(
              context,
              fr: "Aucun produit avec ces filtres.",
              en: "No products with these filters.",
              ar: "لا توجد منتجات بهذه الفلاتر.",
            ),
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _htr(
              context,
              fr: "Essayez: Tous, promo OFF, prix plus elevé.",
              en: "Try: All, promo OFF, higher max price.",
              ar: "جرّب: الكل، إيقاف العروض، وسعر أقصى أعلى.",
            ),
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallHintPill(_htr(context, fr: "lait", en: "milk", ar: "حليب")),
              _SmallHintPill(_htr(context, fr: "pain", en: "bread", ar: "خبز")),
              _SmallHintPill(_htr(context, fr: "jus", en: "juice", ar: "عصير")),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onClearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bordeaux,
                side: const BorderSide(color: AppColors.border),
              ),
              child: Text(
                _htr(
                  context,
                  fr: "Effacer les filtres",
                  en: "Clear filters",
                  ar: "مسح الفلاتر",
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallHintPill extends StatelessWidget {
  final String text;
  const _SmallHintPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TrustPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.bordeauxDark),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== CATEGORY ROW ===================== */

class _CategoryRowFine extends StatelessWidget {
  final List<_Cat> items;
  final ValueChanged<_Cat> onCategoryTap;
  const _CategoryRowFine({required this.items, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth >= 430 ? 3 : 2;
          const gap = 12.0;
          final w = (c.maxWidth - (gap * (cols - 1))) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final it in items)
                SizedBox(
                  width: w,
                  child: _CategoryPillFine(
                    title: it.title,
                    icon: it.icon,
                    imageUrl: it.imageUrl,
                    onTap: () => onCategoryTap(it),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Cat {
  final String title;
  final IconData icon;
  final String? key;
  final String? imageUrl;
  const _Cat(this.title, this.icon, {this.key, this.imageUrl});
}

class _CategoryPillFine extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback onTap;
  const _CategoryPillFine({
    required this.title,
    required this.icon,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        height: 92,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.85),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: AppColors.bordeaux.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.bordeaux,
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 34,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentProductsStrip extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onOpen;
  const _RecentProductsStrip({required this.products, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _htr(
            context,
            fr: "Continuer vos achats",
            en: "Continue shopping",
            ar: "تابع التسوق",
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final p = products[i];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onOpen(p),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
                  ),
                  child: Row(
                    children: [
                      _FadeInNetworkImage(
                        url: p.image,
                        width: 64,
                        height: 64,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizeProductText(context, p.name),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${p.price.toStringAsFixed(2)} DT",
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ===================== SHEETS ===================== */

class _ProSheetFine extends StatelessWidget {
  final String title;
  final Widget child;
  const _ProSheetFine({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.90)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 46,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: AppTextStyles.h3
                            .copyWith(fontWeight: FontWeight.w800))),
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
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.text, size: 18),
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

/* ===================== SMART SEARCH SHEET (FIX OPEN PRODUCT) ===================== */

class _SmartSearchSheetFine extends StatefulWidget {
  const _SmartSearchSheetFine();

  @override
  State<_SmartSearchSheetFine> createState() => _SmartSearchSheetFineState();
}

class _SmartSearchSheetFineState extends State<_SmartSearchSheetFine> {
  final _c = TextEditingController();
  final _debounce = _Debouncer(ms: 250);

  List<Product> _results = [];
  final List<String> _recentQueries = [];
  bool _loading = false;
  List<Product> get _catalog {
    final cubit = context.read<HomeCubit>();
    return <Product>[...cubit.state.forYou, ...cubit.state.deals];
  }

  List<String> _suggestionsFor(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final names = _catalog.map((e) => e.name).toSet();
    return names
        .where(
            (n) => n.toLowerCase().contains(q) || n.toLowerCase().startsWith(q))
        .take(6)
        .toList();
  }

  @override
  void dispose() {
    _debounce.dispose();
    _c.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);

    final res = await context.read<HomeCubit>().ai.smartSearch(query, _catalog);

    if (!mounted) return;
    setState(() {
      _results = res;
      if (!_recentQueries.contains(query)) {
        _recentQueries.insert(0, query);
      }
      if (_recentQueries.length > 5) {
        _recentQueries.removeLast();
      }
      _loading = false;
    });
  }

  void _openProduct(Product p) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: p.id,
          initialName: p.name,
          initialImage: p.image,
          initialPrice: p.price,
          initialOldPrice: p.oldPrice,
          initialDescription: p.description,
          initialCategory: p.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trending = <String>[
      _htr(context, fr: "Lait", en: "Milk", ar: "حليب"),
      _htr(context, fr: "Pain", en: "Bread", ar: "خبز"),
      _htr(context, fr: "Pâtes", en: "Pasta", ar: "معكرونة"),
      _htr(context, fr: "Eau", en: "Water", ar: "ماء"),
      _htr(context, fr: "Jus", en: "Juice", ar: "عصير"),
      _htr(context, fr: "Fruits", en: "Fruits", ar: "فواكه"),
    ];
    final suggestions = _suggestionsFor(_c.text);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ProSheetFine(
        title: _htr(
          context,
          fr: "Smart Search",
          en: "Smart Search",
          ar: "بحث ذكي",
        ),
        child: Column(
          children: [
            TextField(
              controller: _c,
              onChanged: (q) {
                setState(() {});
                _debounce.run(() => _runSearch(q));
              },
              decoration: InputDecoration(
                hintText: _htr(
                  context,
                  fr: "Tapez un produit… (ex: lait, pâtes)",
                  en: "Type a product… (e.g. milk, pasta)",
                  ar: "اكتب منتجًا… (مثال: حليب، معكرونة)",
                ),
                filled: true,
                fillColor: AppColors.fieldFill,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic_none_rounded),
                      onPressed: () {
                        AppSnackBar.show(
                          context,
                          _htr(
                            context,
                            fr: "Recherche vocale bientôt disponible.",
                            en: "Voice search coming soon.",
                            ar: "البحث الصوتي قريبًا.",
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      onPressed: () {
                        AppSnackBar.show(
                          context,
                          _htr(
                            context,
                            fr: "Scan produit bientôt disponible.",
                            en: "Product scan coming soon.",
                            ar: "مسح المنتج قريبًا.",
                          ),
                        );
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_results.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _htr(
                        context,
                        fr: "Commencez à taper. Je propose des résultats même si vous vous trompez.",
                        en: "Start typing. I suggest results even with typos.",
                        ar: "ابدأ بالكتابة. أقترح نتائج حتى مع الأخطاء.",
                      ),
                      style: const TextStyle(
                          color: AppColors.muted, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_recentQueries.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _htr(
                        context,
                        fr: "Recherches récentes",
                        en: "Recent searches",
                        ar: "عمليات البحث الأخيرة",
                      ),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentQueries.map((q) {
                        return ActionChip(
                          label: Text(q),
                          onPressed: () {
                            _c.text = q;
                            _runSearch(q);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    _htr(
                      context,
                      fr: "Suggestions",
                      en: "Suggestions",
                      ar: "اقتراحات",
                    ),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: trending.map((q) {
                      return ActionChip(
                        label: Text(q),
                        onPressed: () {
                          _c.text = q;
                          _runSearch(q);
                        },
                      );
                    }).toList(),
                  ),
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _htr(
                        context,
                        fr: "Autocomplétion",
                        en: "Autocomplete",
                        ar: "إكمال تلقائي",
                      ),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((q) {
                        return ActionChip(
                          label: Text(q),
                          onPressed: () {
                            _c.text = q;
                            _runSearch(q);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  if (_c.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _htr(
                          context,
                          fr: "Aucun résultat. Essayez un mot plus court ou une catégorie.",
                          en: "No result. Try a shorter word or a category.",
                          ar: "لا توجد نتائج. جرّب كلمة أقصر أو فئة.",
                        ),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else
              ..._results.map(
                (p) => _SearchResultTileFine(
                  p: p,
                  onTap: () => _openProduct(p),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTileFine extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  const _SearchResultTileFine({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.85),
        child: Row(
          children: [
            _FadeInNetworkImage(
              url: p.image,
              height: 46,
              width: 46,
              borderRadius: BorderRadius.circular(14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizeProductText(context, p.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Text("${p.price.toStringAsFixed(2)} DT",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.bordeaux)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/* ===================== RECIPES SHEET ===================== */

class _RecipesSheetFine extends StatefulWidget {
  const _RecipesSheetFine();

  @override
  State<_RecipesSheetFine> createState() => _RecipesSheetFineState();
}

class _RecipesSheetFineState extends State<_RecipesSheetFine> {
  final _c = TextEditingController();
  String? _result;
  bool _loading = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    final res = await context.read<HomeCubit>().ai.recipeIdea(_c.text.trim());
    if (!mounted) return;
    setState(() {
      _result = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ProSheetFine(
        title: _htr(
          context,
          fr: "Recettes IA 🍽️",
          en: "AI Recipes 🍽️",
          ar: "وصفات بالذكاء الاصطناعي 🍽️",
        ),
        child: Column(
          children: [
            TextField(
              controller: _c,
              maxLines: 2,
              decoration: InputDecoration(
                hintText:
                    _htr(
                      context,
                      fr: "Écrivez vos ingrédients… (ex: œufs, tomate, fromage)",
                      en: "Write your ingredients… (e.g. eggs, tomato, cheese)",
                      ar: "اكتب مكوناتك… (مثال: بيض، طماطم، جبن)",
                    ),
                filled: true,
                fillColor: AppColors.fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        _htr(
                          context,
                          fr: "Générer une idée",
                          en: "Generate an idea",
                          ar: "ولّد فكرة",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_result != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(_result!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.text)),
              ),
          ],
        ),
      ),
    );
  }
}

/* ===================== BUDGET SHEET ===================== */

class _BudgetSheetFine extends StatefulWidget {
  const _BudgetSheetFine();
  @override
  State<_BudgetSheetFine> createState() => _BudgetSheetFineState();
}

class _BudgetSheetFineState extends State<_BudgetSheetFine> {
  double _budget = 50;
  bool _loading = false;
  List<Product> _plan = [];

  Future<void> _generate() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    final cubit = context.read<HomeCubit>();
    final catalog = <Product>[...cubit.state.forYou, ...cubit.state.deals];
    final plan = await cubit.ai.budgetPlan(_budget, catalog);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ProSheetFine(
      title: _htr(
        context,
        fr: "Budget Planner 💸",
        en: "Budget Planner 💸",
        ar: "مخطط الميزانية 💸",
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _htr(
                    context,
                    fr: "Budget: ${_budget.toStringAsFixed(0)} DT",
                    en: "Budget: ${_budget.toStringAsFixed(0)} DT",
                    ar: "الميزانية: ${_budget.toStringAsFixed(0)} د.ت",
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.text),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text("IA",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.bordeaux)),
              ),
            ],
          ),
          Slider(
            value: _budget,
            min: 10,
            max: 200,
            divisions: 19,
            activeColor: AppColors.bordeaux,
            onChanged: (v) => setState(() => _budget = v),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bordeaux,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _loading
                    ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _htr(
                        context,
                        fr: "Générer panier",
                        en: "Generate cart",
                        ar: "ولّد السلة",
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (_plan.isNotEmpty)
            ..._plan.map((p) => _SearchResultTileFine(
                  p: p,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(
                          productId: p.id,
                          initialName: p.name,
                          initialImage: p.image,
                          initialPrice: p.price,
                          initialOldPrice: p.oldPrice,
                          initialDescription: p.description,
                          initialCategory: p.category,
                        ),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }
}

/* ===================== SKELETON ===================== */

class _HomeSkeletonFine extends StatelessWidget {
  const _HomeSkeletonFine();

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 16, double w = double.infinity}) =>
        AppSkeletonBlock(height: h, width: w, radius: 14);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        box(h: 62),
        const SizedBox(height: 12),
        box(h: 160),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: box(h: 42)),
            const SizedBox(width: 8),
            Expanded(child: box(h: 42)),
            const SizedBox(width: 8),
            Expanded(child: box(h: 42)),
          ],
        ),
        const SizedBox(height: 12),
        box(h: 54),
        const SizedBox(height: 16),
        box(h: 18, w: 180),
        const SizedBox(height: 10),
        box(h: 100),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .64,
          ),
          itemBuilder: (_, __) => box(h: 210),
        ),
      ],
    );
  }
}

int _stockFromProduct(Product p) {
  final hash = p.id.codeUnits.fold<int>(0, (a, b) => a + b);
  return 2 + (hash % 24);
}

String _unitLabelFor(Product p) {
  final lower = p.name.toLowerCase();
  if (lower.contains("lait") ||
      lower.contains("jus") ||
      lower.contains("eau")) {
    return "1L";
  }
  if (lower.contains("pommes") || lower.contains("fruit")) return "1kg";
  return "500g";
}

String? _promoEndsIn(Product p) {
  final discount = p.discountPct ?? 0;
  if (discount <= 0) return null;
  final day = (p.id.codeUnits.first % 4) + 1;
  return "Se termine dans $day j";
}
