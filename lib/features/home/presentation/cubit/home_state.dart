import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  static const Object _keep = Object();
  final bool loading;
  final String? error;

  final String locationLabel;
  final String etaLabel;

  final List<Product> deals; // bons plans IA
  final List<Product> forYou; // recommandé
  final List<Product> recent; // continuez
  final List<GroceryItem> list; // liste courses

  const HomeState({
    this.loading = true,
    this.error,
    this.locationLabel = "Tunis • Centre",
    this.etaLabel = "Livraison 45–60 min",
    this.deals = const [],
    this.forYou = const [],
    this.recent = const [],
    this.list = const [],
  });

  HomeState copyWith({
    bool? loading,
    Object? error = _keep,
    String? locationLabel,
    String? etaLabel,
    List<Product>? deals,
    List<Product>? forYou,
    List<Product>? recent,
    List<GroceryItem>? list,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      error: identical(error, _keep) ? this.error : error as String?,
      locationLabel: locationLabel ?? this.locationLabel,
      etaLabel: etaLabel ?? this.etaLabel,
      deals: deals ?? this.deals,
      forYou: forYou ?? this.forYou,
      recent: recent ?? this.recent,
      list: list ?? this.list,
    );
  }
}

// Models
class Product {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String image;
  final double price;
  final double? oldPrice;
  final int? discountPctApi;
  final double rating;
  final int reviews;
  const Product({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.image,
    required this.price,
    this.oldPrice,
    this.discountPctApi,
    this.rating = 4.5,
    this.reviews = 120,
  });

  double? get discountPct {
    if (discountPctApi != null) {
      return discountPctApi!.toDouble().clamp(0, 90);
    }
    if (oldPrice == null || oldPrice! <= 0) return null;
    final p = ((oldPrice! - price) / oldPrice!) * 100;
    return p.clamp(0, 90);
  }
}

class GroceryItem {
  final String? id;
  final String name;
  final String? category;
  final int? quantity;
  final String? image;
  final bool done;
  const GroceryItem(
    this.name, {
    this.id,
    this.category,
    this.quantity,
    this.image,
    this.done = false,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? image,
    bool? done,
  }) =>
      GroceryItem(
        name ?? this.name,
        id: id ?? this.id,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        image: image ?? this.image,
        done: done ?? this.done,
      );
}
