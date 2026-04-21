import 'package:flutter/material.dart';
import 'package:elfaddoui_app/core/l10n/tr3.dart';
import 'package:elfaddoui_app/core/l10n/product_text_localizer.dart';
import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

class ProductListScreen extends StatelessWidget {
  final String? categoryName;
  const ProductListScreen({super.key, this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          categoryName != null
              ? tr3(
                  context,
                  fr: "Produits: ${localizeProductText(context, categoryName!)}",
                  en: "Products: ${localizeProductText(context, categoryName!)}",
                  ar: "المنتجات: ${localizeProductText(context, categoryName!)}",
                )
              : tr3(context, fr: "Tous les produits", en: "All products", ar: "كل المنتجات"),
          style: AppTextStyles.h2.copyWith(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        actions: [
          _TopIconBtn(icon: Icons.tune_rounded, onTap: () {}),
          const SizedBox(width: 8),
          _TopIconBtn(icon: Icons.sort_rounded, onTap: () {}),
          const SizedBox(width: 12),
        ],
      ),

      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.70,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _ProductCard(
            name: tr3(
              context,
              fr: "Produit ${index + 1}",
              en: "Product ${index + 1}",
              ar: "منتج ${index + 1}",
            ),
            desc: tr3(
              context,
              fr: "Description courte du produit ${index + 1}.",
              en: "Short product description ${index + 1}.",
              ar: "وصف قصير للمنتج ${index + 1}.",
            ),
            price: (10 + index * 2).toDouble(),
            image:
                'https://images.pexels.com/photos/4050347/pexels-photo-4050347.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
            onTap: () {
              // TODO: open ProductDetailsScreen
            },
            onAdd: () {},
          );
        },
      ),
    );
  }
}

class _TopIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.soft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String desc;
  final double price;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.soft,
                    child: const Icon(Icons.image_not_supported_rounded, color: AppColors.muted),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Text(desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text("${price.toStringAsFixed(2)} DT",
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux)),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onAdd,
                        child: Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.bordeaux, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
