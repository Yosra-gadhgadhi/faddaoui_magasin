import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/ai_models.dart';
import '../../domain/ai_service.dart';

class AiState {
  final bool loadingRecs;
  final List<AiRecommendation> recs;

  final bool loadingCompare;
  final PriceComparison? comparison;

  final String? error;

  const AiState({
    this.loadingRecs = false,
    this.recs = const [],
    this.loadingCompare = false,
    this.comparison,
    this.error,
  });

  AiState copyWith({
    bool? loadingRecs,
    List<AiRecommendation>? recs,
    bool? loadingCompare,
    PriceComparison? comparison,
    String? error,
  }) {
    return AiState(
      loadingRecs: loadingRecs ?? this.loadingRecs,
      recs: recs ?? this.recs,
      loadingCompare: loadingCompare ?? this.loadingCompare,
      comparison: comparison ?? this.comparison,
      error: error,
    );
  }
}

class AiCubit extends Cubit<AiState> {
  final AiService service;

  AiCubit(this.service) : super(const AiState());

  Future<void> loadRecommendations({
    required List<String> favoriteProductIds,
    required List<String> cartProductIds,
    required List<String> recentViewedProductIds,
  }) async {
    emit(state.copyWith(loadingRecs: true, error: null));
    try {
      final res = await service.getPersonalizedRecommendations(
        favoriteProductIds: favoriteProductIds,
        cartProductIds: cartProductIds,
        recentViewedProductIds: recentViewedProductIds,
      );
      emit(state.copyWith(loadingRecs: false, recs: res));
    } catch (e) {
      emit(state.copyWith(loadingRecs: false, error: e.toString()));
    }
  }

  Future<void> comparePrice({
    required String productId,
    required double ourPrice,
  }) async {
    emit(state.copyWith(loadingCompare: true, error: null, comparison: null));
    try {
      final res = await service.comparePrice(productId: productId, ourPrice: ourPrice);
      emit(state.copyWith(loadingCompare: false, comparison: res));
    } catch (e) {
      emit(state.copyWith(loadingCompare: false, error: e.toString()));
    }
  }
}
