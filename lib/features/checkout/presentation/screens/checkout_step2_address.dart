import 'package:elfaddoui_app/features/checkout/domain/entities/heckout_data.dart';
import 'package:elfaddoui_app/features/checkout/domain/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';

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
      (v == null || v.trim().isEmpty)
          ? tr3(context, fr: "Champ obligatoire", en: "Required field", ar: "حقل إجباري")
          : null;

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
        title: Text(tr3(context, fr: "Adresse", en: "Address", ar: "العنوان"),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        primaryText: tr3(context, fr: "Continuer", en: "Continue", ar: "متابعة"),
        onPrimary: _next,
        secondaryText: tr3(context, fr: "Retour", en: "Back", ar: "رجوع"),
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
            Text(
              tr3(context, fr: "Adresse de livraison", en: "Delivery address", ar: "عنوان التوصيل"),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr3(
                context,
                fr: "Indiquez l’adresse exacte pour une livraison rapide.",
                en: "Provide the exact address for fast delivery.",
                ar: "أدخل العنوان بدقة لتوصيل سريع.",
              ),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ SECTION TITLE خارج الكارد
            _SectionTitle(tr3(context, fr: "Type de lieu", en: "Place type", ar: "نوع المكان")),
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

            _SectionTitle(tr3(context, fr: "Détails de l’adresse", en: "Address details", ar: "تفاصيل العنوان")),
            const SizedBox(height: 10),

            // ===== ADDRESS CARD (fields only) =====
            _CardShell(
              child: Column(
                children: [
                  CheckoutField(
                    label: tr3(context, fr: "Ville / Gouvernorat *", en: "City / Governorate *", ar: "المدينة / الولاية *"),
                    hint: tr3(context, fr: "Ville ou gouvernorat", en: "City or governorate", ar: "المدينة أو الولاية"),
                    controller: _city,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Zone / Délégation *", en: "Area / District *", ar: "المنطقة / المعتمدية *"),
                    hint: tr3(context, fr: "Zone ou délégation", en: "Area or district", ar: "المنطقة أو المعتمدية"),
                    controller: _area,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Rue / Résidence *", en: "Street / Residence *", ar: "الشارع / الإقامة *"),
                    hint: tr3(context, fr: "Rue, résidence, lotissement…", en: "Street, residence, block…", ar: "الشارع، الإقامة، التجزئة…"),
                    controller: _street,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Immeuble / Étage / Appartement (optionnel)", en: "Building / Floor / Apartment (optional)", ar: "العمارة / الطابق / الشقة (اختياري)"),
                    hint: tr3(context, fr: "Bâtiment, étage, appartement…", en: "Building, floor, apartment…", ar: "العمارة، الطابق، الشقة…"),
                    controller: _extra,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Code postal (optionnel)", en: "Postal code (optional)", ar: "الرمز البريدي (اختياري)"),
                    hint: tr3(context, fr: "Code postal", en: "Postal code", ar: "الرمز البريدي"),
                    controller: _postal,
                    keyboardType: TextInputType.number,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Repère (optionnel)", en: "Landmark (optional)", ar: "معلم قريب (اختياري)"),
                    hint: tr3(context, fr: "Repère pour faciliter la livraison", en: "Landmark to help delivery", ar: "معلم لتسهيل التوصيل"),
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
