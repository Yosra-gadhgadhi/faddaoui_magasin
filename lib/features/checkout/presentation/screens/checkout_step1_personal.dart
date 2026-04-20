import 'package:elfaddoui_app/features/checkout/domain/entities/heckout_data.dart';
import 'package:elfaddoui_app/features/checkout/domain/widgets/checkout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

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
      (v == null || v.trim().isEmpty) ? "Champ obligatoire" : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Téléphone obligatoire";
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return "Numéro invalide";
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
        title: const Text(
          "Commander",
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
            const CheckoutTopStepper(current: 1),
            const SizedBox(height: 12),

            // ===== HEADER (minimal) =====
            const Text(
              "Informations personnelles",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Veuillez renseigner vos informations",
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
                  const Expanded(
                    child: Text(
                      "Résumé de la commande",
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
            const _SectionTitle("Contact"),
            const SizedBox(height: 10),

            // ===== CONTACT CARD (فقط fields) =====
            _CardShell(
              child: Column(
                children: [
                  CheckoutField(
                    label: "Nom & Prénom *",
                    hint: "Votre nom complet",
                    controller: _name,
                    validator: _req,
                  ),
                  CheckoutField(
                    label: "Téléphone *",
                    hint: "Numéro de téléphone",
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                  ),
                  CheckoutField(
                    label: "Email (optionnel)",
                    hint: "Adresse email (optionnel)",
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const _SectionTitle("Note"),
            const SizedBox(height: 10),

            // ===== NOTE CARD =====
            _CardShell(
              child: CheckoutField(
                label: "Note pour le livreur (optionnel)",
                hint: "Ajouter une note pour le livreur",
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
