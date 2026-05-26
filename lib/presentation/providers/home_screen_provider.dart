import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/presentation/providers/organization_provider.dart';

class HomeState {
  final List<int> types;
  final List<int> selectedTypes;
  final bool isExpanded;

  HomeState({
    required this.types,
    required this.selectedTypes,
    required this.isExpanded,
  });

  HomeState copyWith({
    List<int>? types,
    List<int>? selectedTypes,
    bool? isExpanded,
  }) {
    return HomeState(
      types: types ?? this.types,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref ref;

  HomeNotifier(this.ref)
    : super(HomeState(types: [], selectedTypes: [], isExpanded: false)) {
    _init();
  }

  void _init() {
    ref.listen(organizationTypesListProvider, (prev, next) {
      next.whenData((list) {
        state = state.copyWith(types: list.map((e) => e.id).toList());
      });
    }, fireImmediately: true);
  }

  void toggleType(int typeId) {
    final updated = [...state.selectedTypes];
    if (updated.contains(typeId)) {
      updated.remove(typeId);
    } else {
      updated.add(typeId);
    }
    state = state.copyWith(selectedTypes: updated);

    ref.read(organizationTypeFilterProvider.notifier).state = updated.toSet();
  }

  void toggleExpansion() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
