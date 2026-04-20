import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:elfaddoui_app/core/theme/app_colors.dart';
import 'package:elfaddoui_app/core/theme/app_text_styles.dart';
import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';
import 'package:elfaddoui_app/features/catalog/presentation/screens/product_details_screen.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/* ===================== MODELS ===================== */

enum ChatRole { user, bot }

class ChatSource {
  final String title;
  final String? url;
  const ChatSource({required this.title, this.url});
}

class ChatProductCard {
  final String id;
  final String name;
  final String image;
  final double price;
  final String? badge;
  const ChatProductCard({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.badge,
  });
}

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime at;
  final List<ChatProductCard> products;
  final List<ChatSource> sources;

  const ChatMessage({
    required this.role,
    required this.text,
    required this.at,
    this.products = const [],
    this.sources = const [],
  });
}

/* ===================== SCREEN ===================== */

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _c = TextEditingController();
  final _scroll = ScrollController();

  bool _sending = false;

  final List<ChatMessage> _msgs = [
    ChatMessage(
      role: ChatRole.bot,
      text:
          "Salut 👋 Je suis ton assistant ElFaddaoui.\nDis-moi ce que tu cherches (ex: “lait pas cher”, “recette omelette”, “panier 50 DT”).",
      at: DateTime.now(),
    ),
  ];

  AiHomeService get _ai => context.read<HomeCubit>().ai;

  @override
  void dispose() {
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    if (!_scroll.hasClients) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _push(ChatMessage m) {
    setState(() => _msgs.add(m));
    _scrollDown();
  }

  Future<void> _sendText([String? override]) async {
    final text = (override ?? _c.text).trim();
    if (text.isEmpty || _sending) return;

    HapticFeedback.lightImpact();
    _c.clear();

    _push(ChatMessage(role: ChatRole.user, text: text, at: DateTime.now()));
    setState(() => _sending = true);

    try {
      final state = context.read<HomeCubit>().state;
      final catalog = <Product>[...state.forYou, ...state.deals];

      final lower = text.toLowerCase();
      if (lower.contains("recette") || lower.contains("cuisin") || lower.contains("ingr")) {
        final r = await _ai.recipeIdea(text);
        _push(ChatMessage(role: ChatRole.bot, text: r, at: DateTime.now()));
      } else if (lower.contains("budget") || lower.contains("dt") || lower.contains("panier")) {
        final budget = _extractBudget(text) ?? 50.0;
        final plan = await _ai.budgetPlan(budget, catalog);

        _push(
          ChatMessage(
            role: ChatRole.bot,
            text: "Voilà une proposition pour ~${budget.toStringAsFixed(0)} DT :",
            at: DateTime.now(),
            products: plan
                .take(6)
                .map((p) => ChatProductCard(
                      id: p.id,
                      name: p.name,
                      image: p.image,
                      price: p.price,
                      badge: "Sélection",
                    ))
                .toList(),
            sources: const [ChatSource(title: "Catalogue interne")],
          ),
        );
      } else {
        final res = await _ai.smartSearch(text, catalog);

        if (res.isEmpty) {
          _push(
            ChatMessage(
              role: ChatRole.bot,
              text: "Je n’ai rien trouvé pour “$text”. Essaie lait, pâtes, riz…",
              at: DateTime.now(),
            ),
          );
        } else {
          _push(
            ChatMessage(
              role: ChatRole.bot,
              text: "J’ai trouvé ces produits :",
              at: DateTime.now(),
              products: res
                  .take(6)
                  .map((p) => ChatProductCard(
                        id: p.id,
                        name: p.name,
                        image: p.image,
                        price: p.price,
                        badge: "Résultat",
                      ))
                  .toList(),
              sources: const [ChatSource(title: "Catalogue interne")],
            ),
          );
        }
      }
    } catch (e) {
      _push(ChatMessage(role: ChatRole.bot, text: "Oups 😅 erreur: ${e.toString()}", at: DateTime.now()));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollDown();
      }
    }
  }

  double? _extractBudget(String text) {
    final m = RegExp(r'(\d{1,4})').firstMatch(text);
    if (m == null) return null;
    return double.tryParse(m.group(1)!);
  }

  void _openProduct(String id) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(productId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.bordeaux, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Assistant IA", style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                const Text(
                  "Recherche • Recettes • Budget",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, height: 1),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ChipMini(icon: Icons.search_rounded, text: "Search", onTap: () => _sendText("lait pas cher")),
                  const SizedBox(width: 10),
                  _ChipMini(icon: Icons.restaurant_rounded, text: "Recette", onTap: () => _sendText("recette rapide")),
                  const SizedBox(width: 10),
                  _ChipMini(icon: Icons.savings_rounded, text: "Budget 50", onTap: () => _sendText("budget 50 dt")),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                final isUser = m.role == ChatRole.user;
                return _BubbleClean(
                  isUser: isUser,
                  text: m.text,
                  products: m.products,
                  sources: m.sources,
                  onOpenProduct: _openProduct,
                );
              },
            ),
          ),

          _InputClean(
            controller: _c,
            sending: _sending,
            onSend: () => _sendText(),
          ),
        ],
      ),
    );
  }
}

/* ===================== UI ===================== */

class _ChipMini extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _ChipMini({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.bordeaux),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class _BubbleClean extends StatelessWidget {
  final bool isUser;
  final String text;
  final List<ChatProductCard> products;
  final List<ChatSource> sources;
  final void Function(String productId) onOpenProduct;

  const _BubbleClean({
    required this.isUser,
    required this.text,
    required this.products,
    required this.sources,
    required this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? AppColors.bordeaux : Colors.white;
    final textColor = isUser ? Colors.white : AppColors.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 330),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
              border: isUser ? null : Border.all(color: AppColors.border.withValues(alpha: 0.85)),
            ),
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800, height: 1.25),
            ),
          ),

          if (products.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _MiniProductClean(
                  p: products[i],
                  onTap: () => onOpenProduct(products[i].id),
                ),
              ),
            ),
          ],

          if (sources.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sources", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 6),
                  ...sources.map(
                    (s) => Text(
                      "• ${s.title}",
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniProductClean extends StatelessWidget {
  final ChatProductCard p;
  final VoidCallback onTap;
  const _MiniProductClean({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                p.image,
                height: 62,
                width: 62,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 62,
                  width: 62,
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
                  const SizedBox(height: 6),
                  Text(
                    "${p.price.toStringAsFixed(2)} DT",
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux),
                  ),
                  const Spacer(),
                  if (p.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        p.badge!,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.bordeaux, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputClean extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _InputClean({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.85))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: "Écrire un message…",
                  filled: true,
                  fillColor: AppColors.fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.bordeaux.withValues(alpha: 0.55), width: 1.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: sending ? null : () {
                HapticFeedback.lightImpact();
                onSend();
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.bordeaux,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
