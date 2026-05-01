import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:elfaddoui_app/core/storage/token_storage.dart';

class NotificationsState {
  final int unreadCount;
  final bool loading;

  const NotificationsState({
    required this.unreadCount,
    required this.loading,
  });

  factory NotificationsState.initial() => const NotificationsState(
        unreadCount: 0,
        loading: false,
      );

  NotificationsState copyWith({
    int? unreadCount,
    bool? loading,
  }) {
    return NotificationsState(
      unreadCount: unreadCount ?? this.unreadCount,
      loading: loading ?? this.loading,
    );
  }
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._dio, this._storage) : super(NotificationsState.initial()) {
    refreshUnreadCount();
  }

  final Dio _dio;
  final TokenStorage _storage;

  Future<Options> _authOptions() async {
    final token = await _storage.readToken();
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      validateStatus: (code) => code != null && code < 500,
    );
  }

  Future<void> refreshUnreadCount() async {
    emit(state.copyWith(loading: true));
    try {
      const endpoints = [
        '/api/notifications',
        '/api/notifications/in-app',
        '/api/users/me/notifications',
      ];

      for (final path in endpoints) {
        final r = await _dio.get(path, options: await _authOptions());
        final status = r.statusCode ?? 500;
        if (status == 404 || status == 405) {
          continue;
        }
        if (status >= 400) {
          break;
        }

        final unread = _computeUnreadFromPayload(r.data);
        emit(state.copyWith(unreadCount: unread, loading: false));
        return;
      }
    } catch (_) {
      // Keep old unread count on failure.
    }
    emit(state.copyWith(loading: false));
  }

  void setUnreadCount(int value) {
    emit(state.copyWith(unreadCount: value < 0 ? 0 : value));
  }

  int _computeUnreadFromPayload(dynamic data) {
    List raw = const [];
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final items = map['items'] ?? map['content'] ?? map['notifications'] ?? map['data'];
      if (items is List) raw = items;
    }

    int unread = 0;
    for (final row in raw.whereType<Map>()) {
      final item = Map<String, dynamic>.from(row);
      final unreadFlag = item['unread'];
      final readFlag = item['read'];
      final isUnread = unreadFlag is bool
          ? unreadFlag
          : !(readFlag is bool ? readFlag : false);
      if (isUnread) unread++;
    }
    return unread;
  }
}

