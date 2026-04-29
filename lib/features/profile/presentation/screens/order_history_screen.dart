import 'package:dio/dio.dart';
import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/features/profile/presentation/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _tokenStorage = TokenStorage();
  final ScrollController _scrollController = ScrollController();
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
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 0;
  static const int _pageSize = 10;
  String? _error;
  List<_OrderHistoryItem> _items = const [];
  final Set<String> _cancellingRefs = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter < 220) {
      _loadMore();
    }
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 0;
      _hasMore = false;
    });

    try {
      final r = await _dio.get(
        '/api/orders/history',
        options: await _authOptions(),
        queryParameters: const {
          'page': 0,
          'size': _pageSize,
        },
      );
      if (!mounted) return;

      final status = r.statusCode ?? 500;
      if (status == 401 || status == 403) {
        await _tokenStorage.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }

      if (status >= 400) {
        setState(() {
          _error = "load_failed";
          _loading = false;
        });
        return;
      }

      final parsed = _parseHistoryPayload(r.data, fallbackPage: 0);

      setState(() {
        _items = parsed.items;
        _page = parsed.page;
        _hasMore = parsed.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "load_failed";
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;

    try {
      final r = await _dio.get(
        '/api/orders/history',
        options: await _authOptions(),
        queryParameters: {
          'page': nextPage,
          'size': _pageSize,
        },
      );
      if (!mounted) return;

      final status = r.statusCode ?? 500;
      if (status == 401 || status == 403) {
        await _tokenStorage.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if (status >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible de charger plus de commandes."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final parsed = _parseHistoryPayload(r.data, fallbackPage: nextPage);
      final merged = <_OrderHistoryItem>[
        ..._items,
        ...parsed.items.where((e) => !_items.any((it) => it.orderReference == e.orderReference)),
      ];

      setState(() {
        _items = merged;
        _page = parsed.page;
        _hasMore = parsed.hasMore;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur réseau pendant le chargement."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  _HistoryPagePayload _parseHistoryPayload(dynamic data, {required int fallbackPage}) {
    if (data is List) {
      final list = data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map(_OrderHistoryItem.fromJson)
          .toList(growable: false);
      return _HistoryPagePayload(
        items: list,
        page: fallbackPage,
        hasMore: false,
      );
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final rawContent = map['content'];
      final content = rawContent is List ? rawContent : const [];
      final list = content
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .map(_OrderHistoryItem.fromJson)
          .toList(growable: false);

      final page = map['number'] is num ? (map['number'] as num).toInt() : fallbackPage;
      final hasNext = map['hasNext'] == true;
      final last = map['last'] == true;
      final totalElements = map['totalElements'] is num ? (map['totalElements'] as num).toInt() : null;
      final size = map['size'] is num ? (map['size'] as num).toInt() : _pageSize;
      final computedHasMore = hasNext || (!last && totalElements != null && ((page + 1) * size) < totalElements);

      return _HistoryPagePayload(
        items: list,
        page: page,
        hasMore: computedHasMore,
      );
    }

    return _HistoryPagePayload(
      items: const [],
      page: fallbackPage,
      hasMore: false,
    );
  }

  String _statusText(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "En attente";
      case "CONFIRMED":
        return "Confirmée";
      case "PREPARING":
        return "En préparation";
      case "SHIPPED":
        return "En route";
      case "DELIVERED":
        return "Livrée";
      case "CANCELLED":
        return "Annulée";
      default:
        return status;
    }
  }

  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case "CANCELLED":
        return const Color(0xFFFFEEF0);
      default:
        return AppColors.bordeaux.withValues(alpha: 0.08);
    }
  }

  Color _statusFg(String status) {
    switch (status.toUpperCase()) {
      case "CANCELLED":
        return const Color(0xFFB33A4A);
      default:
        return AppColors.bordeauxDark;
    }
  }

  String _dateText(DateTime? dt) {
    if (dt == null) return "—";
    final d = dt.toLocal();
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  bool _canCancel(String status) {
    final s = status.toUpperCase();
    return s == "PENDING" || s == "CONFIRMED";
  }

  Future<void> _cancelOrder(_OrderHistoryItem item) async {
    if (item.orderReference.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Annuler la commande ?",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text("Commande #${item.orderReference}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Garder"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bordeaux,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _cancellingRefs.add(item.orderReference));
    try {
      final r = await _dio.patch(
        '/api/orders/${item.orderReference}/cancel',
        options: await _authOptions(),
      );
      if (!mounted) return;
      final status = r.statusCode ?? 500;
      if (status == 401 || status == 403) {
        await _tokenStorage.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if (status == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Backend annulation non prêt (404)."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (status >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'annuler la commande."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _items = _items
            .map((e) => e.orderReference == item.orderReference
                ? e.copyWith(status: "CANCELLED")
                : e)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Commande annulée."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur réseau pendant l'annulation."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cancellingRefs.remove(item.orderReference));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.bordeauxDark,
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.bordeauxDark),
            SizedBox(width: 8),
            Text(
              "Historique commandes",
              style: TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w800,
                fontSize: 18.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.78),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.bordeaux.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 18,
                        color: AppColors.bordeauxDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Vos commandes récentes",
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
                      ),
                      child: Text(
                        "${_items.length}",
                        style: const TextStyle(
                          color: AppColors.bordeauxDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_error != null)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Impossible de charger l'historique. Tirez pour actualiser.",
                  style: TextStyle(
                    color: AppColors.bordeaux,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (!_loading && _items.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.78),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: AppColors.muted, size: 28),
                    SizedBox(height: 10),
                    Text(
                      "Aucune commande pour le moment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Vos prochaines commandes apparaîtront ici.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: item.orderReference.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(
                                orderReference: item.orderReference,
                              ),
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.78),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.bordeaux.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_rounded,
                                size: 18,
                                color: AppColors.bordeauxDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Commande #${item.orderReference}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Text(
                              "${item.total.toStringAsFixed(2)} DT",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16.5,
                                color: AppColors.bordeaux,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusBg(item.status),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: _statusFg(item.status).withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                _statusText(item.status),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _statusFg(item.status),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _dateText(item.createdAt),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 15, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Text(
                                "${item.itemsCount} article(s)",
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                "Voir détails",
                                style: TextStyle(
                                  color: AppColors.bordeauxDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.bordeauxDark,
                              ),
                            ],
                          ),
                        ),
                        if (_canCancel(item.status)) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: AppSize.buttonHeight,
                            child: TextButton.icon(
                              onPressed: _cancellingRefs.contains(item.orderReference)
                                  ? null
                                  : () => _cancelOrder(item),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.soft,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  side: BorderSide(
                                    color: AppColors.bordeaux.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              icon: _cancellingRefs.contains(item.orderReference)
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.bordeaux,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppColors.bordeaux,
                                    ),
                              label: Text(
                                _cancellingRefs.contains(item.orderReference)
                                    ? "Annulation..."
                                    : "Annuler la commande",
                                style: const TextStyle(
                                  color: AppColors.bordeaux,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_loadingMore)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.bordeaux,
                    ),
                  ),
                ),
              ),
            if (!_loading && !_hasMore && _items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 10),
                child: Center(
                  child: Text(
                    "Fin de l'historique",
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
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

class _HistoryPagePayload {
  final List<_OrderHistoryItem> items;
  final int page;
  final bool hasMore;

  const _HistoryPagePayload({
    required this.items,
    required this.page,
    required this.hasMore,
  });
}

class _OrderHistoryItem {
  final String orderReference;
  final String status;
  final double total;
  final DateTime? createdAt;
  final int itemsCount;

  const _OrderHistoryItem({
    required this.orderReference,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.itemsCount,
  });

  _OrderHistoryItem copyWith({
    String? orderReference,
    String? status,
    double? total,
    DateTime? createdAt,
    int? itemsCount,
  }) {
    return _OrderHistoryItem(
      orderReference: orderReference ?? this.orderReference,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }

  factory _OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'];
    final total = rawTotal is num ? rawTotal.toDouble() : double.tryParse('$rawTotal') ?? 0.0;
    final createdAt = DateTime.tryParse('${json['createdAt'] ?? ''}');
    return _OrderHistoryItem(
      orderReference: '${json['orderReference'] ?? ''}'.trim(),
      status: '${json['status'] ?? ''}'.trim(),
      total: total,
      createdAt: createdAt,
      itemsCount: json['itemsCount'] is int ? json['itemsCount'] as int : int.tryParse('${json['itemsCount'] ?? 0}') ?? 0,
    );
  }
}
