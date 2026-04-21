import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/l10n/product_text_localizer.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _history = ['Pommes', 'Lait', 'Pain'];
  final List<String> _popular = ['Jus', 'Yaourt', 'Pates', 'Eau'];
  final List<String> _fallbackQueries = ['lait', 'jus', 'pain'];
  List<_SearchHit> _results = const [];

  static const List<_SearchProduct> _catalog = [
    _SearchProduct('Lait Frais 1L', 'Boissons'),
    _SearchProduct('Lait Amande', 'Boissons'),
    _SearchProduct('Yaourt Nature', 'Produits Laitiers'),
    _SearchProduct('Fromage Tranches', 'Produits Laitiers'),
    _SearchProduct('Pain Complet', 'Boulangerie'),
    _SearchProduct('Croissant Beurre', 'Boulangerie'),
    _SearchProduct('Pates Italiennes', 'Epicerie'),
    _SearchProduct('Riz Jasmin', 'Epicerie'),
    _SearchProduct('Huile Olive', 'Epicerie'),
    _SearchProduct('Jus Orange', 'Boissons'),
    _SearchProduct('Eau Minerale', 'Boissons'),
    _SearchProduct('Soda Citron', 'Boissons'),
    _SearchProduct('Pommes Rouges', 'Fruits et Legumes'),
    _SearchProduct('Bananes', 'Fruits et Legumes'),
    _SearchProduct('Tomates', 'Fruits et Legumes'),
    _SearchProduct('Concombre', 'Fruits et Legumes'),
    _SearchProduct('Poulet Frais', 'Viandes et Poissons'),
    _SearchProduct('Thon', 'Viandes et Poissons'),
    _SearchProduct('Lessive Fraicheur', 'Produits Menagers'),
    _SearchProduct('Shampoing Doux', 'Hygiene et Beaute'),
  ];

  static const Map<String, List<String>> _synonyms = {
    'lait': ['lait', 'dairy', 'yaourt', 'fromage', 'beurre'],
    'pain': ['pain', 'baguette', 'croissant', 'boulangerie'],
    'boisson': ['boisson', 'jus', 'eau', 'soda', 'cafe', 'the'],
    'fruit': ['fruit', 'pomme', 'banane', 'orange', 'tomate'],
    'epicerie': ['epicerie', 'pates', 'riz', 'huile', 'conserve'],
    'viande': ['viande', 'poulet', 'boeuf', 'poisson', 'thon'],
    'menage': ['menage', 'lessive', 'nettoyant', 'javel'],
    'beaute': ['beaute', 'hygiene', 'shampoing', 'savon', 'creme'],
  };

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _results = _search(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitQuery(String raw) {
    final q = raw.trim();
    if (q.isEmpty) return;

    if (!_history.contains(q)) {
      _history.insert(0, q);
      if (_history.length > 8) {
        _history.removeLast();
      }
    }

    setState(() {
      _controller.text = q;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
      _results = _search(q);
    });
  }

  List<_SearchHit> _search(String query) {
    final q = _normalize(query);
    if (q.isEmpty) return const [];

    final scored = <_SearchHit>[];
    for (final p in _catalog) {
      final score = _scoreProduct(p, q);
      if (score > 0) {
        scored.add(_SearchHit(product: p, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(12).toList(growable: false);
  }

  int _scoreProduct(_SearchProduct product, String normalizedQuery) {
    final queryTokens = normalizedQuery.split(' ').where((e) => e.isNotEmpty);
    final name = _normalize(product.name);
    final category = _normalize(product.category);
    final productText = '$name $category';

    var score = 0;

    if (name.startsWith(normalizedQuery)) score += 120;
    if (name.contains(normalizedQuery)) score += 95;
    if (category.contains(normalizedQuery)) score += 55;

    for (final token in queryTokens) {
      if (token.length < 2) continue;

      if (productText.contains(token)) {
        score += 36;
      }

      for (final syn in _expandedSynonyms(token)) {
        if (productText.contains(syn)) {
          score += 24;
          break;
        }
      }

      final nameTokens = name.split(' ').where((e) => e.length >= 3);
      var bestDistance = 99;
      for (final nt in nameTokens) {
        final d = _levenshtein(token, nt);
        if (d < bestDistance) bestDistance = d;
        if (bestDistance == 0) break;
      }

      if (bestDistance == 1) score += 20;
      if (bestDistance == 2) score += 10;
    }

    if (queryTokens.length > 1 && name.contains(normalizedQuery)) {
      score += 26;
    }

    return score;
  }

  Iterable<String> _expandedSynonyms(String token) sync* {
    for (final entry in _synonyms.entries) {
      final key = entry.key;
      final values = entry.value;
      final hit = key.contains(token) ||
          token.contains(key) ||
          values.any((v) => v.contains(token));
      if (!hit) continue;
      yield key;
      yield* values;
    }
  }

  List<String> _suggestionsFor(String query) {
    final q = _normalize(query);
    if (q.isEmpty) return const [];

    final suggestions = <String>{};

    for (final p in _catalog) {
      final normalized = _normalize(p.name);
      if (normalized.contains(q) || normalized.startsWith(q)) {
        suggestions.add(p.name);
      }
    }

    for (final entry in _synonyms.entries) {
      final key = entry.key;
      final values = entry.value;
      if (key.contains(q) || values.any((v) => v.contains(q))) {
        suggestions.add(key);
        suggestions.addAll(values.take(2));
      }
    }

    return suggestions.take(8).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().isNotEmpty;
    final suggestions = _suggestionsFor(_controller.text);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
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
            });
          },
        ),
      ),
      body: _results.isNotEmpty
          ? ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final hit = _results[i];
                return _ResultTile(
                  hit: hit,
                  onTap: () => _submitQuery(hit.product.name),
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
                        fr: 'Aucun resultat',
                        en: 'No result',
                        ar: 'لا توجد نتائج',
                      ),
                      subtitle: tr3(
                        context,
                        fr: 'Essaye: lait, jus, pain.',
                        en: 'Try: milk, juice, bread.',
                        ar: 'جرّب: حليب، عصير، خبز.',
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
                        });
                      },
                    ),
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        tr3(context, fr: 'Suggestions intelligentes', en: 'Smart suggestions', ar: 'اقتراحات ذكية'),
                        style: AppTextStyles.h3
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: suggestions
                            .map(
                              (s) => _Chip(
                                text: localizeProductText(context, s),
                                onTap: () => _submitQuery(s),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    const SizedBox(height: 18),
                  ],
                  Text(
                    tr3(context, fr: 'Recherches recentes', en: 'Recent searches', ar: 'عمليات البحث الأخيرة'),
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _history
                        .map(
                          (q) => _Chip(
                            text: localizeProductText(context, q),
                            onTap: () => _submitQuery(q),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    tr3(context, fr: 'Recherches populaires', en: 'Popular searches', ar: 'عمليات البحث الشائعة'),
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _popular
                        .map(
                          (q) => _Chip(
                            text: localizeProductText(context, q),
                            onTap: () => _submitQuery(q),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    tr3(context, fr: 'Essaye aussi', en: 'Try also', ar: 'جرّب أيضاً'),
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _fallbackQueries
                        .map(
                          (q) => _Chip(
                            text: localizeProductText(context, q),
                            onTap: () => _submitQuery(q),
                          ),
                        )
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
                  child:
                      const Icon(Icons.close_rounded, color: AppColors.muted),
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
  final _SearchHit hit;
  final VoidCallback onTap;

  const _ResultTile({required this.hit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = hit.product;
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
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.bordeaux,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeProductText(context, p.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    localizeProductText(context, p.category),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.muted,
            ),
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

class _SearchProduct {
  final String name;
  final String category;

  const _SearchProduct(this.name, this.category);
}

class _SearchHit {
  final _SearchProduct product;
  final int score;

  const _SearchHit({required this.product, required this.score});
}

String _normalize(String input) {
  const source = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñÝýÿ';
  const target = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNnYyy';
  final buffer = StringBuffer();

  for (final rune in input.trim().toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    final idx = source.indexOf(ch);
    if (idx >= 0) {
      buffer.write(target[idx].toLowerCase());
    } else {
      buffer.write(ch);
    }
  }

  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
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
