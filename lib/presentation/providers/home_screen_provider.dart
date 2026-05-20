import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/presentation/providers/organization_provider.dart';

class HomeState {
  final List<String> categories;
  final List<String> selectedCategories;
  final bool isExpanded;

  HomeState({
    required this.categories,
    required this.selectedCategories,
    required this.isExpanded,
  });

  HomeState copyWith({
    List<String>? categories,
    List<String>? selectedCategories,
    bool? isExpanded,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref ref;

  HomeNotifier(this.ref)
    : super(
        HomeState(categories: [], selectedCategories: [], isExpanded: false),
      ) {
    _init();
  }

  void _init() {
    ref.listen<AsyncValue<List<OrganizationModel>>>(organizationsProvider, (
      prev,
      next,
    ) {
      next.whenData((orgs) {
        final categories = orgs.map((e) => e.primaryType).toSet().toList()
          ..sort();

        state = state.copyWith(categories: categories);
      });
    });
  }

  void toggleExpansion() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void toggleCategory(String category) {
    final updated = [...state.selectedCategories];

    if (updated.contains(category)) {
      updated.remove(category);
    } else {
      updated.add(category);
    }

    state = state.copyWith(selectedCategories: updated);

    // sync to global filter provider
    ref.read(organizationTypeFilterProvider.notifier).state = updated.toSet();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
final homeFilteredOrganizationsProvider = Provider<List<OrganizationModel>>((
  ref,
) {
  final orgsAsync = ref.watch(organizationsProvider);
  final homeState = ref.watch(homeProvider);

  return orgsAsync.when(
    data: (orgs) {
      final selected = homeState.selectedCategories;

      if (selected.isEmpty) return orgs;

      return orgs
          .where((o) => selected.contains(o.primaryType))
          .toList(growable: false);
    },
    loading: () => const [],
    error: (_, _) => const [],
  );
});
