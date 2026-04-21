import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';

class LoyaltyVouchersScreen extends StatefulWidget {
  const LoyaltyVouchersScreen({super.key});

  @override
  State<LoyaltyVouchersScreen> createState() => _LoyaltyVouchersScreenState();
}

class _LoyaltyVouchersScreenState extends State<LoyaltyVouchersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_VoucherItem> _vouchers(BuildContext context) => [
        _VoucherItem(
          title: tr3(context, fr: '-15% sur Boissons', en: '-15% on Drinks', ar: '-15% على المشروبات'),
          code: 'DRINK15',
          date: tr3(context, fr: 'Expire le 30 Avril', en: 'Expires Apr 30', ar: 'ينتهي في 30 أفريل'),
          expired: false,
        ),
        _VoucherItem(
          title: tr3(context, fr: '5 DT offerts', en: '5 DT bonus', ar: '5 د.ت هدية'),
          code: 'BONUS5',
          date: tr3(context, fr: 'Expire le 12 Mai', en: 'Expires May 12', ar: 'ينتهي في 12 ماي'),
          expired: true,
        ),
        _VoucherItem(
          title: tr3(context, fr: '-20% sur Hygiène', en: '-20% on Hygiene', ar: '-20% على النظافة'),
          code: 'CARE20',
          date: tr3(context, fr: 'Expire le 18 Mai', en: 'Expires May 18', ar: 'ينتهي في 18 ماي'),
          expired: false,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final all = _vouchers(context);
    final vouchers = all.where((v) {
      if (query.isEmpty) return true;
      return v.title.toLowerCase().contains(query) ||
          v.code.toLowerCase().contains(query) ||
          v.date.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr3(context, fr: 'Mes bons', en: 'My vouchers', ar: 'قسائمي'),
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: tr3(
                  context,
                  fr: 'Rechercher par code ou date',
                  en: 'Search by code or date',
                  ar: 'ابحث بالكود أو التاريخ',
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.soft,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.45)),
                ),
              ),
            ),
          ),
          Expanded(
            child: vouchers.isEmpty
                ? _buildEmptySearchState(context)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: vouchers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final v = vouchers[i];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.98, end: 1),
                        duration: Duration(milliseconds: 180 + (i * 40)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value.clamp(0, 1),
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 16),
                              child: child,
                            ),
                          );
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openVoucherDetails(context, v),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.bordeaux.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        v.code,
                                        style: const TextStyle(
                                          color: AppColors.bordeaux,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      v.date,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  v.title,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: v.expired
                                        ? null
                                        : () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                duration: const Duration(milliseconds: 900),
                                                content: Text(
                                                  tr3(
                                                    context,
                                                    fr: 'Bon appliqué.',
                                                    en: 'Voucher applied.',
                                                    ar: 'تم تطبيق القسيمة.',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: v.expired ? AppColors.border : AppColors.bordeaux,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppColors.border,
                                      disabledForegroundColor: AppColors.muted,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      v.expired
                                          ? tr3(context, fr: 'Expiré', en: 'Expired', ar: 'منتهي')
                                          : tr3(context, fr: 'Utiliser', en: 'Use voucher', ar: 'استخدم'),
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
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
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: EmptyStatePanel(
        icon: Icons.search_off_rounded,
        title: tr3(context, fr: 'Aucun bon trouvé', en: 'No vouchers found', ar: 'لم يتم العثور على قسائم'),
        subtitle: tr3(
          context,
          fr: 'Essayez un autre code ou une autre date.',
          en: 'Try another code or date.',
          ar: 'جرّب كودًا أو تاريخًا آخر.',
        ),
        primaryLabel: tr3(context, fr: 'Effacer la recherche', en: 'Clear search', ar: 'مسح البحث'),
        onPrimary: () {
          _searchCtrl.clear();
          setState(() {});
        },
      ),
    );
  }

  void _openVoucherDetails(BuildContext context, _VoucherItem v) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              v.title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Code: ${v.code}',
                  style: const TextStyle(
                    color: AppColors.bordeaux,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  v.date,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              tr3(
                context,
                fr: 'Utilisable sur une sélection de produits.',
                en: 'Usable on a selected product range.',
                ar: 'قابلة للاستخدام على مجموعة منتجات محددة.',
              ),
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  tr3(context, fr: 'Fermer', en: 'Close', ar: 'إغلاق'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherItem {
  final String title;
  final String code;
  final String date;
  final bool expired;

  const _VoucherItem({
    required this.title,
    required this.code,
    required this.date,
    required this.expired,
  });
}
