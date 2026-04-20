import '../domain/ai_models.dart';
import '../domain/ai_service.dart';

class MockAiService implements AiService {
  @override
  Future<List<AiRecommendation>> getPersonalizedRecommendations({
    required List<String> favoriteProductIds,
    required List<String> cartProductIds,
    required List<String> recentViewedProductIds,
  }) async {
    // simulate network
    await Future.delayed(const Duration(milliseconds: 350));

    final ids = <String>{...favoriteProductIds, ...cartProductIds, ...recentViewedProductIds};

    // Rules بسيطة (تنجم توسعهم)
    final recs = <AiRecommendation>[];

    bool hasKeyword(String kw) => ids.any((x) => x.toLowerCase().contains(kw));

    if (hasKeyword("lait")) {
      recs.add(const AiRecommendation(
        id: "rec_1",
        title: "Céréales",
        reason: "يكمّلوا مع الحليب و الناس تشريهم برشة مع بعضهم.",
        productId: "cereales_1",
        image: "https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?auto=compress&cs=tinysrgb&w=800",
        price: 6.90,
      ));
      recs.add(const AiRecommendation(
        id: "rec_2",
        title: "Café",
        reason: "اقتراح حسب مشتريات مشابهة.",
        productId: "cafe_1",
        image: "https://images.pexels.com/photos/585750/pexels-photo-585750.jpeg?auto=compress&cs=tinysrgb&w=800",
        price: 8.50,
      ));
    }

    if (hasKeyword("pates") || hasKeyword("pâtes") || hasKeyword("spaghetti")) {
      recs.add(const AiRecommendation(
        id: "rec_3",
        title: "Sauce tomate",
        reason: "اقتراح ذكي: غالباً تُشترى مع العجين.",
        productId: "sauce_1",
        image: "https://images.pexels.com/photos/1435907/pexels-photo-1435907.jpeg?auto=compress&cs=tinysrgb&w=800",
        price: 3.40,
      ));
    }

    // fallback: 3 recs general
    if (recs.isEmpty) {
      recs.addAll(const [
        AiRecommendation(
          id: "rec_4",
          title: "Eau minérale",
          reason: "اقتراح عام حسب المنتجات الأكثر شراءً.",
          productId: "eau_1",
          image: "https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg?auto=compress&cs=tinysrgb&w=800",
          price: 1.20,
        ),
        AiRecommendation(
          id: "rec_5",
          title: "Fruits de saison",
          reason: "اقتراح: منتجات طازجة و مطلوبة.",
          productId: "fruits_1",
          image: "https://images.pexels.com/photos/952360/pexels-photo-952360.jpeg?auto=compress&cs=tinysrgb&w=800",
          price: 7.30,
        ),
      ]);
    }

    return recs;
  }

  @override
  Future<PriceComparison> comparePrice({
    required String productId,
    required double ourPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    // Mock competitors offers (later Spring Boot will fetch real)
    return PriceComparison(
      productId: productId,
      ourPrice: ourPrice,
      offers: const [
        CompetitorOffer(storeName: "Géant", price: 3.10, url: "https://example.com/geant"),
        CompetitorOffer(storeName: "Aziza", price: 3.30, url: "https://example.com/aziza"),
        CompetitorOffer(storeName: "Jumia", price: 3.05, url: "https://example.com/jumia"),
      ],
    );
  }
}
