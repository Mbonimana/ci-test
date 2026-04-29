import 'package:flutter/material.dart';
import 'package:street_team/core/utils/sentry_helper.dart';
import 'package:street_team/core/utils/talker_helper.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _throwError() {
    try {
      talker.error("User triggered error button");

      throw Exception("Test exception from HomeScreen");
    } catch (e, stack) {
      talker.handle(e, stack, "Exception caught in HomeScreen");

      SentryHelper.captureException(
        e,
        stackTrace: stack,
        extras: {
          "screen": "home",
          "action": "throw_error_button",
        },
      );
    }
  }

  void _sendMessage() {
    talker.info("User sent test message to Sentry");

    SentryHelper.captureMessage(
      "Test message from HomeScreen",
    );
  }

  void _setUser() {
    talker.info("User set in Sentry scope: user_123");

    SentryHelper.setUser(
      id: "user_123",
      email: "test@email.com",
    );
  }

  void _clearUser() {
    talker.warning("User cleared from Sentry scope");

    SentryHelper.clearUser();
  }

  @override
  Widget build(BuildContext context) {
    talker.debug("HomeScreen built");

    return Scaffold(
      appBar: AppBar(title: const Text('Sentry + Talker Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _throwError,
              child: const Text("Send Exception"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text("Send Message"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _setUser,
              child: const Text("Set User"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearUser,
              child: const Text("Clear User"),
            ),
          ],
        ),
      ),
    );
  }
}