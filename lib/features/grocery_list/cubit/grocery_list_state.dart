// // import 'package:equatable/equatable.dart';

// // class GroceryItem extends Equatable {
// //   final String name;
// //   final bool done;

// //   const GroceryItem({
// //     required this.name,
// //     this.done = false,
// //   });

// //   GroceryItem copyWith({String? name, bool? done}) {
// //     return GroceryItem(
// //       name: name ?? this.name,
// //       done: done ?? this.done,
// //     );
// //   }

// //   @override
// //   List<Object?> get props => [name, done];
// // }

// // class GroceryListState extends Equatable {
// //   final bool loading;
// //   final List<GroceryItem> items;
// //   final List<String> suggestions; // “IA” suggestions (simple)

// //   const GroceryListState({
// //     this.loading = false,
// //     this.items = const [],
// //     this.suggestions = const [],
// //   });

// //   GroceryListState copyWith({
// //     bool? loading,
// //     List<GroceryItem>? items,
// //     List<String>? suggestions,
// //   }) {
// //     return GroceryListState(
// //       loading: loading ?? this.loading,
// //       items: items ?? this.items,
// //       suggestions: suggestions ?? this.suggestions,
// //     );
// //   }

// //   @override
// //   List<Object?> get props => [loading, items, suggestions];
// // }

// import 'package:equatable/equatable.dart';

// class GroceryItem extends Equatable {
//   final String name;
//   final bool done;

//   const GroceryItem({
//     required this.name,
//     this.done = false,
//   });

//   GroceryItem copyWith({String? name, bool? done}) {
//     return GroceryItem(
//       name: name ?? this.name,
//       done: done ?? this.done,
//     );
//   }

//   @override
//   List<Object?> get props => [name, done];
// }

// class GroceryListState extends Equatable {
//   final List<GroceryItem> items;
//   final List<String> suggestions;

//   const GroceryListState({
//     this.items = const [],
//     this.suggestions = const [],
//   });

//   GroceryListState copyWith({
//     List<GroceryItem>? items,
//     List<String>? suggestions,
//   }) {
//     return GroceryListState(
//       items: items ?? this.items,
//       suggestions: suggestions ?? this.suggestions,
//     );
//   }

//   @override
//   List<Object?> get props => [items, suggestions];
// }

import 'package:equatable/equatable.dart';

class GroceryItem extends Equatable {
  final String name;
  final bool done;

  const GroceryItem({
    required this.name,
    this.done = false,
  });

  GroceryItem copyWith({String? name, bool? done}) {
    return GroceryItem(
      name: name ?? this.name,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [name, done];
}

class GroceryListState extends Equatable {
  final bool loading;
  final List<GroceryItem> items;
  final List<String> suggestions;

  const GroceryListState({
    this.loading = false,
    this.items = const [],
    this.suggestions = const [],
  });

  GroceryListState copyWith({
    bool? loading,
    List<GroceryItem>? items,
    List<String>? suggestions,
  }) {
    return GroceryListState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [loading, items, suggestions];
}
