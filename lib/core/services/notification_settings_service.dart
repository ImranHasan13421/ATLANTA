import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sound_effects_service.dart';

/// Service managing all notification and alert preferences across ATLANTA.
class NotificationSettingsService extends ChangeNotifier {
  static final NotificationSettingsService instance = NotificationSettingsService._internal();

  NotificationSettingsService._internal() {
    _loadSettings();
  }

  bool _taskReminders = true;
  bool _scheduledAlarms = true;
  bool _systemTelemetry = true;
  bool _voiceFeedback = true;
  bool _soundEffects = true;
  bool _doNotDisturb = false;

  bool get taskReminders => _taskReminders;
  bool get scheduledAlarms => _scheduledAlarms;
  bool get systemTelemetry => _systemTelemetry;
  bool get voiceFeedback => _voiceFeedback;
  bool get soundEffects => _soundEffects;
  bool get doNotDisturb => _doNotDisturb;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _taskReminders = prefs.getBool('notif_task_reminders') ?? true;
      _scheduledAlarms = prefs.getBool('notif_scheduled_alarms') ?? true;
      _systemTelemetry = prefs.getBool('notif_system_telemetry') ?? true;
      _voiceFeedback = prefs.getBool('notif_voice_feedback') ?? true;
      _soundEffects = prefs.getBool('notif_sound_effects') ?? true;
      _doNotDisturb = prefs.getBool('notif_do_not_disturb') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setTaskReminders(bool val) async {
    _taskReminders = val;
    notifyListeners();
    SoundEffectsService.instance.playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_task_reminders', val);
  }

  Future<void> setScheduledAlarms(bool val) async {
    _scheduledAlarms = val;
    notifyListeners();
    SoundEffectsService.instance.playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_scheduled_alarms', val);
  }

  Future<void> setSystemTelemetry(bool val) async {
    _systemTelemetry = val;
    notifyListeners();
    SoundEffectsService.instance.playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_system_telemetry', val);
  }

  Future<void> setVoiceFeedback(bool val) async {
    _voiceFeedback = val;
    notifyListeners();
    SoundEffectsService.instance.playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_voice_feedback', val);
  }

  Future<void> setSoundEffects(bool val) async {
    _soundEffects = val;
    notifyListeners();
    SoundEffectsService.instance.playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_sound_effects', val);
  }

  Future<void> setDoNotDisturb(bool val) async {
    _doNotDisturb = val;
    notifyListeners();
    SoundEffectsService.instance.playClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_do_not_disturb', val);
  }
}
