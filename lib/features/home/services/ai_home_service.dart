import 'package:dio/dio.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/features/home/presentation/cubit/home_state.dart';

class HomeBootstrapData {
  final String locationLabel;
  final String etaLabel;
  final List<Product> deals;
  final List<Product> forYou;
  final List<Product> recent;
  final List<GroceryItem> list;

  HomeBootstrapData({
    required this.locationLabel,
    required this.etaLabel,
    required this.deals,
    required this.forYou,
    required this.recent,
    required this.list,
  });
}

class AiHomeService {
  AiHomeService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {"Content-Type": "application/json"},
                validateStatus: (code) => code != null && code < 500,
              ),
            );

  final Dio _dio;
  static const String _defaultProductImage =
      "https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _freshImage =
      "https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _electronicsImage =
      "https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _fridgeImage =
      "https://images.pexels.com/photos/5825570/pexels-photo-5825570.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _washingMachineImage =
      "https://images.pexels.com/photos/5591838/pexels-photo-5591838.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _gasCookerImage =
      "https://images.pexels.com/photos/6996164/pexels-photo-6996164.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _tvImage =
      "https://images.pexels.com/photos/5825570/pexels-photo-5825570.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _kitchenwareImage =
      "https://images.pexels.com/photos/4226805/pexels-photo-4226805.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _householdImage =
      "https://images.pexels.com/photos/4239031/pexels-photo-4239031.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _beverageImage =
      "https://images.pexels.com/photos/96974/pexels-photo-96974.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _dairyBakeryImage =
      "https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _snacksImage =
      "https://images.pexels.com/photos/230325/pexels-photo-230325.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";
  static const String _groceryImage =
      "https://images.pexels.com/photos/4518843/pexels-photo-4518843.jpeg?auto=compress&cs=tinysrgb&w=1200&h=900&dpr=2";

  Future<HomeBootstrapData> bootstrapHome() async {
    final r = await _dio.get('/api/home');
    if ((r.statusCode ?? 500) >= 400) {
      throw Exception("HTTP ${r.statusCode} on /api/home");
    }
    final data = _asMap(r.data);
    return HomeBootstrapData(
      locationLabel: (data['locationLabel'] ?? 'Tunis • Centre').toString(),
      etaLabel: (data['etaLabel'] ?? 'Livraison 45–60 min').toString(),
      deals: _toProducts(data['deals']),
      forYou: _toProducts(data['forYou']),
      recent: _toProducts(data['recent']),
      list: _toGroceryItems(data['groceryItems']),
    );
  }

  Future<Product?> getProductById(String productId) async {
    try {
      final r = await _dio.get('/api/home/products/$productId');
      if ((r.statusCode ?? 500) >= 400) return null;
      return _toProduct(_asMap(r.data));
    } catch (_) {
      return null;
    }
  }

  Future<List<Product>> smartSearch(String query, List<Product> catalog) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final res = catalog.where((p) {
      final n = p.name.toLowerCase();
      final c = (p.category ?? '').toLowerCase();
      return n.contains(q) || n.startsWith(q) || c.contains(q);
    }).toList();

    return res.take(12).toList();
  }

  Future<String> recipeIdea(String ingredientsText) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return "Idée recette : Omelette + salade\n"
        "• Étapes : 1) Battre œufs 2) Ajouter ingrédients 3) Cuire 6–8 min\n"
        "• Suggestion : Ajouter fromage / tomates.";
  }

  Future<List<Product>> budgetPlan(double budget, List<Product> catalog) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sorted = [...catalog]..sort((a, b) => a.price.compareTo(b.price));
    double sum = 0;
    final cart = <Product>[];
    for (final p in sorted) {
      if (sum + p.price <= budget) {
        cart.add(p);
        sum += p.price;
      }
      if (cart.length >= 10) break;
    }
    return cart;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  List<Product> _toProducts(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => _toProduct(Map<String, dynamic>.from(e)))
        .toList();
  }

  Product _toProduct(Map<String, dynamic> j) {
    double toDouble(dynamic v, [double fallback = 0]) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    return Product(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      description: j['description']?.toString(),
      category: j['category']?.toString(),
      image: _resolveStoreImage(
        imageValue: j['image'],
        name: (j['name'] ?? '').toString(),
        category: j['category']?.toString(),
        id: (j['id'] ?? '').toString(),
      ),
      price: toDouble(j['price']),
      oldPrice: j['oldPrice'] == null ? null : toDouble(j['oldPrice']),
      discountPctApi: j['discountPct'] is num
          ? (j['discountPct'] as num).toInt()
          : int.tryParse('${j['discountPct']}'),
      rating: toDouble(j['rating'], 4.5),
      reviews: (j['reviews'] is num)
          ? (j['reviews'] as num).toInt()
          : int.tryParse('${j['reviews']}') ?? 0,
    );
  }

  List<GroceryItem> _toGroceryItems(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      return GroceryItem(
        (m['name'] ?? '').toString(),
        id: m['id']?.toString(),
        category: m['category']?.toString(),
        quantity: m['quantity'] is num
            ? (m['quantity'] as num).toInt()
            : int.tryParse('${m['quantity']}'),
        image: m['image']?.toString(),
      );
    }).toList();
  }

  String _resolveStoreImage({
    required dynamic imageValue,
    required String name,
    required String? category,
    required String id,
  }) {
    final raw = (imageValue ?? '').toString().trim();
    if (_isValidImageUrl(raw)) return raw;
    return _pickStoreImage(name: name, category: category, id: id);
  }

  bool _isValidImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  String _pickStoreImage({
    required String name,
    required String? category,
    required String id,
  }) {
    final c = (category ?? '').toLowerCase();
    final n = name.toLowerCase();
    final text = '$c $n';

    bool has(List<String> keys) => keys.any(text.contains);

    if (has([
      'fregidaire',
      'frigidaire',
      'réfrigérateur',
      'refrigerateur',
      'réfrigérateur',
      'réfrig',
      'frigo',
    ])) {
      return _fridgeImage;
    }

    if (has([
      'ghasala',
      'غسالة',
      'lave-linge',
      'lave linge',
      'machine a laver',
      'machine à laver',
      'washing machine',
    ])) {
      return _washingMachineImage;
    }

    if (has([
      'gaz',
      'gaziniere',
      'gazinière',
      'cuisiniere',
      'cuisinière',
      'plaque',
      'four',
      'oven',
      'cooker',
    ])) {
      return _gasCookerImage;
    }

    if (has([
      'tv',
      'télé',
      'tele',
      'télévision',
      'television',
      'smart tv',
      'écran',
      'ecran',
    ])) {
      return _tvImage;
    }

    if (has([
      'ma3oun',
      'maoun',
      'plat',
      'assiette',
      'vaisselle',
      'ustensile',
      'casserole',
      'poele',
      'poêle',
      'kitchenware',
      'tableware',
      'service de table',
    ])) {
      return _kitchenwareImage;
    }

    if (has([
      'electro',
      'électro',
      'electron',
      'phone',
      'iphone',
      'smartphone',
      'laptop',
      'pc',
      'ordinateur',
      'mixeur',
      'blender',
      'micro-ondes',
      'micro ondes',
      'machine',
    ])) {
      return _electronicsImage;
    }

    if (has([
      'khodhra',
      'khodra',
      'fruit',
      'frais',
      'légume',
      'legume',
      'pomme',
      'banane',
      'tomate',
      'orange',
      'salade',
    ])) {
      return _freshImage;
    }

    if (has([
      'boisson',
      'eau',
      'jus',
      'soda',
      'cola',
      'café',
      'cafe',
      'thé',
      'the',
    ])) {
      return _beverageImage;
    }

    if (has([
      'lait',
      'yaourt',
      'fromage',
      'beurre',
      'pain',
      'boulangerie',
      'viennoiserie',
    ])) {
      return _dairyBakeryImage;
    }

    if (has([
      'snack',
      'chips',
      'biscuit',
      'chocolat',
      'bonbon',
      'gateau',
      'gâteau',
    ])) {
      return _snacksImage;
    }

    if (has([
      'maison',
      'ménage',
      'menage',
      'nettoyage',
      'lessive',
      'savon',
      'papier',
      'detergent',
      'détergent',
    ])) {
      return _householdImage;
    }

    if (has([
      'epicerie',
      'épicerie',
      'pates',
      'pâtes',
      'riz',
      'semoule',
      'farine',
      'huile',
      'thon',
      'conserve',
    ])) {
      return _groceryImage;
    }

    final pool = <String>[
      _defaultProductImage,
      _freshImage,
      _electronicsImage,
      _fridgeImage,
      _washingMachineImage,
      _gasCookerImage,
      _tvImage,
      _kitchenwareImage,
      _groceryImage,
      _beverageImage,
      _householdImage,
      _dairyBakeryImage,
      _snacksImage,
    ];
    final idx = id.codeUnits.fold<int>(0, (a, b) => a + b) % pool.length;
    return pool[idx];
  }
}
