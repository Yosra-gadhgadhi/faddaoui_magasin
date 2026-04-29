import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderReference;

  const OrderDetailsScreen({
    super.key,
    required this.orderReference,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
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
  bool _reordering = false;
  bool _downloadingInvoice = false;
  String? _error;
  _OrderDetails? _details;

  @override
  void initState() {
    super.initState();
    _load();
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
    });

    try {
      final candidates = <String>[
        '/api/orders/${widget.orderReference}/details',
        '/api/orders/${widget.orderReference}',
      ];

      Map<String, dynamic>? payload;
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
        if (status == 404) continue;
        if (status >= 400 || r.data is! Map) continue;

        payload = Map<String, dynamic>.from(r.data as Map);
        break;
      }

      if (payload == null) {
        setState(() {
          _error = "load_failed";
          _loading = false;
        });
        return;
      }

      final details = _OrderDetails.fromAny(payload, widget.orderReference);
      setState(() {
        _details = details;
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

  Future<void> _reorderAgain() async {
    final details = _details;
    if (details == null || _reordering) return;
    final validItems = details.items.where((e) => e.productId != null && e.quantity > 0).toList(growable: false);
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun article réutilisable pour recommander."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _reordering = true);
    try {
      int success = 0;
      String? firstError;
      for (final item in validItems) {
        final r = await _dio.post(
          '/api/cart/items',
          options: await _authOptions(),
          data: {
            'productId': item.productId,
            'qty': item.quantity,
          },
        );
        final status = r.statusCode ?? 500;
        if (status < 400) {
          success++;
        } else {
          firstError ??= _extractApiMessage(r.data);
        }
      }

      if (!mounted) return;
      await context.read<CartCubit>().syncFromServer();
      if (success == validItems.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Articles ajoutés au panier."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (success > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$success/${validItems.length} article(s) ajoutés au panier."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(firstError ?? "Impossible d'ajouter les articles au panier."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur réseau pendant la recommandation."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _reordering = false);
    }
  }

  String? _extractApiMessage(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = (map['message'] ?? map['error_description'] ?? map['error'] ?? '').toString().trim();
      if (msg.isNotEmpty) return msg;
    }
    return null;
  }

  Future<void> _downloadInvoice(_OrderDetails details) async {
    if (_downloadingInvoice) return;
    setState(() => _downloadingInvoice = true);

    try {
      final options = await _authOptions();
      final ref = details.orderReference;

      final urlCandidates = <String>[
        '/api/orders/$ref/invoice-url',
        '/api/orders/$ref/invoice/link',
      ];
      for (final path in urlCandidates) {
        try {
          final r = await _dio.get(path, options: options);
          final status = r.statusCode ?? 500;
          if (status == 404 || status == 405) {
            continue;
          }
          if (status >= 400 || r.data is! Map) {
            break;
          }
          final m = Map<String, dynamic>.from(r.data as Map);
          final invoiceUrl = (m['url'] ?? m['invoiceUrl'] ?? m['downloadUrl'] ?? '').toString().trim();
          if (invoiceUrl.isNotEmpty) {
            final uri = Uri.tryParse(invoiceUrl);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return;
            }
          }
        } catch (_) {
          // Ignore and fallback to PDF binary endpoint.
        }
      }

      final pdfCandidates = <String>[
        '/api/orders/$ref/invoice',
        '/api/orders/$ref/facture',
      ];
      for (final path in pdfCandidates) {
        try {
          final r = await _dio.get<List<int>>(
            path,
            options: options.copyWith(
              responseType: ResponseType.bytes,
              headers: {
                ...?options.headers,
                'Accept': 'application/pdf',
              },
            ),
          );
          final status = r.statusCode ?? 500;
          final bytes = r.data;
          if (status == 404 || status == 405) {
            continue;
          }
          if (status >= 400 || bytes == null || bytes.isEmpty) {
            break;
          }

          final filename = 'facture_$ref.pdf';
          final file = File('${Directory.systemTemp.path}/$filename');
          await file.writeAsBytes(bytes, flush: true);

          final fileUri = Uri.file(file.path);
          if (await canLaunchUrl(fileUri)) {
            await launchUrl(fileUri);
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Facture téléchargée: ${file.path}"),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        } catch (_) {
          // Try next candidate.
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de télécharger la facture."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _downloadingInvoice = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
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
        title: const Text(
          "Détail commande",
          style: TextStyle(
            color: AppColors.bordeauxDark,
            fontWeight: FontWeight.w800,
            fontSize: 18.5,
            letterSpacing: 0.1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            if (_error != null && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Impossible de charger le détail. Tirez pour actualiser.",
                  style: TextStyle(
                    color: AppColors.bordeaux,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (!_loading && _error == null && details != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.78),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Résumé",
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.bordeaux.withValues(alpha: 0.1),
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
                            "Commande #${details.orderReference}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          "${details.total.toStringAsFixed(2)} DT",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.bordeaux,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusBg(details.status),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _statusFg(details.status).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            _statusText(details.status),
                            style: TextStyle(
                              color: _statusFg(details.status),
                              fontWeight: FontWeight.w800,
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
                          _dateText(details.createdAt),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: "Livraison",
                icon: Icons.local_shipping_rounded,
                children: [
                  _LineRow(label: "Adresse", value: details.deliveryAddress),
                  _LineRow(label: "Créneau", value: details.deliverySlotLabel),
                  _LineRow(label: "Frais", value: "${details.deliveryFee.toStringAsFixed(2)} DT"),
                  _LineRow(label: "Livreur", value: details.courierName),
                  _LineRow(label: "Téléphone livreur", value: details.courierPhone),
                  _LineRow(label: "Téléphone magasin", value: details.storePhone),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: "Paiement",
                icon: Icons.payments_rounded,
                children: [
                  _LineRow(label: "Méthode", value: details.paymentMethod),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: "Articles (${details.items.length})",
                icon: Icons.shopping_bag_rounded,
                children: details.items.isEmpty
                    ? const [
                        Text(
                          "Aucun article détaillé renvoyé.",
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ]
                    : details.items
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.soft.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${e.name} x${e.quantity}",
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${e.lineTotal.toStringAsFixed(2)} DT",
                                  style: const TextStyle(
                                    color: AppColors.bordeaux,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(growable: false),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: AppSize.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: _downloadingInvoice ? null : () => _downloadInvoice(details),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.26),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: _downloadingInvoice
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.bordeaux,
                                ),
                              )
                            : const Icon(
                                Icons.download_rounded,
                                size: 17,
                                color: AppColors.bordeaux,
                              ),
                        label: Text(
                          _downloadingInvoice ? "Téléchargement..." : "Facture",
                          style: const TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: AppSize.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DeliveryTrackingScreen(orderId: details.orderReference),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.26),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: const Icon(
                          Icons.local_shipping_rounded,
                          size: 17,
                          color: AppColors.bordeaux,
                        ),
                        label: const Text(
                          "Suivi",
                          style: TextStyle(
                            color: AppColors.bordeaux,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: AppSize.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _reordering ? null : _reorderAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bordeaux,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: _reordering
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_bag_rounded,
                          size: 17,
                        ),
                  label: Text(
                    _reordering ? "Ajout en cours..." : "Recommander les mêmes produits",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppSurface.card(radius: AppRadius.lg, borderAlpha: 0.78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.bordeaux.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.bordeauxDark),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final String label;
  final String value;

  const _LineRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails {
  final String orderReference;
  final String status;
  final DateTime? createdAt;
  final double total;

  final String paymentMethod;
  final String deliveryAddress;
  final String deliverySlotLabel;
  final double deliveryFee;
  final String courierName;
  final String courierPhone;
  final String storePhone;
  final List<_OrderItemDetails> items;

  const _OrderDetails({
    required this.orderReference,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.deliverySlotLabel,
    required this.deliveryFee,
    required this.courierName,
    required this.courierPhone,
    required this.storePhone,
    required this.items,
  });

  factory _OrderDetails.fromAny(Map<String, dynamic> json, String fallbackRef) {
    final paymentMap = (json['payment'] is Map)
        ? Map<String, dynamic>.from(json['payment'] as Map)
        : const <String, dynamic>{};
    final addressMap = (json['address'] is Map)
        ? Map<String, dynamic>.from(json['address'] as Map)
        : const <String, dynamic>{};

    final builtAddress = [
      addressMap['city'],
      addressMap['area'],
      addressMap['street'],
      addressMap['extra'],
      json['city'],
      json['area'],
      json['street'],
      json['extra'],
    ]
        .map((e) => (e ?? '').toString().trim())
        .where((e) => e.isNotEmpty)
        .join(', ');

    final orderReference = _asText(
      json['orderReference'] ?? json['reference'] ?? json['orderCode'] ?? json['orderId'],
      fallback: fallbackRef,
    );
    final status = _asText(json['status'], fallback: 'CONFIRMED');
    final createdAt = DateTime.tryParse('${json['createdAt'] ?? ''}');

    final total = _toDouble(
      json['total'] ?? json['totalAmount'] ?? json['amount'],
      fallback: 0,
    );
    final paymentMethod = _asText(
      json['paymentMethod'] ?? paymentMap['method'],
      fallback: "—",
    );
    final deliveryAddress = _asText(
      json['deliveryAddress'] ?? (builtAddress.isEmpty ? null : builtAddress) ?? json['shippingAddress'],
      fallback: "—",
    );
    final deliverySlotLabel = _asText(
      json['deliverySlotLabel'] ?? json['deliverySlot'] ?? json['slot'],
      fallback: "—",
    );
    final deliveryFee = _toDouble(
      json['deliveryFee'],
      fallback: 0,
    );
    final courierName = _asText(json['courierName'], fallback: "—");
    final courierPhone = _asText(json['courierPhone'], fallback: "—");
    final storePhone = _asText(json['storePhone'], fallback: "—");

    final rawItems = (json['items'] is List) ? json['items'] as List : const [];
    final items = rawItems
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(_OrderItemDetails.fromJson)
        .toList(growable: false);

    return _OrderDetails(
      orderReference: orderReference,
      status: status,
      createdAt: createdAt,
      total: total,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      deliverySlotLabel: deliverySlotLabel,
      deliveryFee: deliveryFee,
      courierName: courierName,
      courierPhone: courierPhone,
      storePhone: storePhone,
      items: items,
    );
  }

  static String _asText(dynamic v, {String fallback = ''}) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? fallback : s;
  }

  static double _toDouble(dynamic v, {double fallback = 0}) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? fallback;
  }
}

class _OrderItemDetails {
  final int? productId;
  final String name;
  final int quantity;
  final double lineTotal;

  const _OrderItemDetails({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.lineTotal,
  });

  factory _OrderItemDetails.fromJson(Map<String, dynamic> json) {
    final productMap = (json['product'] is Map)
        ? Map<String, dynamic>.from(json['product'] as Map)
        : const <String, dynamic>{};
    final productId = (json['productId'] is num)
        ? (json['productId'] as num).toInt()
        : (json['id'] is num)
            ? (json['id'] as num).toInt()
            : (productMap['id'] is num)
                ? (productMap['id'] as num).toInt()
                : int.tryParse('${json['productId'] ?? json['id'] ?? productMap['id'] ?? ''}');
    final quantity = (json['quantity'] is num)
        ? (json['quantity'] as num).toInt()
        : (json['qty'] is num)
            ? (json['qty'] as num).toInt()
            : (json['lineQty'] is num)
                ? (json['lineQty'] as num).toInt()
                : int.tryParse('${json['quantity'] ?? json['qty'] ?? json['lineQty'] ?? 0}') ?? 0;
    final lineTotal = (json['lineTotal'] is num)
        ? (json['lineTotal'] as num).toDouble()
        : double.tryParse('${json['lineTotal'] ?? 0}') ?? 0;
    final name = (json['productName'] ?? json['productNameSnapshot'] ?? json['name'] ?? 'Produit').toString().trim();
    return _OrderItemDetails(
      productId: productId,
      name: name.isEmpty ? 'Produit' : name,
      quantity: quantity < 0 ? 0 : quantity,
      lineTotal: lineTotal,
    );
  }
}
