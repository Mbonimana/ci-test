import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/presentation/providers/types_provider.dart';

enum CategoryMode { organization, location }

class HomeState {
  final List<int> types;
  final List<int> selectedTypes;
  final bool isExpanded;
  final CategoryMode mode;

  const HomeState({
    required this.types,
    required this.selectedTypes,
    required this.isExpanded,
    required this.mode,
  });

  HomeState copyWith({
    List<int>? types,
    List<int>? selectedTypes,
    bool? isExpanded,
    CategoryMode? mode,
  }) {
    return HomeState(
      types: types ?? this.types,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      isExpanded: isExpanded ?? this.isExpanded,
      mode: mode ?? this.mode,
    );
  }
}

final organizationTypeFilterProvider = StateProvider<Set<int>>((ref) => {});

final locationTypeFilterProvider = StateProvider<Set<int>>((ref) => {});

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref ref;

  HomeNotifier(this.ref)
    : super(
        const HomeState(
          types: [],
          selectedTypes: [],
          isExpanded: false,
          mode: CategoryMode.organization,
        ),
      ) {
    _listenToTypes();
  }

  void _listenToTypes() {
    ref.listen<AsyncValue<List<TypeModel>>>(organizationTypesProvider, (
      previous,
      next,
    ) {
      if (state.mode != CategoryMode.organization) return;

      next.whenData((list) {
        state = state.copyWith(types: list.map((e) => e.id).toList());
      });
    }, fireImmediately: true);

    ref.listen<AsyncValue<List<TypeModel>>>(locationTypesProvider, (
      previous,
      next,
    ) {
      if (state.mode != CategoryMode.location) return;

      next.whenData((list) {
        state = state.copyWith(types: list.map((e) => e.id).toList());
      });
    }, fireImmediately: true);
  }

  void switchMode(CategoryMode mode) {
    state = state.copyWith(mode: mode, selectedTypes: []);

    final provider = mode == CategoryMode.organization
        ? organizationTypesProvider
        : locationTypesProvider;

    final asyncValue = ref.read(provider);

    asyncValue.whenData((list) {
      state = state.copyWith(types: list.map((e) => e.id).toList());
    });
  }

  void toggleType(int typeId) {
    final updated = [...state.selectedTypes];

    if (updated.contains(typeId)) {
      updated.remove(typeId);
    } else {
      updated.add(typeId);
    }

    state = state.copyWith(selectedTypes: updated);

    if (state.mode == CategoryMode.organization) {
      ref.read(organizationTypeFilterProvider.notifier).state = updated.toSet();
    } else {
      ref.read(locationTypeFilterProvider.notifier).state = updated.toSet();
    }
  }

  void toggleExpansion() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
