// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:flutter_bloc/flutter_bloc.dart';

// // // // // // // import 'package:elfaddoui_app/core/theme/app_colors.dart';
// // // // // // // import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// // // // // // // import '../../cubit/grocery_list_cubit.dart';
// // // // // // // import '../../cubit/grocery_list_state.dart';

// // // // // // // class GroceryListScreen extends StatelessWidget {
// // // // // // //   const GroceryListScreen({super.key});

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return BlocProvider(
// // // // // // //       create: (_) => GroceryListCubit(),
// // // // // // //       child: const _GroceryListView(),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class _GroceryListView extends StatelessWidget {
// // // // // // //   const _GroceryListView();

// // // // // // //   void _openAdd(BuildContext context) {
// // // // // // //     final c = TextEditingController();
// // // // // // //     showModalBottomSheet(
// // // // // // //       context: context,
// // // // // // //       backgroundColor: Colors.transparent,
// // // // // // //       isScrollControlled: true,
// // // // // // //       builder: (_) {
// // // // // // //         return Padding(
// // // // // // //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// // // // // // //           child: _ProSheet(
// // // // // // //             title: "Ajouter un item",
// // // // // // //             child: Column(
// // // // // // //               children: [
// // // // // // //                 TextField(
// // // // // // //                   controller: c,
// // // // // // //                   decoration: InputDecoration(
// // // // // // //                     hintText: "Ex: Lait, Pain, Pâtes...",
// // // // // // //                     filled: true,
// // // // // // //                     fillColor: AppColors.fieldFill,
// // // // // // //                     border: OutlineInputBorder(
// // // // // // //                       borderRadius: BorderRadius.circular(16),
// // // // // // //                       borderSide: BorderSide(color: AppColors.border),
// // // // // // //                     ),
// // // // // // //                     enabledBorder: OutlineInputBorder(
// // // // // // //                       borderRadius: BorderRadius.circular(16),
// // // // // // //                       borderSide: BorderSide(color: AppColors.border),
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //                 const SizedBox(height: 12),
// // // // // // //                 SizedBox(
// // // // // // //                   height: 48,
// // // // // // //                   width: double.infinity,
// // // // // // //                   child: ElevatedButton(
// // // // // // //                     onPressed: () {
// // // // // // //                       final txt = c.text.trim();
// // // // // // //                       if (txt.isNotEmpty) context.read<GroceryListCubit>().addItem(txt);
// // // // // // //                       Navigator.pop(context);
// // // // // // //                     },
// // // // // // //                     style: ElevatedButton.styleFrom(
// // // // // // //                       backgroundColor: AppColors.bordeaux,
// // // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // // // // //                       elevation: 0,
// // // // // // //                     ),
// // // // // // //                     child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w900)),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         );
// // // // // // //       },
// // // // // // //     );
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       backgroundColor: Colors.white,
// // // // // // //       appBar: AppBar(
// // // // // // //         backgroundColor: Colors.white,
// // // // // // //         surfaceTintColor: Colors.transparent,
// // // // // // //         elevation: 0,
// // // // // // //         title: Text("📝 Liste de courses", style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text)),
// // // // // // //         actions: [
// // // // // // //           InkWell(
// // // // // // //             borderRadius: BorderRadius.circular(14),
// // // // // // //             onTap: () => context.read<GroceryListCubit>().clearDone(),
// // // // // // //             child: Container(
// // // // // // //               margin: const EdgeInsets.only(right: 12),
// // // // // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // // // // //               decoration: BoxDecoration(
// // // // // // //                 color: AppColors.soft,
// // // // // // //                 borderRadius: BorderRadius.circular(14),
// // // // // // //                 border: Border.all(color: AppColors.border),
// // // // // // //               ),
// // // // // // //               child: const Text("Nettoyer", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux)),
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //       floatingActionButton: FloatingActionButton(
// // // // // // //         backgroundColor: AppColors.bordeaux,
// // // // // // //         elevation: 0,
// // // // // // //         onPressed: () => _openAdd(context),
// // // // // // //         child: const Icon(Icons.add_rounded, color: Colors.white),
// // // // // // //       ),
// // // // // // //       body: BlocBuilder<GroceryListCubit, GroceryListState>(
// // // // // // //         builder: (context, s) {
// // // // // // //           return ListView(
// // // // // // //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
// // // // // // //             children: [
// // // // // // //               // Suggestions “IA”
// // // // // // //               if (s.suggestions.isNotEmpty) ...[
// // // // // // //                 _SectionHeader(title: "✨ Suggestions IA", actionText: "Ajouter", onAction: () {}),
// // // // // // //                 const SizedBox(height: 10),
// // // // // // //                 Wrap(
// // // // // // //                   spacing: 10,
// // // // // // //                   runSpacing: 10,
// // // // // // //                   children: s.suggestions.map((x) {
// // // // // // //                     return InkWell(
// // // // // // //                       borderRadius: BorderRadius.circular(999),
// // // // // // //                       onTap: () => context.read<GroceryListCubit>().addItem(x),
// // // // // // //                       child: Container(
// // // // // // //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // // // // //                         decoration: BoxDecoration(
// // // // // // //                           color: AppColors.soft,
// // // // // // //                           borderRadius: BorderRadius.circular(999),
// // // // // // //                           border: Border.all(color: AppColors.border),
// // // // // // //                         ),
// // // // // // //                         child: Row(
// // // // // // //                           mainAxisSize: MainAxisSize.min,
// // // // // // //                           children: [
// // // // // // //                             const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.bordeaux),
// // // // // // //                             const SizedBox(width: 8),
// // // // // // //                             Text(x, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
// // // // // // //                           ],
// // // // // // //                         ),
// // // // // // //                       ),
// // // // // // //                     );
// // // // // // //                   }).toList(),
// // // // // // //                 ),
// // // // // // //                 const SizedBox(height: 16),
// // // // // // //               ],

// // // // // // //               _SectionHeader(
// // // // // // //                 title: "Votre liste",
// // // // // // //                 actionText: "Ajouter",
// // // // // // //                 onAction: () => _openAdd(context),
// // // // // // //               ),
// // // // // // //               const SizedBox(height: 10),

// // // // // // //               if (s.items.isEmpty)
// // // // // // //                 Container(
// // // // // // //                   padding: const EdgeInsets.all(14),
// // // // // // //                   decoration: BoxDecoration(
// // // // // // //                     color: AppColors.soft,
// // // // // // //                     borderRadius: BorderRadius.circular(18),
// // // // // // //                     border: Border.all(color: AppColors.border),
// // // // // // //                   ),
// // // // // // //                   child: const Text(
// // // // // // //                     "Votre liste est vide. Ajoutez des produits ✨",
// // // // // // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // // // // //                   ),
// // // // // // //                 )
// // // // // // //               else
// // // // // // //                 ...List.generate(s.items.length, (i) {
// // // // // // //                   final it = s.items[i];
// // // // // // //                   return _ListTile(
// // // // // // //                     item: it,
// // // // // // //                     onToggle: () => context.read<GroceryListCubit>().toggleItem(i),
// // // // // // //                     onRemove: () => context.read<GroceryListCubit>().removeItem(i),
// // // // // // //                   );
// // // // // // //                 }),
// // // // // // //             ],
// // // // // // //           );
// // // // // // //         },
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // // ---------------- Widgets ----------------

// // // // // // // class _ListTile extends StatelessWidget {
// // // // // // //   final GroceryItem item;
// // // // // // //   final VoidCallback onToggle;
// // // // // // //   final VoidCallback onRemove;

// // // // // // //   const _ListTile({
// // // // // // //     required this.item,
// // // // // // //     required this.onToggle,
// // // // // // //     required this.onRemove,
// // // // // // //   });

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return InkWell(
// // // // // // //       borderRadius: BorderRadius.circular(16),
// // // // // // //       onTap: onToggle,
// // // // // // //       child: Container(
// // // // // // //         padding: const EdgeInsets.all(12),
// // // // // // //         margin: const EdgeInsets.only(bottom: 10),
// // // // // // //         decoration: BoxDecoration(
// // // // // // //           color: Colors.white,
// // // // // // //           borderRadius: BorderRadius.circular(16),
// // // // // // //           border: Border.all(color: AppColors.border),
// // // // // // //         ),
// // // // // // //         child: Row(
// // // // // // //           children: [
// // // // // // //             Container(
// // // // // // //               height: 34,
// // // // // // //               width: 34,
// // // // // // //               decoration: BoxDecoration(
// // // // // // //                 color: AppColors.soft,
// // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // //                 border: Border.all(color: AppColors.border),
// // // // // // //               ),
// // // // // // //               child: Icon(
// // // // // // //                 item.done ? Icons.check_rounded : Icons.circle_outlined,
// // // // // // //                 color: item.done ? AppColors.bordeaux : AppColors.muted,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             const SizedBox(width: 12),
// // // // // // //             Expanded(
// // // // // // //               child: Text(
// // // // // // //                 item.name,
// // // // // // //                 style: TextStyle(
// // // // // // //                   fontWeight: FontWeight.w900,
// // // // // // //                   color: item.done ? AppColors.muted : AppColors.text,
// // // // // // //                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             InkWell(
// // // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // // //               onTap: onRemove,
// // // // // // //               child: Container(
// // // // // // //                 height: 34,
// // // // // // //                 width: 34,
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: Colors.white,
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                   border: Border.all(color: AppColors.border),
// // // // // // //                 ),
// // // // // // //                 child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class _SectionHeader extends StatelessWidget {
// // // // // // //   final String title;
// // // // // // //   final String actionText;
// // // // // // //   final VoidCallback onAction;

// // // // // // //   const _SectionHeader({
// // // // // // //     required this.title,
// // // // // // //     required this.actionText,
// // // // // // //     required this.onAction,
// // // // // // //   });

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Row(
// // // // // // //       children: [
// // // // // // //         Expanded(
// // // // // // //           child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text)),
// // // // // // //         ),
// // // // // // //         InkWell(
// // // // // // //           borderRadius: BorderRadius.circular(12),
// // // // // // //           onTap: onAction,
// // // // // // //           child: Container(
// // // // // // //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// // // // // // //             decoration: BoxDecoration(
// // // // // // //               color: AppColors.soft,
// // // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // // //               border: Border.all(color: AppColors.border),
// // // // // // //             ),
// // // // // // //             child: Text(
// // // // // // //               actionText,
// // // // // // //               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ],
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class _ProSheet extends StatelessWidget {
// // // // // // //   final String title;
// // // // // // //   final Widget child;
// // // // // // //   const _ProSheet({required this.title, required this.child});

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Container(
// // // // // // //       margin: const EdgeInsets.all(12),
// // // // // // //       padding: const EdgeInsets.all(14),
// // // // // // //       decoration: BoxDecoration(
// // // // // // //         color: Colors.white,
// // // // // // //         borderRadius: BorderRadius.circular(22),
// // // // // // //         border: Border.all(color: AppColors.border),
// // // // // // //         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 22, offset: const Offset(0, 12))],
// // // // // // //       ),
// // // // // // //       child: SafeArea(
// // // // // // //         top: false,
// // // // // // //         child: Column(
// // // // // // //           mainAxisSize: MainAxisSize.min,
// // // // // // //           children: [
// // // // // // //             Container(height: 4, width: 46, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999))),
// // // // // // //             const SizedBox(height: 12),
// // // // // // //             Row(
// // // // // // //               children: [
// // // // // // //                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
// // // // // // //                 InkWell(
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                   onTap: () => Navigator.pop(context),
// // // // // // //                   child: Container(
// // // // // // //                     height: 36,
// // // // // // //                     width: 36,
// // // // // // //                     decoration: BoxDecoration(
// // // // // // //                       color: AppColors.soft,
// // // // // // //                       borderRadius: BorderRadius.circular(14),
// // // // // // //                       border: Border.all(color: AppColors.border),
// // // // // // //                     ),
// // // // // // //                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //             const SizedBox(height: 14),
// // // // // // //             child,
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter_bloc/flutter_bloc.dart';

// // // // // // import 'package:elfaddoui_app/core/theme/app_colors.dart';
// // // // // // import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// // // // // // import '../../cubit/grocery_list_cubit.dart';
// // // // // // import '../../cubit/grocery_list_state.dart';

// // // // // // class GroceryListScreen extends StatelessWidget {
// // // // // //   const GroceryListScreen({super.key});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return BlocProvider(
// // // // // //       create: (_) => GroceryListCubit(),
// // // // // //       child: const _GroceryListView(),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class _GroceryListView extends StatefulWidget {
// // // // // //   const _GroceryListView();

// // // // // //   @override
// // // // // //   State<_GroceryListView> createState() => _GroceryListViewState();
// // // // // // }

// // // // // // class _GroceryListViewState extends State<_GroceryListView> {
// // // // // //   final _search = TextEditingController();

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _search.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   void _openAdd(BuildContext context) {
// // // // // //     final c = TextEditingController();
// // // // // //     showModalBottomSheet(
// // // // // //       context: context,
// // // // // //       backgroundColor: Colors.transparent,
// // // // // //       isScrollControlled: true,
// // // // // //       builder: (_) {
// // // // // //         return Padding(
// // // // // //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// // // // // //           child: _ProSheet(
// // // // // //             title: "Ajouter un item",
// // // // // //             child: Column(
// // // // // //               children: [
// // // // // //                 TextField(
// // // // // //                   controller: c,
// // // // // //                   decoration: InputDecoration(
// // // // // //                     hintText: "Ex: Lait, Pain, Pâtes...",
// // // // // //                     filled: true,
// // // // // //                     fillColor: AppColors.fieldFill,
// // // // // //                     border: OutlineInputBorder(
// // // // // //                       borderRadius: BorderRadius.circular(16),
// // // // // //                       borderSide: BorderSide(color: AppColors.border),
// // // // // //                     ),
// // // // // //                     enabledBorder: OutlineInputBorder(
// // // // // //                       borderRadius: BorderRadius.circular(16),
// // // // // //                       borderSide: BorderSide(color: AppColors.border),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 12),
// // // // // //                 SizedBox(
// // // // // //                   height: 48,
// // // // // //                   width: double.infinity,
// // // // // //                   child: ElevatedButton(
// // // // // //                     onPressed: () {
// // // // // //                       final txt = c.text.trim();
// // // // // //                       if (txt.isNotEmpty) context.read<GroceryListCubit>().addItem(txt);
// // // // // //                       Navigator.pop(context);
// // // // // //                     },
// // // // // //                     style: ElevatedButton.styleFrom(
// // // // // //                       backgroundColor: AppColors.bordeaux,
// // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // // // //                       elevation: 0,
// // // // // //                     ),
// // // // // //                     child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w900)),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //         );
// // // // // //       },
// // // // // //     ).whenComplete(() => c.dispose());
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       backgroundColor: Colors.white,

// // // // // //       appBar: AppBar(
// // // // // //         backgroundColor: Colors.white,
// // // // // //         surfaceTintColor: Colors.transparent,
// // // // // //         elevation: 0,
// // // // // //         title: Text(
// // // // // //           "📝 Liste de courses",
// // // // // //           style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// // // // // //         ),
// // // // // //         actions: [
// // // // // //           InkWell(
// // // // // //             borderRadius: BorderRadius.circular(14),
// // // // // //             onTap: () => context.read<GroceryListCubit>().clearDone(),
// // // // // //             child: Container(
// // // // // //               margin: const EdgeInsets.only(right: 12),
// // // // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // // // //               decoration: BoxDecoration(
// // // // // //                 color: AppColors.soft,
// // // // // //                 borderRadius: BorderRadius.circular(14),
// // // // // //                 border: Border.all(color: AppColors.border),
// // // // // //               ),
// // // // // //               child: const Text(
// // // // // //                 "Nettoyer",
// // // // // //                 style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),

// // // // // //       floatingActionButton: FloatingActionButton(
// // // // // //         heroTag: "grocery_fab", // ✅ يمنع hero conflict
// // // // // //         backgroundColor: AppColors.bordeaux,
// // // // // //         elevation: 0,
// // // // // //         onPressed: () => _openAdd(context),
// // // // // //         child: const Icon(Icons.add_rounded, color: Colors.white),
// // // // // //       ),

// // // // // //       body: BlocBuilder<GroceryListCubit, GroceryListState>(
// // // // // //         builder: (context, s) {
// // // // // //           // ✅ Search filter
// // // // // //           final q = _search.text.trim().toLowerCase();
// // // // // //           final filteredItems = s.items.where((it) {
// // // // // //             if (q.isEmpty) return true;
// // // // // //             return it.name.toLowerCase().contains(q);
// // // // // //           }).toList();

// // // // // //           // ✅ progress
// // // // // //           final total = s.items.length;
// // // // // //           final done = s.items.where((x) => x.done).length;
// // // // // //           final progress = total == 0 ? 0.0 : (done / total);

// // // // // //           return ListView(
// // // // // //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
// // // // // //             children: [
// // // // // //               // ✅ Progress header
// // // // // //               Container(
// // // // // //                 padding: const EdgeInsets.all(14),
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   color: AppColors.soft,
// // // // // //                   borderRadius: BorderRadius.circular(18),
// // // // // //                   border: Border.all(color: AppColors.border),
// // // // // //                 ),
// // // // // //                 child: Column(
// // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                   children: [
// // // // // //                     Row(
// // // // // //                       children: [
// // // // // //                         Expanded(
// // // // // //                           child: Text(
// // // // // //                             "Progress",
// // // // // //                             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         Text(
// // // // // //                           "$done / $total",
// // // // // //                           style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                     const SizedBox(height: 10),
// // // // // //                     ClipRRect(
// // // // // //                       borderRadius: BorderRadius.circular(999),
// // // // // //                       child: LinearProgressIndicator(
// // // // // //                         value: progress,
// // // // // //                         minHeight: 10,
// // // // // //                         backgroundColor: Colors.white,
// // // // // //                         color: AppColors.bordeaux,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),

// // // // // //               const SizedBox(height: 12),

// // // // // //               // ✅ Search bar
// // // // // //               _SearchBar(
// // // // // //                 controller: _search,
// // // // // //                 onClear: () => setState(() => _search.clear()),
// // // // // //               ),

// // // // // //               const SizedBox(height: 16),

// // // // // //               // Suggestions “IA”
// // // // // //               if (s.suggestions.isNotEmpty) ...[
// // // // // //                 _SectionHeader(
// // // // // //                   title: "✨ Suggestions IA",
// // // // // //                   actionText: "Tout ajouter",
// // // // // //                   onAction: () {
// // // // // //                     for (final x in s.suggestions) {
// // // // // //                       context.read<GroceryListCubit>().addItem(x);
// // // // // //                     }
// // // // // //                   },
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 10),
// // // // // //                 Wrap(
// // // // // //                   spacing: 10,
// // // // // //                   runSpacing: 10,
// // // // // //                   children: s.suggestions.map((x) {
// // // // // //                     return InkWell(
// // // // // //                       borderRadius: BorderRadius.circular(999),
// // // // // //                       onTap: () => context.read<GroceryListCubit>().addItem(x),
// // // // // //                       child: Container(
// // // // // //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // // // //                         decoration: BoxDecoration(
// // // // // //                           color: AppColors.soft,
// // // // // //                           borderRadius: BorderRadius.circular(999),
// // // // // //                           border: Border.all(color: AppColors.border),
// // // // // //                         ),
// // // // // //                         child: Row(
// // // // // //                           mainAxisSize: MainAxisSize.min,
// // // // // //                           children: [
// // // // // //                             const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.bordeaux),
// // // // // //                             const SizedBox(width: 8),
// // // // // //                             Text(x, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
// // // // // //                           ],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     );
// // // // // //                   }).toList(),
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 16),
// // // // // //               ],

// // // // // //               _SectionHeader(
// // // // // //                 title: "Votre liste",
// // // // // //                 actionText: "Ajouter",
// // // // // //                 onAction: () => _openAdd(context),
// // // // // //               ),
// // // // // //               const SizedBox(height: 10),

// // // // // //               if (s.items.isEmpty)
// // // // // //                 Container(
// // // // // //                   padding: const EdgeInsets.all(14),
// // // // // //                   decoration: BoxDecoration(
// // // // // //                     color: AppColors.soft,
// // // // // //                     borderRadius: BorderRadius.circular(18),
// // // // // //                     border: Border.all(color: AppColors.border),
// // // // // //                   ),
// // // // // //                   child: const Text(
// // // // // //                     "Votre liste est vide. Ajoutez des produits ✨",
// // // // // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // // // //                   ),
// // // // // //                 )
// // // // // //               else if (filteredItems.isEmpty)
// // // // // //                 Container(
// // // // // //                   padding: const EdgeInsets.all(14),
// // // // // //                   decoration: BoxDecoration(
// // // // // //                     color: AppColors.soft,
// // // // // //                     borderRadius: BorderRadius.circular(18),
// // // // // //                     border: Border.all(color: AppColors.border),
// // // // // //                   ),
// // // // // //                   child: const Text(
// // // // // //                     "Aucun résultat pour cette recherche.",
// // // // // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // // // //                   ),
// // // // // //                 )
// // // // // //               else
// // // // // //                 ...List.generate(filteredItems.length, (i) {
// // // // // //                   final it = filteredItems[i];

// // // // // //                   // لازم نرجّع index الحقيقي من s.items
// // // // // //                   final realIndex = s.items.indexOf(it);

// // // // // //                   return Dismissible(
// // // // // //                     key: ValueKey("${it.name}-$realIndex"),
// // // // // //                     direction: DismissDirection.endToStart,
// // // // // //                     background: Container(
// // // // // //                       margin: const EdgeInsets.only(bottom: 10),
// // // // // //                       padding: const EdgeInsets.symmetric(horizontal: 16),
// // // // // //                       alignment: Alignment.centerRight,
// // // // // //                       decoration: BoxDecoration(
// // // // // //                         color: AppColors.bordeaux.withValues(alpha: 0.12),
// // // // // //                         borderRadius: BorderRadius.circular(16),
// // // // // //                         border: Border.all(color: AppColors.border),
// // // // // //                       ),
// // // // // //                       child: const Icon(Icons.delete_outline_rounded, color: AppColors.bordeaux),
// // // // // //                     ),
// // // // // //                     onDismissed: (_) => context.read<GroceryListCubit>().removeItem(realIndex),
// // // // // //                     child: _ListTile(
// // // // // //                       item: it,
// // // // // //                       onToggle: () => context.read<GroceryListCubit>().toggleItem(realIndex),
// // // // // //                       onRemove: () => context.read<GroceryListCubit>().removeItem(realIndex),
// // // // // //                     ),
// // // // // //                   );
// // // // // //                 }),
// // // // // //             ],
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // ---------------- Widgets ----------------

// // // // // // class _SearchBar extends StatelessWidget {
// // // // // //   final TextEditingController controller;
// // // // // //   final VoidCallback onClear;

// // // // // //   const _SearchBar({required this.controller, required this.onClear});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Container(
// // // // // //       height: 54,
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: AppColors.fieldFill,
// // // // // //         borderRadius: BorderRadius.circular(18),
// // // // // //         border: Border.all(color: AppColors.border),
// // // // // //       ),
// // // // // //       child: Row(
// // // // // //         children: [
// // // // // //           const SizedBox(width: 12),
// // // // // //           const Icon(Icons.search_rounded, color: AppColors.muted),
// // // // // //           const SizedBox(width: 10),
// // // // // //           Expanded(
// // // // // //             child: TextField(
// // // // // //               controller: controller,
// // // // // //               onChanged: (_) => (context as Element).markNeedsBuild(), // simple refresh
// // // // // //               style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
// // // // // //               decoration: const InputDecoration(
// // // // // //                 hintText: "Rechercher dans la liste…",
// // // // // //                 hintStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // // // //                 border: InputBorder.none,
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //           if (controller.text.isNotEmpty)
// // // // // //             IconButton(
// // // // // //               onPressed: onClear,
// // // // // //               icon: const Icon(Icons.close_rounded, color: AppColors.muted),
// // // // // //             ),
// // // // // //           const SizedBox(width: 6),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class _ListTile extends StatelessWidget {
// // // // // //   final GroceryItem item;
// // // // // //   final VoidCallback onToggle;
// // // // // //   final VoidCallback onRemove;

// // // // // //   const _ListTile({
// // // // // //     required this.item,
// // // // // //     required this.onToggle,
// // // // // //     required this.onRemove,
// // // // // //   });

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return InkWell(
// // // // // //       borderRadius: BorderRadius.circular(16),
// // // // // //       onTap: onToggle,
// // // // // //       child: Container(
// // // // // //         padding: const EdgeInsets.all(12),
// // // // // //         margin: const EdgeInsets.only(bottom: 10),
// // // // // //         decoration: BoxDecoration(
// // // // // //           color: Colors.white,
// // // // // //           borderRadius: BorderRadius.circular(16),
// // // // // //           border: Border.all(color: AppColors.border),
// // // // // //         ),
// // // // // //         child: Row(
// // // // // //           children: [
// // // // // //             Container(
// // // // // //               height: 34,
// // // // // //               width: 34,
// // // // // //               decoration: BoxDecoration(
// // // // // //                 color: AppColors.soft,
// // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // //                 border: Border.all(color: AppColors.border),
// // // // // //               ),
// // // // // //               child: Icon(
// // // // // //                 item.done ? Icons.check_rounded : Icons.circle_outlined,
// // // // // //                 color: item.done ? AppColors.bordeaux : AppColors.muted,
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(width: 12),
// // // // // //             Expanded(
// // // // // //               child: Text(
// // // // // //                 item.name,
// // // // // //                 style: TextStyle(
// // // // // //                   fontWeight: FontWeight.w900,
// // // // // //                   color: item.done ? AppColors.muted : AppColors.text,
// // // // // //                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //             InkWell(
// // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // //               onTap: onRemove,
// // // // // //               child: Container(
// // // // // //                 height: 34,
// // // // // //                 width: 34,
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   color: Colors.white,
// // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // //                   border: Border.all(color: AppColors.border),
// // // // // //                 ),
// // // // // //                 child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
// // // // // //               ),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class _SectionHeader extends StatelessWidget {
// // // // // //   final String title;
// // // // // //   final String actionText;
// // // // // //   final VoidCallback onAction;

// // // // // //   const _SectionHeader({
// // // // // //     required this.title,
// // // // // //     required this.actionText,
// // // // // //     required this.onAction,
// // // // // //   });

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Row(
// // // // // //       children: [
// // // // // //         Expanded(
// // // // // //           child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text)),
// // // // // //         ),
// // // // // //         InkWell(
// // // // // //           borderRadius: BorderRadius.circular(12),
// // // // // //           onTap: onAction,
// // // // // //           child: Container(
// // // // // //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// // // // // //             decoration: BoxDecoration(
// // // // // //               color: AppColors.soft,
// // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // //               border: Border.all(color: AppColors.border),
// // // // // //             ),
// // // // // //             child: Text(
// // // // // //               actionText,
// // // // // //               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class _ProSheet extends StatelessWidget {
// // // // // //   final String title;
// // // // // //   final Widget child;
// // // // // //   const _ProSheet({required this.title, required this.child});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Container(
// // // // // //       margin: const EdgeInsets.all(12),
// // // // // //       padding: const EdgeInsets.all(14),
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: Colors.white,
// // // // // //         borderRadius: BorderRadius.circular(22),
// // // // // //         border: Border.all(color: AppColors.border),
// // // // // //         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 22, offset: const Offset(0, 12))],
// // // // // //       ),
// // // // // //       child: SafeArea(
// // // // // //         top: false,
// // // // // //         child: Column(
// // // // // //           mainAxisSize: MainAxisSize.min,
// // // // // //           children: [
// // // // // //             Container(
// // // // // //               height: 4,
// // // // // //               width: 46,
// // // // // //               decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
// // // // // //             ),
// // // // // //             const SizedBox(height: 12),
// // // // // //             Row(
// // // // // //               children: [
// // // // // //                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
// // // // // //                 InkWell(
// // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // //                   onTap: () => Navigator.pop(context),
// // // // // //                   child: Container(
// // // // // //                     height: 36,
// // // // // //                     width: 36,
// // // // // //                     decoration: BoxDecoration(
// // // // // //                       color: AppColors.soft,
// // // // // //                       borderRadius: BorderRadius.circular(14),
// // // // // //                       border: Border.all(color: AppColors.border),
// // // // // //                     ),
// // // // // //                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //             const SizedBox(height: 14),
// // // // // //             child,
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter_bloc/flutter_bloc.dart';

// // // // // import 'package:elfaddoui_app/core/theme/app_colors.dart';
// // // // // import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// // // // // import '../../cubit/grocery_list_cubit.dart';
// // // // // import '../../cubit/grocery_list_state.dart';

// // // // // class GroceryListScreen extends StatelessWidget {
// // // // //   const GroceryListScreen({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return BlocProvider(
// // // // //       create: (_) => GroceryListCubit(),
// // // // //       child: const _GroceryListView(),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _GroceryListView extends StatefulWidget {
// // // // //   const _GroceryListView();

// // // // //   @override
// // // // //   State<_GroceryListView> createState() => _GroceryListViewState();
// // // // // }

// // // // // class _GroceryListViewState extends State<_GroceryListView> {
// // // // //   final _search = TextEditingController();

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _search.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   void _openAdd(BuildContext context) {
// // // // //     final c = TextEditingController();
// // // // //     showModalBottomSheet(
// // // // //       context: context,
// // // // //       backgroundColor: Colors.transparent,
// // // // //       isScrollControlled: true,
// // // // //       builder: (_) {
// // // // //         return Padding(
// // // // //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// // // // //           child: _ProSheet(
// // // // //             title: "Ajouter un item",
// // // // //             child: Column(
// // // // //               children: [
// // // // //                 TextField(
// // // // //                   controller: c,
// // // // //                   autofocus: true,
// // // // //                   decoration: InputDecoration(
// // // // //                     hintText: "Ex: Lait, Pain, Pâtes...",
// // // // //                     filled: true,
// // // // //                     fillColor: AppColors.fieldFill,
// // // // //                     border: OutlineInputBorder(
// // // // //                       borderRadius: BorderRadius.circular(16),
// // // // //                       borderSide: BorderSide(color: AppColors.border),
// // // // //                     ),
// // // // //                     enabledBorder: OutlineInputBorder(
// // // // //                       borderRadius: BorderRadius.circular(16),
// // // // //                       borderSide: BorderSide(color: AppColors.border),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(height: 12),
// // // // //                 SizedBox(
// // // // //                   height: 48,
// // // // //                   width: double.infinity,
// // // // //                   child: ElevatedButton(
// // // // //                     onPressed: () {
// // // // //                       final txt = c.text.trim();
// // // // //                       if (txt.isNotEmpty) context.read<GroceryListCubit>().addItem(txt);
// // // // //                       Navigator.pop(context);
// // // // //                     },
// // // // //                     style: ElevatedButton.styleFrom(
// // // // //                       backgroundColor: AppColors.bordeaux,
// // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // // //                       elevation: 0,
// // // // //                     ),
// // // // //                     child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w900)),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         );
// // // // //       },
// // // // //     ).whenComplete(() => c.dispose());
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: Colors.white,

// // // // //       appBar: AppBar(
// // // // //         backgroundColor: Colors.white,
// // // // //         surfaceTintColor: Colors.transparent,
// // // // //         elevation: 0,
// // // // //         title: Text(
// // // // //           "📝 Liste de courses",
// // // // //           style: AppTextStyles.h3.copyWith(
// // // // //             fontWeight: FontWeight.w900,
// // // // //             color: AppColors.text,
// // // // //           ),
// // // // //         ),
// // // // //         actions: [
// // // // //           InkWell(
// // // // //             borderRadius: BorderRadius.circular(14),
// // // // //             onTap: () => context.read<GroceryListCubit>().clearDone(),
// // // // //             child: Container(
// // // // //               margin: const EdgeInsets.only(right: 12),
// // // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // // //               decoration: BoxDecoration(
// // // // //                 color: AppColors.soft,
// // // // //                 borderRadius: BorderRadius.circular(14),
// // // // //                 border: Border.all(color: AppColors.border),
// // // // //               ),
// // // // //               child: const Text(
// // // // //                 "Nettoyer",
// // // // //                 style: TextStyle(
// // // // //                   fontWeight: FontWeight.w900,
// // // // //                   color: AppColors.bordeaux,
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),

// // // // //       floatingActionButton: FloatingActionButton(
// // // // //         heroTag: "grocery_fab",
// // // // //         backgroundColor: AppColors.bordeaux,
// // // // //         elevation: 0,
// // // // //         onPressed: () => _openAdd(context),
// // // // //         child: const Icon(Icons.add_rounded, color: Colors.white),
// // // // //       ),

// // // // //       body: BlocBuilder<GroceryListCubit, GroceryListState>(
// // // // //         builder: (context, s) {
// // // // //           final q = _search.text.trim().toLowerCase();

// // // // //           final filtered = s.items.where((it) {
// // // // //             if (q.isEmpty) return true;
// // // // //             return it.name.toLowerCase().contains(q);
// // // // //           }).toList();

// // // // //           final total = s.items.length;
// // // // //           final done = s.items.where((x) => x.done).length;
// // // // //           final progress = total == 0 ? 0.0 : done / total;

// // // // //           return ListView(
// // // // //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
// // // // //             children: [
// // // // //               _ProgressCard(done: done, total: total, progress: progress),
// // // // //               const SizedBox(height: 12),

// // // // //               _SearchBar(
// // // // //                 controller: _search,
// // // // //                 onChanged: () => setState(() {}),
// // // // //                 onClear: () => setState(() => _search.clear()),
// // // // //               ),

// // // // //               const SizedBox(height: 16),

// // // // //               if (s.suggestions.isNotEmpty) ...[
// // // // //                 _SectionHeader(
// // // // //                   title: "✨ Suggestions IA",
// // // // //                   actionText: "Tout ajouter",
// // // // //                   onAction: () => context.read<GroceryListCubit>().addAllSuggestions(),
// // // // //                 ),
// // // // //                 const SizedBox(height: 10),
// // // // //                 Wrap(
// // // // //                   spacing: 10,
// // // // //                   runSpacing: 10,
// // // // //                   children: s.suggestions.map((x) {
// // // // //                     return InkWell(
// // // // //                       borderRadius: BorderRadius.circular(999),
// // // // //                       onTap: () => context.read<GroceryListCubit>().addItem(x),
// // // // //                       child: Container(
// // // // //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // // //                         decoration: BoxDecoration(
// // // // //                           color: AppColors.soft,
// // // // //                           borderRadius: BorderRadius.circular(999),
// // // // //                           border: Border.all(color: AppColors.border),
// // // // //                         ),
// // // // //                         child: Row(
// // // // //                           mainAxisSize: MainAxisSize.min,
// // // // //                           children: [
// // // // //                             const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.bordeaux),
// // // // //                             const SizedBox(width: 8),
// // // // //                             Text(
// // // // //                               x,
// // // // //                               style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                     );
// // // // //                   }).toList(),
// // // // //                 ),
// // // // //                 const SizedBox(height: 16),
// // // // //               ],

// // // // //               _SectionHeader(
// // // // //                 title: "Votre liste",
// // // // //                 actionText: "Ajouter",
// // // // //                 onAction: () => _openAdd(context),
// // // // //               ),
// // // // //               const SizedBox(height: 10),

// // // // //               if (s.items.isEmpty)
// // // // //                 _EmptyBox(text: "Votre liste est vide. Ajoutez des produits ✨")
// // // // //               else if (filtered.isEmpty)
// // // // //                 _EmptyBox(text: "Aucun résultat pour cette recherche.")
// // // // //               else
// // // // //                 ...List.generate(filtered.length, (i) {
// // // // //                   final it = filtered[i];
// // // // //                   final realIndex = s.items.indexOf(it);

// // // // //                   return Dismissible(
// // // // //                     key: ValueKey("${it.name}-$realIndex"),
// // // // //                     direction: DismissDirection.endToStart,
// // // // //                     background: Container(
// // // // //                       margin: const EdgeInsets.only(bottom: 10),
// // // // //                       padding: const EdgeInsets.symmetric(horizontal: 16),
// // // // //                       alignment: Alignment.centerRight,
// // // // //                       decoration: BoxDecoration(
// // // // //                         color: AppColors.bordeaux.withValues(alpha: 0.12),
// // // // //                         borderRadius: BorderRadius.circular(16),
// // // // //                         border: Border.all(color: AppColors.border),
// // // // //                       ),
// // // // //                       child: const Icon(Icons.delete_outline_rounded, color: AppColors.bordeaux),
// // // // //                     ),
// // // // //                     onDismissed: (_) => context.read<GroceryListCubit>().removeItem(realIndex),
// // // // //                     child: _ListTile(
// // // // //                       item: it,
// // // // //                       onToggle: () => context.read<GroceryListCubit>().toggleItem(realIndex),
// // // // //                       onRemove: () => context.read<GroceryListCubit>().removeItem(realIndex),
// // // // //                     ),
// // // // //                   );
// // // // //                 }),
// // // // //             ],
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // /* ---------------- Small widgets ---------------- */

// // // // // class _ProgressCard extends StatelessWidget {
// // // // //   final int done;
// // // // //   final int total;
// // // // //   final double progress;

// // // // //   const _ProgressCard({
// // // // //     required this.done,
// // // // //     required this.total,
// // // // //     required this.progress,
// // // // //   });

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.all(14),
// // // // //       decoration: BoxDecoration(
// // // // //         color: AppColors.soft,
// // // // //         borderRadius: BorderRadius.circular(18),
// // // // //         border: Border.all(color: AppColors.border),
// // // // //       ),
// // // // //       child: Column(
// // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // //         children: [
// // // // //           Row(
// // // // //             children: [
// // // // //               Expanded(
// // // // //                 child: Text(
// // // // //                   "Progress",
// // // // //                   style: AppTextStyles.h3.copyWith(
// // // // //                     fontWeight: FontWeight.w900,
// // // // //                     color: AppColors.text,
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //               Text(
// // // // //                 "$done / $total",
// // // // //                 style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //           const SizedBox(height: 10),
// // // // //           ClipRRect(
// // // // //             borderRadius: BorderRadius.circular(999),
// // // // //             child: LinearProgressIndicator(
// // // // //               value: progress,
// // // // //               minHeight: 10,
// // // // //               backgroundColor: Colors.white,
// // // // //               color: AppColors.bordeaux,
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _SearchBar extends StatelessWidget {
// // // // //   final TextEditingController controller;
// // // // //   final VoidCallback onChanged;
// // // // //   final VoidCallback onClear;

// // // // //   const _SearchBar({
// // // // //     required this.controller,
// // // // //     required this.onChanged,
// // // // //     required this.onClear,
// // // // //   });

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       height: 54,
// // // // //       decoration: BoxDecoration(
// // // // //         color: AppColors.fieldFill,
// // // // //         borderRadius: BorderRadius.circular(18),
// // // // //         border: Border.all(color: AppColors.border),
// // // // //       ),
// // // // //       child: Row(
// // // // //         children: [
// // // // //           const SizedBox(width: 12),
// // // // //           const Icon(Icons.search_rounded, color: AppColors.muted),
// // // // //           const SizedBox(width: 10),
// // // // //           Expanded(
// // // // //             child: TextField(
// // // // //               controller: controller,
// // // // //               onChanged: (_) => onChanged(),
// // // // //               style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
// // // // //               decoration: const InputDecoration(
// // // // //                 hintText: "Rechercher dans la liste…",
// // // // //                 hintStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // // //                 border: InputBorder.none,
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //           if (controller.text.isNotEmpty)
// // // // //             IconButton(
// // // // //               onPressed: onClear,
// // // // //               icon: const Icon(Icons.close_rounded, color: AppColors.muted),
// // // // //             ),
// // // // //           const SizedBox(width: 6),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _EmptyBox extends StatelessWidget {
// // // // //   final String text;
// // // // //   const _EmptyBox({required this.text});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.all(14),
// // // // //       decoration: BoxDecoration(
// // // // //         color: AppColors.soft,
// // // // //         borderRadius: BorderRadius.circular(18),
// // // // //         border: Border.all(color: AppColors.border),
// // // // //       ),
// // // // //       child: Text(
// // // // //         text,
// // // // //         style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _ListTile extends StatelessWidget {
// // // // //   final GroceryItem item;
// // // // //   final VoidCallback onToggle;
// // // // //   final VoidCallback onRemove;

// // // // //   const _ListTile({
// // // // //     required this.item,
// // // // //     required this.onToggle,
// // // // //     required this.onRemove,
// // // // //   });

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return InkWell(
// // // // //       borderRadius: BorderRadius.circular(16),
// // // // //       onTap: onToggle,
// // // // //       child: Container(
// // // // //         padding: const EdgeInsets.all(12),
// // // // //         margin: const EdgeInsets.only(bottom: 10),
// // // // //         decoration: BoxDecoration(
// // // // //           color: Colors.white,
// // // // //           borderRadius: BorderRadius.circular(16),
// // // // //           border: Border.all(color: AppColors.border),
// // // // //         ),
// // // // //         child: Row(
// // // // //           children: [
// // // // //             Container(
// // // // //               height: 34,
// // // // //               width: 34,
// // // // //               decoration: BoxDecoration(
// // // // //                 color: AppColors.soft,
// // // // //                 borderRadius: BorderRadius.circular(12),
// // // // //                 border: Border.all(color: AppColors.border),
// // // // //               ),
// // // // //               child: Icon(
// // // // //                 item.done ? Icons.check_rounded : Icons.circle_outlined,
// // // // //                 color: item.done ? AppColors.bordeaux : AppColors.muted,
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(width: 12),
// // // // //             Expanded(
// // // // //               child: Text(
// // // // //                 item.name,
// // // // //                 style: TextStyle(
// // // // //                   fontWeight: FontWeight.w900,
// // // // //                   color: item.done ? AppColors.muted : AppColors.text,
// // // // //                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //             InkWell(
// // // // //               borderRadius: BorderRadius.circular(12),
// // // // //               onTap: onRemove,
// // // // //               child: Container(
// // // // //                 height: 34,
// // // // //                 width: 34,
// // // // //                 decoration: BoxDecoration(
// // // // //                   color: Colors.white,
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                   border: Border.all(color: AppColors.border),
// // // // //                 ),
// // // // //                 child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class _SectionHeader extends StatelessWidget {
// // // // //   final String title;
// // // // //   final String actionText;
// // // // //   final VoidCallback onAction;

// // // // //   const _SectionHeader({
// // // // //     required this.title,
// // // // //     required this.actionText,
// // // // //     required this.onAction,
// // // // //   });

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Row(
// // // // //       children: [
// // // // //         Expanded(
// // // // //           child: Text(
// // // // //             title,
// // // // //             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// // // // //           ),
// // // // //         ),
// // // // //         InkWell(
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           onTap: onAction,
// // // // //           child: Container(
// // // // //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// // // // //             decoration: BoxDecoration(
// // // // //               color: AppColors.soft,
// // // // //               borderRadius: BorderRadius.circular(12),
// // // // //               border: Border.all(color: AppColors.border),
// // // // //             ),
// // // // //             child: Text(
// // // // //               actionText,
// // // // //               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ],
// // // // //      );
// // // // //   }
// // // // // }

// // // // // class _ProSheet extends StatelessWidget {
// // // // //   final String title;
// // // // //   final Widget child;
// // // // //   const _ProSheet({required this.title, required this.child});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       margin: const EdgeInsets.all(12),
// // // // //       padding: const EdgeInsets.all(14),
// // // // //       decoration: BoxDecoration(
// // // // //         color: Colors.white,
// // // // //         borderRadius: BorderRadius.circular(22),
// // // // //         border: Border.all(color: AppColors.border),
// // // // //         boxShadow: [
// // // // //           BoxShadow(
// // // // //             color: Colors.black.withValues(alpha: 0.08),
// // // // //             blurRadius: 22,
// // // // //             offset: const Offset(0, 12),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //       child: SafeArea(
// // // // //         top: false,
// // // // //         child: Column(
// // // // //           mainAxisSize: MainAxisSize.min,
// // // // //           children: [
// // // // //             Container(
// // // // //               height: 4,
// // // // //               width: 46,
// // // // //               decoration: BoxDecoration(
// // // // //                 color: AppColors.border,
// // // // //                 borderRadius: BorderRadius.circular(999),
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 12),
// // // // //             Row(
// // // // //               children: [
// // // // //                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
// // // // //                 InkWell(
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                   onTap: () => Navigator.pop(context),
// // // // //                   child: Container(
// // // // //                     height: 36,
// // // // //                     width: 36,
// // // // //                     decoration: BoxDecoration(
// // // // //                       color: AppColors.soft,
// // // // //                       borderRadius: BorderRadius.circular(14),
// // // // //                       border: Border.all(color: AppColors.border),
// // // // //                     ),
// // // // //                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //             const SizedBox(height: 14),
// // // // //             child,
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_bloc/flutter_bloc.dart';

// // // // import 'package:elfaddoui_app/core/theme/app_colors.dart';
// // // // import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// // // // import '../../cubit/grocery_list_cubit.dart';
// // // // import '../../cubit/grocery_list_state.dart';

// // // // class GroceryListScreen extends StatelessWidget {
// // // //   const GroceryListScreen({super.key});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return BlocProvider(
// // // //       create: (_) => GroceryListCubit(),
// // // //       child: const _GroceryListView(),
// // // //     );
// // // //   }
// // // // }

// // // // class _GroceryListView extends StatefulWidget {
// // // //   const _GroceryListView();

// // // //   @override
// // // //   State<_GroceryListView> createState() => _GroceryListViewState();
// // // // }

// // // // class _GroceryListViewState extends State<_GroceryListView> {
// // // //   final _search = TextEditingController();

// // // //   @override
// // // //   void dispose() {
// // // //     _search.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   void _openAdd(BuildContext context) {
// // // //     final c = TextEditingController();
// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       backgroundColor: Colors.transparent,
// // // //       isScrollControlled: true,
// // // //       builder: (_) {
// // // //         return Padding(
// // // //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// // // //           child: _ProSheet(
// // // //             title: "Ajouter un item",
// // // //             child: Column(
// // // //               children: [
// // // //                 TextField(
// // // //                   controller: c,
// // // //                   autofocus: true,
// // // //                   decoration: InputDecoration(
// // // //                     hintText: "Ex: Lait, Pain, Pâtes...",
// // // //                     filled: true,
// // // //                     fillColor: const Color(0xFFF7F7F7),
// // // //                     border: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(16),
// // // //                       borderSide: BorderSide(color: AppColors.border),
// // // //                     ),
// // // //                     enabledBorder: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(16),
// // // //                       borderSide: BorderSide(color: AppColors.border),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 12),
// // // //                 SizedBox(
// // // //                   height: 48,
// // // //                   width: double.infinity,
// // // //                   child: ElevatedButton(
// // // //                     onPressed: () {
// // // //                       final txt = c.text.trim();
// // // //                       if (txt.isNotEmpty) context.read<GroceryListCubit>().addItem(txt);
// // // //                       Navigator.pop(context);
// // // //                     },
// // // //                     style: ElevatedButton.styleFrom(
// // // //                       backgroundColor: AppColors.bordeaux,
// // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // // //                       elevation: 0,
// // // //                     ),
// // // //                     child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         );
// // // //       },
// // // //     ).whenComplete(() => c.dispose());
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final softBordeaux = AppColors.bordeaux.withValues(alpha: 0.06);
// // // //     final softBorder = AppColors.bordeaux.withValues(alpha: 0.18);

// // // //     return Scaffold(
// // // //       backgroundColor: Colors.white,

// // // //       appBar: AppBar(
// // // //         backgroundColor: Colors.white,
// // // //         surfaceTintColor: Colors.transparent,
// // // //         elevation: 0,
// // // //         centerTitle: true,
// // // //         title: Text(
// // // //           "Liste de courses",
// // // //           style: AppTextStyles.h3.copyWith(
// // // //             fontWeight: FontWeight.w900,
// // // //             color: AppColors.text,
// // // //           ),
// // // //         ),
// // // //         actions: [
// // // //           InkWell(
// // // //             borderRadius: BorderRadius.circular(14),
// // // //             onTap: () => context.read<GroceryListCubit>().clearDone(),
// // // //             child: Container(
// // // //               margin: const EdgeInsets.only(right: 12),
// // // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // //               decoration: BoxDecoration(
// // // //                 color: softBordeaux,
// // // //                 borderRadius: BorderRadius.circular(14),
// // // //                 border: Border.all(color: softBorder),
// // // //               ),
// // // //               child: const Text(
// // // //                 "Nettoyer",
// // // //                 style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),

// // // //       floatingActionButton: FloatingActionButton(
// // // //         heroTag: "grocery_fab",
// // // //         backgroundColor: AppColors.bordeaux,
// // // //         elevation: 0,
// // // //         onPressed: () => _openAdd(context),
// // // //         child: const Icon(Icons.add_rounded, color: Colors.white),
// // // //       ),

// // // //       body: BlocBuilder<GroceryListCubit, GroceryListState>(
// // // //         builder: (context, s) {
// // // //           final q = _search.text.trim().toLowerCase();

// // // //           final filtered = s.items.where((it) {
// // // //             if (q.isEmpty) return true;
// // // //             return it.name.toLowerCase().contains(q);
// // // //           }).toList();

// // // //           final total = s.items.length;
// // // //           final done = s.items.where((x) => x.done).length;
// // // //           final progress = total == 0 ? 0.0 : done / total;

// // // //           return ListView(
// // // //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
// // // //             children: [
// // // //               _WhiteCard(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     Row(
// // // //                       children: [
// // // //                         Expanded(
// // // //                           child: Text(
// // // //                             "Progress",
// // // //                             style: AppTextStyles.h3.copyWith(
// // // //                               fontWeight: FontWeight.w900,
// // // //                               color: AppColors.text,
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                         Text(
// // // //                           "$done / $total",
// // // //                           style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     const SizedBox(height: 10),
// // // //                     ClipRRect(
// // // //                       borderRadius: BorderRadius.circular(999),
// // // //                       child: LinearProgressIndicator(
// // // //                         value: progress,
// // // //                         minHeight: 10,
// // // //                         backgroundColor: const Color(0xFFF2F2F2),
// // // //                         color: AppColors.bordeaux,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),

// // // //               const SizedBox(height: 12),

// // // //               _SearchBar(
// // // //                 controller: _search,
// // // //                 onChanged: () => setState(() {}),
// // // //                 onClear: () => setState(() => _search.clear()),
// // // //               ),

// // // //               const SizedBox(height: 16),

// // // //               _SectionHeader(
// // // //                 title: "Votre liste",
// // // //                 actionText: "Ajouter",
// // // //                 onAction: () => _openAdd(context),
// // // //               ),
// // // //               const SizedBox(height: 10),

// // // //               if (s.items.isEmpty)
// // // //                 _WhiteCard(
// // // //                   child: const Text(
// // // //                     "Votre liste est vide. Ajoutez des produits ✨",
// // // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // //                   ),
// // // //                 )
// // // //               else if (filtered.isEmpty)
// // // //                 _WhiteCard(
// // // //                   child: const Text(
// // // //                     "Aucun résultat pour cette recherche.",
// // // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // //                   ),
// // // //                 )
// // // //               else
// // // //                 ...List.generate(filtered.length, (i) {
// // // //                   final it = filtered[i];
// // // //                   final realIndex = s.items.indexOf(it);

// // // //                   return Dismissible(
// // // //                     key: ValueKey("${it.name}-$realIndex"),
// // // //                     direction: DismissDirection.endToStart,
// // // //                     background: Container(
// // // //                       margin: const EdgeInsets.only(bottom: 10),
// // // //                       padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //                       alignment: Alignment.centerRight,
// // // //                       decoration: BoxDecoration(
// // // //                         color: AppColors.bordeaux.withValues(alpha: 0.10),
// // // //                         borderRadius: BorderRadius.circular(16),
// // // //                         border: Border.all(color: AppColors.border),
// // // //                       ),
// // // //                       child: const Icon(Icons.delete_outline_rounded, color: AppColors.bordeaux),
// // // //                     ),
// // // //                     onDismissed: (_) => context.read<GroceryListCubit>().removeItem(realIndex),
// // // //                     child: _ListTile(
// // // //                       item: it,
// // // //                       onToggle: () => context.read<GroceryListCubit>().toggleItem(realIndex),
// // // //                       onRemove: () => context.read<GroceryListCubit>().removeItem(realIndex),
// // // //                     ),
// // // //                   );
// // // //                 }),
// // // //             ],
// // // //           );
// // // //         },
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // /* ---------------- Widgets ---------------- */

// // // // class _WhiteCard extends StatelessWidget {
// // // //   final Widget child;
// // // //   const _WhiteCard({required this.child});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(14),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(18),
// // // //         border: Border.all(color: AppColors.border),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.black.withValues(alpha: 0.03),
// // // //             blurRadius: 18,
// // // //             offset: const Offset(0, 10),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: child,
// // // //     );
// // // //   }
// // // // }

// // // // class _SearchBar extends StatelessWidget {
// // // //   final TextEditingController controller;
// // // //   final VoidCallback onChanged;
// // // //   final VoidCallback onClear;

// // // //   const _SearchBar({
// // // //     required this.controller,
// // // //     required this.onChanged,
// // // //     required this.onClear,
// // // //   });

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return _WhiteCard(
// // // //       child: Row(
// // // //         children: [
// // // //           const Icon(Icons.search_rounded, color: AppColors.muted),
// // // //           const SizedBox(width: 10),
// // // //           Expanded(
// // // //             child: TextField(
// // // //               controller: controller,
// // // //               onChanged: (_) => onChanged(),
// // // //               style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
// // // //               decoration: const InputDecoration(
// // // //                 hintText: "Rechercher dans la liste…",
// // // //                 hintStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // // //                 border: InputBorder.none,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           if (controller.text.isNotEmpty)
// // // //             IconButton(
// // // //               onPressed: onClear,
// // // //               icon: const Icon(Icons.close_rounded, color: AppColors.muted),
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _ListTile extends StatelessWidget {
// // // //   final GroceryItem item;
// // // //   final VoidCallback onToggle;
// // // //   final VoidCallback onRemove;

// // // //   const _ListTile({
// // // //     required this.item,
// // // //     required this.onToggle,
// // // //     required this.onRemove,
// // // //   });

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return InkWell(
// // // //       borderRadius: BorderRadius.circular(16),
// // // //       onTap: onToggle,
// // // //       child: Container(
// // // //         padding: const EdgeInsets.all(12),
// // // //         margin: const EdgeInsets.only(bottom: 10),
// // // //         decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           border: Border.all(color: AppColors.border),
// // // //         ),
// // // //         child: Row(
// // // //           children: [
// // // //             Container(
// // // //               height: 34,
// // // //               width: 34,
// // // //               decoration: BoxDecoration(
// // // //                 color: const Color(0xFFF7F7F7),
// // // //                 borderRadius: BorderRadius.circular(12),
// // // //                 border: Border.all(color: AppColors.border),
// // // //               ),
// // // //               child: Icon(
// // // //                 item.done ? Icons.check_rounded : Icons.circle_outlined,
// // // //                 color: item.done ? AppColors.bordeaux : AppColors.muted,
// // // //               ),
// // // //             ),
// // // //             const SizedBox(width: 12),
// // // //             Expanded(
// // // //               child: Text(
// // // //                 item.name,
// // // //                 style: TextStyle(
// // // //                   fontWeight: FontWeight.w900,
// // // //                   color: item.done ? AppColors.muted : AppColors.text,
// // // //                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             InkWell(
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               onTap: onRemove,
// // // //               child: Container(
// // // //                 height: 34,
// // // //                 width: 34,
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.white,
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                   border: Border.all(color: AppColors.border),
// // // //                 ),
// // // //                 child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class _SectionHeader extends StatelessWidget {
// // // //   final String title;
// // // //   final String actionText;
// // // //   final VoidCallback onAction;

// // // //   const _SectionHeader({
// // // //     required this.title,
// // // //     required this.actionText,
// // // //     required this.onAction,
// // // //   });

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final softBordeaux = AppColors.bordeaux.withValues(alpha: 0.06);
// // // //     final softBorder = AppColors.bordeaux.withValues(alpha: 0.18);

// // // //     return Row(
// // // //       children: [
// // // //         Expanded(
// // // //           child: Text(
// // // //             title,
// // // //             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// // // //           ),
// // // //         ),
// // // //         InkWell(
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           onTap: onAction,
// // // //           child: Container(
// // // //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
// // // //             decoration: BoxDecoration(
// // // //               color: softBordeaux,
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               border: Border.all(color: softBorder),
// // // //             ),
// // // //             child: Text(
// // // //               actionText,
// // // //               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // // }

// // // // class _ProSheet extends StatelessWidget {
// // // //   final String title;
// // // //   final Widget child;
// // // //   const _ProSheet({required this.title, required this.child});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       margin: const EdgeInsets.all(12),
// // // //       padding: const EdgeInsets.all(14),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(22),
// // // //         border: Border.all(color: AppColors.border),
// // // //         boxShadow: [
// // // //           BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 22, offset: const Offset(0, 12)),
// // // //         ],
// // // //       ),
// // // //       child: SafeArea(
// // // //         top: false,
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Container(height: 4, width: 46, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999))),
// // // //             const SizedBox(height: 12),
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
// // // //                 InkWell(
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                   onTap: () => Navigator.pop(context),
// // // //                   child: Container(
// // // //                     height: 36,
// // // //                     width: 36,
// // // //                     decoration: BoxDecoration(
// // // //                       color: const Color(0xFFF7F7F7),
// // // //                       borderRadius: BorderRadius.circular(14),
// // // //                       border: Border.all(color: AppColors.border),
// // // //                     ),
// // // //                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const SizedBox(height: 14),
// // // //             child,
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';

// // // import 'package:elfaddoui_app/core/theme/app_colors.dart';
// // // import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// // // import '../../cubit/grocery_list_cubit.dart';
// // // import '../../cubit/grocery_list_state.dart';

// // // class GroceryListScreen extends StatelessWidget {
// // //   const GroceryListScreen({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return BlocProvider(
// // //       create: (_) => GroceryListCubit(),
// // //       child: const _GroceryListView(),
// // //     );
// // //   }
// // // }

// // // class _GroceryListView extends StatefulWidget {
// // //   const _GroceryListView();

// // //   @override
// // //   State<_GroceryListView> createState() => _GroceryListViewState();
// // // }

// // // class _GroceryListViewState extends State<_GroceryListView> {
// // //   final _search = TextEditingController();
// // //   bool _sheetOpen = false;

// // //   @override
// // //   void dispose() {
// // //     _search.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   void deactivate() {
// // //     if (_sheetOpen && Navigator.of(context).canPop()) {
// // //       Navigator.of(context).pop(); // ensure sheet closes before provider deactivates
// // //       _sheetOpen = false;
// // //     }
// // //     super.deactivate();
// // //   }

// // //   void _openAdd(BuildContext context) {
// // //     final c = TextEditingController();
// // //     final cubit = context.read<GroceryListCubit>();
// // //     _sheetOpen = true;
// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: Colors.transparent,
// // //       isScrollControlled: true,
// // //       builder: (sheetContext) {
// // //         return Padding(
// // //           padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
// // //           child: _ProSheet(
// // //             title: "Ajouter un item",
// // //             child: Column(
// // //               children: [
// // //                 TextField(
// // //                   controller: c,
// // //                   decoration: InputDecoration(
// // //                     hintText: "Lait, Pain, Pâtes...",
// // //                     filled: true,
// // //                     fillColor: AppColors.fieldFill,
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(16),
// // //                       borderSide: BorderSide(color: AppColors.border),
// // //                     ),
// // //                     enabledBorder: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(16),
// // //                       borderSide: BorderSide(color: AppColors.border),
// // //                     ),
// // //                     focusedBorder: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(16),
// // //                       borderSide: BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.5)),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 12),
// // //                 SizedBox(
// // //                   height: 48,
// // //                   width: double.infinity,
// // //                   child: ElevatedButton(
// // //                     onPressed: () {
// // //                       final txt = c.text.trim();
// // //                       if (txt.isNotEmpty) cubit.addItem(txt);
// // //                       Navigator.of(sheetContext).pop();
// // //                     },
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: AppColors.bordeaux,
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //                       elevation: 0,
// // //                     ),
// // //                     child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     ).whenComplete(() {
// // //       _sheetOpen = false;
// // //       c.dispose();
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,

// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         surfaceTintColor: Colors.transparent,
// // //         elevation: 0,
// // //         centerTitle: true,
// // //         title: Text(
// // //           "📝 Liste de courses",
// // //           style: AppTextStyles.h3.copyWith(
// // //             fontWeight: FontWeight.w900,
// // //             color: AppColors.text,
// // //           ),
// // //         ),
// // //         actions: [
// // //           InkWell(
// // //             borderRadius: BorderRadius.circular(14),
// // //             onTap: () => context.read<GroceryListCubit>().clearDone(),
// // //             child: Container(
// // //               margin: const EdgeInsets.only(right: 12),
// // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // //               decoration: BoxDecoration(
// // //                 color: AppColors.soft,
// // //                 borderRadius: BorderRadius.circular(14),
// // //                 border: Border.all(color: AppColors.border),
// // //               ),
// // //               child: const Text(
// // //                 "Nettoyer",
// // //                 style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),

// // //       floatingActionButton: FloatingActionButton(
// // //         heroTag: "grocery_fab",
// // //         backgroundColor: AppColors.bordeaux,
// // //         elevation: 0,
// // //         onPressed: () => _openAdd(context),
// // //         child: const Icon(Icons.add_rounded, color: Colors.white),
// // //       ),

// // //       body: BlocBuilder<GroceryListCubit, GroceryListState>(
// // //         builder: (context, s) {
// // //           // ✅ Search filter
// // //           final q = _search.text.trim().toLowerCase();
// // //           final filteredItems = s.items.where((it) {
// // //             if (q.isEmpty) return true;
// // //             return it.name.toLowerCase().contains(q);
// // //           }).toList();

// // //           // ✅ progress
// // //           final total = s.items.length;
// // //           final done = s.items.where((x) => x.done).length;
// // //           final progress = total == 0 ? 0.0 : (done / total);

// // //           return ListView(
// // //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
// // //             children: [
// // //               // ✅ Progress header
// // //               Container(
// // //                 padding: const EdgeInsets.all(14),
// // //                 decoration: BoxDecoration(
// // //                   color: AppColors.soft,
// // //                   borderRadius: BorderRadius.circular(18),
// // //                   border: Border.all(color: AppColors.border),
// // //                 ),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Row(
// // //                       children: [
// // //                         Expanded(
// // //                           child: Text(
// // //                             "Progress",
// // //                             style: AppTextStyles.h3.copyWith(
// // //                               fontWeight: FontWeight.w900,
// // //                               color: AppColors.text,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         Text(
// // //                           "$done / $total",
// // //                           style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     const SizedBox(height: 10),
// // //                     ClipRRect(
// // //                       borderRadius: BorderRadius.circular(999),
// // //                       child: LinearProgressIndicator(
// // //                         value: progress,
// // //                         minHeight: 10,
// // //                         backgroundColor: Colors.white,
// // //                         color: AppColors.bordeaux,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),

// // //               const SizedBox(height: 12),

// // //               // ✅ Search bar (FIXED)
// // //               _SearchBar(
// // //                 controller: _search,
// // //                 onChanged: () => setState(() {}), // ✅ refresh propre
// // //                 onClear: () => setState(() => _search.clear()),
// // //               ),

// // //               const SizedBox(height: 16),

// // //               // ✅ Suggestions IA
// // //               if (s.suggestions.isNotEmpty) ...[
// // //                 _SectionHeader(
// // //                   title: "✨ Suggestions IA",
// // //                   actionText: "Tout ajouter",
// // //                   onAction: () {
// // //                     for (final x in s.suggestions) {
// // //                       context.read<GroceryListCubit>().addItem(x);
// // //                     }
// // //                   },
// // //                 ),
// // //                 const SizedBox(height: 10),
// // //                 Wrap(
// // //                   spacing: 10,
// // //                   runSpacing: 10,
// // //                   children: s.suggestions.map((x) {
// // //                     return InkWell(
// // //                       borderRadius: BorderRadius.circular(999),
// // //                       onTap: () => context.read<GroceryListCubit>().addItem(x),
// // //                       child: Container(
// // //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // //                         decoration: BoxDecoration(
// // //                           color: AppColors.soft,
// // //                           borderRadius: BorderRadius.circular(999),
// // //                           border: Border.all(color: AppColors.border),
// // //                         ),
// // //                         child: Row(
// // //                           mainAxisSize: MainAxisSize.min,
// // //                           children: [
// // //                             const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.bordeaux),
// // //                             const SizedBox(width: 8),
// // //                             Text(x, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     );
// // //                   }).toList(),
// // //                 ),
// // //                 const SizedBox(height: 16),
// // //               ],

// // //               _SectionHeader(
// // //                 title: "Votre liste",
// // //                 actionText: "Ajouter",
// // //                 onAction: () => _openAdd(context),
// // //               ),
// // //               const SizedBox(height: 10),

// // //               if (s.items.isEmpty)
// // //                 Container(
// // //                   padding: const EdgeInsets.all(14),
// // //                   decoration: BoxDecoration(
// // //                     color: AppColors.soft,
// // //                     borderRadius: BorderRadius.circular(18),
// // //                     border: Border.all(color: AppColors.border),
// // //                   ),
// // //                   child: const Text(
// // //                     "Votre liste est vide. Ajoutez des produits ✨",
// // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // //                   ),
// // //                 )
// // //               else if (filteredItems.isEmpty)
// // //                 Container(
// // //                   padding: const EdgeInsets.all(14),
// // //                   decoration: BoxDecoration(
// // //                     color: AppColors.soft,
// // //                     borderRadius: BorderRadius.circular(18),
// // //                     border: Border.all(color: AppColors.border),
// // //                   ),
// // //                   child: const Text(
// // //                     "Aucun résultat pour cette recherche.",
// // //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // //                   ),
// // //                 )
// // //               else
// // //                 ...List.generate(filteredItems.length, (i) {
// // //                   final it = filteredItems[i];

// // //                   // index الحقيقي
// // //                   final realIndex = s.items.indexOf(it);

// // //                   return Dismissible(
// // //                     key: ValueKey("${it.name}-$realIndex"),
// // //                     direction: DismissDirection.endToStart,
// // //                     background: Container(
// // //                       margin: const EdgeInsets.only(bottom: 10),
// // //                       padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                       alignment: Alignment.centerRight,
// // //                       decoration: BoxDecoration(
// // //                         color: AppColors.bordeaux.withValues(alpha: 0.12),
// // //                         borderRadius: BorderRadius.circular(16),
// // //                         border: Border.all(color: AppColors.border),
// // //                       ),
// // //                       child: const Icon(Icons.delete_outline_rounded, color: AppColors.bordeaux),
// // //                     ),
// // //                     onDismissed: (_) => context.read<GroceryListCubit>().removeItem(realIndex),
// // //                     child: _ListTile(
// // //                       item: it,
// // //                       onToggle: () => context.read<GroceryListCubit>().toggleItem(realIndex),
// // //                       onRemove: () => context.read<GroceryListCubit>().removeItem(realIndex),
// // //                     ),
// // //                   );
// // //                 }),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }

// // // /* ================= Widgets ================= */

// // // class _SearchBar extends StatelessWidget {
// // //   final TextEditingController controller;
// // //   final VoidCallback onChanged;
// // //   final VoidCallback onClear;

// // //   const _SearchBar({
// // //     required this.controller,
// // //     required this.onChanged,
// // //     required this.onClear,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       height: 54,
// // //       padding: const EdgeInsets.symmetric(horizontal: 12),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(18),
// // //         border: Border.all(color: AppColors.border),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withValues(alpha: 0.03),
// // //             blurRadius: 18,
// // //             offset: const Offset(0, 10),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           const Icon(Icons.search_rounded, color: AppColors.muted),
// // //           const SizedBox(width: 10),
// // //           Expanded(
// // //             child: TextField(
// // //               controller: controller,
// // //               onChanged: (_) => onChanged(), // ✅ safe rebuild
// // //               style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
// // //               decoration: const InputDecoration(
// // //                 hintText: "Rechercher dans la liste…",
// // //                 hintStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// // //                 border: InputBorder.none,
// // //               ),
// // //             ),
// // //           ),
// // //           if (controller.text.isNotEmpty)
// // //             IconButton(
// // //               onPressed: onClear,
// // //               icon: const Icon(Icons.close_rounded, color: AppColors.muted),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _ListTile extends StatelessWidget {
// // //   final GroceryItem item;
// // //   final VoidCallback onToggle;
// // //   final VoidCallback onRemove;

// // //   const _ListTile({
// // //     required this.item,
// // //     required this.onToggle,
// // //     required this.onRemove,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return InkWell(
// // //       borderRadius: BorderRadius.circular(16),
// // //       onTap: onToggle,
// // //       child: Container(
// // //         padding: const EdgeInsets.all(12),
// // //         margin: const EdgeInsets.only(bottom: 10),
// // //         decoration: BoxDecoration(
// // //           color: Colors.white,
// // //           borderRadius: BorderRadius.circular(16),
// // //           border: Border.all(color: AppColors.border),
// // //         ),
// // //         child: Row(
// // //           children: [
// // //             Container(
// // //               height: 34,
// // //               width: 34,
// // //               decoration: BoxDecoration(
// // //                 color: AppColors.soft,
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 border: Border.all(color: AppColors.border),
// // //               ),
// // //               child: Icon(
// // //                 item.done ? Icons.check_rounded : Icons.circle_outlined,
// // //                 color: item.done ? AppColors.bordeaux : AppColors.muted,
// // //               ),
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Text(
// // //                 item.name,
// // //                 style: TextStyle(
// // //                   fontWeight: FontWeight.w900,
// // //                   color: item.done ? AppColors.muted : AppColors.text,
// // //                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
// // //                 ),
// // //               ),
// // //             ),
// // //             InkWell(
// // //               borderRadius: BorderRadius.circular(12),
// // //               onTap: onRemove,
// // //               child: Container(
// // //                 height: 34,
// // //                 width: 34,
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(color: AppColors.border),
// // //                 ),
// // //                 child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class _SectionHeader extends StatelessWidget {
// // //   final String title;
// // //   final String actionText;
// // //   final VoidCallback onAction;

// // //   const _SectionHeader({
// // //     required this.title,
// // //     required this.actionText,
// // //     required this.onAction,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Row(
// // //       children: [
// // //         Expanded(
// // //           child: Text(
// // //             title,
// // //             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// // //           ),
// // //         ),
// // //         InkWell(
// // //           borderRadius: BorderRadius.circular(12),
// // //           onTap: onAction,
// // //           child: Container(
// // //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// // //             decoration: BoxDecoration(
// // //               color: AppColors.soft,
// // //               borderRadius: BorderRadius.circular(12),
// // //               border: Border.all(color: AppColors.border),
// // //             ),
// // //             child: Text(
// // //               actionText,
// // //               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // // class _ProSheet extends StatelessWidget {
// // //   final String title;
// // //   final Widget child;
// // //   const _ProSheet({required this.title, required this.child});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       margin: const EdgeInsets.all(12),
// // //       padding: const EdgeInsets.all(14),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(22),
// // //         border: Border.all(color: AppColors.border),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withValues(alpha: 0.08),
// // //             blurRadius: 22,
// // //             offset: const Offset(0, 12),
// // //           )
// // //         ],
// // //       ),
// // //       child: SafeArea(
// // //         top: false,
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Container(
// // //               height: 4,
// // //               width: 46,
// // //               decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
// // //             ),
// // //             const SizedBox(height: 12),
// // //             Row(
// // //               children: [
// // //                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
// // //                 InkWell(
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   onTap: () => Navigator.pop(context),
// // //                   child: Container(
// // //                     height: 36,
// // //                     width: 36,
// // //                     decoration: BoxDecoration(
// // //                       color: AppColors.soft,
// // //                       borderRadius: BorderRadius.circular(14),
// // //                       border: Border.all(color: AppColors.border),
// // //                     ),
// // //                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 14),
// // //             child,
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';

// // import 'package:elfaddoui_app/core/theme/app_colors.dart';
// // import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// // import '../../cubit/grocery_list_cubit.dart';
// // import '../../cubit/grocery_list_state.dart';

// // class GroceryListScreen extends StatelessWidget {
// //   const GroceryListScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocProvider(
// //       create: (_) => GroceryListCubit(),
// //       child: const _GroceryListView(),
// //     );
// //   }
// // }

// // class _GroceryListView extends StatefulWidget {
// //   const _GroceryListView();

// //   @override
// //   State<_GroceryListView> createState() => _GroceryListViewState();
// // }

// // class _GroceryListViewState extends State<_GroceryListView> {
// //   final _search = TextEditingController();

// //   @override
// //   void dispose() {
// //     _search.dispose();
// //     super.dispose();
// //   }

// //   void _openAdd(BuildContext context) {
// //     final c = TextEditingController();
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       isScrollControlled: true,
// //       builder: (_) {
// //         return Padding(
// //           padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// //           child: _ProSheet(
// //             title: "Ajouter un item",
// //             child: Column(
// //               children: [
// //                 TextField(
// //                   controller: c,
// //                   decoration: InputDecoration(
// //                     hintText: "Ex: Lait, Pain, Pâtes...",
// //                     filled: true,
// //                     fillColor: AppColors.fieldFill,
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(16),
// //                       borderSide: BorderSide(color: AppColors.border),
// //                     ),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(16),
// //                       borderSide: BorderSide(color: AppColors.border),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(16),
// //                       borderSide: BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.5)),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 SizedBox(
// //                   height: 48,
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       final txt = c.text.trim();
// //                       if (txt.isNotEmpty) context.read<GroceryListCubit>().addItem(txt);
// //                       Navigator.pop(context);
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: AppColors.bordeaux,
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //                       elevation: 0,
// //                     ),
// //                     child: const Text(
// //                       "Ajouter",
// //                       style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     ).whenComplete(() => c.dispose());
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,

// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         surfaceTintColor: Colors.transparent,
// //         elevation: 0,
// //         centerTitle: true,
// //         title: Text(
// //           "📝 Liste de courses",
// //           style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// //         ),
// //         actions: [
// //           InkWell(
// //             borderRadius: BorderRadius.circular(14),
// //             onTap: () => context.read<GroceryListCubit>().clearDone(),
// //             child: Container(
// //               margin: const EdgeInsets.only(right: 12),
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //               decoration: BoxDecoration(
// //                 color: AppColors.soft,
// //                 borderRadius: BorderRadius.circular(14),
// //                 border: Border.all(color: AppColors.border),
// //               ),
// //               child: const Text(
// //                 "Nettoyer",
// //                 style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),

// //       floatingActionButton: FloatingActionButton(
// //         heroTag: "grocery_fab",
// //         backgroundColor: AppColors.bordeaux,
// //         elevation: 0,
// //         onPressed: () => _openAdd(context),
// //         child: const Icon(Icons.add_rounded, color: Colors.white),
// //       ),

// //       body: BlocBuilder<GroceryListCubit, GroceryListState>(
// //         builder: (context, s) {
// //           final q = _search.text.trim().toLowerCase();
// //           final filteredItems = s.items.where((it) {
// //             if (q.isEmpty) return true;
// //             return it.name.toLowerCase().contains(q);
// //           }).toList();

// //           final total = s.items.length;
// //           final done = s.items.where((x) => x.done).length;
// //           final progress = total == 0 ? 0.0 : (done / total);

// //           return ListView(
// //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.all(14),
// //                 decoration: BoxDecoration(
// //                   color: AppColors.soft,
// //                   borderRadius: BorderRadius.circular(18),
// //                   border: Border.all(color: AppColors.border),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: Text(
// //                             "Progress",
// //                             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// //                           ),
// //                         ),
// //                         Text(
// //                           "$done / $total",
// //                           style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 10),
// //                     ClipRRect(
// //                       borderRadius: BorderRadius.circular(999),
// //                       child: LinearProgressIndicator(
// //                         value: progress,
// //                         minHeight: 10,
// //                         backgroundColor: Colors.white,
// //                         color: AppColors.bordeaux,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               const SizedBox(height: 12),

// //               _SearchBar(
// //                 controller: _search,
// //                 onChanged: () => setState(() {}),
// //                 onClear: () => setState(() => _search.clear()),
// //               ),

// //               const SizedBox(height: 16),

// //               if (s.suggestions.isNotEmpty) ...[
// //                 _SectionHeader(
// //                   title: "✨ Suggestions IA",
// //                   actionText: "Tout ajouter",
// //                   onAction: () {
// //                     for (final x in s.suggestions) {
// //                       context.read<GroceryListCubit>().addItem(x);
// //                     }
// //                   },
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Wrap(
// //                   spacing: 10,
// //                   runSpacing: 10,
// //                   children: s.suggestions.map((x) {
// //                     return InkWell(
// //                       borderRadius: BorderRadius.circular(999),
// //                       onTap: () => context.read<GroceryListCubit>().addItem(x),
// //                       child: Container(
// //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //                         decoration: BoxDecoration(
// //                           color: AppColors.soft,
// //                           borderRadius: BorderRadius.circular(999),
// //                           border: Border.all(color: AppColors.border),
// //                         ),
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.bordeaux),
// //                             const SizedBox(width: 8),
// //                             Text(x, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
// //                           ],
// //                         ),
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //                 const SizedBox(height: 16),
// //               ],

// //               _SectionHeader(
// //                 title: "Votre liste",
// //                 actionText: "Ajouter",
// //                 onAction: () => _openAdd(context),
// //               ),
// //               const SizedBox(height: 10),

// //               if (s.items.isEmpty)
// //                 Container(
// //                   padding: const EdgeInsets.all(14),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.soft,
// //                     borderRadius: BorderRadius.circular(18),
// //                     border: Border.all(color: AppColors.border),
// //                   ),
// //                   child: const Text(
// //                     "Votre liste est vide. Ajoutez des produits ✨",
// //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// //                   ),
// //                 )
// //               else if (filteredItems.isEmpty)
// //                 Container(
// //                   padding: const EdgeInsets.all(14),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.soft,
// //                     borderRadius: BorderRadius.circular(18),
// //                     border: Border.all(color: AppColors.border),
// //                   ),
// //                   child: const Text(
// //                     "Aucun résultat pour cette recherche.",
// //                     style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// //                   ),
// //                 )
// //               else
// //                 ...filteredItems.map((it) {
// //                   return Dismissible(
// //                     key: ValueKey(it.id), // ✅ key stable
// //                     direction: DismissDirection.endToStart,
// //                     background: Container(
// //                       margin: const EdgeInsets.only(bottom: 10),
// //                       padding: const EdgeInsets.symmetric(horizontal: 16),
// //                       alignment: Alignment.centerRight,
// //                       decoration: BoxDecoration(
// //                         color: AppColors.bordeaux.withValues(alpha: 0.12),
// //                         borderRadius: BorderRadius.circular(16),
// //                         border: Border.all(color: AppColors.border),
// //                       ),
// //                       child: const Icon(Icons.delete_outline_rounded, color: AppColors.bordeaux),
// //                     ),
// //                     onDismissed: (_) => context.read<GroceryListCubit>().removeItemById(it.id),
// //                     child: _ListTile(
// //                       item: it,
// //                       onToggle: () => context.read<GroceryListCubit>().toggleItemById(it.id),
// //                       onRemove: () => context.read<GroceryListCubit>().removeItemById(it.id),
// //                     ),
// //                   );
// //                 }),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // /* ================= Widgets ================= */

// // class _SearchBar extends StatelessWidget {
// //   final TextEditingController controller;
// //   final VoidCallback onChanged;
// //   final VoidCallback onClear;

// //   const _SearchBar({
// //     required this.controller,
// //     required this.onChanged,
// //     required this.onClear,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 54,
// //       padding: const EdgeInsets.symmetric(horizontal: 12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(18),
// //         border: Border.all(color: AppColors.border),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha: 0.03),
// //             blurRadius: 18,
// //             offset: const Offset(0, 10),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.search_rounded, color: AppColors.muted),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: TextField(
// //               controller: controller,
// //               onChanged: (_) => onChanged(),
// //               style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
// //               decoration: const InputDecoration(
// //                 hintText: "Rechercher dans la liste…",
// //                 hintStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
// //                 border: InputBorder.none,
// //               ),
// //             ),
// //           ),
// //           if (controller.text.isNotEmpty)
// //             IconButton(
// //               onPressed: onClear,
// //               icon: const Icon(Icons.close_rounded, color: AppColors.muted),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _ListTile extends StatelessWidget {
// //   final GroceryItem item;
// //   final VoidCallback onToggle;
// //   final VoidCallback onRemove;

// //   const _ListTile({
// //     required this.item,
// //     required this.onToggle,
// //     required this.onRemove,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return InkWell(
// //       borderRadius: BorderRadius.circular(16),
// //       onTap: onToggle,
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         margin: const EdgeInsets.only(bottom: 10),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: AppColors.border),
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               height: 34,
// //               width: 34,
// //               decoration: BoxDecoration(
// //                 color: AppColors.soft,
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: AppColors.border),
// //               ),
// //               child: Icon(
// //                 item.done ? Icons.check_rounded : Icons.circle_outlined,
// //                 color: item.done ? AppColors.bordeaux : AppColors.muted,
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Text(
// //                 item.name,
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w900,
// //                   color: item.done ? AppColors.muted : AppColors.text,
// //                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
// //                 ),
// //               ),
// //             ),
// //             InkWell(
// //               borderRadius: BorderRadius.circular(12),
// //               onTap: onRemove,
// //               child: Container(
// //                 height: 34,
// //                 width: 34,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(color: AppColors.border),
// //                 ),
// //                 child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _SectionHeader extends StatelessWidget {
// //   final String title;
// //   final String actionText;
// //   final VoidCallback onAction;

// //   const _SectionHeader({
// //     required this.title,
// //     required this.actionText,
// //     required this.onAction,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: Text(
// //             title,
// //             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
// //           ),
// //         ),
// //         InkWell(
// //           borderRadius: BorderRadius.circular(12),
// //           onTap: onAction,
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: AppColors.soft,
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: AppColors.border),
// //             ),
// //             child: Text(
// //               actionText,
// //               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class _ProSheet extends StatelessWidget {
// //   final String title;
// //   final Widget child;
// //   const _ProSheet({required this.title, required this.child});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.all(12),
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(22),
// //         border: Border.all(color: AppColors.border),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha: 0.08),
// //             blurRadius: 22,
// //             offset: const Offset(0, 12),
// //           )
// //         ],
// //       ),
// //       child: SafeArea(
// //         top: false,
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               height: 4,
// //               width: 46,
// //               decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
// //             ),
// //             const SizedBox(height: 12),
// //             Row(
// //               children: [
// //                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
// //                 InkWell(
// //                   borderRadius: BorderRadius.circular(12),
// //                   onTap: () => Navigator.pop(context),
// //                   child: Container(
// //                     height: 36,
// //                     width: 36,
// //                     decoration: BoxDecoration(
// //                       color: AppColors.soft,
// //                       borderRadius: BorderRadius.circular(14),
// //                       border: Border.all(color: AppColors.border),
// //                     ),
// //                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 14),
// //             child,
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:elfaddoui_app/core/theme/app_colors.dart';
// import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

// import '../../cubit/grocery_list_cubit.dart';
// import '../../cubit/grocery_list_state.dart';

// class GroceryListScreen extends StatelessWidget {
//   const GroceryListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => GroceryListCubit(),
//       child: const _GroceryListView(),
//     );
//   }
// }

// class _GroceryListView extends StatefulWidget {
//   const _GroceryListView();

//   @override
//   State<_GroceryListView> createState() => _GroceryListViewState();
// }

// class _GroceryListViewState extends State<_GroceryListView> {
//   final _search = TextEditingController();

//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }

//   void _openAdd() {
//     final c = TextEditingController();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (sheetContext) {
//         final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;
//         return Padding(
//           padding: EdgeInsets.only(bottom: bottom),
//           child: _ProSheet(
//             title: "Ajouter un item",
//             child: Column(
//               children: [
//                 TextField(
//                   controller: c,
//                   decoration: InputDecoration(
//                     hintText: "Ex: Lait, Pain, Pâtes...",
//                     filled: true,
//                     fillColor: AppColors.fieldFill,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide(color: AppColors.border),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide(color: AppColors.border),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 48,
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       final txt = c.text.trim();
//                       if (txt.isNotEmpty) {
//                         context.read<GroceryListCubit>().addItem(txt);
//                       }
//                       Navigator.pop(sheetContext);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.bordeaux,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       "Ajouter",
//                       style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ).whenComplete(() => c.dispose());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           "📝 Liste de courses",
//           style: AppTextStyles.h3.copyWith(
//             fontWeight: FontWeight.w900,
//             color: AppColors.text,
//           ),
//         ),
//         actions: [
//           InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: () => context.read<GroceryListCubit>().clearDone(),
//             child: Container(
//               margin: const EdgeInsets.only(right: 12),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               decoration: BoxDecoration(
//                 color: AppColors.soft,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: const Text(
//                 "Nettoyer",
//                 style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
//               ),
//             ),
//           ),
//         ],
//       ),

//       floatingActionButton: FloatingActionButton(
//         heroTag: "grocery_fab",
//         backgroundColor: AppColors.bordeaux,
//         elevation: 0,
//         onPressed: _openAdd,
//         child: const Icon(Icons.add_rounded, color: Colors.white),
//       ),

//       body: BlocBuilder<GroceryListCubit, GroceryListState>(
//         builder: (context, s) {
//           final q = _search.text.trim().toLowerCase();
//           final filtered = s.items.where((it) {
//             if (q.isEmpty) return true;
//             return it.name.toLowerCase().contains(q);
//           }).toList();

//           final total = s.items.length;
//           final done = s.items.where((x) => x.done).length;
//           final progress = total == 0 ? 0.0 : done / total;

//           return ListView(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
//             children: [
//               // Progress
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: AppColors.soft,
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Progress",
//                             style: AppTextStyles.h3.copyWith(
//                               fontWeight: FontWeight.w900,
//                               color: AppColors.text,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           "$done / $total",
//                           style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(999),
//                       child: LinearProgressIndicator(
//                         value: progress,
//                         minHeight: 10,
//                         backgroundColor: Colors.white,
//                         color: AppColors.bordeaux,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Search
//               _SearchBar(
//                 controller: _search,
//                 onChanged: () => setState(() {}),
//                 onClear: () => setState(() => _search.clear()),
//               ),

//               const SizedBox(height: 16),

//               if (s.suggestions.isNotEmpty) ...[
//                 _SectionHeader(
//                   title: "✨ Suggestions IA",
//                   actionText: "Tout ajouter",
//                   onAction: () {
//                     for (final x in s.suggestions) {
//                       context.read<GroceryListCubit>().addItem(x);
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 10,
//                   children: s.suggestions.map((x) {
//                     return InkWell(
//                       borderRadius: BorderRadius.circular(999),
//                       onTap: () => context.read<GroceryListCubit>().addItem(x),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: AppColors.soft,
//                           borderRadius: BorderRadius.circular(999),
//                           border: Border.all(color: AppColors.border),
//                         ),
//                         child: Text(
//                           x,
//                           style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 16),
//               ],

//               _SectionHeader(
//                 title: "Votre liste",
//                 actionText: "Ajouter",
//                 onAction: _openAdd,
//               ),
//               const SizedBox(height: 10),

//               if (s.items.isEmpty)
//                 _EmptyBox("Votre liste est vide. Ajoutez des produits ✨")
//               else if (filtered.isEmpty)
//                 _EmptyBox("Aucun résultat pour cette recherche.")
//               else
//                 ...filtered.map((it) {
//                   return Dismissible(
//                     key: ValueKey(it.id), // ✅ unique stable
//                     direction: DismissDirection.endToStart,
//                     background: Container(
//                       margin: const EdgeInsets.only(bottom: 10),
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       alignment: Alignment.centerRight,
//                       decoration: BoxDecoration(
//                         color: AppColors.bordeaux.withValues(alpha: 0.12),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: AppColors.border),
//                       ),
//                       child: const Icon(Icons.delete_outline_rounded, color: AppColors.bordeaux),
//                     ),
//                     onDismissed: (_) => context.read<GroceryListCubit>().removeItemById(it.id),
//                     child: _ListTile(
//                       item: it,
//                       onToggle: () => context.read<GroceryListCubit>().toggleItemById(it.id),
//                       onRemove: () => context.read<GroceryListCubit>().removeItemById(it.id),
//                     ),
//                   );
//                 }),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// /* ================= Widgets ================= */

// class _SearchBar extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback onChanged;
//   final VoidCallback onClear;

//   const _SearchBar({
//     required this.controller,
//     required this.onChanged,
//     required this.onClear,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 54,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: AppColors.fieldFill,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.search_rounded, color: AppColors.muted),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               onChanged: (_) => onChanged(), // ✅ setState من parent
//               decoration: const InputDecoration(
//                 hintText: "Rechercher dans la liste…",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           if (controller.text.isNotEmpty)
//             IconButton(
//               onPressed: onClear,
//               icon: const Icon(Icons.close_rounded, color: AppColors.muted),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _ListTile extends StatelessWidget {
//   final GroceryItem item;
//   final VoidCallback onToggle;
//   final VoidCallback onRemove;

//   const _ListTile({
//     required this.item,
//     required this.onToggle,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: onToggle,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               item.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
//               color: item.done ? AppColors.bordeaux : AppColors.muted,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 item.name,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w900,
//                   color: item.done ? AppColors.muted : AppColors.text,
//                   decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
//                 ),
//               ),
//             ),
//             InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: onRemove,
//               child: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final String actionText;
//   final VoidCallback onAction;

//   const _SectionHeader({
//     required this.title,
//     required this.actionText,
//     required this.onAction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.text),
//           ),
//         ),
//         InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: onAction,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             decoration: BoxDecoration(
//               color: AppColors.soft,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.border),
//             ),
//             child: Text(
//               actionText,
//               style: const TextStyle(color: AppColors.bordeaux, fontWeight: FontWeight.w900),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _EmptyBox extends StatelessWidget {
//   final String text;
//   const _EmptyBox(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.soft,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
//       ),
//     );
//   }
// }

// class _ProSheet extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _ProSheet({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: AppColors.border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 22,
//             offset: const Offset(0, 12),
//           )
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(height: 4, width: 46, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999))),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900))),
//                 InkWell(
//                   borderRadius: BorderRadius.circular(12),
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     height: 36,
//                     width: 36,
//                     decoration: BoxDecoration(
//                       color: AppColors.soft,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: const Icon(Icons.close_rounded, color: AppColors.text, size: 18),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';

import '../../cubit/grocery_list_cubit.dart';
import '../../cubit/grocery_list_state.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroceryListCubit(),
      child: const _GroceryListView(),
    );
  }
}

class _GroceryListView extends StatefulWidget {
  const _GroceryListView();

  @override
  State<_GroceryListView> createState() => _GroceryListViewState();
}

class _GroceryListViewState extends State<_GroceryListView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openAdd(BuildContext context) {
    final c = TextEditingController();

    // ✅ نخزّنو cubit قبل ما نفتح الـ bottomSheet (باش ما نستعملوش context بعد pop)
    final cubit = context.read<GroceryListCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _ProSheet(
            title: "Ajouter un item",
            child: Column(
              children: [
                TextField(
                  controller: c,
                  decoration: InputDecoration(
                    hintText: "Ex: Lait, Pain, Pâtes...",
                    filled: true,
                    fillColor: AppColors.fieldFill,
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
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final txt = c.text.trim();
                      if (txt.isNotEmpty) cubit.addItem(txt);
                      Navigator.of(sheetContext).pop(); // ✅ safe pop
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bordeaux,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => c.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "📝 Liste de courses",
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.read<GroceryListCubit>().clearDone(),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                "Nettoyer",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.bordeaux,
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: "grocery_fab",
        backgroundColor: AppColors.bordeaux,
        elevation: 0,
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),

      body: BlocBuilder<GroceryListCubit, GroceryListState>(
        builder: (context, s) {
          final q = _search.text.trim().toLowerCase();
          final filteredItems = s.items.where((it) {
            if (q.isEmpty) return true;
            return it.name.toLowerCase().contains(q);
          }).toList();

          final total = s.items.length;
          final done = s.items.where((x) => x.done).length;
          final progress = total == 0 ? 0.0 : (done / total);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              // ✅ Progress
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Progress",
                            style: AppTextStyles.h3.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          "$done / $total",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.bordeaux,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white,
                        color: AppColors.bordeaux,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Search (FIX: setState بدل markNeedsBuild)
              _SearchBar(
                controller: _search,
                onChanged: (_) => setState(() {}),
                onClear: () => setState(() => _search.clear()),
              ),

              const SizedBox(height: 16),

              // Suggestions IA
              if (s.suggestions.isNotEmpty) ...[
                _SectionHeader(
                  title: "✨ Suggestions IA",
                  actionText: "Tout ajouter",
                  onAction: () {
                    for (final x in s.suggestions) {
                      context.read<GroceryListCubit>().addItem(x);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: s.suggestions.map((x) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => context.read<GroceryListCubit>().addItem(x),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.soft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: AppColors.bordeaux,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              x,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              _SectionHeader(
                title: "Votre liste",
                actionText: "Ajouter",
                onAction: () => _openAdd(context),
              ),
              const SizedBox(height: 10),

              if (s.items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    "Votre liste est vide. Ajoutez des produits ✨",
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (filteredItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.soft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    "Aucun résultat pour cette recherche.",
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                ...List.generate(filteredItems.length, (i) {
                  final it = filteredItems[i];
                  final realIndex = s.items.indexOf(it);

                  return Dismissible(
                    key: ValueKey("${it.name}-$realIndex"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: AppColors.bordeaux.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.bordeaux,
                      ),
                    ),
                    onDismissed: (_) =>
                        context.read<GroceryListCubit>().removeItem(realIndex),
                    child: _ListTile(
                      item: it,
                      onToggle: () =>
                          context.read<GroceryListCubit>().toggleItem(realIndex),
                      onRemove: () =>
                          context.read<GroceryListCubit>().removeItem(realIndex),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

// ---------------- Widgets ----------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                hintText: "Rechercher dans la liste…",
                hintStyle: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: AppColors.muted),
            ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _ListTile({
    required this.item,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onToggle,
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
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                item.done ? Icons.check_rounded : Icons.circle_outlined,
                color: item.done ? AppColors.bordeaux : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: item.done ? AppColors.muted : AppColors.text,
                  decoration: item.done
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onRemove,
              child: Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppColors.bordeaux,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _ProSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.text,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
