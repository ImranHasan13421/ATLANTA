import 'package:flutter/foundation.dart';
import 'task_service.dart';
import 'note_service.dart';
import 'reminder_service.dart';
import 'device_service.dart';
import 'automation_service.dart';
import 'sound_effects_service.dart';
import 'voice_service.dart';
import 'gemini_ai_service.dart';
import 'native_device_service.dart';

class CommandResult {
  final String speechResponse;
  final String displayText;
  final String? intentType; // 'task', 'note', 'reminder', 'alarm', 'app_launch', 'device', 'automation', 'telemetry', 'chat'
  final dynamic payload;
  final bool isSuccess;

  CommandResult({
    required this.speechResponse,
    required this.displayText,
    this.intentType,
    this.payload,
    this.isSuccess = true,
  });
}

/// The intelligence core of ATLANTA.
/// Parses natural language voice commands, coordinates native device intents, and delivers TTS/audio feedback.
class BrainService extends ChangeNotifier {
  static final BrainService instance = BrainService._internal();

  BrainService._internal();

  /// Processes user voice or text input, triggers services, plays futuristic audio, and returns result.
  Future<CommandResult> processCommand(
    String input, {
    bool speakResponse = true,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final text = input.trim();
    if (text.isEmpty) {
      return CommandResult(
        speechResponse: 'I am listening, Boss.',
        displayText: 'I am listening, Boss.',
        isSuccess: false,
      );
    }

    var lower = text.toLowerCase();

    // ── STRIP WAKE WORD PREFIX ──
    // "Atlanta, open clock" → "open clock"
    // "Hey Atlanta set alarm" → "set alarm"
    final wakePatterns = [
      'hey atlanta ',
      'hello atlanta ',
      'hi atlanta ',
      'atlanta ',
      'hey atlanta, ',
      'hello atlanta, ',
      'hi atlanta, ',
      'atlanta, ',
    ];
    var cleanedText = text;
    for (final prefix in wakePatterns) {
      if (lower.startsWith(prefix)) {
        cleanedText = text.substring(prefix.length).trim();
        lower = cleanedText.toLowerCase();
        break;
      }
    }

    // ── 0. IDENTITY / INTRODUCTION INTENT ──
    if (lower.contains('who are you') ||
        lower.contains('what is your name') ||
        lower.contains('introduce yourself') ||
        lower.contains('tell me about yourself') ||
        lower.contains('what can you do')) {
      return await _handleIdentity(speakResponse);
    }

    // Pure greeting (only if the entire cleaned command is just a greeting)
    if (lower == 'hey atlanta' ||
        lower == 'hello atlanta' ||
        lower == 'hi atlanta' ||
        lower == 'atlanta' ||
        lower == 'hey' ||
        lower == 'hello' ||
        lower == 'hi' ||
        lower.isEmpty) {
      await SoundEffectsService.instance.playWake();
      const speech = 'Hello Boss! Its Atlanta at your service. All neural cores are synchronized and awaiting your command.';
      if (speakResponse) await VoiceService.instance.speak(speech);
      return CommandResult(
        speechResponse: speech,
        displayText: '✨ Atlanta: Standing by at your service, Boss.',
        intentType: 'greeting',
      );
    }

    // ── 1. NATIVE APP LAUNCHING INTENT ──
    if (lower.startsWith('open ') ||
        lower.startsWith('launch ') ||
        lower.startsWith('start ') ||
        lower.contains('application on my device') ||
        lower.contains('app on my phone') ||
        lower.contains('open the ') ||
        lower.contains('launch the ')) {
      final appResult = await _handleAppLaunch(text, lower, speakResponse);
      if (appResult != null) return appResult;
    }

    // ── 2. ALARM CREATION INTENT ──
    if (lower.startsWith('set alarm') ||
        lower.startsWith('set an alarm') ||
        lower.startsWith('set a alarm') ||
        lower.contains('alarm for') ||
        lower.contains('alarm at') ||
        lower.startsWith('wake me up at') ||
        lower.startsWith('wake me up')) {
      return await _handleAlarmCreation(text, lower, speakResponse);
    }

    // ── 3. TASK CREATION INTENT ──
    if (lower.startsWith('create task') ||
        lower.startsWith('add task') ||
        lower.startsWith('new task') ||
        lower.contains('add a task') ||
        lower.contains('create a task') ||
        lower.startsWith('schedule a') ||
        lower.startsWith('schedule task') ||
        lower.startsWith('task:')) {
      return await _handleTaskCreation(text, lower, speakResponse);
    }

    // ── 4. TASK INQUIRY INTENT ──
    if (lower.contains('what are my tasks') ||
        lower.contains('show my tasks') ||
        lower.contains('list tasks') ||
        lower.contains('what do i have to do') ||
        lower.contains('pending tasks') ||
        lower.contains('my schedule')) {
      return await _handleTaskInquiry(speakResponse);
    }

    // ── 5. NOTE CREATION INTENT ──
    if (lower.startsWith('take a note') ||
        lower.startsWith('take note') ||
        lower.startsWith('create note') ||
        lower.startsWith('create a note') ||
        lower.startsWith('write this down') ||
        lower.startsWith('make a note') ||
        lower.startsWith('note that') ||
        lower.startsWith('note:')) {
      return await _handleNoteCreation(text, lower, speakResponse);
    }

    // ── 6. REMINDER CREATION INTENT ──
    if (lower.startsWith('set reminder') ||
        lower.startsWith('set a reminder') ||
        lower.startsWith('remind me to') ||
        lower.startsWith('remind me at') ||
        lower.startsWith('remind me tomorrow') ||
        lower.startsWith('remind me')) {
      return await _handleReminderCreation(text, lower, speakResponse);
    }

    // ── 7. SMART HOME / DEVICE CONTROL INTENT ──
    if (lower.contains('turn on') ||
        lower.contains('turn off') ||
        lower.contains('activate device') ||
        lower.contains('switch on') ||
        lower.contains('switch off') ||
        lower.contains('lock the') ||
        lower.contains('unlock the') ||
        lower.contains('lights on') ||
        lower.contains('lights off')) {
      return await _handleDeviceControl(lower, speakResponse);
    }

    // ── 8. AUTOMATION EXECUTION INTENT ──
    if (lower.startsWith('run automation') ||
        lower.startsWith('execute automation') ||
        lower.contains('morning protocol') ||
        lower.contains('focus mode') ||
        lower.contains('night protocol') ||
        lower.contains('defense grid') ||
        lower.contains('execute protocol')) {
      return await _handleAutomationExecution(lower, speakResponse);
    }

    // ── 9. SYSTEM STATUS / DIAGNOSTICS INTENT ──
    if (lower.contains('status') ||
        lower.contains('diagnostic') ||
        lower.contains('telemetry')) {
      return await _handleSystemStatus(speakResponse);
    }

    // ── 10. WEATHER / ATMOSPHERIC TELEMETRY INTENT ──
    if (lower.contains('weather') || lower.contains('temperature') || lower.contains('forecast')) {
      return await _handleWeather(speakResponse);
    }

    // ── 11. CONVERSATIONAL & GENERAL INTELLIGENCE ──
    return await _handleGeneralQuery(
      text,
      lower,
      speakResponse,
      conversationHistory: conversationHistory,
    );
  }

  // ──── HANDLERS ────

  Future<CommandResult?> _handleAppLaunch(String text, String lower, bool speak) async {
    // Determine the target app keyword
    var appQuery = lower;
    final cleanupPatterns = [
      'open the ',
      'open ',
      'launch the ',
      'launch ',
      'start the ',
      'start ',
      ' application on my device',
      ' app on my device',
      ' application on my phone',
      ' app on my phone',
      ' application',
      ' app',
      ' please',
    ];

    for (final pattern in cleanupPatterns) {
      appQuery = appQuery.replaceAll(pattern, '');
    }
    appQuery = appQuery.trim();

    if (appQuery.isEmpty) return null;

    // Check if user is asking to open a note/task instead
    if (appQuery == 'task' || appQuery == 'tasks' || appQuery == 'note' || appQuery == 'notes') {
      return null;
    }

    await SoundEffectsService.instance.playScanning();

    // Capitalize first letter for display
    final appDisplayName = appQuery.isEmpty
        ? 'Application'
        : appQuery[0].toUpperCase() + appQuery.substring(1);

    // Trigger native app launcher
    final success = await NativeDeviceService.instance.launchApp(appQuery);

    if (success) {
      await SoundEffectsService.instance.playSuccess();
      final speech = 'Right away, Boss. Launching $appDisplayName now.';
      final display = '🚀 Launching $appDisplayName on device...';

      if (speak) await VoiceService.instance.speak(speech);

      return CommandResult(
        speechResponse: speech,
        displayText: display,
        intentType: 'app_launch',
        payload: appQuery,
      );
    } else {
      // If it looks like a broader topic rather than a simple app name, fallback to Gemini AI
      if (appQuery.split(' ').length > 2) {
        return await _handleGeneralQuery(text, lower, speak);
      }

      await SoundEffectsService.instance.playSuccess();
      final speech = 'Attempted to launch $appDisplayName, Boss. Please ensure the app is installed and granted access.';
      final display = '📱 App request: $appDisplayName';
      if (speak) await VoiceService.instance.speak(speech);
      return CommandResult(
        speechResponse: speech,
        displayText: display,
        intentType: 'app_launch',
        payload: appQuery,
      );
    }
  }

  Future<CommandResult> _handleAlarmCreation(String text, String lower, bool speak) async {
    await SoundEffectsService.instance.playScanning();

    var hour = 8;
    var minute = 0;
    String displayTime = '8:00 AM';

    // Parse time patterns: e.g. "9:00 p.m.", "9:00 pm", "9 pm", "21:00", "7:30 am", "7 am"
    final timeMatch24 = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(lower);
    final isPmMatch = lower.contains('p.m.') || lower.contains('pm') || lower.contains('night') || lower.contains('evening');
    final isAmMatch = lower.contains('a.m.') || lower.contains('am') || lower.contains('morning');

    if (timeMatch24 != null) {
      hour = int.tryParse(timeMatch24.group(1) ?? '8') ?? 8;
      minute = int.tryParse(timeMatch24.group(2) ?? '0') ?? 0;
      if (isPmMatch && hour < 12) {
        hour += 12;
      } else if (isAmMatch && hour == 12) {
        hour = 0;
      }
    } else {
      final hourMatch = RegExp(r'(\d{1,2})\s*(?:o\s*clock|am|pm|p\.m\.|a\.m\.)?').firstMatch(lower);
      if (hourMatch != null) {
        hour = int.tryParse(hourMatch.group(1) ?? '8') ?? 8;
        if (isPmMatch && hour < 12) hour += 12;
        if (isAmMatch && hour == 12) hour = 0;
      }
    }

    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    displayTime = '$hStr:$mStr';

    // 1. Add to Atlanta Reminder Service
    ReminderService.instance.addReminder(
      title: 'Alarm at $displayTime',
      time: displayTime,
      date: lower.contains('tomorrow') ? 'Tomorrow' : 'Today',
    );

    // 2. Trigger native OS Alarm Intent
    await NativeDeviceService.instance.setAlarm(
      hour: hour,
      minutes: minute,
      message: 'Atlanta Alarm',
    );

    await SoundEffectsService.instance.playSuccess();
    final speech = 'Alarm set for $displayTime, Boss. Consider it handled.';
    final display = '⏰ Alarm set for $displayTime, Boss. Consider it handled.';

    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: display,
      intentType: 'alarm',
      payload: {'hour': hour, 'minute': minute, 'time': displayTime},
    );
  }

  Future<CommandResult> _handleIdentity(bool speak) async {
    await SoundEffectsService.instance.playSuccess();
    const speech =
        'I am Atlanta, Boss. Your personal high-intelligence AI assistant. I manage your daily tasks, capture notes, schedule reminders and alarms, launch device applications, control connected devices, and execute autonomous workflows at your command.';
    const display =
        '✨ ATLANTA PERSONAL AI\n• Architecture: High-Precision Neural Assistant\n• Capabilities: Native App Launching, Alarms, Voice STT/TTS, Task Mgmt, Smart Grid\n• Status: At your service, Boss.';
    if (speak) await VoiceService.instance.speak(speech);
    return CommandResult(
      speechResponse: speech,
      displayText: display,
      intentType: 'identity',
    );
  }

  Future<CommandResult> _handleTaskCreation(String text, String lower, bool speak) async {
    // Extract task title
    var title = text;
    final prefixes = [
      'create task to',
      'create a task to',
      'create task',
      'create a task',
      'add task to',
      'add a task to',
      'add task',
      'add a task',
      'new task to',
      'new task',
      'schedule a task to',
      'schedule task to',
      'schedule a',
      'task:'
    ];
    for (final p in prefixes) {
      if (lower.startsWith(p)) {
        title = text.substring(p.length).trim();
        if (title.startsWith(':') || title.startsWith('-')) {
          title = title.substring(1).trim();
        }
        break;
      }
    }

    if (title.isEmpty) title = 'Important objective';

    var priority = 'medium';
    if (lower.contains('urgent') || lower.contains('priority high') || lower.contains('high priority')) {
      priority = 'high';
      title = title.replaceAll(RegExp(r'(urgent|priority high|high priority)', caseSensitive: false), '').trim();
    } else if (lower.contains('low priority')) {
      priority = 'low';
      title = title.replaceAll(RegExp(r'low priority', caseSensitive: false), '').trim();
    }

    var dueDate = 'Today';
    if (lower.contains('tomorrow')) {
      dueDate = 'Tomorrow';
      title = title.replaceAll(RegExp(r'tomorrow', caseSensitive: false), '').trim();
    }

    final task = TaskService.instance.addTask(
      title: title,
      dueDate: dueDate,
      priority: priority,
    );

    await SoundEffectsService.instance.playSuccess();
    final speech = 'Task added for you, Boss: "$title". Scheduled for $dueDate with $priority priority.';
    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: '✓ Created task: "$title"',
      intentType: 'task',
      payload: task,
    );
  }

  Future<CommandResult> _handleTaskInquiry(bool speak) async {
    final pending = TaskService.instance.pendingCount;
    final tasks = TaskService.instance.tasks.where((t) => !t.isCompleted).take(3).toList();

    await SoundEffectsService.instance.playScanning();

    String speech;
    String display;

    if (pending == 0) {
      speech = 'You have zero pending tasks, Boss. All objectives are accomplished.';
      display = 'All objectives completed. 0 pending tasks.';
    } else {
      final titles = tasks.map((t) => t.title).join(', ');
      speech = 'You have $pending active tasks, Boss. Upcoming objectives include: $titles.';
      final taskItems = tasks.map((t) => '• ${t.title} (${t.dueDate})').join('\n');
      display = '📋 $pending active tasks:\n$taskItems';
    }

    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: display,
      intentType: 'task_inquiry',
      payload: tasks,
    );
  }

  Future<CommandResult> _handleNoteCreation(String text, String lower, bool speak) async {
    var content = text;
    final prefixes = [
      'take a note of',
      'take a note that',
      'take a note',
      'take note of',
      'take note that',
      'take note',
      'create note',
      'create a note',
      'write this down',
      'make a note of',
      'make a note',
      'note that',
      'note:'
    ];
    for (final p in prefixes) {
      if (lower.startsWith(p)) {
        content = text.substring(p.length).trim();
        if (content.startsWith(':') || content.startsWith('-')) {
          content = content.substring(1).trim();
        }
        break;
      }
    }

    if (content.isEmpty) content = 'Quick voice memo';

    final words = content.split(' ');
    final title = words.length > 5 ? '${words.take(5).join(' ')}...' : content;

    final note = NoteService.instance.addNote(
      title: title,
      content: content,
      category: 'Voice Memo',
      colorValue: 0xFF1D2E47,
    );

    await SoundEffectsService.instance.playSuccess();
    final speech = 'Note documented in your neural archive, Boss: "$title".';
    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: '📝 Note saved: "$content"',
      intentType: 'note',
      payload: note,
    );
  }

  Future<CommandResult> _handleReminderCreation(String text, String lower, bool speak) async {
    var title = text;
    final prefixes = [
      'set reminder for',
      'set a reminder for',
      'set reminder to',
      'set a reminder to',
      'set reminder',
      'set a reminder',
      'remind me to',
      'remind me at',
      'remind me'
    ];
    for (final p in prefixes) {
      if (lower.startsWith(p)) {
        title = text.substring(p.length).trim();
        break;
      }
    }

    var time = 'In 1 hour';
    if (lower.contains('at ')) {
      final parts = lower.split('at ');
      if (parts.length > 1) {
        time = parts.last.trim();
        title = title.replaceAll(RegExp('at $time', caseSensitive: false), '').trim();
      }
    }

    final reminder = ReminderService.instance.addReminder(
      title: title.isEmpty ? 'Scheduled reminder' : title,
      time: time,
      date: lower.contains('tomorrow') ? 'Tomorrow' : 'Today',
    );

    await SoundEffectsService.instance.playSuccess();
    final speech = 'Reminder set for you, Boss: "$title" at $time.';
    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: '⏰ Reminder active: "$title" at $time',
      intentType: 'reminder',
      payload: reminder,
    );
  }

  Future<CommandResult> _handleDeviceControl(String lower, bool speak) async {
    final devices = DeviceService.instance.devices;
    AtlantaDevice? target;

    for (final d in devices) {
      if (lower.contains(d.name.toLowerCase()) || lower.contains(d.room.toLowerCase())) {
        target = d;
        break;
      }
    }

    // Default to lights or smart locks if generic command
    if (target == null) {
      if (lower.contains('light') || lower.contains('lights')) {
        target = DeviceService.instance.findDeviceByName('Light');
      } else if (lower.contains('lock') || lower.contains('door')) {
        target = DeviceService.instance.findDeviceByName('Lock');
      }
    }

    if (target != null) {
      final turnOn = lower.contains('turn on') || lower.contains('switch on') || lower.contains('lights on') || lower.contains('lock');
      if (target.isOn != turnOn) {
        DeviceService.instance.toggleDevice(target.id);
      }

      await SoundEffectsService.instance.playSuccess();
      final action = target.isOn ? 'activated' : 'powered down';
      final speech = '${target.name} has been $action, Boss.';
      if (speak) await VoiceService.instance.speak(speech);

      return CommandResult(
        speechResponse: speech,
        displayText: '⚡ ${target.name}: ${target.isOn ? "ONLINE" : "STANDBY"}',
        intentType: 'device',
        payload: target,
      );
    }

    await SoundEffectsService.instance.playError();
    final speech = 'Device not recognized in current telemetry grid, Boss.';
    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: '⚠️ Device not found in telemetry grid',
      intentType: 'device',
      isSuccess: false,
    );
  }

  Future<CommandResult> _handleAutomationExecution(String lower, bool speak) async {
    AtlantaAutomation? target;
    if (lower.contains('morning')) {
      target = AutomationService.instance.findAutomationByName('Morning');
    } else if (lower.contains('focus')) {
      target = AutomationService.instance.findAutomationByName('Focus');
    } else if (lower.contains('night')) {
      target = AutomationService.instance.findAutomationByName('Night');
    } else if (lower.contains('defense') || lower.contains('grid')) {
      target = AutomationService.instance.findAutomationByName('Defense');
    } else {
      target = AutomationService.instance.automations.first;
    }

    if (target != null) {
      await SoundEffectsService.instance.playScanning();
      final speech = 'Initiating ${target.name}, Boss. Executing protocol sequence now.';
      if (speak) await VoiceService.instance.speak(speech);

      // Execute live
      AutomationService.instance.executeAutomation(target.id);

      return CommandResult(
        speechResponse: speech,
        displayText: '🚀 Executing Protocol: ${target.name}',
        intentType: 'automation',
        payload: target,
      );
    }

    return CommandResult(
      speechResponse: 'Workflow protocol not recognized, Boss.',
      displayText: 'Workflow not found',
      isSuccess: false,
    );
  }

  Future<CommandResult> _handleSystemStatus(bool speak) async {
    await SoundEffectsService.instance.playScanning();
    final onlineDev = DeviceService.instance.onlineCount;
    final pendingTasks = TaskService.instance.pendingCount;

    final speech =
        'All Atlanta subsystems running at peak efficiency, Boss. Quantum neural core is synchronized, $onlineDev connected devices active, and $pendingTasks pending objectives in queue. Ready for your command.';
    final display =
        '⚡ ATLANTA TELEMETRY STATUS\n• Neural Core: NOMINAL (99.8%)\n• Connected Devices: $onlineDev Online\n• Pending Objectives: $pendingTasks Tasks\n• Network: Supabase Encrypted Mesh';

    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: display,
      intentType: 'telemetry',
    );
  }

  Future<CommandResult> _handleWeather(bool speak) async {
    await SoundEffectsService.instance.playScanning();
    final speech =
        'Atmospheric scan indicates 24 degrees Celsius, gentle breeze from the northeast, and 48% humidity. Conditions are optimal, Boss.';
    final display = '🌤️ Current Atmospheric Telemetry:\n24°C | 48% Humidity | 1014 hPa | Clear';

    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: display,
      intentType: 'weather',
    );
  }

  Future<CommandResult> _handleGeneralQuery(
    String text,
    String lower,
    bool speak, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    String speech;
    String display;

    if (lower.contains('thank you') || lower.contains('thanks')) {
      await SoundEffectsService.instance.playSuccess();
      speech = 'Always at your service, Boss. Let me know if you require further assistance.';
      display = 'Always at your service, Boss.';
    } else if (lower.contains('time') || lower.contains('what time is it')) {
      await SoundEffectsService.instance.playSuccess();
      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final ampm = now.hour >= 12 ? 'PM' : 'AM';
      final min = now.minute.toString().padLeft(2, '0');
      speech = 'The current local time is $hour:$min $ampm, Boss.';
      display = '🕒 Current Time: $hour:$min $ampm';
    } else {
      // Query Google AI Studio Gemini Cloud AI
      final cloudResponse = await GeminiAiService.instance.generateResponse(
        text,
        conversationHistory: conversationHistory,
      );
      await SoundEffectsService.instance.playSuccess();
      speech = cloudResponse;
      display = cloudResponse;
    }

    if (speak) await VoiceService.instance.speak(speech);

    return CommandResult(
      speechResponse: speech,
      displayText: display,
      intentType: 'chat',
    );
  }
}
