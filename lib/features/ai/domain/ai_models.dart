class AiRecommendation {
  final String id;
  final String title;
  final String reason;
  final String productId;
  final String image;
  final double price;

  const AiRecommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.productId,
    required this.image,
    required this.price,
  });
}

class CompetitorOffer {
  final String storeName;
  final double price;
  final String url; // source link

  const CompetitorOffer({
    required this.storeName,
    required this.price,
    required this.url,
  });
}

class PriceComparison {
  final String productId;
  final double ourPrice;
  final List<CompetitorOffer> offers;

  const PriceComparison({
    required this.productId,
    required this.ourPrice,
    required this.offers,
  });

  CompetitorOffer? bestOffer() {
    if (offers.isEmpty) return null;
    CompetitorOffer best = offers.first;
    for (final o in offers) {
      if (o.price < best.price) best = o;
    }
    return best;
  }
}
