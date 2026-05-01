import 'dart:async';

import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:elfaddoui_app/features/home/presentation/cubit/home_state.dart';
import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final AiHomeService _api = AiHomeService();

  final List<String> _history = [];
  List<String> _popular = const [];
  List<Product> _results = const [];

  bool _loading = false;
  String? _error;
  int _searchSeq = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _loadPopular();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPopular() async {
    try {
      final products = await _api.searchPublicProducts(size: 12, sort: 'top');
      if (!mounted) return;
      final names = products
          .map((e) => e.name.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .take(8)
          .toList(growable: false);
      setState(() => _popular = names);
    } catch (_) {
      if (!mounted) return;
      setState(() => _popular = const []);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      _runSearch(_controller.text);
    });
  }

  Future<void> _runSearch(String raw) async {
    final q = raw.trim();
    final seq = ++_searchSeq;

    if (q.isEmpty) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.searchPublicProducts(query: q, size: 24);
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _results = res;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _results = const [];
        _loading = false;
        _error = tr3(
          context,
          fr: 'Erreur serveur',
          en: 'Server error',
          ar: 'خطأ في الخادم',
        );
      });
    }
  }

  void _submitQuery(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;

    _history.remove(q);
    _history.insert(0, q);
    if (_history.length > 10) _history.removeLast();

    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    _runSearch(q);
  }

  List<String> _suggestionsFor(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _results
        .map((e) => e.name)
        .where((e) => e.toLowerCase().contains(q))
        .toSet()
        .take(8)
        .toList(growable: false);
  }

  void _openProduct(Product p) {
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
    final hasQuery = _controller.text.trim().isNotEmpty;
    final suggestions = _suggestionsFor(_controller.text);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: _SearchBarInline(
          controller: _controller,
          onSubmitted: _submitQuery,
          onClear: () {
            setState(() {
              _controller.clear();
              _results = const [];
              _error = null;
              _loading = false;
            });
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isNotEmpty
              ? ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = _results[i];
                    return _ResultTile(
                      product: p,
                      onTap: () => _openProduct(p),
                    );
                  },
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasQuery) ...[
                        EmptyStatePanel(
                          icon: Icons.search_off_rounded,
                          title: tr3(
                            context,
                            fr: 'Aucun résultat',
                            en: 'No result',
                            ar: 'لا توجد نتائج',
                          ),
                          subtitle: _error ??
                              tr3(
                                context,
                                fr: 'Aucun produit trouvé pour cette recherche.',
                                en: 'No product found for this query.',
                                ar: 'لا يوجد منتج مطابق لهذا البحث.',
                              ),
                          primaryLabel: tr3(
                            context,
                            fr: 'Effacer la recherche',
                            en: 'Clear search',
                            ar: 'مسح البحث',
                          ),
                          onPrimary: () {
                            setState(() {
                              _controller.clear();
                              _results = const [];
                              _error = null;
                            });
                          },
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            tr3(context, fr: 'Suggestions', en: 'Suggestions', ar: 'اقتراحات'),
                            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: suggestions
                                .map((s) => _Chip(text: s, onTap: () => _submitQuery(s)))
                                .toList(growable: false),
                          ),
                        ],
                        const SizedBox(height: 18),
                      ],
                      Text(
                        tr3(context, fr: 'Recherches recentes', en: 'Recent searches', ar: 'عمليات البحث الأخيرة'),
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _history
                            .map((q) => _Chip(text: q, onTap: () => _submitQuery(q)))
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        tr3(context, fr: 'Produits populaires', en: 'Popular products', ar: 'منتجات شائعة'),
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _popular
                            .map((q) => _Chip(text: q, onTap: () => _submitQuery(q)))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _SearchBarInline extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBarInline({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: tr3(context, fr: 'Rechercher un produit...', en: 'Search a product...', ar: 'ابحث عن منتج...'),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) {
              if (v.text.trim().isEmpty) return const SizedBox(width: 8);
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onClear,
                child: Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close_rounded, color: AppColors.muted),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ResultTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: product.image.trim().isEmpty
                  ? const Icon(Icons.shopping_bag_rounded, color: AppColors.bordeaux, size: 20)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_bag_rounded,
                          color: AppColors.bordeaux,
                          size: 20,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.category ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _Chip({required this.text, required this.onTap});

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
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
