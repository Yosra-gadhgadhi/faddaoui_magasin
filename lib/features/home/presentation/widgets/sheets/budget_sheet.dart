import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/widgets/pro_sheet.dart';

import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';
import 'smart_search_sheet.dart'; // للـ SearchResultTile

class BudgetSheet extends StatefulWidget {
  const BudgetSheet({super.key});

  @override
  State<BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<BudgetSheet> {
  double _budget = 50;
  bool _loading = false;
  List<Product> _plan = [];

  Future<void> _generate() async {
    setState(() => _loading = true);

    final cubit = context.read<HomeCubit>();
    final catalog = <Product>[
      ...cubit.state.forYou,
      ...cubit.state.deals,
      ...cubit.state.recent,
    ];

    final plan = await cubit.ai.budgetPlan(_budget, catalog);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProSheet(
      title: "Budget Planner 💸",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Budget: ${_budget.toStringAsFixed(0)} DT",
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  "IA",
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
                ),
              ),
            ],
          ),
          Slider(
            value: _budget,
            min: 10,
            max: 200,
            divisions: 19,
            onChanged: (v) => setState(() => _budget = v),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bordeaux,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Générer panier", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 12),
          if (_plan.isNotEmpty)
            ..._plan.map((p) => SearchResultTile(p: p, onTap: () {})),
        ],
      ),
    );
  }
}
