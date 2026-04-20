import 'package:elfaddoui_app/features/checkout/domain/entities/heckout_data.dart';
import 'package:elfaddoui_app/features/checkout/domain/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

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

  void _confirm() {
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
          content: const Text(
            "Veuillez accepter les conditions.",
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      return;
    }

    final orderId =
        "ELF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OrderSuccessScreen(orderId: orderId, total: widget.total),
      ),
    );
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Paiement",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        primaryText: "Confirmer",
        onPrimary: _confirm,
        secondaryText: "Retour",
        onSecondary: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          const CheckoutTopStepper(current: 3),
          const SizedBox(height: 12),

          // ===== HEADER =====
          const Text(
            "Paiement & Livraison",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Choisissez votre mode de paiement et le créneau.",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 18),

          // ===== PAYMENT METHOD =====
          const _SectionTitle("Mode de paiement"),
          const SizedBox(height: 10),
          _CardShell(
            child: Column(
              children: [
                _RadioRow(
                  title: "Paiement à la livraison",
                  subtitle: "Cash",
                  selected: data.paymentMethod == "cash",
                  onTap: () => setState(() => data.paymentMethod = "cash"),
                ),
                const SizedBox(height: 10),
                _RadioRow(
                  title: "Carte",
                  subtitle: "TPE à la livraison (optionnel)",
                  selected: data.paymentMethod == "card",
                  onTap: () => setState(() => data.paymentMethod = "card"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ===== DELIVERY SLOT =====
          const _SectionTitle("Créneau de livraison"),
          const SizedBox(height: 10),
          _CardShell(
            child: Column(
              children: [
                _RadioRow(
                  title: "ASAP",
                  subtitle: "45–60 minutes",
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
                  title: "Choisir une heure",
                  subtitle: data.scheduledTime ?? "Choisir",
                  selected: data.deliverySlot == "scheduled",
                  onTap: () async {
                    setState(() => data.deliverySlot = "scheduled");
                    await _pickTime(data);
                  },
                ),

                // ✅ يظهر فقط في scheduled
                if (data.deliverySlot == "scheduled") ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _pickTime(data),
                      child: const Text(
                        "Modifier l’heure",
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
          const _SectionTitle("Résumé"),
          const SizedBox(height: 10),
          _CardShell(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Total à payer",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  "${widget.total.toStringAsFixed(2)} DT",
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
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "J’accepte les conditions et la politique de livraison.",
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
