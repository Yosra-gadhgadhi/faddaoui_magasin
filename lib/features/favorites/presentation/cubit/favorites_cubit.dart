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
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';

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
  final Dio _dio;
  final TokenStorage _tokenStorage;
  Timer? _retryTimer;
  bool _syncInFlight = false;
  bool serverAvailable = true;
  bool hasSynced = false;
  bool unauthorized = false;

  FavoritesCubit(this._dio, this._tokenStorage) : super({}) {
    syncFromServer();
  }

  bool isFavorite(String id) => state.containsKey(id);

  Future<bool> toggle(FavoriteItem item) async {
    final pid = int.tryParse(item.id);
    if (pid == null) {
      await syncFromServer();
      return isFavorite(item.id);
    }

    try {
      final r = await _dio.post('/api/favorites/$pid/toggle');
      if ((r.statusCode ?? 500) >= 400) {
        await syncFromServer();
        return isFavorite(item.id);
      }
      _applyToggleResponse(r.data, fallbackItem: item);
      return isFavorite(item.id);
    } catch (_) {
      await syncFromServer();
      return isFavorite(item.id);
    }
  }

  Future<void> remove(String id) async {
    final pid = int.tryParse(id);
    if (pid == null) {
      await syncFromServer();
      return;
    }
    try {
      final r = await _dio.delete('/api/favorites/$pid');
      if ((r.statusCode ?? 500) >= 400) {
        await syncFromServer();
      } else {
        await syncFromServer();
      }
    } catch (_) {
      await syncFromServer();
    }
  }

  Future<void> clear() async {
    final ids = state.keys.toList(growable: false);
    for (final id in ids) {
      final pid = int.tryParse(id);
      if (pid == null) continue;
      try {
        await _dio.delete('/api/favorites/$pid');
      } catch (_) {
        // Best effort.
      }
    }
    await syncFromServer();
  }

  Future<void> syncFromServer() async {
    if (_syncInFlight) return;
    _syncInFlight = true;
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      unauthorized = false;
      serverAvailable = true;
      _stopAutoRetry();
      _syncInFlight = false;
      return;
    }

    try {
      final r = await _dio.get('/api/favorites');
      final status = r.statusCode ?? 500;
      hasSynced = true;
      if (status == 401 || status == 403) {
        unauthorized = true;
        serverAvailable = false;
        _stopAutoRetry();
        emit(Map<String, FavoriteItem>.from(state));
        return;
      }
      if (status >= 400) {
        unauthorized = false;
        serverAvailable = false;
        _ensureAutoRetry();
        emit(Map<String, FavoriteItem>.from(state));
        _syncInFlight = false;
        return;
      }
      unauthorized = false;
      serverAvailable = true;
      _stopAutoRetry();
      _applyFavoritesList(r.data);
    } catch (_) {
      hasSynced = true;
      unauthorized = false;
      serverAvailable = false;
      _ensureAutoRetry();
      emit(Map<String, FavoriteItem>.from(state));
    } finally {
      _syncInFlight = false;
    }
  }

  void _applyFavoritesList(dynamic data) {
    if (data is! List) {
      emit({});
      return;
    }
    final map = <String, FavoriteItem>{};
    for (final raw in data) {
      final item = _fromBackendItem(raw);
      if (item == null) continue;
      map[item.id] = item;
    }
    emit(map);
  }

  void _applyToggleResponse(dynamic data, {required FavoriteItem fallbackItem}) {
    if (data is! Map) return;
    final fav = data['favorite'];
    if (fav is bool) {
      final next = Map<String, FavoriteItem>.from(state);
      if (fav) {
        final parsed = _fromBackendItem(data['item']);
        next[fallbackItem.id] = parsed ?? fallbackItem;
      } else {
        next.remove(fallbackItem.id);
      }
      emit(next);
    }
  }

  FavoriteItem? _fromBackendItem(dynamic raw) {
    if (raw is! Map) return null;
    final productId = raw['productId'];
    if (productId == null) return null;
    final id = '$productId';
    final name = (raw['name'] ?? '').toString();
    final image = ApiConstants.resolveAssetUrl((raw['imageUrl'] ?? '').toString());
    final price = _toDouble(raw['price']);
    return FavoriteItem(id: id, name: name, image: image, price: price);
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  void _persist(Map<String, FavoriteItem> data) {
    // Storage persistence is intentionally removed after backend sync migration.
    if (data.isEmpty) {
      // no-op
    }
  }

  void _ensureAutoRetry() {
    _retryTimer ??= Timer.periodic(const Duration(seconds: 4), (_) {
      syncFromServer();
    });
  }

  void _stopAutoRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  Future<void> close() {
    _stopAutoRetry();
    return super.close();
  }
}
