import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'activity_service.dart';

class AtlantaReminder {
  final String id;
  String title;
  String time;
  String date;
  String category;
  bool isActive;
  bool isSnoozed;

  AtlantaReminder({
    String? id,
    required this.title,
    required this.time,
    required this.date,
    this.category = 'General',
    this.isActive = true,
    this.isSnoozed = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'date': date,
        'category': category,
        'is_active': isActive,
        'is_snoozed': isSnoozed,
      };

  factory AtlantaReminder.fromJson(Map<String, dynamic> json) => AtlantaReminder(
        id: json['id'],
        title: json['title'] ?? '',
        time: json['time'] ?? '12:00 PM',
        date: json['date'] ?? 'Today',
        category: json['category'] ?? 'General',
        isActive: json['is_active'] ?? true,
        isSnoozed: json['is_snoozed'] ?? false,
      );
}

class ReminderService extends ChangeNotifier {
  static final ReminderService instance = ReminderService._internal();

  ReminderService._internal() {
    _seedDefaultReminders();
  }

  final List<AtlantaReminder> _reminders = [];

  List<AtlantaReminder> get reminders => List.unmodifiable(_reminders);
  List<AtlantaReminder> get activeReminders => _reminders.where((r) => r.isActive).toList();
  List<AtlantaReminder> get pastReminders => _reminders.where((r) => !r.isActive).toList();

  void _seedDefaultReminders() {
    _reminders.addAll([
      AtlantaReminder(
        title: 'Review flight telemetry data',
        time: '3:30 PM',
        date: 'Today',
        category: 'Work',
      ),
      AtlantaReminder(
        title: 'Calibrate environmental sensors',
        time: '6:00 PM',
        date: 'Today',
        category: 'Personal',
      ),
      AtlantaReminder(
        title: 'Conference call with Tony Stark',
        time: '10:00 AM',
        date: 'Tomorrow',
        category: 'Work',
      ),
      AtlantaReminder(
        title: 'Secure mainframe backup vault',
        time: '11:00 PM',
        date: 'Tomorrow',
        category: 'Security',
      ),
    ]);
  }

  AtlantaReminder addReminder({
    required String title,
    required String time,
    String date = 'Today',
    String category = 'General',
  }) {
    final reminder = AtlantaReminder(
      title: title,
      time: time,
      date: date,
      category: category,
    );
    _reminders.insert(0, reminder);
    ActivityService.instance.log(
      title: 'Reminder set',
      description: '"$title" at $time ($date)',
      type: ActivityType.reminder,
    );
    notifyListeners();
    return reminder;
  }

  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isActive = !_reminders[index].isActive;
      notifyListeners();
    }
  }

  void snoozeReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isSnoozed = true;
      ActivityService.instance.log(
        title: 'Reminder snoozed',
        description: 'Snoozed 15 mins: "${_reminders[index].title}"',
        type: ActivityType.reminder,
      );
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders.removeAt(index);
      notifyListeners();
    }
  }
}
