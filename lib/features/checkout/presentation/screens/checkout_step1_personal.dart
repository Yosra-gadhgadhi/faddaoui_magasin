import 'package:elfaddoui_app/features/checkout/domain/entities/heckout_data.dart';
import 'package:elfaddoui_app/features/checkout/domain/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';

import 'checkout_step2_address.dart';

class CheckoutStep1Personal extends StatefulWidget {
  final double total;
  const CheckoutStep1Personal({super.key, required this.total});

  @override
  State<CheckoutStep1Personal> createState() => _CheckoutStep1PersonalState();
}

class _CheckoutStep1PersonalState extends State<CheckoutStep1Personal> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty)
          ? tr3(context, fr: "Champ obligatoire", en: "Required field", ar: "حقل إجباري")
          : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) {
      return tr3(context, fr: "Téléphone obligatoire", en: "Phone required", ar: "رقم الهاتف إجباري");
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      return tr3(context, fr: "Numéro invalide", en: "Invalid number", ar: "رقم غير صالح");
    }
    return null;
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    final data = CheckoutData(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutStep2Address(
          total: widget.total,
          data: data,
        ),
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
        title: Text(
          tr3(context, fr: "Commander", en: "Checkout", ar: "إتمام الطلب"),
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
            const CheckoutTopStepper(current: 1),
            const SizedBox(height: 12),

            // ===== HEADER (minimal) =====
            Text(
              tr3(context, fr: "Informations personnelles", en: "Personal information", ar: "المعلومات الشخصية"),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tr3(context, fr: "Veuillez renseigner vos informations", en: "Please fill in your information", ar: "يرجى إدخال معلوماتك"),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 14),

            // ===== SUMMARY =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.bordeaux.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.bordeaux,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr3(context, fr: "Résumé de la commande", en: "Order summary", ar: "ملخص الطلب"),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    "${widget.total.toStringAsFixed(2)} DT",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.bordeaux,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ✅ SECTION TITLE خارج الكارد (يفرق واضح)
            _SectionTitle(tr3(context, fr: "Contact", en: "Contact", ar: "التواصل")),
            const SizedBox(height: 10),

            // ===== CONTACT CARD (فقط fields) =====
            _CardShell(
              child: Column(
                children: [
                  CheckoutField(
                    label: tr3(context, fr: "Nom & Prénom *", en: "Full name *", ar: "الاسم الكامل *"),
                    hint: tr3(context, fr: "Votre nom complet", en: "Your full name", ar: "اسمك الكامل"),
                    controller: _name,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Téléphone *", en: "Phone *", ar: "الهاتف *"),
                    hint: tr3(context, fr: "Numéro de téléphone", en: "Phone number", ar: "رقم الهاتف"),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                  ),
                  CheckoutField(
                    label: tr3(context, fr: "Email (optionnel)", en: "Email (optional)", ar: "البريد الإلكتروني (اختياري)"),
                    hint: tr3(context, fr: "Adresse email (optionnel)", en: "Email address (optional)", ar: "البريد الإلكتروني (اختياري)"),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _SectionTitle(tr3(context, fr: "Note", en: "Note", ar: "ملاحظة")),
            const SizedBox(height: 10),

            // ===== NOTE CARD =====
            _CardShell(
              child: CheckoutField(
                label: tr3(context, fr: "Note pour le livreur (optionnel)", en: "Note for courier (optional)", ar: "ملاحظة للمُوصل (اختياري)"),
                hint: tr3(context, fr: "Ajouter une note pour le livreur", en: "Add a note for the courier", ar: "أضف ملاحظة للمُوصل"),
                controller: _note,
                maxLines: 3,
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
