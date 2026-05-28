import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/organization_request.dart';
import 'package:street_team/data/repositories/organization_repository.dart';
import 'package:street_team/data/services/location_capture_service.dart';

class OrganizationFormState {
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  const OrganizationFormState({
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  OrganizationFormState copyWith({
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrganizationFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

final organizationLocationCaptureProvider = Provider<LocationCaptureService>((
  ref,
) {
  return LocationCaptureService();
});

class OrganizationFormNotifier extends StateNotifier<OrganizationFormState> {
  final OrganizationRepository _repository;
  final LocationCaptureService _locationCaptureService;

  OrganizationFormNotifier(this._repository, this._locationCaptureService)
    : super(const OrganizationFormState());

  Future<void> submitOrganization({
    required String action,
    required String name,
    required String type,
    required List<int> types,
    required List<int> subTypes,
    required List<Map<String, dynamic>> selectedOptions,
    required Map<String, dynamic> workingHoursData,
    String? phone,
    String? quickInfo,
    String? website,
    String? onlineMenu,
    String? murugoLocationId,
    String? submitterServer,
    String? submitterAtName,
    Map<String, dynamic>? userLocation,
    Map<String, dynamic>? newLocationData,
    int? murugoOrganizationId,
    String? orgBuildingInfo,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    talker.info('OrganizationFormNotifier.submitOrganization started');

    try {
      talker.debug('Resolving submitter metadata...');
      final resolvedSubmitterServer =
          submitterServer ??
          await _locationCaptureService.resolveSubmitterServer();
      final resolvedSubmitterAtName =
          submitterAtName ??
          await _locationCaptureService.resolveSubmitterName();

      talker.debug('Building user location for organization submit...');
      final resolvedUserLocation =
          userLocation ?? await _locationCaptureService.buildUserLocation();

      final effectiveAction = newLocationData != null ? 'NEW' : action;
      talker.debug(
        'Organization submit action resolved: $effectiveAction '
        '(input action: $action)',
      );

      final model = OrganizationRequestModel(
        action: effectiveAction,
        name: name,
        type: type,
        phone: phone,
        quickInfo: quickInfo,
        website: website,
        onlineMenu: onlineMenu,
        murugoOrganizationId: murugoOrganizationId,
        murugoLocationId: murugoLocationId,
        submitterServer: resolvedSubmitterServer,
        submitterAtName: resolvedSubmitterAtName,
        types: types,
        subTypes: subTypes,
        userLocation: resolvedUserLocation,
        newLocationData: newLocationData,
        workingHoursData: workingHoursData,
        selectedOptions: selectedOptions,
        orgBuildingInfo: orgBuildingInfo,
      );

      talker.debug('Organization request payload prepared: ${model.toJson()}');

      final response = await _repository.submitOrganization(model);

      if (!response.success) {
        final message = response.message ?? 'Failed to submit organization';
        talker.error('Organization submit rejected: $message');
        state = state.copyWith(
          isSubmitting: false,
          isSubmitted: false,
          errorMessage: message,
        );
        throw Exception(message);
      }

      talker.info('Organization submit completed successfully.');

      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
        clearError: true,
      );
    } catch (e, st) {
      final message = e.toString().replaceFirst('Exception: ', '');
      talker.error('Organization submit failed in provider: $message', e, st);
      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: false,
        errorMessage: message,
      );
      throw Exception(message);
    }
  }

  void reset() {
    state = const OrganizationFormState();
  }
}

final organizationFormProvider =
    StateNotifierProvider<OrganizationFormNotifier, OrganizationFormState>((
      ref,
    ) {
      return OrganizationFormNotifier(
        ref.watch(organizationRepositoryProvider),
        ref.watch(organizationLocationCaptureProvider),
      );
    });
