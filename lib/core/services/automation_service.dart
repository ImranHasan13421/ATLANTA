import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'activity_service.dart';
import 'device_service.dart';

class AtlantaAutomation {
  final String id;
  String name;
  String triggerDesc;
  String actionDesc;
  String iconName;
  bool isEnabled;
  DateTime? lastRunTime;
  List<String> steps;
  bool isExecuting;

  AtlantaAutomation({
    String? id,
    required this.name,
    required this.triggerDesc,
    required this.actionDesc,
    required this.iconName,
    this.isEnabled = true,
    this.lastRunTime,
    required this.steps,
    this.isExecuting = false,
  }) : id = id ?? const Uuid().v4();
}

class AutomationService extends ChangeNotifier {
  static final AutomationService instance = AutomationService._internal();

  AutomationService._internal() {
    _seedDefaultAutomations();
  }

  final List<AtlantaAutomation> _automations = [];

  List<AtlantaAutomation> get automations => List.unmodifiable(_automations);

  void _seedDefaultAutomations() {
    _automations.addAll([
      AtlantaAutomation(
        name: 'Morning Protocol',
        triggerDesc: 'At 07:00 AM on weekdays',
        actionDesc: 'Briefing, HVAC 72°F, daylight illumination',
        iconName: 'wb_sunny_rounded',
        steps: [
          'Analyzing atmospheric & traffic telemetry',
          'Adjusting HVAC thermostat to 72°F',
          'Activating living room illumination to 80%',
          'Preparing schedule briefing audio',
        ],
      ),
      AtlantaAutomation(
        name: 'Focus Deep Work',
        triggerDesc: 'When initiated or calendar event matches "Sprint"',
        actionDesc: 'Mute non-priority notifications, ambient soundscape',
        iconName: 'psychology_rounded',
        steps: [
          'Silencing non-essential telemetry notifications',
          'Dimming ambient lab illumination to deep azure',
          'Initializing binaural acoustic soundscape',
          'Quantum compute priority assigned to IDE process',
        ],
      ),
      AtlantaAutomation(
        name: 'Night Lockdown Protocol',
        triggerDesc: 'At 11:30 PM or voice command "Night Protocol"',
        actionDesc: 'Lock perimeter, arm motion grid, power down arrays',
        iconName: 'nightlight_round',
        steps: [
          'Engaging high-torque smart deadbolts on perimeter',
          'Arming thermal motion sensors',
          'Powering down auxiliary display arrays',
          'Switching mainframe to low-energy quantum standby',
        ],
      ),
      AtlantaAutomation(
        name: 'High-Alert Defense Grid',
        triggerDesc: 'Triggered by anomalous perimeter vibration',
        actionDesc: 'Full sensor telemetry sweep, strobe warning, notify user',
        iconName: 'shield_rounded',
        steps: [
          'Locking all access portals',
          'Broadcasting 360-degree LiDAR sweep',
          'Capturing 4K perimeter security snapshot',
          'Transmitting encrypted alert packet to user mobile device',
        ],
      ),
    ]);
  }

  void toggleAutomation(String id) {
    final index = _automations.indexWhere((a) => a.id == id);
    if (index != -1) {
      _automations[index].isEnabled = !_automations[index].isEnabled;
      notifyListeners();
    }
  }

  Future<void> executeAutomation(
    String id, {
    Function(String step, double progress)? onProgress,
  }) async {
    final index = _automations.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final auto = _automations[index];
    auto.isExecuting = true;
    notifyListeners();

    ActivityService.instance.log(
      title: 'Executing: ${auto.name}',
      description: 'Starting automated workflow sequence...',
      type: ActivityType.automation,
      status: 'pending',
    );

    for (var i = 0; i < auto.steps.length; i++) {
      final step = auto.steps[i];
      final progress = (i + 1) / auto.steps.length;
      onProgress?.call(step, progress);

      // Perform real effects if applicable
      if (step.contains('illumination') || step.contains('Lights')) {
        final light = DeviceService.instance.findDeviceByName('Light');
        if (light != null && !light.isOn) {
          DeviceService.instance.toggleDevice(light.id);
        }
      }
      if (step.contains('deadbolts') || step.contains('Lock')) {
        final lock = DeviceService.instance.findDeviceByName('Lock');
        if (lock != null && !lock.isOn) {
          DeviceService.instance.toggleDevice(lock.id);
        }
      }

      await Future.delayed(const Duration(milliseconds: 600));
    }

    auto.isExecuting = false;
    auto.lastRunTime = DateTime.now();

    ActivityService.instance.log(
      title: 'Workflow Complete: ${auto.name}',
      description: 'All ${auto.steps.length} sequence steps executed successfully.',
      type: ActivityType.automation,
      status: 'success',
    );

    notifyListeners();
  }

  AtlantaAutomation? findAutomationByName(String query) {
    final q = query.toLowerCase();
    for (final a in _automations) {
      if (a.name.toLowerCase().contains(q)) {
        return a;
      }
    }
    return null;
  }
}
