import 'package:elfaddoui_app/features/checkout/domain/entities/heckout_data.dart';
import 'package:elfaddoui_app/features/checkout/domain/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

import 'checkout_step3_payment.dart';

class CheckoutStep2Address extends StatefulWidget {
  final double total;
  final CheckoutData data;

  const CheckoutStep2Address({
    super.key,
    required this.total,
    required this.data,
  });

  @override
  State<CheckoutStep2Address> createState() => _CheckoutStep2AddressState();
}

class _CheckoutStep2AddressState extends State<CheckoutStep2Address> {
  final _formKey = GlobalKey<FormState>();

  final _city = TextEditingController();
  final _area = TextEditingController();
  final _street = TextEditingController();
  final _extra = TextEditingController();
  final _postal = TextEditingController();
  final _hint = TextEditingController();

  String _placeType = "Maison";

  @override
  void initState() {
    super.initState();
    _placeType = widget.data.placeType;

    _city.text = widget.data.city;
    _area.text = widget.data.area;
    _street.text = widget.data.street;
    _extra.text = widget.data.extra ?? "";
    _postal.text = widget.data.postalCode ?? "";
    _hint.text = widget.data.addressHint ?? "";
  }

  @override
  void dispose() {
    _city.dispose();
    _area.dispose();
    _street.dispose();
    _extra.dispose();
    _postal.dispose();
    _hint.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? "Champ obligatoire" : null;

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    widget.data.city = _city.text.trim();
    widget.data.area = _area.text.trim();
    widget.data.street = _street.text.trim();
    widget.data.extra = _extra.text.trim().isEmpty ? null : _extra.text.trim();
    widget.data.postalCode =
        _postal.text.trim().isEmpty ? null : _postal.text.trim();
    widget.data.addressHint =
        _hint.text.trim().isEmpty ? null : _hint.text.trim();
    widget.data.placeType = _placeType;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CheckoutStep3Payment(total: widget.total, data: widget.data),
      ),
    );
  }

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
        centerTitle: true,
        title: const Text("Adresse",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        primaryText: "Continuer",
        onPrimary: _next,
        secondaryText: "Retour",
        onSecondary: () => Navigator.pop(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: [
            const CheckoutTopStepper(current: 2),
            const SizedBox(height: 12),

            // ===== HEADER (minimal) =====
            const Text(
              "Adresse de livraison",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Indiquez l’adresse exacte pour une livraison rapide.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ SECTION TITLE خارج الكارد
            const _SectionTitle("Type de lieu"),
            const SizedBox(height: 10),

            // ===== PLACE TYPE CARD (soft) =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: PlaceTypeSegment(
                value: _placeType,
                onChanged: (v) => setState(() => _placeType = v),
              ),
            ),

            const SizedBox(height: 18),

            const _SectionTitle("Détails de l’adresse"),
            const SizedBox(height: 10),

            // ===== ADDRESS CARD (fields only) =====
            _CardShell(
              child: Column(
                children: [
                  CheckoutField(
                    label: "Ville / Gouvernorat *",
                    hint: "Ville ou gouvernorat",
                    controller: _city,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: "Zone / Délégation *",
                    hint: "Zone ou délégation",
                    controller: _area,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: "Rue / Résidence *",
                    hint: "Rue, résidence, lotissement…",
                    controller: _street,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: "Immeuble / Étage / Appartement (optionnel)",
                    hint: "Bâtiment, étage, appartement…",
                    controller: _extra,
                  ),
                  CheckoutField(
                    label: "Code postal (optionnel)",
                    hint: "Code postal",
                    controller: _postal,
                    keyboardType: TextInputType.number,
                  ),
                  CheckoutField(
                    label: "Repère (optionnel)",
                    hint: "Repère pour faciliter la livraison",
                    controller: _hint,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
