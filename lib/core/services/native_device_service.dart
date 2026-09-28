import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for executing native device actions (App launching, Alarms, Settings, OS Intents)
/// across Android, Windows, and Web.
class NativeDeviceService {
  static final NativeDeviceService instance = NativeDeviceService._internal();

  NativeDeviceService._internal();

  static const MethodChannel _channel = MethodChannel('com.ezzeai.atlanta/native_bridge');

  /// Launches a native application by name or category (e.g. 'clock', 'camera', 'youtube', 'settings')
  Future<bool> launchApp(String appName) async {
    final lower = appName.toLowerCase().trim();

    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('launchApp', {'appName': lower});
        return result ?? false;
      } catch (e) {
        debugPrint('Android native launchApp error: $e');
      }
    } else if (!kIsWeb && Platform.isWindows) {
      return await _launchWindowsApp(lower);
    }

    // Web / Cross-platform fallback via url_launcher
    return await _launchUrlFallback(lower);
  }

  /// Sets a native system alarm at [hour] and [minutes]
  Future<bool> setAlarm({
    required int hour,
    required int minutes,
    String message = 'Atlanta Alarm',
    bool skipUi = false,
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('setAlarm', {
          'hour': hour,
          'minutes': minutes,
          'message': message,
          'skipUi': skipUi,
        });
        return result ?? false;
      } catch (e) {
        debugPrint('Android setAlarm error: $e');
      }
    } else if (!kIsWeb && Platform.isWindows) {
      try {
        await Process.run('cmd', ['/c', 'start', 'ms-clock:']);
        return true;
      } catch (e) {
        debugPrint('Windows alarm launch error: $e');
      }
    }

    return false;
  }

  /// Opens native device settings (wifi, bluetooth, sound, general)
  Future<bool> openSettings([String type = 'general']) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('openSettings', {'type': type});
        return result ?? false;
      } catch (e) {
        debugPrint('Android openSettings error: $e');
      }
    } else if (!kIsWeb && Platform.isWindows) {
      try {
        final uri = type == 'wifi'
            ? 'ms-settings:network-wifi'
            : (type == 'bluetooth'
                ? 'ms-settings:bluetooth'
                : (type == 'sound' ? 'ms-settings:sound' : 'ms-settings:'));
        await Process.run('cmd', ['/c', 'start', uri]);
        return true;
      } catch (e) {
        debugPrint('Windows openSettings error: $e');
      }
    }
    return false;
  }

  /// Opens a web URL or deep link in the default browser
  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('openUrl error: $e');
    }
    return false;
  }

  Future<bool> _launchWindowsApp(String name) async {
    try {
      if (name.contains('clock') || name.contains('alarm') || name.contains('timer')) {
        await Process.run('cmd', ['/c', 'start', 'ms-clock:']);
        return true;
      } else if (name.contains('calc')) {
        await Process.run('cmd', ['/c', 'start', 'calc']);
        return true;
      } else if (name.contains('camera')) {
        await Process.run('cmd', ['/c', 'start', 'microsoft.windows.camera:']);
        return true;
      } else if (name.contains('setting')) {
        await Process.run('cmd', ['/c', 'start', 'ms-settings:']);
        return true;
      } else if (name.contains('notepad') || name.contains('note')) {
        await Process.run('cmd', ['/c', 'start', 'notepad']);
        return true;
      } else if (name.contains('explorer') || name.contains('file')) {
        await Process.run('cmd', ['/c', 'start', 'explorer']);
        return true;
      } else if (name.contains('youtube')) {
        await Process.run('cmd', ['/c', 'start', 'https://youtube.com']);
        return true;
      } else if (name.contains('chrome') || name.contains('browser')) {
        await Process.run('cmd', ['/c', 'start', 'https://google.com']);
        return true;
      } else {
        await Process.run('cmd', ['/c', 'start', name]);
        return true;
      }
    } catch (e) {
      debugPrint('Windows app launch error: $e');
      return false;
    }
  }

  Future<bool> _launchUrlFallback(String name) async {
    String? url;
    if (name.contains('youtube')) {
      url = 'https://youtube.com';
    } else if (name.contains('map')) {
      url = 'https://maps.google.com';
    } else if (name.contains('mail') || name.contains('gmail')) {
      url = 'mailto:';
    } else if (name.contains('search') || name.contains('google')) {
      url = 'https://google.com';
    }

    if (url != null) {
      return await openUrl(url);
    }
    return false;
  }
}
