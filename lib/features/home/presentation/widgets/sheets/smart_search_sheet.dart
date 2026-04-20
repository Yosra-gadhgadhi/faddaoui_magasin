import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/pro_sheet.dart';

import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart'; // فيها Product model (ولا import من models)

class SmartSearchSheet extends StatefulWidget {
  const SmartSearchSheet({super.key});

  @override
  State<SmartSearchSheet> createState() => _SmartSearchSheetState();
}

class _SmartSearchSheetState extends State<SmartSearchSheet> {
  final _c = TextEditingController();
  List<Product> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String q) async {
    final cubit = context.read<HomeCubit>();

    setState(() => _loading = true);

    // catalog from state
    final catalog = <Product>[
      ...cubit.state.forYou,
      ...cubit.state.deals,
      ...cubit.state.recent,
    ];

    // smartSearch from AiHomeService
    final res = await cubit.ai.smartSearch(q, catalog);

    if (!mounted) return;
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ProSheet(
        title: "Smart Search",
        child: Column(
          children: [
            TextField(
              controller: _c,
              onChanged: _runSearch,
              decoration: InputDecoration(
                hintText: "Tapez un produit… (ex: lait, pâtes)",
                filled: true,
                fillColor: AppColors.fieldFill,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_results.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  "Commencez à taper. Je propose des résultats même si vous vous trompez.",
                  style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
                ),
              )
            else
              ..._results.map(
                (p) => SearchResultTile(
                  p: p,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.p,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                p.image,
                height: 46,
                width: 46,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 46,
                  width: 46,
                  color: AppColors.soft,
                  child: const Icon(Icons.image_not_supported_rounded, color: AppColors.muted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p.price.toStringAsFixed(2)} DT",
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
