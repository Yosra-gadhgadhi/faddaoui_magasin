import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _items = [
    _NotifItem(
      icon: Icons.local_offer_rounded,
      titleKey: "notif_flash_title",
      subtitleKey: "notif_flash_subtitle",
      timeKey: "notif_time_10m",
      unread: true,
    ),
    _NotifItem(
      icon: Icons.local_shipping_rounded,
      titleKey: "notif_order_title",
      subtitleKey: "notif_order_subtitle",
      timeKey: "notif_time_25m",
      unread: true,
    ),
    _NotifItem(
      icon: Icons.new_releases_rounded,
      titleKey: "notif_new_title",
      subtitleKey: "notif_new_subtitle",
      timeKey: "notif_time_today",
      unread: false,
    ),
    _NotifItem(
      icon: Icons.inventory_2_rounded,
      titleKey: "notif_stock_title",
      subtitleKey: "notif_stock_subtitle",
      timeKey: "notif_time_yesterday",
      unread: false,
    ),
  ];

  int get _unreadCount => _items.where((e) => e.unread).length;

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(unread: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_rounded,
                size: 16, color: AppColors.bordeauxDark),
            const SizedBox(width: 8),
            Text(
              t.tr('notif_title'),
              style: const TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.tr('notif_mark_all_read'),
            onPressed: _markAllRead,
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.bordeaux.withValues(alpha: 0.16)),
              ),
              child: const Icon(
                Icons.done_all_rounded,
                size: 18,
                color: AppColors.bordeaux,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            if (!mounted) return;
            setState(() {});
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bordeaux.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_unread_rounded,
                          color: AppColors.bordeaux, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.tr(
                            'notif_unread_count',
                            params: {'count': '$_unreadCount'},
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: EmptyStatePanel(
                          icon: Icons.notifications_off_rounded,
                          title: tr3(
                            context,
                            fr: 'Aucune notification',
                            en: 'No notifications',
                            ar: 'لا توجد إشعارات',
                          ),
                          subtitle: tr3(
                            context,
                            fr: 'Les nouvelles alertes apparaîtront ici.',
                            en: 'New alerts will appear here.',
                            ar: 'ستظهر التنبيهات الجديدة هنا.',
                          ),
                          primaryLabel: tr3(
                            context,
                            fr: 'Actualiser',
                            en: 'Refresh',
                            ar: 'تحديث',
                          ),
                          onPrimary: () => setState(() {}),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final n = _items[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: n.unread
                                    ? AppColors.bordeaux.withValues(alpha: 0.28)
                                    : AppColors.border.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.soft,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(n.icon, color: AppColors.bordeaux, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.tr(n.titleKey),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        t.tr(n.subtitleKey),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.tr(n.timeKey),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (n.unread)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.bordeaux,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final String timeKey;
  final bool unread;

  _NotifItem({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.timeKey,
    required this.unread,
  });

  _NotifItem copyWith({
    IconData? icon,
    String? titleKey,
    String? subtitleKey,
    String? timeKey,
    bool? unread,
  }) {
    return _NotifItem(
      icon: icon ?? this.icon,
      titleKey: titleKey ?? this.titleKey,
      subtitleKey: subtitleKey ?? this.subtitleKey,
      timeKey: timeKey ?? this.timeKey,
      unread: unread ?? this.unread,
    );
  }
}
