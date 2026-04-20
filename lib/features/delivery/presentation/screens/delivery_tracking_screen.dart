import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
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
        return "وصل بعد ~35 دقيقة";
      case 1:
        return "وصل بعد ~18 دقيقة";
      case 2:
        return "تم التسليم";
      default:
        return "-";
    }
  }

  String get _statusLabel {
    switch (_step) {
      case 0:
        return "En préparation";
      case 1:
        return "En route";
      case 2:
        return "Livrée";
      default:
        return "En attente";
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
        content: Text("$label indisponible. Numéro copié: $phone"),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            Icon(Icons.local_shipping_rounded,
                size: 16, color: AppColors.bordeauxDark),
            SizedBox(width: 8),
            Text(
              "Suivi livraison",
              style: TextStyle(
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            children: [
              _InfoCard(
                title: "Commande",
                value: "#${widget.orderId}",
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(height: 10),
              const _InfoCard(
                title: "Adresse",
                value: "Tunis Centre, Rue Habib Bourguiba",
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: "Créneau",
                      value: "19:00 - 20:00",
                      icon: Icons.schedule_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      title: "Frais",
                      value: "4.00 DT",
                      icon: Icons.attach_money_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
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
                        const Icon(Icons.timelapse_rounded,
                            color: AppColors.bordeaux, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Statut: $_statusLabel",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          _etaLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.bordeaux,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: _progress,
                        backgroundColor: AppColors.soft,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.bordeaux),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: "Livreur",
                        value: "Ali Ben Salem",
                        icon: Icons.person_rounded,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _InfoCard(
                        title: "Téléphone",
                        value: "+216 55 123 456",
                        icon: Icons.phone_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _callNumber("Livreur", "+216 55 123 456"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.25)),
                        foregroundColor: AppColors.bordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: const Text(
                        "Appeler livreur",
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
                        minimumSize: const Size.fromHeight(46),
                        side: BorderSide(
                            color: AppColors.bordeaux.withValues(alpha: 0.25)),
                        foregroundColor: AppColors.bordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.store_mall_directory_rounded,
                          size: 18),
                      label: const Text(
                        "Contacter magasin",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
                ),
                child: Column(
                  children: [
                    _StepTile(
                      title: "En préparation",
                      done: _step >= 0,
                      active: _step == 0,
                    ),
                    _StepTile(
                      title: "En route",
                      done: _step >= 1,
                      active: _step == 1,
                    ),
                    _StepTile(
                      title: "Livrée",
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
                  label: const Text(
                    "Actualiser le statut",
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 17, color: AppColors.bordeaux),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String title;
  final bool done;
  final bool active;
  final bool isLast;

  const _StepTile({
    required this.title,
    required this.done,
    required this.active,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.bordeaux : AppColors.muted.withValues(alpha: 0.6);
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
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: done
                    ? AppColors.bordeaux.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                color: done ? AppColors.text : AppColors.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
