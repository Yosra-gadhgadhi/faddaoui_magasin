import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/l10n/product_text_localizer.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/widgets/icon_pill.dart';
import 'package:elfaddoui_app/core/widgets/primary_card.dart';
import 'package:elfaddoui_app/core/widgets/section_header.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/category_products_screen.dart'
    hide Product;
import 'package:elfaddoui_app/features/home/presentation/cubit/home_state.dart';
import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = AiHomeService();
  final _search = TextEditingController();

  bool _loading = true;
  String? _error;

  int _filterIndex = 0;
  final _fixedCategoryKeys = const <String>[
    'electromenager',
    'tv multimedia',
    'cuisine vaisselle',
    'fruits et legumes',
    'boissons',
    'epicerie',
  ];

  List<_CategoryUi> _all = const [];
  List<_CategoryUi> _view = const [];

  final Map<String, List<String>> _synonyms = const {
    'fruits': ['fruit', 'pomme', 'banane', 'orange', 'legume', 'salade', 'khodhra', 'ghalla'],
    'boissons': ['boisson', 'jus', 'eau', 'soda', 'cafe', 'the'],
    'epicerie': ['epicerie', 'pates', 'riz', 'huile', 'conserve'],
    'laitiers': ['lait', 'yaourt', 'fromage', 'beurre'],
    'electromenager': [
      'electro',
      'electromenager',
      'frigo',
      'fregidaire',
      'frigidaire',
      'ghasala',
      'machine',
      'lavelinge',
      'gaz',
      'gaziniere',
      'four',
      'tv',
      'tele',
      'television',
      'microondes',
    ],
    'vaisselle': ['ma3oun', 'maoun', 'plat', 'assiette', 'vaisselle', 'casserole', 'poele', 'ustensile'],
    'maison': ['maison', 'menage', 'nettoyage', 'lessive', 'savon', 'detergent'],
    'promo': ['promo', 'promotion', 'remise', 'discount'],
    'bio': ['bio', 'organic', 'naturel'],
    'populaire': ['populaire', 'top', 'tendance', 'best'],
  };

  @override
  void initState() {
    super.initState();
    _search.addListener(_applyFilters);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.bootstrapHome();
      final products = _uniqById([
        ...data.deals,
        ...data.forYou,
        ...data.recent,
      ]);

      final grouped = <String, List<Product>>{};
      for (final p in products) {
        final key = _categoryKey(p);
        grouped.putIfAbsent(key, () => <Product>[]).add(p);
      }

      final built = _buildFixedCategories(grouped);

      setState(() {
        _all = built;
        _loading = false;
      });
      _applyFilters();
    } catch (_) {
      setState(() {
        _all = _fallback();
        _loading = false;
        _error = AppLocalizations.of(context).tr('categories_server_unavailable');
      });
      _applyFilters();
    }
  }

  List<_CategoryUi> _buildFixedCategories(Map<String, List<Product>> grouped) {
    final fallbackMap = {for (final c in _fallback()) c.key: c};
    final out = <_CategoryUi>[];

    for (final key in _fixedCategoryKeys) {
      final items = grouped[key] ?? const <Product>[];
      if (items.isEmpty) {
        final base = fallbackMap[key];
        if (base != null) out.add(base);
        continue;
      }
      out.add(_toCategory(key, items));
    }

    return out;
  }

  List<Product> _uniqById(List<Product> list) {
    final map = <String, Product>{};
    for (final p in list) {
      map[p.id] = p;
    }
    return map.values.toList(growable: false);
  }

  String _categoryKey(Product p) {
    final fromApi = _normalize(p.category ?? '');
    if (fromApi.isNotEmpty) return _normalizeCategoryKey(fromApi);

    final n = _normalize(p.name);
    return _normalizeCategoryKey(n);
  }

  String _normalizeCategoryKey(String input) {
    final n = _normalize(input);
    bool has(List<String> keys) => keys.any(n.contains);

    if (has([
      'tv',
      'tele',
      'television',
      'ecran',
      'multimedia',
    ])) {
      return 'tv multimedia';
    }

    if (has([
      'electro',
      'electromenager',
      'frigo',
      'fregidaire',
      'frigidaire',
      'ghasala',
      'lave linge',
      'machine a laver',
      'gaz',
      'gaziniere',
      'four',
      'micro ondes',
      'microondes',
    ])) {
      return 'electromenager';
    }

    if (has([
      'ma3oun',
      'maoun',
      'plat',
      'assiette',
      'vaisselle',
      'ustensile',
      'casserole',
      'poele',
      'cuisine',
    ])) {
      return 'cuisine vaisselle';
    }

    if (has([
      'lait',
      'yaourt',
      'fromage',
      'beurre',
    ])) {
      return 'produits laitiers';
    }
    if (has(['jus', 'eau', 'boisson', 'soda', 'cafe', 'the'])) {
      return 'boissons';
    }
    if (has([
      'fruit',
      'pomme',
      'banane',
      'orange',
      'legume',
      'khodhra',
      'ghalla',
      'tomate',
    ])) {
      return 'fruits et legumes';
    }
    if (has([
      'maison',
      'menage',
      'nettoyage',
      'lessive',
      'savon',
      'detergent',
    ])) {
      return 'maison';
    }
    return 'epicerie';
  }

  _CategoryUi _toCategory(String key, List<Product> items) {
    final promoCount = items.where((e) => (e.discountPct ?? 0) > 0).length;
    final avgReviews = items.isEmpty
        ? 0
        : (items.fold<int>(0, (s, e) => s + e.reviews) / items.length).toInt();

    final tags = <String>[];
    if (promoCount > 0) tags.add('Promos');
    if (avgReviews >= 140) tags.add('Populaires');
    if (key.contains('fruit') ||
        key.contains('beaute') ||
        key.contains('hygiene')) {
      tags.add('Bio');
    }
    if (items.length <= 3) tags.add('Nouveaux');
    if (tags.isEmpty) tags.add('Populaires');

    final visual = _visualFor(key);
    return _CategoryUi(
      key: key,
      name: _displayName(key),
      image: _categoryCover(key, items.first.image),
      count: items.length,
      promoCount: promoCount,
      tags: tags,
      icon: visual.$1,
      color: visual.$2,
    );
  }

  String _displayName(String key) {
    if (key.contains('electromenager')) return 'Électroménager';
    if (key.contains('tv multimedia')) return 'TV & Multimédia';
    if (key.contains('cuisine vaisselle')) return 'Cuisine & Vaisselle';
    if (key.contains('fruit')) return 'Fruits & Légumes';
    if (key.contains('boisson')) return 'Boissons';
    if (key.contains('lait')) return 'Produits Laitiers';
    if (key.contains('epicerie')) return 'Épicerie';
    if (key.contains('viande') || key.contains('poisson')) {
      return 'Viandes & Poissons';
    }
    if (key.contains('menager') || key.contains('maison')) return 'Maison';
    return _capitalizeWords(key);
  }

  (IconData, Color) _visualFor(String key) {
    if (key.contains('electromenager')) {
      return (Icons.kitchen_rounded, const Color(0xFFEFF2FF));
    }
    if (key.contains('tv multimedia')) {
      return (Icons.tv_rounded, const Color(0xFFEAF4FF));
    }
    if (key.contains('cuisine vaisselle')) {
      return (Icons.restaurant_rounded, const Color(0xFFFFF4EC));
    }
    if (key.contains('fruit')) {
      return (Icons.eco_rounded, const Color(0xFFE8F5EC));
    }
    if (key.contains('boisson')) {
      return (Icons.local_drink_rounded, const Color(0xFFEAF4FF));
    }
    if (key.contains('lait')) {
      return (Icons.breakfast_dining_rounded, const Color(0xFFEFF0FF));
    }
    if (key.contains('epicerie')) {
      return (Icons.storefront_rounded, const Color(0xFFFFF3E8));
    }
    if (key.contains('viande') || key.contains('poisson')) {
      return (Icons.set_meal_rounded, const Color(0xFFFFECEC));
    }
    if (key.contains('maison')) {
      return (Icons.cleaning_services_rounded, const Color(0xFFF3F3F3));
    }
    return (Icons.shopping_bag_rounded, const Color(0xFFF3F3F3));
  }

  String _categoryCover(String key, String fallback) {
    if (key.contains('electromenager')) {
      return 'https://images.pexels.com/photos/5591838/pexels-photo-5591838.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('tv multimedia')) {
      return 'https://images.pexels.com/photos/5825570/pexels-photo-5825570.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('cuisine vaisselle')) {
      return 'https://images.pexels.com/photos/4226805/pexels-photo-4226805.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('fruit')) {
      return 'https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('boisson')) {
      return 'https://images.pexels.com/photos/96974/pexels-photo-96974.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    if (key.contains('maison')) {
      return 'https://images.pexels.com/photos/4239031/pexels-photo-4239031.jpeg?auto=compress&cs=tinysrgb&w=1200';
    }
    return fallback;
  }

  void _applyFilters() {
    final q = _normalize(_search.text);
    final list = _all.where((c) {
      final searchOk = q.isEmpty || _matchesCategory(c, q);
      final chipOk = switch (_filterIndex) {
        1 => c.tags.contains('Populaires'),
        2 => c.tags.contains('Promos'),
        3 => c.tags.contains('Bio'),
        4 => c.tags.contains('Nouveaux'),
        _ => true,
      };
      return searchOk && chipOk;
    }).toList();

    list.sort((a, b) {
      final ai = _fixedCategoryKeys.indexOf(a.key);
      final bi = _fixedCategoryKeys.indexOf(b.key);
      return ai.compareTo(bi);
    });

    if (!mounted) return;
    setState(() => _view = list);
  }

  bool _matchesCategory(_CategoryUi c, String q) {
    final name = _normalize(c.name);
    if (name.contains(q)) return true;
    if (c.tags.any((t) => _normalize(t).contains(q))) return true;

    for (final entry in _synonyms.entries) {
      final bucket = entry.key;
      final words = entry.value;
      final hit =
          bucket.contains(q) || words.any((w) => _normalize(w).contains(q));
      if (!hit) continue;
      if (name.contains(bucket)) return true;
      if (bucket == 'promo' && c.tags.contains('Promos')) return true;
      if (bucket == 'bio' && c.tags.contains('Bio')) return true;
      if (bucket == 'populaire' && c.tags.contains('Populaires')) return true;
    }

    final tokens = name.split(' ').where((e) => e.length >= 3);
    for (final t in tokens) {
      final d = _levenshtein(q, t);
      if (d <= 1) return true;
      if (q.length >= 5 && d == 2) return true;
    }
    return false;
  }

  List<String> _suggestions() {
    final q = _normalize(_search.text);
    if (q.isEmpty) return const ['lait', 'fruit', 'promo', 'boisson'];
    final out = <String>{};
    for (final c in _all) {
      final n = _normalize(c.name);
      if (n.contains(q) || n.startsWith(q)) out.add(c.name);
    }
    for (final entry in _synonyms.entries) {
      if (entry.key.contains(q) ||
          entry.value.any((w) => _normalize(w).contains(q))) {
        out.add(entry.key);
        out.addAll(entry.value.take(2));
      }
    }
    return out.take(8).toList(growable: false);
  }

  List<_CategoryUi> _fallback() => const [
        _CategoryUi(
          key: 'electromenager',
          name: 'Électroménager',
          image:
              'https://images.pexels.com/photos/5591838/pexels-photo-5591838.jpeg?auto=compress&cs=tinysrgb&w=1200',
          count: 11,
          promoCount: 2,
          tags: ['Populaires', 'Nouveaux'],
          icon: Icons.kitchen_rounded,
          color: Color(0xFFEFF2FF),
        ),
        _CategoryUi(
          key: 'tv multimedia',
          name: 'TV & Multimédia',
          image:
              'https://images.pexels.com/photos/5825570/pexels-photo-5825570.jpeg?auto=compress&cs=tinysrgb&w=1200',
          count: 7,
          promoCount: 1,
          tags: ['Populaires'],
          icon: Icons.tv_rounded,
          color: Color(0xFFEAF4FF),
        ),
        _CategoryUi(
          key: 'cuisine vaisselle',
          name: 'Cuisine & Vaisselle',
          image:
              'https://images.pexels.com/photos/4226805/pexels-photo-4226805.jpeg?auto=compress&cs=tinysrgb&w=1200',
          count: 13,
          promoCount: 3,
          tags: ['Promos', 'Populaires'],
          icon: Icons.restaurant_rounded,
          color: Color(0xFFFFF4EC),
        ),
        _CategoryUi(
          key: 'boissons',
          name: 'Boissons',
          image:
              'https://images.pexels.com/photos/616836/pexels-photo-616836.jpeg?auto=compress&cs=tinysrgb&w=1200',
          count: 9,
          promoCount: 2,
          tags: ['Promos', 'Populaires'],
          icon: Icons.local_drink_rounded,
          color: Color(0xFFEAF4FF),
        ),
        _CategoryUi(
          key: 'epicerie',
          name: 'Épicerie',
          image:
              'https://images.pexels.com/photos/3962285/pexels-photo-3962285.jpeg?auto=compress&cs=tinysrgb&w=1200',
          count: 12,
          promoCount: 3,
          tags: ['Promos', 'Populaires'],
          icon: Icons.storefront_rounded,
          color: Color(0xFFFFF3E8),
        ),
        _CategoryUi(
          key: 'fruits et legumes',
          name: 'Fruits & Légumes',
          image:
              'https://images.pexels.com/photos/1132047/pexels-photo-1132047.jpeg?auto=compress&cs=tinysrgb&w=1200',
          count: 8,
          promoCount: 1,
          tags: ['Bio', 'Populaires'],
          icon: Icons.eco_rounded,
          color: Color(0xFFE8F5EC),
        ),
      ];

  void _openCategory(_CategoryUi c) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryName: localizeProductText(context, c.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions();
    final isEmpty = !_loading && _error == null && _view.isEmpty;
    final promoTotal = _view.fold<int>(0, (s, c) => s + c.promoCount);

    final t = AppLocalizations.of(context);
    final filters = <String>[
      t.tr('common_all'),
      t.tr('common_popular'),
      t.tr('common_promos'),
      t.tr('common_bio'),
      t.tr('common_new'),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: AppColors.bordeauxDark,
              ),
              SizedBox(width: 8),
              Text(
                t.tr('nav_categories'),
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
            tooltip: t.tr('common_refresh'),
            onPressed: _load,
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.bordeaux.withValues(alpha: 0.14)),
              ),
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const _CategoriesSkeleton()
            : _error != null
                ? _CategoriesError(message: _error!, onRetry: _load)
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: _CategoriesHero(
                          title: t.tr('categories_hero_title'),
                          subtitle: t.tr('categories_hero_subtitle'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        child: _SearchField(
                          controller: _search,
                          hint: t.tr('categories_search_hint'),
                          onClear: () {
                            _search.clear();
                            _applyFilters();
                          },
                        ),
                      ),
                      if (_search.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: SizedBox(
                            height: AppSize.chipHeight,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: suggestions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final s = suggestions[i];
                                return _SuggestionChip(
                                  text: localizeProductText(context, s),
                                  onTap: () {
                                    _search.text = s;
                                    _search.selection = TextSelection.collapsed(
                                        offset: _search.text.length);
                                    _applyFilters();
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _HorizontalChips(
                          labels: filters,
                          selected: _filterIndex,
                          onTap: (i) {
                            setState(() => _filterIndex = i);
                            _applyFilters();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                        child: SectionHeader(
                          title: t.tr('categories_all_title'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MiniStatChip(
                                icon: Icons.grid_view_rounded,
                                text: '${_view.length}',
                              ),
                              const SizedBox(width: 8),
                              _MiniStatChip(
                                icon: Icons.local_offer_rounded,
                                text: t.tr(
                                  'common_promos_count',
                                  params: {'count': '$promoTotal'},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: isEmpty
                              ? _EmptyState(
                                  key: const ValueKey('empty'),
                                  onReset: () {
                                    setState(() {
                                      _filterIndex = 0;
                                    });
                                    _search.clear();
                                    _applyFilters();
                                  },
                                )
                              : GridView.builder(
                                  key: const ValueKey('grid'),
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 2, 16, 16),
                                  itemCount: _view.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        MediaQuery.of(context).size.width >= 420
                                            ? 3
                                            : 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.68,
                                  ),
                                  itemBuilder: (_, i) {
                                    final c = _view[i];
                                    return _CategoryCard(
                                      c: c,
                                      onTap: () => _openCategory(c),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
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

class _CategoriesHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CategoriesHero({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      radius: AppRadius.lg,
      color: AppColors.soft,
      borderAlpha: 0.82,
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.bordeaux.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.bordeaux,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.8,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalChips extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onTap;

  const _HorizontalChips({
    required this.labels,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: AppSize.chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.bordeaux.withValues(alpha: 0.10)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected
                      ? AppColors.bordeaux.withValues(alpha: 0.26)
                      : AppColors.border.withValues(alpha: 0.72),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.bordeaux
                        : AppColors.text.withValues(alpha: .78),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryUi c;
  final VoidCallback onTap;

  const _CategoryCard({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = this.c;
    final tag = c.tags.contains('Promos')
        ? t.tr('common_promos')
        : c.tags.contains('Bio')
            ? t.tr('common_bio')
            : c.tags.contains('Nouveaux')
                ? t.tr('common_new')
                : c.tags.contains('Populaires')
                    ? t.tr('common_popular')
                    : null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: c.color.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
                  ),
                  child: Icon(c.icon, size: 18, color: AppColors.bordeaux),
                ),
                const Spacer(),
                if (tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bordeaux.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppColors.bordeaux,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                c.image,
                height: 88,
                width: double.infinity,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Container(
                  height: 88,
                  color: AppColors.soft,
                  alignment: Alignment.center,
                  child: Icon(c.icon, color: AppColors.bordeaux),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              localizeProductText(context, c.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.tr('categories_products_count', params: {'count': '${c.count}'}),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  t.tr('categories_view_products'),
                  style: const TextStyle(
                    color: AppColors.bordeaux,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.bordeaux,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        const Row(
          children: [
            Expanded(child: _SkeletonBox(height: 68)),
            SizedBox(width: 10),
            Expanded(child: _SkeletonBox(height: 68)),
          ],
        ),
        const SizedBox(height: 10),
        const _SkeletonBox(height: 60),
        const SizedBox(height: 10),
        const _SkeletonBox(height: 54),
        const SizedBox(height: 10),
        const _SkeletonBox(height: 40),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (_, __) => const _SkeletonBox(height: 210),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: AppSurface.card(
        radius: AppRadius.lg,
        color: AppColors.soft,
        borderAlpha: 1,
      ),
    );
  }
}

class _CategoriesError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _CategoriesError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 44, color: AppColors.bordeaux),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bordeaux,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(t.tr('common_retry')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _KpiCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.75),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.bordeaux),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Container(
        height: AppSize.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniStatChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return IconPill(
      icon: icon,
      label: text,
      iconSize: 13,
      backgroundColor: AppColors.soft,
      borderAlpha: 0.72,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        EmptyStatePanel(
          icon: Icons.search_off_rounded,
          title: t.tr('categories_empty_title'),
          subtitle: t.tr('categories_empty_subtitle'),
          primaryLabel: t.tr('common_clear'),
          onPrimary: onReset,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HintChip(text: t.tr('categories_hint_milk')),
            _HintChip(text: t.tr('categories_hint_fruit')),
            _HintChip(text: t.tr('categories_hint_promo')),
          ],
        ),
      ],
    );
  }
}

class _HintChip extends StatelessWidget {
  final String text;
  const _HintChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CategoryUi {
  final String key;
  final String name;
  final String image;
  final int count;
  final int promoCount;
  final List<String> tags;
  final IconData icon;
  final Color color;

  const _CategoryUi({
    required this.key,
    required this.name,
    required this.image,
    required this.count,
    required this.promoCount,
    required this.tags,
    required this.icon,
    required this.color,
  });
}

String _normalize(String input) {
  const source = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñÝýÿ';
  const target = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNnYyy';
  final b = StringBuffer();

  for (final rune in input.trim().toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    final i = source.indexOf(ch);
    if (i >= 0) {
      b.write(target[i].toLowerCase());
    } else {
      b.write(ch);
    }
  }

  return b
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _capitalizeWords(String input) {
  return input
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  final cur = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    cur[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = _min3(
        cur[j - 1] + 1,
        prev[j] + 1,
        prev[j - 1] + cost,
      );
    }
    for (var j = 0; j <= b.length; j++) {
      prev[j] = cur[j];
    }
  }
  return prev[b.length];
}

int _min3(int a, int b, int c) {
  var m = a;
  if (b < m) m = b;
  if (c < m) m = c;
  return m;
}
