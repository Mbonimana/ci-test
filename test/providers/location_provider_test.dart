// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:street_team/data/models/location_models/location_request_model.dart';
// import 'package:street_team/data/models/location_models/location_response.dart';
// import 'package:street_team/data/repositories/location_repository.dart';
// import 'package:street_team/presentation/providers/location_provider.dart';

// // Define Mocks
// class MockLocationRepository extends Mock implements LocationRepository {}

// void main() {
//   late MockLocationRepository mockRepo;
//   late LocationResponse mockLocation1;
//   late LocationResponse mockLocation2;

//   setUp(() {
//     mockRepo = MockLocationRepository();
//     mockLocation1 = LocationResponse(
//       id: 101,
//       name: 'First location',
//       physicalAddress: 'Address 1',
//       latitude: -1.1,
//       longitude: 36.1,
//       types: const [],
//       organizations: const [],
//     );
//     mockLocation2 = LocationResponse(
//       id: 202,
//       name: 'Second location',
//       physicalAddress: 'Address 2',
//       latitude: -1.2,
//       longitude: 36.2,
//       types: const [],
//       organizations: const [],
//     );
//   });

//   group('DiscoveryNotifier', () {
//     test('initial state starts as an empty list', () {
//       final notifier = DiscoveryNotifier(mockRepo);
//       expect(notifier.state, isEmpty);
//     });

//     test(
//       'fetchNextPage increments current page and appends returned results to the state',
//       () async {
//         final notifier = DiscoveryNotifier(mockRepo);
//         when(
//           () => mockRepo.fetchMoreLocations(2),
//         ).thenAnswer((_) async => [mockLocation1]);

//         await notifier.fetchNextPage();

//         expect(notifier.state, [mockLocation1]);
//         verify(() => mockRepo.fetchMoreLocations(2)).called(1);
//       },
//     );

//     test(
//       'injectLocation appends new location when it does not exist in state',
//       () {
//         final notifier = DiscoveryNotifier(mockRepo);
//         notifier.injectLocation(mockLocation1);

//         expect(notifier.state, [mockLocation1]);
//       },
//     );

//     test(
//       'injectLocation ignores insertion when location id is already present in state',
//       () {
//         final notifier = DiscoveryNotifier(mockRepo);

//         notifier.injectLocation(mockLocation1);
//         expect(notifier.state, [mockLocation1]);

//         // Attempt duplicate injection
//         notifier.injectLocation(mockLocation1);
//         expect(notifier.state, [mockLocation1]); // Length remains 1
//       },
//     );
//   });

//   group('LocationFormNotifier', () {
//     test('initial state defaults to non-loading with no initial model', () {
//       final notifier = LocationFormNotifier(mockRepo);
//       expect(notifier.state.initial, isNull);
//       expect(notifier.state.loading, isFalse);
//     });

//     test(
//       'loadLocation fetches the correct model and updates loading states',
//       () async {
//         final notifier = LocationFormNotifier(mockRepo);
//         final mockModel = LocationModel(
//           name: 'Loaded location',
//           physicalAddress: 'Loaded address',
//           latitude: -1.25,
//           longitude: 36.25,
//           types: const [1],
//           submitterServer: 'server',
//           submitterAtName: 'Admin',
//           userLocation: const {'street': 'Loaded street'},
//         );

//         when(
//           () => mockRepo.getLocationById('loc_id'),
//         ).thenAnswer((_) async => mockModel);

//         final future = notifier.loadLocation('loc_id');

//         // Verify immediate transition to loading = true
//         expect(notifier.state.loading, isTrue);

//         await future;

//         // Verify final transition
//         expect(notifier.state.loading, isFalse);
//         expect(notifier.state.initial, mockModel);
//       },
//     );

//     test('resetFormState clears state back to empty template', () {
//       final notifier = LocationFormNotifier(mockRepo);
//       notifier.resetFormState();

//       expect(notifier.state.initial, isNull);
//       expect(notifier.state.loading, isFalse);
//     });

//     group('submitLocation', () {
//       late LocationModel mockModel;
//       late Response<dynamic> successResponse;
//       late Response<dynamic> failureResponse;

//       setUp(() {
//         mockModel = LocationModel(
//           name: 'Submitted location',
//           physicalAddress: 'Submitted address',
//           latitude: -1.3,
//           longitude: 36.3,
//           types: const [1, 2],
//           submitterServer: 'server',
//           submitterAtName: 'Tester',
//           userLocation: const {'street': 'Submitted street'},
//         );
//         successResponse = Response<dynamic>(
//           requestOptions: RequestOptions(path: '/locations'),
//           statusCode: 201,
//           data: {},
//         );
//         failureResponse = Response<dynamic>(
//           requestOptions: RequestOptions(path: '/locations'),
//           statusCode: 500,
//           data: {'message': 'Internal Server Error'},
//         );
//       });

//       test('calls submitLocation (POST) when editId is null', () async {
//         final notifier = LocationFormNotifier(mockRepo);
//         when(
//           () => mockRepo.submitLocation(mockModel),
//         ).thenAnswer((_) async => successResponse);

//         await notifier.submitLocation(mockModel, editId: null);

//         verify(() => mockRepo.submitLocation(mockModel)).called(1);
//         verifyNever(() => mockRepo.updateLocation('edit_123', mockModel));
//       });

//       test('calls updateLocation (PUT) when editId is provided', () async {
//         final notifier = LocationFormNotifier(mockRepo);
//         when(
//           () => mockRepo.updateLocation('edit_123', mockModel),
//         ).thenAnswer((_) async => successResponse);

//         await notifier.submitLocation(mockModel, editId: 'edit_123');

//         verify(() => mockRepo.updateLocation('edit_123', mockModel)).called(1);
//         verifyNever(() => mockRepo.submitLocation(mockModel));
//       });

//       test(
//         'throws an Exception when the server responds with a non-success status code',
//         () async {
//           final notifier = LocationFormNotifier(mockRepo);
//           when(
//             () => mockRepo.submitLocation(mockModel),
//           ).thenAnswer((_) async => failureResponse);

//           expect(
//             () => notifier.submitLocation(mockModel, editId: null),
//             throwsA(
//               isA<Exception>().having(
//                 (e) => e.toString(),
//                 'message',
//                 contains('Server Error: Internal Server Error'),
//               ),
//             ),
//           );
//         },
//       );

//       test(
//         'parses and extracts error message from raw DioException response payloads',
//         () async {
//           final notifier = LocationFormNotifier(mockRepo);
//           final dioException = DioException(
//             requestOptions: RequestOptions(path: '/locations'),
//             response: Response(
//               requestOptions: RequestOptions(path: '/locations'),
//               data: {'message': 'Database constraint failure'},
//             ),
//           );

//           when(
//             () => mockRepo.submitLocation(mockModel),
//           ).thenThrow(dioException);

//           expect(
//             () => notifier.submitLocation(mockModel, editId: null),
//             throwsA(
//               isA<Exception>().having(
//                 (e) => e.toString(),
//                 'message',
//                 contains('Database constraint failure'),
//               ),
//             ),
//           );
//         },
//       );
//     });
//   });

//   group('ProviderContainer Integrations', () {
//     test(
//       'remoteSearchResultsProvider returns empty when search query length is less than 2',
//       () async {
//         final container = ProviderContainer(
//           overrides: [locationRepoProvider.overrideWithValue(mockRepo)],
//         );

//         // Set search query too short
//         container.read(locationSearchProvider.notifier).state = 'A';

//         final results = await container.read(
//           remoteSearchResultsProvider.future,
//         );

//         expect(results, isEmpty);
//         verifyNever(() => mockRepo.searchLocations('A'));
//       },
//     );

//     test(
//       'remoteSearchResultsProvider calls repository search when query is sufficient',
//       () async {
//         final container = ProviderContainer(
//           overrides: [locationRepoProvider.overrideWithValue(mockRepo)],
//         );

//         when(
//           () => mockRepo.searchLocations('Kigali'),
//         ).thenAnswer((_) async => [mockLocation1]);

//         // Trigger valid query state
//         container.read(locationSearchProvider.notifier).state = 'Kigali';

//         final results = await container.read(
//           remoteSearchResultsProvider.future,
//         );

//         expect(results, [mockLocation1]);
//         verify(() => mockRepo.searchLocations('Kigali')).called(1);
//       },
//     );

//     test(
//       'filteredLocationsProvider merges initial map results and paginated discovery lists',
//       () {
//         final container = ProviderContainer(
//           overrides: [
//             locationRepoProvider.overrideWithValue(mockRepo),
//             // Stub static provider states
//             locationsProvider.overrideWith((ref) => [mockLocation1]),
//             otherResultsProvider.overrideWith(
//               (ref) => DiscoveryNotifier(mockRepo)..state = [mockLocation2],
//             ),
//           ],
//         );

//         final combinedList = container.read(filteredLocationsProvider);

//         expect(combinedList, containsAll([mockLocation1, mockLocation2]));
//         expect(combinedList.length, 2);
//       },
//     );
//   });
// }
