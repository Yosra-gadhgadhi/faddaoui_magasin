import 'package:flutter/widgets.dart';

class _Term {
  final String fr;
  final String en;
  final String ar;
  const _Term(this.fr, this.en, this.ar);
}

const List<_Term> _terms = [
  _Term('Produit', 'Product', 'منتج'),
  _Term('produit', 'product', 'منتج'),
  _Term('Quantité', 'Quantity', 'الكمية'),
  _Term('Panier', 'Cart', 'السلة'),
  _Term('Sélection', 'Selection', 'اختيار'),
  _Term('sélection', 'selection', 'اختيار'),
  _Term('Frigo', 'Fridge', 'ثلاجة'),
  _Term('Ghasala', 'Washing Machine', 'غسالة'),
  _Term('Micro-ondes', 'Microwave', 'ميكروويف'),
  _Term('Gaz', 'Gas Cooker', 'طباخة غاز'),
  _Term('Four', 'Oven', 'فرن'),
  _Term('Électroménager', 'Home Appliances', 'أجهزة منزلية'),
  _Term('TV & Multimédia', 'TV & Multimedia', 'تلفاز ووسائط'),
  _Term('Boissons', 'Drinks', 'مشروبات'),
  _Term('Épicerie', 'Grocery', 'بقالة'),
  _Term('Fruits & Légumes', 'Fruits & Vegetables', 'فواكه وخضر'),
  _Term('Fruits et Legumes', 'Fruits and Vegetables', 'فواكه وخضر'),
  _Term('Produits Laitiers', 'Dairy', 'منتجات ألبان'),
  _Term('Boulangerie', 'Bakery', 'مخبوزات'),
  _Term('Viandes et Poissons', 'Meat and Fish', 'لحوم وأسماك'),
  _Term('Produits Menagers', 'Household Products', 'مواد منزلية'),
  _Term('Hygiene et Beaute', 'Hygiene and Beauty', 'نظافة وجمال'),
  _Term('Tomates', 'Tomatoes', 'طماطم'),
  _Term('Pommes', 'Apples', 'تفاح'),
  _Term('Bananes', 'Bananas', 'موز'),
  _Term('Lait', 'Milk', 'حليب'),
  _Term('Pain', 'Bread', 'خبز'),
  _Term('Yaourt', 'Yogurt', 'ياغورت'),
  _Term('Fromage', 'Cheese', 'جبن'),
  _Term('Huile', 'Oil', 'زيت'),
  _Term('Riz', 'Rice', 'أرز'),
  _Term('Pates', 'Pasta', 'معكرونة'),
  _Term('Pâtes', 'Pasta', 'معكرونة'),
  _Term('Poulet', 'Chicken', 'دجاج'),
  _Term('Thon', 'Tuna', 'تن'),
  _Term('Jus', 'Juice', 'عصير'),
  _Term('Eau', 'Water', 'ماء'),
  _Term('Soda', 'Soda', 'صودا'),
  _Term('Lessive', 'Detergent', 'مسحوق غسيل'),
  _Term('Shampoing', 'Shampoo', 'شامبو'),
];

String localizeProductText(BuildContext context, String text) {
  final lang = Localizations.localeOf(context).languageCode;
  if (lang == 'fr') return text;

  var out = text;
  for (final t in _terms) {
    final replacement = lang == 'ar' ? t.ar : t.en;
    out = out.replaceAll(t.fr, replacement);
  }
  return out;
}

String localizeProductDescription(
  BuildContext context,
  String description, {
  String? productName,
  String? category,
}) {
  final lang = Localizations.localeOf(context).languageCode;
  if (lang == 'fr') return description;

  var out = localizeProductText(context, description);

  final phraseMapEn = <String, String>{
    'produit disponible localement': 'product available locally',
    'les détails backend ne sont pas encore synchronisés pour cet article':
        'backend details are not fully synced yet for this item',
    'description indisponible pour ce produit': 'description unavailable for this product',
    'haute qualité': 'high quality',
    'qualité premium': 'premium quality',
    'prix abordable': 'affordable price',
    'livraison rapide': 'fast delivery',
    'format pratique': 'practical format',
    'idéal pour': 'ideal for',
  };

  final phraseMapAr = <String, String>{
    'produit disponible localement': 'المنتج متوفر محليًا',
    'les détails backend ne sont pas encore synchronisés pour cet article':
        'تفاصيل الخادم غير متزامنة بالكامل لهذا العنصر بعد',
    'description indisponible pour ce produit': 'الوصف غير متاح لهذا المنتج',
    'haute qualité': 'جودة عالية',
    'qualité premium': 'جودة ممتازة',
    'prix abordable': 'سعر مناسب',
    'livraison rapide': 'توصيل سريع',
    'format pratique': 'حجم عملي',
    'idéal pour': 'مثالي لـ',
  };

  final lower = out.toLowerCase();
  final map = lang == 'ar' ? phraseMapAr : phraseMapEn;
  for (final e in map.entries) {
    if (lower.contains(e.key)) {
      out = out.replaceAll(RegExp(e.key, caseSensitive: false), e.value);
    }
  }

  if (out.trim() == description.trim()) {
    if (lang == 'ar') {
      return 'منتج ${productName ?? ''} من قسم ${category ?? 'الكتالوج'}، بجودة ممتازة وسعر مناسب.';
    }
    return 'Product ${productName ?? ''} from ${category ?? 'catalog'}, with good quality and fair price.';
  }

  return out;
}
