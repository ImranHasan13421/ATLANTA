import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'activity_service.dart';

class AtlantaTask {
  final String id;
  String title;
  String description;
  String dueDate;
  String priority; // 'high', 'medium', 'low'
  bool isCompleted;
  final DateTime createdAt;

  AtlantaTask({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate = 'Today',
    this.priority = 'medium',
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate,
        'priority': priority,
        'is_completed': isCompleted,
        'created_at': createdAt.toIso8601String(),
      };

  factory AtlantaTask.fromJson(Map<String, dynamic> json) => AtlantaTask(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        dueDate: json['due_date'] ?? 'Today',
        priority: json['priority'] ?? 'medium',
        isCompleted: json['is_completed'] ?? false,
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}

class TaskService extends ChangeNotifier {
  static final TaskService instance = TaskService._internal();

  TaskService._internal() {
    _seedDefaultTasks();
  }

  final List<AtlantaTask> _tasks = [];

  List<AtlantaTask> get tasks => List.unmodifiable(_tasks);

  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  List<AtlantaTask> get todayTasks =>
      _tasks.where((t) => !t.isCompleted && t.dueDate.toLowerCase().contains('today')).toList();

  List<AtlantaTask> get upcomingTasks =>
      _tasks.where((t) => !t.isCompleted && !t.dueDate.toLowerCase().contains('today')).toList();

  List<AtlantaTask> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  void _seedDefaultTasks() {
    _tasks.addAll([
      AtlantaTask(
        title: 'Calibrate Atlanta neural core',
        description: 'Verify sub-millisecond voice recognition latency',
        dueDate: 'Today, 4:00 PM',
        priority: 'high',
      ),
      AtlantaTask(
        title: 'Review quarterly project deliverables',
        description: 'Prepare executive summary presentation',
        dueDate: 'Today, 7:00 PM',
        priority: 'medium',
      ),
      AtlantaTask(
        title: 'Inspect smart perimeter locks',
        description: 'Run automated hardware diagnostics',
        dueDate: 'Tomorrow, 10:00 AM',
        priority: 'medium',
      ),
      AtlantaTask(
        title: 'Submit system documentation',
        description: 'Finalize architectural schematics',
        dueDate: 'Tomorrow, 2:00 PM',
        priority: 'high',
      ),
      AtlantaTask(
        title: 'Archive server telemetry logs',
        dueDate: 'Wed, 12:00 PM',
        priority: 'low',
      ),
      AtlantaTask(
        title: 'Optimize memory cache buffers',
        isCompleted: true,
        dueDate: 'Yesterday',
        priority: 'low',
      ),
    ]);
  }

  AtlantaTask addTask({
    required String title,
    String description = '',
    String dueDate = 'Today',
    String priority = 'medium',
  }) {
    final task = AtlantaTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    _tasks.insert(0, task);
    ActivityService.instance.log(
      title: 'Task created',
      description: 'Added task: "$title"',
      type: ActivityType.task,
    );
    notifyListeners();
    return task;
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      ActivityService.instance.log(
        title: _tasks[index].isCompleted ? 'Task completed' : 'Task reopened',
        description: '"${_tasks[index].title}"',
        type: ActivityType.task,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final removed = _tasks.removeAt(index);
      ActivityService.instance.log(
        title: 'Task deleted',
        description: 'Removed task: "${removed.title}"',
        type: ActivityType.task,
      );
      notifyListeners();
    }
  }

  void updateTask({
    required String id,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
  }) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      if (title != null) _tasks[index].title = title;
      if (description != null) _tasks[index].description = description;
      if (dueDate != null) _tasks[index].dueDate = dueDate;
      if (priority != null) _tasks[index].priority = priority;
      notifyListeners();
    }
  }
}
