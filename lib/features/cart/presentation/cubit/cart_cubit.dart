import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:elfaddoui_app/core/network/api_constants.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';

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
  final Dio _dio;
  final TokenStorage _tokenStorage;
  Timer? _retryTimer;
  bool _syncInFlight = false;
  bool serverAvailable = true;
  bool hasSynced = false;
  bool unauthorized = false;

  CartCubit(this._dio, this._tokenStorage) : super({}) {
    syncFromServer();
  }

  int get totalItems => state.values.fold(0, (sum, e) => sum + e.qty);

  bool contains(String id) => state.containsKey(id);

  Future<void> add({
    required String id,
    required String name,
    required String image,
    required double price,
    int qty = 1,
  }) async {
    final pid = int.tryParse(id);
    if (pid == null) {
      await syncFromServer();
      return;
    }
    try {
      final r = await _dio.post(
        '/api/cart/items',
        data: {'productId': pid, 'qty': qty},
      );
      if ((r.statusCode ?? 500) >= 400) {
        await syncFromServer();
      } else {
        if (r.data is Map && (r.data as Map).containsKey('items')) {
          _applyServerCart(r.data);
        } else {
          await syncFromServer();
        }
      }
    } catch (_) {
      await syncFromServer();
    }
  }

  Future<void> remove(String id) async {
    final pid = int.tryParse(id);
    if (pid == null) {
      await syncFromServer();
      return;
    }
    try {
      final r = await _dio.delete('/api/cart/items/$pid');
      if ((r.statusCode ?? 500) >= 400) {
        await syncFromServer();
      } else {
        await syncFromServer();
      }
    } catch (_) {
      await syncFromServer();
    }
  }

  Future<void> setQty(String id, int qty) async {
    if (!state.containsKey(id)) return;
    if (qty <= 0) {
      await remove(id);
      return;
    }
    final pid = int.tryParse(id);
    if (pid == null) {
      await syncFromServer();
      return;
    }
    try {
      final r = await _dio.patch(
        '/api/cart/items/$pid',
        data: {'qty': qty},
      );
      if ((r.statusCode ?? 500) >= 400) {
        await syncFromServer();
      } else {
        if (r.data is Map && (r.data as Map).containsKey('items')) {
          _applyServerCart(r.data);
        } else {
          await syncFromServer();
        }
      }
    } catch (_) {
      await syncFromServer();
    }
  }

  Future<void> clear() async {
    try {
      final r = await _dio.delete('/api/cart');
      if ((r.statusCode ?? 500) >= 400) {
        await syncFromServer();
      } else {
        emit({});
      }
    } catch (_) {
      await syncFromServer();
    }
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
      final r = await _dio.get('/api/cart');
      final status = r.statusCode ?? 500;
      hasSynced = true;
      if (status == 401 || status == 403) {
        unauthorized = true;
        serverAvailable = false;
        _stopAutoRetry();
        emit(Map<String, CartLine>.from(state));
        return;
      }
      if (status >= 400) {
      unauthorized = false;
      serverAvailable = false;
      _ensureAutoRetry();
      emit(Map<String, CartLine>.from(state));
      _syncInFlight = false;
      return;
    }
      unauthorized = false;
      serverAvailable = true;
      _stopAutoRetry();
      _applyServerCart(r.data);
    } catch (_) {
      hasSynced = true;
      unauthorized = false;
      serverAvailable = false;
      _ensureAutoRetry();
      emit(Map<String, CartLine>.from(state));
    } finally {
      _syncInFlight = false;
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

  void _applyServerCart(dynamic data) {
    if (data is! Map) return;
    final items = data['items'];
    if (items is! List) {
      emit({});
      return;
    }

    final map = <String, CartLine>{};
    for (final raw in items) {
      if (raw is! Map) continue;
      final productId = raw['productId'];
      if (productId == null) continue;
      final id = '$productId';
      final name = (raw['name'] ?? '').toString();
      final image = ApiConstants.resolveAssetUrl((raw['imageUrl'] ?? '').toString());
      final price = _toDouble(raw['price']);
      final qty = _toInt(raw['qty'], fallback: 1);
      map[id] = CartLine(
        id: id,
        name: name,
        image: image,
        price: price,
        qty: qty,
      );
    }
    emit(map);
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  int _toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }
}
