import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class CheckoutTopStepper extends StatelessWidget {
  final int current; // 1..3
  const CheckoutTopStepper({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final active = i <= current;
      return Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: active ? AppColors.bordeaux : AppColors.border,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "$i",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      );
    }

    Widget line(bool active) => Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.bordeaux : AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.soft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          dot(1),
          line(current >= 2),
          dot(2),
          line(current >= 3),
          dot(3),
        ],
      ),
    );
  }
}

class CheckoutField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;

  const CheckoutField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.prefixText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              fontSize: 13.2,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.muted),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: AppColors.soft.withValues(alpha: 0.35),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.bordeaux, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutBottomBar extends StatelessWidget {
  final String primaryText;
  final VoidCallback onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;

  const CheckoutBottomBar({
    super.key,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: [
            if (secondaryText != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondary,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    secondaryText!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bordeaux,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  primaryText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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

class CheckoutCard extends StatelessWidget {
  final String title;
  final Widget child;

  const CheckoutCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class CheckoutRadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String group;
  final ValueChanged<String> onChanged;
  final IconData icon;

  const CheckoutRadioTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.group,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == group;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppColors.bordeaux.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? AppColors.bordeaux.withValues(alpha: 0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.bordeaux.withValues(alpha: 0.12)
                    : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.bordeaux),
            ),
            const SizedBox(width: 12),
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
            RadioGroup<String>(
              groupValue: group,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              child: Radio<String>(
                value: value,
                activeColor: AppColors.bordeaux,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceTypeSegment extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const PlaceTypeSegment({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String t) {
      final active = value == t;
          return Expanded(
        child: InkWell(
          onTap: () => onChanged(t),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.bordeaux.withValues(alpha: 0.10)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? AppColors.bordeaux.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                t,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.bordeaux : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip("Maison"),
        const SizedBox(width: 10),
        chip("Bureau"),
      ],
    );
  }
}
