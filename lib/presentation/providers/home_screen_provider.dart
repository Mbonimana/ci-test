import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/repositories/category_repository.dart';
import 'package:street_team/data/services/category_service.dart';

class HomeCategoryState {
  final List<String> categories;
  final List<String> selectedCategories;
  final bool isExpanded;

  HomeCategoryState({
    required this.categories,
    required this.selectedCategories,
    required this.isExpanded,
  });

  HomeCategoryState copyWith({
    List<String>? categories,
    List<String>? selectedCategories,
    bool? isExpanded,
  }) {
    return HomeCategoryState(
      categories: categories ?? this.categories,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

final categoryServiceProvider = Provider((ref) => CategoryService());
final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(ref.watch(categoryServiceProvider)),
);

// The Notifier
class HomeCategoryNotifier
    extends StateNotifier<AsyncValue<HomeCategoryState>> {
  final CategoryRepository _repository;

  HomeCategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    try {
      final list = await _repository.getHomeCategories();
      state = AsyncValue.data(
        HomeCategoryState(
          categories: list,
          selectedCategories: [], // Initialized as empty list
          isExpanded: false,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void toggleExpansion() {
    state.whenData(
      (data) =>
          state = AsyncValue.data(data.copyWith(isExpanded: !data.isExpanded)),
    );
  }

  // multi-select toggle
  void toggleCategory(String category) {
    state.whenData((data) {
      final currentList = [...data.selectedCategories];
      if (currentList.contains(category)) {
        currentList.remove(category);
      } else {
        currentList.add(category);
      }
      state = AsyncValue.data(data.copyWith(selectedCategories: currentList));
    });
  }
}

final homeCategoryProvider =
    StateNotifierProvider<HomeCategoryNotifier, AsyncValue<HomeCategoryState>>((
      ref,
    ) {
      return HomeCategoryNotifier(ref.watch(categoryRepositoryProvider));
    });
