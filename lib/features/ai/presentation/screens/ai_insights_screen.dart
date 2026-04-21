import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/ai_cubit.dart';

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr3(context, fr: "Insights IA", en: "AI Insights", ar: "رؤى الذكاء الاصطناعي"),
          style: AppTextStyles.h2,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AiCubit, AiState>(
          builder: (context, state) {
            return ListView(
              children: [
                Text(
                  tr3(context, fr: "Recommandations pour toi", en: "Recommendations for you", ar: "توصيات لك"),
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 10),

                if (state.loadingRecs)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.recs.isEmpty)
                  Text(
                    tr3(context, fr: "Pas de recommandations pour le moment.", en: "No recommendations for now.", ar: "لا توجد توصيات حالياً."),
                    style: AppTextStyles.muted,
                  )
                else
                  ...state.recs.map((r) => _RecCard(
                        title: r.title,
                        reason: r.reason,
                        image: r.image,
                        price: r.price,
                        onTap: () {},
                      )),

                const SizedBox(height: 22),
                Text(
                  tr3(context, fr: "Comparaison de prix", en: "Price comparison", ar: "مقارنة الأسعار"),
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 10),

                const _CompareDemoBox(),
                const SizedBox(height: 12),

                if (state.loadingCompare)
                  const Center(child: CircularProgressIndicator())
                else if (state.comparison != null)
                  _ComparisonResult(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  final String title;
  final String reason;
  final String image;
  final double price;
  final VoidCallback onTap;

  const _RecCard({
    required this.title,
    required this.reason,
    required this.image,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  image,
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(reason, style: AppTextStyles.muted),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${price.toStringAsFixed(2)} dt",
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.bordeaux,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareDemoBox extends StatelessWidget {
  const _CompareDemoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr3(context, fr: "Exemple: comparer le prix d’un produit", en: "Example: compare a product price", ar: "مثال: قارن سعر منتج"),
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              context.read<AiCubit>().comparePrice(
                    productId: "lait_1",
                    ourPrice: 3.20,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bordeaux,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            child: Text(
              tr3(context, fr: "Comparer", en: "Compare", ar: "قارن"),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}

class _ComparisonResult extends StatelessWidget {
  final AiState state;
  const _ComparisonResult({required this.state});

  @override
  Widget build(BuildContext context) {
    final cmp = state.comparison!;
    final best = cmp.bestOffer();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr3(context, fr: "Notre prix: ", en: "Our price: ", ar: "سعرنا: "),
                style: AppTextStyles.muted,
              ),
              Text(
                "${cmp.ourPrice.toStringAsFixed(2)} dt",
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.bordeaux,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (best != null)
            Text(
              tr3(
                context,
                fr: "Meilleur concurrent: ${best.storeName} (${best.price.toStringAsFixed(2)} dt)",
                en: "Best competitor: ${best.storeName} (${best.price.toStringAsFixed(2)} dt)",
                ar: "أفضل منافس: ${best.storeName} (${best.price.toStringAsFixed(2)} د.ت)",
              ),
              style: AppTextStyles.body,
            ),
          const SizedBox(height: 10),
          ...cmp.offers.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(o.storeName, style: AppTextStyles.body),
                  Text(
                    "${o.price.toStringAsFixed(2)} dt",
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
