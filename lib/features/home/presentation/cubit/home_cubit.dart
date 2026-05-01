import 'package:elfaddoui_app/features/home/services/ai_home_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AiHomeService ai;

  HomeCubit(this.ai) : super(const HomeState());

  Future<void> init() async {
    if (isClosed) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await ai.bootstrapHome();
      if (isClosed) return;
      emit(state.copyWith(
        loading: false,
        error: null,
        locationLabel: data.locationLabel,
        etaLabel: data.etaLabel,
        deals: data.deals,
        forYou: data.forYou,
        recent: data.recent,
        list: data.list,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        loading: false,
        error: "Backend non disponible. Vérifie le serveur /api/home.",
      ));
    }
  }

  Future<Product?> getProductById(String productId) =>
      ai.getProductById(productId);

  void toggleListItem(int index) {
    if (isClosed) return;
    final updated = [...state.list];
    updated[index] = updated[index].copyWith(done: !updated[index].done);
    emit(state.copyWith(list: updated));
  }

  void addListItem(String name) {
    if (isClosed) return;
    final updated = [GroceryItem(name), ...state.list];
    emit(state.copyWith(list: updated));
  }

  void removeListItem(int index) {
    if (isClosed) return;
    final updated = [...state.list]..removeAt(index);
    emit(state.copyWith(list: updated));
  }
}
