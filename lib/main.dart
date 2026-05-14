import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:street_team/core/config/env_config.dart';
import 'package:street_team/presentation/ui/screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(EnvConfig.mapBoxToken);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig.sentryDsn;
      options.debug = true;

      options.replay.sessionSampleRate = 1.0;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () {
      runApp(const MyApp());
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
      builder: (context, child) {
        return MaterialApp(
          title: 'Street Team',
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      child: const LoginScreen(),
    );
  }
}
