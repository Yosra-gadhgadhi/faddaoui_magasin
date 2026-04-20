import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _items = [
    _NotifItem(
      icon: Icons.local_offer_rounded,
      title: "Promo flash aujourd'hui",
      subtitle: "Jusqu'à -30% sur fruits et légumes.",
      time: "Il y a 10 min",
      unread: true,
    ),
    _NotifItem(
      icon: Icons.local_shipping_rounded,
      title: "Commande en route",
      subtitle: "Votre commande #ELF-1024 arrive dans 25 min.",
      time: "Il y a 25 min",
      unread: true,
    ),
    _NotifItem(
      icon: Icons.new_releases_rounded,
      title: "Nouveaux produits disponibles",
      subtitle: "Découvrez les nouveaux arrivages en épicerie.",
      time: "Aujourd'hui",
      unread: false,
    ),
    _NotifItem(
      icon: Icons.inventory_2_rounded,
      title: "Produit de retour en stock",
      subtitle: "Lait Frais 1L est à nouveau disponible.",
      time: "Hier",
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_rounded,
                size: 16, color: AppColors.bordeauxDark),
            SizedBox(width: 8),
            Text(
              "Notifications",
              style: TextStyle(
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
            tooltip: "Tout lu",
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
                          "$_unreadCount notification(s) non lue(s)",
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
                child: ListView.separated(
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
                            child: Icon(n.icon,
                                color: AppColors.bordeaux, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n.time,
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
  final String title;
  final String subtitle;
  final String time;
  final bool unread;

  _NotifItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
  });

  _NotifItem copyWith({
    IconData? icon,
    String? title,
    String? subtitle,
    String? time,
    bool? unread,
  }) {
    return _NotifItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      unread: unread ?? this.unread,
    );
  }
}
