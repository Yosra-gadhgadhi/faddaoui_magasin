import 'ai_models.dart';

abstract class AiService {
  Future<List<AiRecommendation>> getPersonalizedRecommendations({
    required List<String> favoriteProductIds,
    required List<String> cartProductIds,
    required List<String> recentViewedProductIds,
  });

  Future<PriceComparison> comparePrice({
    required String productId,
    required double ourPrice,
  });
}
