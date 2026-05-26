import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/presentation/providers/auth/auth_provider.dart';
import 'package:street_team/presentation/ui/screens/auth/login_screen.dart';
import 'package:street_team/presentation/ui/screens/home_screen.dart';
import 'package:street_team/presentation/ui/screens/location_screen.dart';
import 'package:street_team/presentation/ui/screens/map_pin_picker_screen.dart';
import 'package:street_team/presentation/ui/screens/map_screen.dart';
import 'package:street_team/presentation/ui/screens/organization_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    // global auth guard
    redirect: (context, state) {
      final isLoggedIn = authState;

      final isGoingToLogin = state.matchedLocation == RouteNames.login;

      if (!isLoggedIn && !isGoingToLogin) {
        return RouteNames.login;
      }

      if (isLoggedIn && isGoingToLogin) {
        return RouteNames.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: RouteNames.mapScreen,
        name: 'map-screen',
        builder: (context, state) => const MapScreen(),
      ),

      GoRoute(
        path: RouteNames.mapPinScreen,
        name: 'map-pin-screen',
        builder: (context, state) => const MapPinPickerScreen(),
      ),

      GoRoute(
        path: RouteNames.location,
        name: 'location-screen',
        builder: (context, state) => const LocationDetailsScreen(),
      ),

      GoRoute(
        path: RouteNames.organization,
        name: 'organization-screen',
        builder: (context, state) => const OrganizationScreen(),
      ),
    ],
  );
});
