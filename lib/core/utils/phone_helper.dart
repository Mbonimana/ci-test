import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneHelper {
  static Future<void> call(String number) async {
    final clean = number.replaceAll(' ', '').trim();

    final Uri uri = Uri(scheme: 'tel', path: clean);

    try {
      final canLaunch = await canLaunchUrl(uri);

      if (!canLaunch) {
        debugPrint("No dialer app available for: $clean");

        // fallback
        await Clipboard.setData(ClipboardData(text: clean));
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint("Dialer failed, copying number");
        await Clipboard.setData(ClipboardData(text: clean));
      }
    } catch (e) {
      debugPrint("Phone error: $e");
      await Clipboard.setData(ClipboardData(text: clean));
    }
  }
}
