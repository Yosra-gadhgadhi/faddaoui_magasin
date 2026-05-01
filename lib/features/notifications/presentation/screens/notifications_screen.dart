import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/app_localizations.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/empty_state_panel.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';
import 'package:elfaddoui_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _tokenStorage = TokenStorage();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  bool _loading = true;
  String? _error;
  List<_NotifItem> _items = const [];

  int get _unreadCount => _items.where((e) => e.unread).length;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.readToken();
    return Options(
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
    );
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    const candidates = [
      '/api/notifications',
      '/api/notifications/in-app',
      '/api/users/me/notifications',
    ];

    try {
      List<_NotifItem> loaded = const [];
      for (final path in candidates) {
        final r = await _dio.get(path, options: await _authOptions());
        if (!mounted) return;

        final status = r.statusCode ?? 500;
        if (status == 401 || status == 403) {
          await _tokenStorage.clear();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
          return;
        }
        if (status == 404 || status == 405) {
          continue;
        }
        if (status >= 400) {
          break;
        }

        loaded = _parseNotificationsPayload(r.data);
        if (loaded.isNotEmpty || r.data is List || r.data is Map) {
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _items = loaded;
        _loading = false;
      });
      context.read<NotificationsCubit>().setUnreadCount(_unreadCount);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "load_failed";
        _loading = false;
      });
    }
  }

  List<_NotifItem> _parseNotificationsPayload(dynamic data) {
    List raw = const [];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final items = map['items'] ?? map['content'] ?? map['notifications'] ?? map['data'];
      if (items is List) raw = items;
    }

    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(_NotifItem.fromJson)
        .toList(growable: false);
  }

  Future<void> _markAllRead() async {
    setState(() {
      _items = _items.map((e) => e.copyWith(unread: false)).toList(growable: false);
    });
    context.read<NotificationsCubit>().setUnreadCount(0);

    const endpoints = [
      '/api/notifications/read-all',
      '/api/notifications/mark-all-read',
    ];
    for (final path in endpoints) {
      try {
        final r = await _dio.patch(path, options: await _authOptions());
        final status = r.statusCode ?? 500;
        if (status == 404 || status == 405) continue;
        break;
      } catch (_) {
        // Keep local state even if backend endpoint is absent.
      }
    }
    context.read<NotificationsCubit>().refreshUnreadCount();
  }

  void _openNotification(_NotifItem item) {
    if (item.orderReference != null && item.orderReference!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeliveryTrackingScreen(orderId: item.orderReference),
        ),
      );
      return;
    }
  }

  String _timeText(_NotifItem item) {
    final dt = item.createdAt;
    if (dt == null) return tr3(context, fr: "Maintenant", en: "Now", ar: "الآن");

    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return tr3(context, fr: "À l’instant", en: "Just now", ar: "الآن");
    if (diff.inMinutes < 60) {
      return tr3(
        context,
        fr: "Il y a ${diff.inMinutes} min",
        en: "${diff.inMinutes} min ago",
        ar: "منذ ${diff.inMinutes} د",
      );
    }
    if (diff.inHours < 24) {
      return tr3(
        context,
        fr: "Il y a ${diff.inHours} h",
        en: "${diff.inHours} h ago",
        ar: "منذ ${diff.inHours} س",
      );
    }
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
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
            const Icon(Icons.notifications_rounded, size: 16, color: AppColors.bordeauxDark),
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
            onPressed: _items.isEmpty ? null : _markAllRead,
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
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
          onRefresh: _loadNotifications,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bordeaux.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_unread_rounded, color: AppColors.bordeaux, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.tr('notif_unread_count', params: {'count': '$_unreadCount'}),
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.bordeaux))
                    : _error != null
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              EmptyStatePanel(
                                icon: Icons.wifi_off_rounded,
                                title: tr3(
                                  context,
                                  fr: 'Impossible de charger',
                                  en: 'Unable to load',
                                  ar: 'تعذر التحميل',
                                ),
                                subtitle: tr3(
                                  context,
                                  fr: 'Tirez vers le bas pour actualiser.',
                                  en: 'Pull down to refresh.',
                                  ar: 'اسحب للأسفل للتحديث.',
                                ),
                                primaryLabel: tr3(
                                  context,
                                  fr: 'Actualiser',
                                  en: 'Refresh',
                                  ar: 'تحديث',
                                ),
                                onPrimary: _loadNotifications,
                              ),
                            ],
                          )
                        : _items.isEmpty
                            ? ListView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [
                                  EmptyStatePanel(
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
                                    onPrimary: _loadNotifications,
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                                itemCount: _items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final n = _items[i];
                                  return InkWell(
                                    onTap: () => _openNotification(n),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
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
                                                  _timeText(n),
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
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime? createdAt;
  final bool unread;
  final String? orderReference;

  const _NotifItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.unread,
    required this.orderReference,
  });

  _NotifItem copyWith({
    String? id,
    IconData? icon,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    bool? unread,
    String? orderReference,
  }) {
    return _NotifItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      createdAt: createdAt ?? this.createdAt,
      unread: unread ?? this.unread,
      orderReference: orderReference ?? this.orderReference,
    );
  }

  factory _NotifItem.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? json['kind'] ?? json['eventType'] ?? '').toString().trim().toLowerCase();
    final status = (json['status'] ?? '').toString().trim().toLowerCase();
    final icon = _iconFor(type, status);

    final title = _txt(
      json['title'] ?? json['subject'] ?? json['eventTitle'],
      fallback: "Notification",
    );
    final subtitle = _txt(
      json['message'] ?? json['body'] ?? json['description'] ?? json['content'],
      fallback: "Nouvelle activité.",
    );
    final createdAt = DateTime.tryParse('${json['createdAt'] ?? json['time'] ?? json['date'] ?? ''}');
    final unread = (json['unread'] is bool)
        ? json['unread'] as bool
        : !((json['read'] is bool) ? json['read'] as bool : false);
    final orderReference = _txt(
      json['orderReference'] ?? json['orderRef'] ?? json['reference'],
      fallback: '',
    );

    return _NotifItem(
      id: '${json['id'] ?? json['uuid'] ?? createdAt?.millisecondsSinceEpoch ?? title}',
      icon: icon,
      title: title,
      subtitle: subtitle,
      createdAt: createdAt,
      unread: unread,
      orderReference: orderReference.isEmpty ? null : orderReference,
    );
  }

  static IconData _iconFor(String type, String status) {
    if (type.contains('order') || status.isNotEmpty) return Icons.local_shipping_rounded;
    if (type.contains('promo') || type.contains('offer')) return Icons.local_offer_rounded;
    if (type.contains('stock')) return Icons.inventory_2_rounded;
    return Icons.notifications_rounded;
  }

  static String _txt(dynamic v, {String fallback = ''}) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? fallback : s;
  }
}
