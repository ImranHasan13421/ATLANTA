import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'activity_service.dart';

class AtlantaNote {
  final String id;
  String title;
  String content;
  String category;
  int colorValue;
  bool isPinned;
  DateTime updatedAt;

  AtlantaNote({
    String? id,
    required this.title,
    required this.content,
    this.category = 'General',
    this.colorValue = 0xFF111C2B,
    this.isPinned = false,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'color_value': colorValue,
        'is_pinned': isPinned,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory AtlantaNote.fromJson(Map<String, dynamic> json) => AtlantaNote(
        id: json['id'],
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        category: json['category'] ?? 'General',
        colorValue: json['color_value'] ?? 0xFF111C2B,
        isPinned: json['is_pinned'] ?? false,
        updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
}

class NoteService extends ChangeNotifier {
  static final NoteService instance = NoteService._internal();

  NoteService._internal() {
    _seedDefaultNotes();
  }

  final List<AtlantaNote> _notes = [];

  List<AtlantaNote> get notes => List.unmodifiable(_notes);
  List<AtlantaNote> get pinnedNotes => _notes.where((n) => n.isPinned).toList();
  List<AtlantaNote> get otherNotes => _notes.where((n) => !n.isPinned).toList();

  void _seedDefaultNotes() {
    _notes.addAll([
      AtlantaNote(
        title: 'Project Atlanta Blueprint',
        content:
            'Autonomous AI Assistant architecture:\n- Reactive voice streaming\n- Stark-grade sound wave synthesizer\n- Integrated smart home neural node',
        category: 'Project',
        isPinned: true,
        colorValue: 0xFF1A2840,
      ),
      AtlantaNote(
        title: 'Lab Server Access Keys',
        content: 'Secondary terminal port: 8080\nSubnet gateway: 192.168.1.1\nQuantum firewall: ACTIVE',
        category: 'Work',
        isPinned: true,
        colorValue: 0xFF172D24,
      ),
      AtlantaNote(
        title: 'Ideas for Holographic HUD',
        content: 'Integrate dynamic circular telemetry gauges and neon cyan frequency spectrum bars.',
        category: 'Ideas',
        isPinned: false,
        colorValue: 0xFF281D3B,
      ),
      AtlantaNote(
        title: 'Weekly Training Regimen',
        content: 'Cardio morning 6 AM, strength training 5 PM, mobility drill 9 PM.',
        category: 'Personal',
        isPinned: false,
        colorValue: 0xFF111C2B,
      ),
    ]);
  }

  AtlantaNote addNote({
    required String title,
    required String content,
    String category = 'General',
    int colorValue = 0xFF111C2B,
    bool isPinned = false,
  }) {
    final note = AtlantaNote(
      title: title,
      content: content,
      category: category,
      colorValue: colorValue,
      isPinned: isPinned,
    );
    _notes.insert(0, note);
    ActivityService.instance.log(
      title: 'Note created',
      description: 'Documented: "$title"',
      type: ActivityType.note,
    );
    notifyListeners();
    return note;
  }

  void updateNote({
    required String id,
    String? title,
    String? content,
    String? category,
    int? colorValue,
    bool? isPinned,
  }) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      if (title != null) _notes[index].title = title;
      if (content != null) _notes[index].content = content;
      if (category != null) _notes[index].category = category;
      if (colorValue != null) _notes[index].colorValue = colorValue;
      if (isPinned != null) _notes[index].isPinned = isPinned;
      _notes[index].updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isPinned = !_notes[index].isPinned;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final removed = _notes.removeAt(index);
      ActivityService.instance.log(
        title: 'Note deleted',
        description: 'Removed: "${removed.title}"',
        type: ActivityType.note,
      );
      notifyListeners();
    }
  }
}
