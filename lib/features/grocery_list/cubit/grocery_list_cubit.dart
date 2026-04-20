import 'package:flutter_bloc/flutter_bloc.dart';
import 'grocery_list_state.dart';

class GroceryListCubit extends Cubit<GroceryListState> {
  GroceryListCubit() : super(const GroceryListState());

  void addItem(String name) {
    final txt = name.trim();
    if (txt.isEmpty) return;

    final updated = [GroceryItem(name: txt), ...state.items];
    emit(state.copyWith(items: updated));
    _refreshSuggestions();
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final updated = [...state.items]..removeAt(index);
    emit(state.copyWith(items: updated));
    _refreshSuggestions();
  }

  void toggleItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final updated = [...state.items];
    updated[index] = updated[index].copyWith(done: !updated[index].done);
    emit(state.copyWith(items: updated));
  }

  void clearDone() {
    final updated = state.items.where((e) => !e.done).toList();
    emit(state.copyWith(items: updated));
    _refreshSuggestions();
  }

  void _refreshSuggestions() {
    final lower = state.items.map((e) => e.name.toLowerCase()).toList();
    final s = <String>{};

    bool has(String key) => lower.any((x) => x.contains(key));

    if (has("pâtes") || has("pates") || has("spaghetti")) {
      s.addAll(["Sauce tomate", "Thon", "Fromage râpé"]);
    }
    if (has("lait")) {
      s.addAll(["Céréales", "Café"]);
    }
    if (has("pain")) {
      s.addAll(["Beurre", "Confiture"]);
    }
    if (has("tomate") || has("tomates")) {
      s.addAll(["Oignon", "Poivron"]);
    }

    emit(state.copyWith(suggestions: s.toList()));
  }
}
