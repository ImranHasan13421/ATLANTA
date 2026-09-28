import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum ActivityType { voice, task, note, reminder, device, automation, security, system }

class AtlantaActivity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime timestamp;
  final String status; // 'success', 'pending', 'alert'

  AtlantaActivity({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    DateTime? timestamp,
    this.status = 'success',
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory AtlantaActivity.fromJson(Map<String, dynamic> json) => AtlantaActivity(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: ActivityType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ActivityType.system,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        status: json['status'] ?? 'success',
      );
}

class ActivityService extends ChangeNotifier {
  static final ActivityService instance = ActivityService._internal();

  ActivityService._internal() {
    _seedDefaultActivities();
  }

  final List<AtlantaActivity> _activities = [];

  List<AtlantaActivity> get activities => List.unmodifiable(_activities);

  void _seedDefaultActivities() {
    _activities.addAll([
      AtlantaActivity(
        title: 'Voice command executed',
        description: 'Command: "Atlanta, prepare evening protocol"',
        type: ActivityType.voice,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        status: 'success',
      ),
      AtlantaActivity(
        title: 'Device state synchronized',
        description: 'Living Room Lights: Brightness adjusted to 60%',
        type: ActivityType.device,
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        status: 'success',
      ),
      AtlantaActivity(
        title: 'Security audit completed',
        description: 'All 8 perimeter sensors nominal, neural firewall active',
        type: ActivityType.security,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'success',
      ),
      AtlantaActivity(
        title: 'Automation triggered',
        description: 'Workflow "Focus Mode" completed 4 steps',
        type: ActivityType.automation,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'success',
      ),
    ]);
  }

  void log({
    required String title,
    required String description,
    required ActivityType type,
    String status = 'success',
  }) {
    final activity = AtlantaActivity(
      title: title,
      description: description,
      type: type,
      status: status,
    );
    _activities.insert(0, activity);
    notifyListeners();
  }

  void clear() {
    _activities.clear();
    notifyListeners();
  }
}
