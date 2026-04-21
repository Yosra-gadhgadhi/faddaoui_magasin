import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/features/delivery/presentation/screens/delivery_tracking_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double total;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final soft = AppColors.bordeaux.withValues(alpha: 0.06);
    final border = AppColors.bordeaux.withValues(alpha: 0.18);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          tr3(context, fr: "Succès", en: "Success", ar: "تم بنجاح"),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  tr3(context, fr: "Retour à l’accueil", en: "Back to home", ar: "العودة للرئيسية"),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              )),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Container(
                height: 86,
                width: 86,
                decoration: BoxDecoration(
                  color: soft,
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: AppColors.bordeaux,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                tr3(context, fr: "Commande confirmée", en: "Order confirmed", ar: "تم تأكيد الطلب"),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                tr3(
                  context,
                  fr: "Numéro de commande : $orderId",
                  en: "Order number: $orderId",
                  ar: "رقم الطلب: $orderId",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _Line(
                        label: tr3(context, fr: "Total payé", en: "Total paid", ar: "إجمالي المدفوع"),
                        value: "${total.toStringAsFixed(2)} DT"),
                    const SizedBox(height: 10),
                    _Line(
                      label: tr3(context, fr: "Statut", en: "Status", ar: "الحالة"),
                      value: tr3(context, fr: "Confirmée", en: "Confirmed", ar: "مؤكدة"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DeliveryTrackingScreen(orderId: orderId),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.25)),
                    foregroundColor: AppColors.bordeaux,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.local_shipping_rounded),
                  label: Text(
                    tr3(context, fr: "Suivre ma commande", en: "Track my order", ar: "تتبع طلبي"),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                tr3(context, fr: "Merci pour votre commande", en: "Thank you for your order", ar: "شكراً على طلبك"),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted.withValues(alpha: 0.9),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
