// import 'package:flutter_bloc/flutter_bloc.dart';

// class FavoriteItem {
//   final String id;
//   final String name;
//   final String image;
//   final double price;

//   const FavoriteItem({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.price,
//   });
// }

// class FavoritesCubit extends Cubit<Map<String, FavoriteItem>> {
//   FavoritesCubit() : super({});

//   bool isFavorite(String id) => state.containsKey(id);

//   void toggle(FavoriteItem item) {
//     final newState = Map<String, FavoriteItem>.from(state);
//     if (newState.containsKey(item.id)) {
//       newState.remove(item.id);
//     } else {
//       newState[item.id] = item;
//     }
//     emit(newState);
//   }

//   void remove(String id) {
//     final newState = Map<String, FavoriteItem>.from(state);
//     newState.remove(id);
//     emit(newState);
//   }

//   void clear() => emit({});
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String id;
  final String name;
  final String image;
  final double price;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });
}

class FavoritesCubit extends Cubit<Map<String, FavoriteItem>> {
  static const _storageKey = 'favorites_v1';

  FavoritesCubit() : super({}) {
    _hydrate();
  }

  bool isFavorite(String id) => state.containsKey(id);

  void toggle(FavoriteItem item) {
    final newState = Map<String, FavoriteItem>.from(state);
    if (newState.containsKey(item.id)) {
      newState.remove(item.id);
    } else {
      newState[item.id] = item;
    }
    emit(newState);
    _persist(newState);
  }

  void remove(String id) {
    final newState = Map<String, FavoriteItem>.from(state);
    newState.remove(id);
    emit(newState);
    _persist(newState);
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

      final map = <String, FavoriteItem>{};
      for (final line in raw) {
        // id|name|image|price
        final parts = line.split('|');
        if (parts.length < 4) continue;
        final id = parts[0];
        final name = parts[1];
        final image = parts[2];
        final price = double.tryParse(parts[3]) ?? 0.0;
        map[id] = FavoriteItem(id: id, name: name, image: image, price: price);
      }
      emit(map);
    } catch (_) {
      // Keep app resilient: if corrupted storage, fallback to empty state.
    }
  }

  Future<void> _persist(Map<String, FavoriteItem> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = data.values
          .map((e) => '${e.id}|${e.name}|${e.image}|${e.price}')
          .toList(growable: false);
      await prefs.setStringList(_storageKey, raw);
    } catch (_) {
      // Ignore storage errors to avoid blocking UI interactions.
    }
  }
}
