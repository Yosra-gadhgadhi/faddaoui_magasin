import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String orderId;
  const DeliveryTrackingScreen({super.key, this.orderId = "ELF-1024"});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  int _step = 1; // 0 preparing, 1 on route, 2 delivered

  String get _etaLabel {
    switch (_step) {
      case 0:
        return "eta_35";
      case 1:
        return "eta_18";
      case 2:
        return "eta_done";
      default:
        return "eta_none";
    }
  }

  String get _statusLabel {
    switch (_step) {
      case 0:
        return "preparing";
      case 1:
        return "on_route";
      case 2:
        return "delivered";
      default:
        return "pending";
    }
  }

  double get _progress => (_step + 1) / 3;

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
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            if (!mounted) return;
            setState(() {
              _step = (_step + 1) % 3;
            });
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            children: [
              _StatusHeroCard(
                orderId: widget.orderId,
                statusLabel: _statusLabel,
                etaLabel: _etaLabel,
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
                      value: "Tunis Centre, Rue Habib Bourguiba",
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniDetail(
                            icon: Icons.schedule_rounded,
                            label: tr3(context, fr: "Créneau", en: "Slot", ar: "الفترة"),
                            value: "19:00 - 20:00",
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MiniDetail(
                            icon: Icons.attach_money_rounded,
                            label: tr3(context, fr: "Frais", en: "Fee", ar: "الرسوم"),
                            value: "4.00 DT",
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
                      value: "Ali Ben Salem",
                    ),
                    SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.phone_rounded,
                      label: tr3(
                          context, fr: "Téléphone", en: "Phone", ar: "الهاتف"),
                      value: "+216 55 123 456",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _callNumber("Livreur", "+216 55 123 456"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.25)),
                        foregroundColor: AppColors.bordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: Text(
                        tr3(
                          context,
                          fr: "Appeler livreur",
                          en: "Call courier",
                          ar: "اتصل بالمُوصل",
                        ),
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _callNumber("Magasin", "+216 71 000 111"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.25)),
                        foregroundColor: AppColors.bordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.store_mall_directory_rounded,
                          size: 18),
                      label: Text(
                        tr3(
                          context,
                          fr: "Contacter magasin",
                          en: "Contact store",
                          ar: "اتصل بالمتجر",
                        ),
                        style: TextStyle(fontWeight: FontWeight.w800),
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
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _step = (_step + 1) % 3;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bordeaux,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    tr3(
                      context,
                      fr: "Actualiser le statut",
                      en: "Refresh status",
                      ar: "تحديث الحالة",
                    ),
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.white),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  color: AppColors.bordeaux.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.bordeaux.withValues(alpha: 0.2),
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
                    color: AppColors.bordeauxDark,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  tr3(
                    context,
                    fr: etaLabel == "eta_35"
                        ? "Arrive dans ~35 min"
                        : etaLabel == "eta_18"
                            ? "Arrive dans ~18 min"
                            : etaLabel == "eta_done"
                                ? "Livré"
                                : "-",
                    en: etaLabel == "eta_35"
                        ? "Arrives in ~35 min"
                        : etaLabel == "eta_18"
                            ? "Arrives in ~18 min"
                            : etaLabel == "eta_done"
                                ? "Delivered"
                                : "-",
                    ar: etaLabel == "eta_35"
                        ? "يصل خلال ~35 دقيقة"
                        : etaLabel == "eta_18"
                            ? "يصل خلال ~18 دقيقة"
                            : etaLabel == "eta_done"
                                ? "تم التسليم"
                                : "-",
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.bordeaux,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr3(
              context,
              fr: statusLabel == "preparing"
                  ? "En préparation"
                  : statusLabel == "on_route"
                      ? "En route"
                      : statusLabel == "delivered"
                          ? "Livrée"
                          : "En attente",
              en: statusLabel == "preparing"
                  ? "Preparing"
                  : statusLabel == "on_route"
                      ? "On route"
                      : statusLabel == "delivered"
                          ? "Delivered"
                          : "Pending",
              ar: statusLabel == "preparing"
                  ? "قيد التحضير"
                  : statusLabel == "on_route"
                      ? "في الطريق"
                      : statusLabel == "delivered"
                          ? "تم التسليم"
                          : "قيد الانتظار",
            ),
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
            style: TextStyle(
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
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.bordeaux),
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
        borderRadius: BorderRadius.circular(16),
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
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 17, color: AppColors.bordeaux),
        ),
        const SizedBox(width: 10),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.soft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
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
    final markerColor =
        done ? AppColors.bordeaux : AppColors.muted.withValues(alpha: 0.6);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.bordeaux.withValues(alpha: 0.12)
                    : AppColors.soft,
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
                height: 30,
                color: done
                    ? AppColors.bordeaux.withValues(alpha: 0.35)
                    : AppColors.border,
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
