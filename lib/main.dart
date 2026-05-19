import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:street_team/core/config/env_config.dart';
import 'package:street_team/core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(EnvConfig.mapBoxToken);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  // SENTRY INIT
  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig.sentryDsn;
      options.debug = EnvConfig.enableLogs;
      options.replay.sessionSampleRate = 1.0;
      options.replay.onErrorSampleRate = 1.0;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () {
      runApp(const ProviderScope(child: MyApp()));
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 869),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) {
        return MaterialApp.router(
          title: 'Street Team',
          debugShowCheckedModeBanner: false,

          // ROUTER
          routerConfig: AppRouter.router,

          // THEME
          theme: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: Colors.white,
            splashFactory: InkRipple.splashFactory,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          // BUILDER
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
