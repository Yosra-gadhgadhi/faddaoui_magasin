import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/core/widgets/icon_pill.dart';
import 'package:elfaddoui_app/core/widgets/primary_card.dart';
import 'package:elfaddoui_app/core/widgets/section_header.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';
import 'package:elfaddoui_app/core/widgets/app_skeleton.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/category_products_screen.dart'
    hide Product;
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

  List<_CategoryUi> _all = const [];
  List<_CategoryUi> _view = const [];

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
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final categories = await _api.getPublicCategories();
      if (!mounted) return;
      final built = categories.map(_toPublicCategoryUi).toList(growable: false);

      setState(() {
        _all = built;
        _loading = false;
      });
      _applyFilters();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _all = const [];
        _loading = false;
        _error = AppLocalizations.of(context).tr('categories_server_unavailable');
      });
      _applyFilters();
    }
  }

  _CategoryUi _toPublicCategoryUi(Map<String, dynamic> raw) {
    String key = (raw['key'] ?? raw['name'] ?? '').toString().trim();
    key = key.isEmpty ? 'category' : key;
    final name = (raw['name'] ?? '').toString().trim();
    final image = ApiConstants.resolveAssetUrl((raw['imageUrl'] ?? '').toString().trim());
    final count = _toInt(raw['productCount']);
    final promoCount = _toInt(raw['promoCount']);
    final rawTags = raw['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(growable: false)
        : const <String>[];
    return _CategoryUi(
      key: key,
      name: name.isNotEmpty ? name : key,
      image: image,
      count: count,
      promoCount: promoCount,
      tags: tags.isEmpty ? const ['Populaires'] : tags,
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFFF3F3F3),
    );
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
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

    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (!mounted) return;
    setState(() => _view = list);
  }

  bool _matchesCategory(_CategoryUi c, String q) {
    final name = _normalize(c.name);
    final key = _normalize(c.key);
    if (name.contains(q) || key.contains(q)) return true;
    return c.tags.any((t) => _normalize(t).contains(q));
  }

  List<String> _suggestions() {
    final q = _normalize(_search.text);
    if (q.isEmpty) return const [];
    final out = <String>{};
    for (final c in _all) {
      final n = _normalize(c.name);
      if (n.contains(q) || n.startsWith(q)) out.add(c.name);
    }
    return out.take(8).toList(growable: false);
  }

  void _openCategory(_CategoryUi c) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryName: c.name,
          categoryKey: c.key,
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
                                  text: s,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
              Container(
                height: 88,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.75),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.network(
                    c.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(c.icon, color: AppColors.bordeaux),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                c.name,
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
            Expanded(child: AppSkeletonBlock(height: 68)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBlock(height: 68)),
          ],
        ),
        const SizedBox(height: 10),
        const AppSkeletonBlock(height: 60),
        const SizedBox(height: 10),
        const AppSkeletonBlock(height: 54),
        const SizedBox(height: 10),
        const AppSkeletonBlock(height: 40),
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
          itemBuilder: (_, __) => const AppSkeletonBlock(height: 210),
        ),
      ],
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
