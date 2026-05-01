import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elfaddoui_app/app/routes.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String? orderId;
  const DeliveryTrackingScreen({super.key, this.orderId});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
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
  String _resolvedOrderId = "—";

  int _step = 1;
  int _totalSteps = 3;
  int? _etaMinutes;
  String _statusLabel = "pending";
  String _deliveryAddress = "—";
  String _deliverySlotLabel = "—";
  String _deliveryFeeLabel = "—";
  String _courierName = "—";
  String _courierPhone = "—";
  String _storePhone = "—";
  DateTime? _lastUpdatedAt;
  bool _sseConnected = false;
  bool _sseReconnecting = false;
  StreamSubscription<String>? _sseSub;
  HttpClient? _sseClient;
  Timer? _sseReconnectTimer;
  Timer? _pollingTimer;
  String? _sseOrderRef;
  bool _isDisposing = false;

  String get _etaText {
    if (_etaMinutes == null) {
      return _statusLabel == "delivered" ? "Livré" : "-";
    }
    return "~$_etaMinutes min";
  }

  double get _progress {
    final safeTotal = _totalSteps <= 0 ? 3 : _totalSteps;
    final safeStep = _step < 0 ? 0 : (_step > safeTotal - 1 ? safeTotal - 1 : _step);
    return (safeStep + 1) / safeTotal;
  }

  bool get _isOfflineState => !_sseConnected && (_sseReconnecting || _error != null);

  String get _lastUpdatedLabel {
    final dt = _lastUpdatedAt;
    if (dt == null) return "—";
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  @override
  void dispose() {
    _isDisposing = true;
    _closeSse();
    _stopPolling();
    super.dispose();
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

  Future<void> _loadTracking() async {
    await _loadTrackingInternal(showLoading: true);
  }

  Future<void> _loadTrackingInternal({required bool showLoading}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final defaults = await _loadDeliveryDefaults();
      final fromWidget = widget.orderId?.trim();
      final fromStorage = await _tokenStorage.readLastOrderId();
      final orderId = (fromWidget != null && fromWidget.isNotEmpty)
          ? fromWidget
          : ((fromStorage != null && fromStorage.trim().isNotEmpty)
              ? fromStorage.trim()
              : null);

      final path = (orderId == null) ? '/api/orders/latest' : '/api/orders/$orderId';
      final r = await _dio.get(path, options: await _authOptions());
      if (!mounted) return;

      final status = r.statusCode ?? 500;
      if (status == 401 || status == 403) {
        await _tokenStorage.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if ((orderId == null && status == 404) || (status >= 400 && r.data is! Map)) {
        // No order yet for this user: keep dynamic delivery settings only.
        _closeSse();
        _stopPolling();
        setState(() {
          _error = null;
          _resolvedOrderId = "—";
          _deliverySlotLabel = defaults['slot'] ?? _deliverySlotLabel;
          _deliveryFeeLabel = defaults['fee'] ?? _deliveryFeeLabel;
          _courierName = defaults['courierName'] ?? _courierName;
          _courierPhone = defaults['courierPhone'] ?? _courierPhone;
          _storePhone = defaults['storePhone'] ?? _storePhone;
          _loading = false;
        });
        return;
      }

      if (status >= 400 || r.data is! Map) {
        _closeSse();
        _startPollingFallback();
        setState(() {
          _error = "tracking_error";
          _resolvedOrderId = orderId ?? "—";
          _deliverySlotLabel = defaults['slot'] ?? _deliverySlotLabel;
          _deliveryFeeLabel = defaults['fee'] ?? _deliveryFeeLabel;
          _courierName = defaults['courierName'] ?? _courierName;
          _courierPhone = defaults['courierPhone'] ?? _courierPhone;
          _storePhone = defaults['storePhone'] ?? _storePhone;
          _loading = false;
        });
        return;
      }

      final m = Map<String, dynamic>.from(r.data as Map);
      final backendOrderId = _asText(
        m['orderCode'] ?? m['orderId'],
        fallback: orderId ?? "—",
      );
      _applyTrackingMap(m, defaults, backendOrderId);
      if (backendOrderId != "—") {
        _startSse(backendOrderId, defaults);
        _startPollingFallback();
      } else {
        _closeSse();
        _stopPolling();
      }
    } catch (_) {
      _closeSse();
      _startPollingFallback();
      if (!mounted) return;
      setState(() {
        _error = "tracking_error";
        _resolvedOrderId = widget.orderId ?? "—";
        _loading = false;
      });
    }
  }

  void _applyTrackingMap(
    Map<String, dynamic> m,
    Map<String, String> defaults,
    String backendOrderId,
    {bool fromStream = false}
  ) {
    if (!mounted) return;
    final previousStatus = _statusLabel;
    final nextStatus = _asText(m['status'], fallback: 'pending');
    setState(() {
      _resolvedOrderId = backendOrderId;
      _statusLabel = nextStatus;
      _step = _toInt(m['step'], fallback: 1);
      _totalSteps = _toInt(m['totalSteps'], fallback: 3);
      _etaMinutes = _toNullableInt(m['etaMinutes']);
      _deliveryAddress = _asText(m['deliveryAddress'], fallback: '—');
      _deliverySlotLabel = _asText(m['deliverySlotLabel'], fallback: defaults['slot'] ?? '—');
      final fee = _toNullableDouble(m['deliveryFee']);
      _deliveryFeeLabel = fee == null ? (defaults['fee'] ?? '—') : '${fee.toStringAsFixed(2)} DT';
      _courierName = _asText(m['courierName'], fallback: defaults['courierName'] ?? '—');
      _courierPhone = _asText(m['courierPhone'], fallback: defaults['courierPhone'] ?? '—');
      _storePhone = _asText(m['storePhone'], fallback: defaults['storePhone'] ?? '—');
      _error = null;
      _loading = false;
      _lastUpdatedAt = DateTime.now();
    });

    if (fromStream && previousStatus != nextStatus && mounted) {
      final message = switch (nextStatus) {
        "shipped" => tr3(
            context,
            fr: "Votre commande est en route.",
            en: "Your order is on the way.",
            ar: "طلبك في الطريق.",
          ),
        "delivered" => tr3(
            context,
            fr: "Votre commande a été livrée.",
            en: "Your order has been delivered.",
            ar: "تم تسليم طلبك.",
          ),
        "cancelled" => tr3(
            context,
            fr: "Votre commande a été annulée.",
            en: "Your order was cancelled.",
            ar: "تم إلغاء طلبك.",
          ),
        _ => null,
      };
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _startSse(String orderRef, Map<String, String> defaults) async {
    if (!mounted) return;
    if (_sseOrderRef == orderRef && _sseSub != null) return;

    await _closeSse(clearRef: false);
    _sseOrderRef = orderRef;
    if (mounted) {
      setState(() {
        _sseConnected = false;
        _sseReconnecting = true;
      });
    }

    try {
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) return;

      final client = HttpClient();
      _sseClient = client;
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/orders/$orderRef/events');
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final res = await req.close();

      if (res.statusCode == 401 || res.statusCode == 403) {
        await _tokenStorage.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
        return;
      }
      if (res.statusCode >= 400) {
        _scheduleSseReconnect(defaults);
        return;
      }
      if (mounted) {
        setState(() {
          _sseConnected = true;
          _sseReconnecting = false;
        });
      }
      _stopPolling();

      String? eventName;
      final dataBuffer = StringBuffer();
      _sseSub = utf8.decoder.bind(res).transform(const LineSplitter()).listen(
        (line) {
          if (line.isEmpty) {
            if ((eventName == null || eventName == 'tracking') && dataBuffer.isNotEmpty) {
              final raw = dataBuffer.toString().trim();
              dataBuffer.clear();
              eventName = null;
              try {
                final decoded = jsonDecode(raw);
                if (decoded is Map<String, dynamic>) {
                  final backendOrderId = _asText(
                    decoded['orderCode'] ?? decoded['orderId'],
                    fallback: orderRef,
                  );
                  _applyTrackingMap(decoded, defaults, backendOrderId, fromStream: true);
                } else if (decoded is Map) {
                  final map = Map<String, dynamic>.from(decoded);
                  final backendOrderId = _asText(
                    map['orderCode'] ?? map['orderId'],
                    fallback: orderRef,
                  );
                  _applyTrackingMap(map, defaults, backendOrderId, fromStream: true);
                }
              } catch (_) {
                // Ignore malformed event chunk.
              }
            } else {
              dataBuffer.clear();
              eventName = null;
            }
            return;
          }

          if (line.startsWith('event:')) {
            eventName = line.substring(6).trim();
            return;
          }
          if (line.startsWith('data:')) {
            final dataPart = line.substring(5).trimLeft();
            if (dataBuffer.isNotEmpty) {
              dataBuffer.write('\n');
            }
            dataBuffer.write(dataPart);
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _sseConnected = false;
              _sseReconnecting = true;
            });
          }
          _startPollingFallback();
          _scheduleSseReconnect(defaults);
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _sseConnected = false;
              _sseReconnecting = true;
            });
          }
          _startPollingFallback();
          _scheduleSseReconnect(defaults);
        },
        cancelOnError: true,
      );
    } catch (_) {
      _startPollingFallback();
      _scheduleSseReconnect(defaults);
    }
  }

  void _scheduleSseReconnect(Map<String, String> defaults) {
    _sseReconnectTimer?.cancel();
    if (!mounted || _sseOrderRef == null || _sseOrderRef == "—") return;
    if (mounted) {
      setState(() {
        _sseConnected = false;
        _sseReconnecting = true;
      });
    }
    _sseReconnectTimer = Timer(const Duration(seconds: 3), () {
      final ref = _sseOrderRef;
      if (ref == null || ref == "—") return;
      _startSse(ref, defaults);
    });
  }

  Future<void> _closeSse({bool clearRef = true}) async {
    _sseReconnectTimer?.cancel();
    _sseReconnectTimer = null;
    await _sseSub?.cancel();
    _sseSub = null;
    _sseClient?.close(force: true);
    _sseClient = null;
    if (!_isDisposing && mounted) {
      setState(() {
        _sseConnected = false;
        _sseReconnecting = false;
      });
    }
    if (clearRef) {
      _sseOrderRef = null;
    }
  }

  void _startPollingFallback() {
    if (!mounted) return;
    _pollingTimer ??= Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted || _loading) return;
      if (_sseConnected) return;
      _loadTrackingInternal(showLoading: false);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<Map<String, String>> _loadDeliveryDefaults() async {
    const candidates = [
      '/api/delivery/settings',
      '/api/orders/delivery/settings',
      '/api/public/delivery/settings',
      '/api/admin/delivery/settings',
    ];

    for (final path in candidates) {
      try {
        final r = await _dio.get(path, options: await _authOptions());
        final status = r.statusCode ?? 500;
        if (status >= 400 || r.data is! Map) {
          continue;
        }
        final m = Map<String, dynamic>.from(r.data as Map);

        final feeNum = _toNullableDouble(
          m['deliveryFee'] ?? m['fee'] ?? m['delivery_fee'],
        );
        final feeText = _asText(
          m['deliveryFeeLabel'] ?? m['feeLabel'],
          fallback: '',
        );

        final result = <String, String>{};
        final slot = _asText(
          m['deliverySlotLabel'] ?? m['etaLabel'] ?? m['deliveryEtaLabel'],
          fallback: '',
        );
        final courierName = _asText(
          m['courierName'] ?? m['defaultCourierName'],
          fallback: '',
        );
        final courierPhone = _asText(
          m['courierPhone'] ?? m['defaultCourierPhone'],
          fallback: '',
        );
        final storePhone = _asText(
          m['storePhone'] ?? m['defaultStorePhone'],
          fallback: '',
        );

        if (slot.isNotEmpty) result['slot'] = slot;
        if (feeText.isNotEmpty) {
          result['fee'] = feeText;
        } else if (feeNum != null) {
          result['fee'] = '${feeNum.toStringAsFixed(2)} DT';
        }
        if (courierName.isNotEmpty) result['courierName'] = courierName;
        if (courierPhone.isNotEmpty) result['courierPhone'] = courierPhone;
        if (storePhone.isNotEmpty) result['storePhone'] = storePhone;

        if (result.isNotEmpty) return result;
      } catch (_) {
        // Try next candidate endpoint.
      }
    }
    return const {};
  }

  int _toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  int? _toNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  double? _toNullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  String _asText(dynamic v, {String fallback = ''}) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? fallback : s;
  }

  Future<void> _callNumber(String label, String phone) async {
    final tel = phone.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: tel);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    await Clipboard.setData(ClipboardData(text: phone));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr3(
            context,
            fr: "$label indisponible. Numéro copié: $phone",
            en: "$label unavailable. Number copied: $phone",
            ar: "$label غير متاح. تم نسخ الرقم: $phone",
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_shipping_rounded,
                size: 16, color: AppColors.bordeauxDark),
            const SizedBox(width: 8),
            Text(
              tr3(
                context,
                fr: "Suivi livraison",
                en: "Delivery tracking",
                ar: "تتبع التوصيل",
              ),
              style: const TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 0.1,
              ),
            ),
            if (_sseConnected || _sseReconnecting) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _sseConnected
                      ? const Color(0xFFEAF9F0)
                      : const Color(0xFFFFF4E8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _sseConnected
                        ? const Color(0xFF2E9A5A).withValues(alpha: 0.35)
                        : const Color(0xFFE38D2C).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _sseConnected
                      ? "LIVE"
                      : (_sseReconnecting
                          ? tr3(
                              context,
                              fr: "Reconnexion...",
                              en: "Reconnecting...",
                              ar: "إعادة الاتصال...",
                            )
                          : "OFFLINE"),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _sseConnected
                        ? const Color(0xFF2E9A5A)
                        : (_sseReconnecting
                            ? const Color(0xFFE38D2C)
                            : AppColors.bordeaux),
                  ),
                ),
              ),
            ],
            if (!_sseConnected && !_sseReconnecting) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.bordeaux.withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  "OFFLINE",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bordeaux,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadTracking,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    tr3(
                      context,
                      fr: "Hors ligne. Dernières données affichées. Tirez pour actualiser.",
                      en: "Offline. Last known data shown. Pull to refresh.",
                      ar: "أنت غير متصل. تم عرض آخر بيانات متاحة. اسحب للتحديث.",
                    ),
                    style: const TextStyle(
                      color: AppColors.bordeaux,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (_isOfflineState)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    tr3(
                      context,
                      fr: "Dernière mise à jour: $_lastUpdatedLabel",
                      en: "Last update: $_lastUpdatedLabel",
                      ar: "آخر تحديث: $_lastUpdatedLabel",
                    ),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              _StatusHeroCard(
                orderId: _resolvedOrderId,
                statusLabel: _statusLabel,
                etaLabel: _etaText,
                progress: _progress,
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: tr3(
                  context,
                  fr: "Informations commande",
                  en: "Order info",
                  ar: "معلومات الطلب",
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: tr3(context, fr: "Adresse", en: "Address", ar: "العنوان"),
                      value: _deliveryAddress,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniDetail(
                            icon: Icons.schedule_rounded,
                            label: tr3(context, fr: "Créneau", en: "Slot", ar: "الفترة"),
                            value: _deliverySlotLabel,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniDetail(
                            icon: Icons.attach_money_rounded,
                            label: tr3(context, fr: "Frais", en: "Fee", ar: "الرسوم"),
                            value: _deliveryFeeLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: tr3(context, fr: "Livreur", en: "Courier", ar: "الموصل"),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.person_rounded,
                      label: tr3(context, fr: "Nom", en: "Name", ar: "الاسم"),
                      value: _courierName,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.phone_rounded,
                      label: tr3(context, fr: "Téléphone", en: "Phone", ar: "الهاتف"),
                      value: _courierPhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _courierPhone == "—"
                          ? null
                          : () => _callNumber("Livreur", _courierPhone),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSize.buttonHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.25)),
                        foregroundColor: AppColors.bordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: Text(
                        tr3(context, fr: "Appeler livreur", en: "Call courier", ar: "اتصل بالمُوصل"),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _storePhone == "—"
                          ? null
                          : () => _callNumber("Magasin", _storePhone),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSize.buttonHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.25)),
                        foregroundColor: AppColors.bordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: const Icon(Icons.store_mall_directory_rounded, size: 18),
                      label: Text(
                        tr3(context, fr: "Contacter magasin", en: "Contact store", ar: "اتصل بالمتجر"),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: tr3(
                  context,
                  fr: "Étapes de livraison",
                  en: "Delivery steps",
                  ar: "مراحل التوصيل",
                ),
                child: Column(
                  children: [
                    _StepTile(
                      title: tr3(context, fr: "En préparation", en: "Preparing", ar: "قيد التحضير"),
                      subtitle: tr3(
                        context,
                        fr: "La commande est en préparation au magasin.",
                        en: "The order is being prepared in store.",
                        ar: "الطلب قيد التحضير في المتجر.",
                      ),
                      done: _step >= 0,
                      active: _step == 0,
                    ),
                    _StepTile(
                      title: tr3(context, fr: "En route", en: "On route", ar: "في الطريق"),
                      subtitle: tr3(
                        context,
                        fr: "Le livreur est en route vers votre adresse.",
                        en: "The courier is on the way to your address.",
                        ar: "الموصل في الطريق إلى عنوانك.",
                      ),
                      done: _step >= 1,
                      active: _step == 1,
                    ),
                    _StepTile(
                      title: tr3(context, fr: "Livrée", en: "Delivered", ar: "تم التسليم"),
                      subtitle: tr3(
                        context,
                        fr: "Commande reçue avec succès.",
                        en: "Order delivered successfully.",
                        ar: "تم تسليم الطلب بنجاح.",
                      ),
                      done: _step >= 2,
                      active: _step == 2,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: AppSize.buttonHeight,
                child: _sseConnected
                    ? OutlinedButton.icon(
                        onPressed: _loadTracking,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.3),
                          ),
                          foregroundColor: AppColors.bordeaux,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.bordeaux,
                        ),
                        label: Text(
                          tr3(
                            context,
                            fr: "Actualiser (fallback)",
                            en: "Refresh (fallback)",
                            ar: "تحديث (احتياطي)",
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.bordeaux,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _loadTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bordeaux,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          tr3(
                            context,
                            fr: "Actualiser le statut",
                            en: "Refresh status",
                            ar: "تحديث الحالة",
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHeroCard extends StatelessWidget {
  final String orderId;
  final String statusLabel;
  final String etaLabel;
  final double progress;

  const _StatusHeroCard({
    required this.orderId,
    required this.statusLabel,
    required this.etaLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final localizedStatus = tr3(
      context,
      fr: statusLabel == "preparing"
          ? "En préparation"
          : statusLabel == "on_route"
              ? "En route"
              : statusLabel == "delivered"
                  ? "Livrée"
                  : statusLabel == "cancelled"
                      ? "Annulée"
                      : "En attente",
      en: statusLabel == "preparing"
          ? "Preparing"
          : statusLabel == "on_route"
              ? "On route"
              : statusLabel == "delivered"
                  ? "Delivered"
                  : statusLabel == "cancelled"
                      ? "Cancelled"
                      : "Pending",
      ar: statusLabel == "preparing"
          ? "قيد التحضير"
          : statusLabel == "on_route"
              ? "في الطريق"
              : statusLabel == "delivered"
                  ? "تم التسليم"
                  : statusLabel == "cancelled"
                      ? "ملغاة"
                      : "قيد الانتظار",
    );

    final statusTone = statusLabel == "delivered"
        ? const Color(0xFF2E9A5A)
        : statusLabel == "cancelled"
            ? const Color(0xFFB33A4A)
            : AppColors.bordeaux;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusTone.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusTone.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  tr3(
                    context,
                    fr: "Commande #$orderId",
                    en: "Order #$orderId",
                    ar: "الطلب #$orderId",
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  etaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizedStatus,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr3(
              context,
              fr: "Suivi en temps réel de votre commande",
              en: "Real-time tracking of your order",
              ar: "تتبع طلبك في الوقت الحقيقي",
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: AppColors.soft,
              valueColor: AlwaysStoppedAnimation<Color>(statusTone),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.bordeaux),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.soft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.bordeaux),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool active;
  final bool isLast;

  const _StepTile({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = done ? AppColors.bordeaux : AppColors.muted.withValues(alpha: 0.6);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.bordeaux.withValues(alpha: 0.12) : AppColors.soft,
                border: Border.all(
                  color: done ? AppColors.bordeaux : AppColors.border,
                ),
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.circle_outlined,
                size: 14,
                color: markerColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: done ? AppColors.bordeaux.withValues(alpha: 0.35) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.muted.withValues(alpha: active ? 1 : 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
