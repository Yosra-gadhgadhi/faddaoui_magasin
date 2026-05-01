import 'package:elfaddoui_app/features/checkout/domain/entities/checkout_data.dart';
import 'package:elfaddoui_app/features/checkout/domain/widgets/checkout_widgets.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_success_screen.dart';

class CheckoutStep3Payment extends StatefulWidget {
  final double total;
  final CheckoutData data;

  const CheckoutStep3Payment({
    super.key,
    required this.total,
    required this.data,
  });

  @override
  State<CheckoutStep3Payment> createState() => _CheckoutStep3PaymentState();
}

class _CheckoutStep3PaymentState extends State<CheckoutStep3Payment> {
  bool accept = false;
  bool _submitting = false;
  double? _serverSubtotal;
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

  @override
  void initState() {
    super.initState();
    _refreshServerSubtotal();
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

  Map<String, dynamic> _buildOrderPayload(CheckoutData data, {required double total}) {
    final isOnline = data.paymentMethod == "online";
    return {
      "customer": {
        "fullName": data.fullName,
        "phone": data.phone,
        "email": data.email,
        "note": data.note,
      },
      "address": {
        "city": data.city,
        "area": data.area,
        "street": data.street,
        "extra": data.extra,
        "postalCode": data.postalCode,
        "hint": data.addressHint,
        "placeType": data.placeType,
      },
      "payment": {
        // Keep backend compatibility (CASH/CARD) and pass channel as extra.
        "method": isOnline ? "card" : data.paymentMethod,
        if (isOnline) "channel": "online",
      },
      "delivery": {
        "slot": data.deliverySlot,
        "scheduledTime": data.scheduledTime,
      },
      "total": total,
    };
  }

  Future<double?> _fetchServerCartSubtotal() async {
    try {
      final r = await _dio.get('/api/cart', options: await _authOptions());
      if ((r.statusCode ?? 500) >= 400 || r.data is! Map) return null;
      final map = Map<String, dynamic>.from(r.data as Map);
      final raw = map['subtotal'];
      if (raw is num) return raw.toDouble();
      return double.tryParse('$raw');
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshServerSubtotal() async {
    final subtotal = await _fetchServerCartSubtotal();
    if (!mounted || subtotal == null) return;
    setState(() => _serverSubtotal = subtotal);
  }

  Future<(bool, String?)> _startOnlinePayment(CheckoutData data, {required double amount}) async {
    final options = await _authOptions();
    final payload = {
      "amount": amount,
      "currency": "TND",
      "orderPreview": _buildOrderPayload(data, total: amount),
      "providerHint": "auto",
    };
    const candidates = [
      '/api/payments/create-intent',
      '/api/payments/create',
      '/api/orders/payment-intent',
    ];

    for (final path in candidates) {
      try {
        final r = await _dio.post(path, data: payload, options: options);
        final status = r.statusCode ?? 500;
        if (status == 404 || status == 405) {
          continue;
        }
        if (status >= 400 || r.data is! Map) {
          return (false, _extractBackendMessage(r.data) ?? "Paiement en ligne indisponible.");
        }

        final m = Map<String, dynamic>.from(r.data as Map);
        final paymentUrl = (m["checkoutUrl"] ?? m["paymentUrl"] ?? m["redirectUrl"] ?? "").toString().trim();
        if (paymentUrl.isEmpty) {
          return (false, "Lien de paiement manquant.");
        }

        final uri = Uri.tryParse(paymentUrl);
        if (uri == null || !await canLaunchUrl(uri)) {
          return (false, "Impossible d'ouvrir la page de paiement.");
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return (true, null);
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 500;
        if (status == 404 || status == 405) {
          continue;
        }
        return (false, _extractBackendMessage(e.response?.data) ?? "Paiement en ligne indisponible.");
      } catch (_) {
        return (false, "Erreur réseau pendant l'ouverture du paiement.");
      }
    }
    return (false, "Backend paiement non branché.");
  }

  String? _extractOrderId(dynamic body) {
    if (body is! Map) return null;
    final map = Map<String, dynamic>.from(body);
    final direct = map["orderId"] ?? map["id"] ?? map["reference"] ?? map["code"];
    if (direct != null && '$direct'.trim().isNotEmpty) {
      return '$direct';
    }
    final nested = map["order"];
    if (nested is Map) {
      final n = Map<String, dynamic>.from(nested);
      final nestedId = n["orderId"] ?? n["id"] ?? n["reference"] ?? n["code"];
      if (nestedId != null && '$nestedId'.trim().isNotEmpty) {
        return '$nestedId';
      }
    }
    return null;
  }

  String? _extractBackendMessage(dynamic body) {
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final message = map["message"] ?? map["error"] ?? map["detail"];
      if (message != null && '$message'.trim().isNotEmpty) {
        final text = '$message';
        if (text.toLowerCase().contains('total mismatch')) {
          return "Le total du panier a changé. Vérifiez le panier puis réessayez.";
        }
        return text;
      }
    }
    return null;
  }

  Future<(int, String?, String?)> _createOrderOnBackend(CheckoutData data, {required double total}) async {
    final payload = _buildOrderPayload(data, total: total);
    final options = await _authOptions();
    final candidates = const ['/api/orders', '/api/orders/checkout', '/api/checkout'];

    var lastStatus = 500;
    for (final path in candidates) {
      try {
        final r = await _dio.post(path, data: payload, options: options);
        final status = r.statusCode ?? 500;
        lastStatus = status;
        if (status == 404 || status == 405) {
          continue;
        }
        if (status >= 200 && status < 300) {
          return (status, _extractOrderId(r.data), null);
        }
        return (status, null, _extractBackendMessage(r.data));
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 500;
        lastStatus = status;
        if (status == 404 || status == 405) {
          continue;
        }
        return (status, null, _extractBackendMessage(e.response?.data));
      }
    }
    return (lastStatus, null, null);
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    if (!accept) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          content: Text(
            tr3(context, fr: "Veuillez accepter les conditions.", en: "Please accept the terms.", ar: "يرجى قبول الشروط."),
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final latestSubtotal = await _fetchServerCartSubtotal();
      final effectiveTotal = latestSubtotal ?? _serverSubtotal ?? widget.total;
      if (latestSubtotal != null && mounted) {
        setState(() => _serverSubtotal = latestSubtotal);
      }

      if (widget.data.paymentMethod == "online") {
        final (ok, message) = await _startOnlinePayment(
          widget.data,
          amount: effectiveTotal,
        );
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(message ?? "Paiement en ligne indisponible."),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Paiement ouvert. Revenez ensuite pour confirmer la commande."),
          ),
        );
      }

      final (status, backendOrderId, backendMessage) =
          await _createOrderOnBackend(widget.data, total: effectiveTotal);

      if (!mounted) return;
      if (status == 401 || status == 403) {
        await _tokenStorage.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if (status < 200 || status >= 300) {
        if ((backendMessage ?? '').toLowerCase().contains('total du panier a changé') ||
            (backendMessage ?? '').toLowerCase().contains('total mismatch')) {
          await _refreshServerSubtotal();
          await context.read<CartCubit>().syncFromServer();
        }
        final failMessage = (backendMessage != null && backendMessage.trim().isNotEmpty)
            ? backendMessage
            : tr3(
                context,
                fr: "Impossible de confirmer la commande.",
                en: "Unable to confirm order.",
                ar: "تعذر تأكيد الطلب.",
              );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            content: Text(
              failMessage,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        return;
      }

      final orderId = backendOrderId ??
          "ELF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

      await _tokenStorage.saveLastOrderId(orderId);

      // Clear backend cart and keep CartCubit state in sync for home/cart UI.
      await _dio.delete('/api/cart', options: await _authOptions());
      if (mounted) {
        await context.read<CartCubit>().syncFromServer();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: orderId, total: effectiveTotal),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _pickTime(CheckoutData data) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null) return;
    setState(() => data.scheduledTime = t.format(context));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final displayedTotal = _serverSubtotal ?? widget.total;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr3(context, fr: "Paiement", en: "Payment", ar: "الدفع"),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        primaryText: _submitting
            ? tr3(context, fr: "Confirmation...", en: "Confirming...", ar: "جارٍ التأكيد...")
            : tr3(context, fr: "Confirmer", en: "Confirm", ar: "تأكيد"),
        onPrimary: _confirm,
        secondaryText: tr3(context, fr: "Retour", en: "Back", ar: "رجوع"),
        onSecondary: _submitting ? null : () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          const CheckoutTopStepper(current: 3),
          const SizedBox(height: 12),

          // ===== HEADER =====
          Text(
            tr3(context, fr: "Paiement & Livraison", en: "Payment & Delivery", ar: "الدفع والتوصيل"),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr3(context, fr: "Choisissez votre mode de paiement et le créneau.", en: "Choose your payment method and slot.", ar: "اختر طريقة الدفع وفترة التوصيل."),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 18),

          // ===== PAYMENT METHOD =====
          _SectionTitle(tr3(context, fr: "Mode de paiement", en: "Payment method", ar: "طريقة الدفع")),
          const SizedBox(height: 10),
          _CardShell(
            child: Column(
              children: [
                _RadioRow(
                  title: tr3(context, fr: "Paiement à la livraison", en: "Cash on delivery", ar: "الدفع عند الاستلام"),
                  subtitle: tr3(context, fr: "Cash", en: "Cash", ar: "نقداً"),
                  selected: data.paymentMethod == "cash",
                  onTap: () => setState(() => data.paymentMethod = "cash"),
                ),
                const SizedBox(height: 10),
                _RadioRow(
                  title: tr3(context, fr: "Carte", en: "Card", ar: "بطاقة"),
                  subtitle: tr3(context, fr: "TPE à la livraison (optionnel)", en: "POS on delivery (optional)", ar: "جهاز دفع عند التوصيل (اختياري)"),
                  selected: data.paymentMethod == "card",
                  onTap: () => setState(() => data.paymentMethod = "card"),
                ),
                const SizedBox(height: 10),
                _RadioRow(
                  title: tr3(context, fr: "Paiement en ligne", en: "Online payment", ar: "دفع إلكتروني"),
                  subtitle: tr3(context, fr: "Carte / Wallet sécurisé", en: "Secure card / wallet", ar: "بطاقة / محفظة آمنة"),
                  selected: data.paymentMethod == "online",
                  onTap: () => setState(() => data.paymentMethod = "online"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ===== DELIVERY SLOT =====
          _SectionTitle(tr3(context, fr: "Créneau de livraison", en: "Delivery slot", ar: "فترة التوصيل")),
          const SizedBox(height: 10),
          _CardShell(
            child: Column(
              children: [
                _RadioRow(
                  title: tr3(context, fr: "ASAP", en: "ASAP", ar: "في أقرب وقت"),
                  subtitle: tr3(
                    context,
                    fr: "45–60 minutes",
                    en: "45–60 minutes",
                    ar: "45–60 دقيقة",
                  ),
                  selected: data.deliverySlot == "asap",
                  onTap: () {
                    setState(() {
                      data.deliverySlot = "asap";
                      data.scheduledTime = null;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _RadioRow(
                  title: tr3(context, fr: "Choisir une heure", en: "Choose time", ar: "اختر الوقت"),
                  subtitle: data.scheduledTime ?? tr3(context, fr: "Choisir", en: "Choose", ar: "اختر"),
                  selected: data.deliverySlot == "scheduled",
                  onTap: () async {
                    setState(() => data.deliverySlot = "scheduled");
                    await _pickTime(data);
                  },
                ),

                if (data.deliverySlot == "scheduled") ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _pickTime(data),
                      child: Text(
                        tr3(context, fr: "Modifier l’heure", en: "Edit time", ar: "تعديل الوقت"),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.bordeaux,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ===== SUMMARY =====
          _SectionTitle(tr3(context, fr: "Résumé", en: "Summary", ar: "الملخص")),
          const SizedBox(height: 10),
          _CardShell(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tr3(context, fr: "Total à payer", en: "Total to pay", ar: "الإجمالي للدفع"),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  "${displayedTotal.toStringAsFixed(2)} DT",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.bordeaux,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ===== TERMS =====
          _CardShell(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: accept,
                  activeColor: AppColors.bordeaux,
                  onChanged: (v) => setState(() => accept = v ?? false),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      tr3(context, fr: "J’accepte les conditions et la politique de livraison.", en: "I accept the terms and delivery policy.", ar: "أوافق على الشروط وسياسة التوصيل."),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
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

/* ================= UI HELPERS ================= */

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 15,
        color: AppColors.text,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.bordeaux.withValues(alpha: 0.55)
                : AppColors.border,
          ),
          color: selected ? AppColors.bordeaux.withValues(alpha: 0.06) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.bordeaux : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        selected ? AppColors.bordeaux : Colors.transparent,
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
