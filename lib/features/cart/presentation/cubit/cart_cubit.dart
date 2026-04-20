import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLine {
  final String id;
  final String name;
  final String image;
  final double price;
  final int qty;

  const CartLine({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.qty = 1,
  });

  CartLine copyWith({
    String? id,
    String? name,
    String? image,
    double? price,
    int? qty,
  }) {
    return CartLine(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      qty: qty ?? this.qty,
    );
  }
}

class CartCubit extends Cubit<Map<String, CartLine>> {
  static const _storageKey = 'cart_v1';

  CartCubit() : super({}) {
    _hydrate();
  }

  int get totalItems => state.values.fold(0, (sum, e) => sum + e.qty);

  bool contains(String id) => state.containsKey(id);

  void add({
    required String id,
    required String name,
    required String image,
    required double price,
    int qty = 1,
  }) {
    final next = Map<String, CartLine>.from(state);
    if (next.containsKey(id)) {
      final current = next[id]!;
      next[id] = current.copyWith(qty: current.qty + qty);
    } else {
      next[id] = CartLine(
        id: id,
        name: name,
        image: image,
        price: price,
        qty: qty,
      );
    }
    emit(next);
    _persist(next);
  }

  void remove(String id) {
    final next = Map<String, CartLine>.from(state)..remove(id);
    emit(next);
    _persist(next);
  }

  void setQty(String id, int qty) {
    if (!state.containsKey(id)) return;
    if (qty <= 0) {
      remove(id);
      return;
    }
    final next = Map<String, CartLine>.from(state);
    next[id] = next[id]!.copyWith(qty: qty);
    emit(next);
    _persist(next);
  }

  void clear() {
    emit({});
    _persist(const {});
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey) ?? const <String>[];
      if (raw.isEmpty) return;
      final map = <String, CartLine>{};
      for (final line in raw) {
        // id|name|image|price|qty
        final parts = line.split('|');
        if (parts.length < 5) continue;
        final id = parts[0];
        final name = parts[1];
        final image = parts[2];
        final price = double.tryParse(parts[3]) ?? 0;
        final qty = int.tryParse(parts[4]) ?? 1;
        map[id] = CartLine(
          id: id,
          name: name,
          image: image,
          price: price,
          qty: qty,
        );
      }
      emit(map);
    } catch (_) {
      // Ignore storage corruption and continue with empty cart.
    }
  }

  Future<void> _persist(Map<String, CartLine> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = data.values
          .map((e) => '${e.id}|${e.name}|${e.image}|${e.price}|${e.qty}')
          .toList(growable: false);
      await prefs.setStringList(_storageKey, raw);
    } catch (_) {
      // Ignore persistence errors; cart stays functional in memory.
    }
  }
}
