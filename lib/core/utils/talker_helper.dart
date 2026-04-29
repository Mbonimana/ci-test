import 'package:street_team/core/config/env_config.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    enabled: true,
    useConsoleLogs: EnvConfig.enableLogs,
  ),
);