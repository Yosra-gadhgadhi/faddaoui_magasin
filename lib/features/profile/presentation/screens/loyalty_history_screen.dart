import 'package:flutter/material.dart';

import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';

class LoyaltyHistoryScreen extends StatefulWidget {
  const LoyaltyHistoryScreen({super.key});

  @override
  State<LoyaltyHistoryScreen> createState() => _LoyaltyHistoryScreenState();
}

class _LoyaltyHistoryScreenState extends State<LoyaltyHistoryScreen> {
  int _filter = 0; // 0 all, 1 plus, 2 minus

  List<_HistoryRecord> _records(BuildContext context) => [
        _HistoryRecord(
          title: tr3(
            context,
            fr: 'Achat magasin - Tunis Centre',
            en: 'Store purchase - Tunis Center',
            ar: 'شراء من المتجر - تونس الوسط',
          ),
          date: '21 Apr 2026 • 10:40',
          points: 82,
        ),
        _HistoryRecord(
          title: tr3(
            context,
            fr: 'Bon utilisé: DRINK15',
            en: 'Voucher used: DRINK15',
            ar: 'تم استخدام قسيمة: DRINK15',
          ),
          date: '20 Apr 2026 • 18:15',
          points: -150,
        ),
        _HistoryRecord(
          title: tr3(
            context,
            fr: 'Achat en ligne',
            en: 'Online purchase',
            ar: 'شراء عبر الإنترنت',
          ),
          date: '19 Apr 2026 • 13:20',
          points: 56,
        ),
        _HistoryRecord(
          title: tr3(
            context,
            fr: 'Cadeau réclamé',
            en: 'Gift claimed',
            ar: 'تم استلام هدية',
          ),
          date: '18 Apr 2026 • 11:03',
          points: -300,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final all = _records(context);
    final records = all.where((r) {
      if (_filter == 1) return r.points > 0;
      if (_filter == 2) return r.points < 0;
      return true;
    }).toList();

    final tAll = tr3(context, fr: 'Tous', en: 'All', ar: 'الكل');
    final tPlus = tr3(context, fr: '+ points', en: '+ points', ar: '+ نقاط');
    final tMinus = tr3(context, fr: '- points', en: '- points', ar: '- نقاط');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr3(context, fr: 'Historique', en: 'History', ar: 'السجل'),
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.88)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stacked_line_chart_rounded, color: AppColors.bordeaux),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr3(
                        context,
                        fr: 'Solde actuel: 2 480 points',
                        en: 'Current balance: 2,480 points',
                        ar: 'الرصيد الحالي: 2480 نقطة',
                      ),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  text: tAll,
                  selected: _filter == 0,
                  onTap: () => setState(() => _filter = 0),
                ),
                _FilterChip(
                  text: tPlus,
                  selected: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
                _FilterChip(
                  text: tMinus,
                  selected: _filter == 2,
                  onTap: () => setState(() => _filter = 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: EmptyStatePanel(
                      icon: Icons.history_toggle_off_rounded,
                      title: tr3(context, fr: 'Aucun mouvement', en: 'No activity', ar: 'لا توجد عمليات'),
                      subtitle: tr3(
                        context,
                        fr: 'Aucune opération ne correspond à ce filtre.',
                        en: 'No operation matches this filter.',
                        ar: 'لا توجد عملية مطابقة لهذا الفلتر.',
                      ),
                      primaryLabel: tr3(context, fr: 'Réinitialiser', en: 'Reset', ar: 'إعادة تعيين'),
                      onPrimary: () => setState(() => _filter = 0),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = records[i];
                      final positive = r.points > 0;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openDetails(context, r),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  color: positive
                                      ? const Color(0xFFEAF8F0)
                                      : const Color(0xFFFFF0F0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  positive ? Icons.add_rounded : Icons.remove_rounded,
                                  color: positive
                                      ? const Color(0xFF138A57)
                                      : const Color(0xFFD24B4B),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r.date,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${positive ? '+' : ''}${r.points} pts',
                                style: TextStyle(
                                  color: positive
                                      ? const Color(0xFF138A57)
                                      : const Color(0xFFD24B4B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
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
      ),
    );
  }

  void _openDetails(BuildContext context, _HistoryRecord r) {
    final positive = r.points > 0;
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
              r.title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              r.date,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${positive ? '+' : ''}${r.points} pts',
              style: TextStyle(
                color: positive ? const Color(0xFF138A57) : const Color(0xFFD24B4B),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.bordeaux.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.bordeaux.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.9),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? AppColors.bordeauxDark : AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRecord {
  final String title;
  final String date;
  final int points;

  const _HistoryRecord({
    required this.title,
    required this.date,
    required this.points,
  });
}
