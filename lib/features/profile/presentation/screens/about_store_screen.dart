import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';

class AboutStoreScreen extends StatelessWidget {
  const AboutStoreScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Impossible d'ouvrir le lien.")),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appel indisponible sur cet appareil.")),
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
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded,
                size: 16, color: AppColors.bordeauxDark),
            SizedBox(width: 8),
            Text(
              "Contact & À propos",
              style: TextStyle(
                color: AppColors.bordeauxDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          const _CardLine(
            icon: Icons.location_on_rounded,
            title: "Adresse",
            value: "Tunis Centre, Rue Habib Bourguiba",
          ),
          const SizedBox(height: 10),
          const _CardLine(
            icon: Icons.schedule_rounded,
            title: "Horaires",
            value: "Lun - Sam: 08:00 - 22:00",
          ),
          const SizedBox(height: 10),
          _CardButton(
            icon: Icons.phone_rounded,
            title: "Téléphone",
            value: "+216 71 000 111",
            onTap: () => _call(context, "+216 71 000 111"),
          ),
          const SizedBox(height: 10),
          _CardButton(
            icon: Icons.map_rounded,
            title: "Ouvrir sur la map",
            value: "Google Maps",
            onTap: () => _openUrl(
              context,
              "https://maps.google.com/?q=Tunis+Centre+Rue+Habib+Bourguiba",
            ),
          ),
          const SizedBox(height: 10),
          _CardButton(
            icon: Icons.public_rounded,
            title: "Réseaux sociaux",
            value: "@elfaddoui_market",
            onTap: () => _openUrl(context, "https://instagram.com"),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bordeaux.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.bordeaux.withValues(alpha: 0.16)),
            ),
            child: const Text(
              "ElFaddaoui est votre marché de proximité: prix justes, livraison rapide et service client réactif.",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _CardLine({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.bordeaux, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
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

class _CardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  const _CardButton({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: _CardLine(icon: icon, title: title, value: value),
    );
  }
}
