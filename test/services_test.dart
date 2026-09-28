import 'package:flutter_test/flutter_test.dart';
import 'package:atlanta/core/services/task_service.dart';
import 'package:atlanta/core/services/note_service.dart';
import 'package:atlanta/core/services/reminder_service.dart';
import 'package:atlanta/core/services/device_service.dart';
import 'package:atlanta/core/services/brain_service.dart';
import 'package:atlanta/core/audio/wav_synthesizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ATLANTA Services & Brain Engine Tests', () {
    test('TaskService adds, toggles, and tracks counts', () {
      final initialCount = TaskService.instance.totalCount;
      final task = TaskService.instance.addTask(
        title: 'Calibrate neural link',
        dueDate: 'Today',
        priority: 'high',
      );

      expect(TaskService.instance.totalCount, initialCount + 1);
      expect(task.title, 'Calibrate neural link');
      expect(task.isCompleted, false);

      TaskService.instance.toggleTask(task.id);
      expect(task.isCompleted, true);
    });

    test('NoteService creates, pins, and filters notes', () {
      final note = NoteService.instance.addNote(
        title: 'Quantum Gateway',
        content: 'Server port 9000 active',
        category: 'Project',
        isPinned: true,
      );

      expect(note.title, 'Quantum Gateway');
      expect(note.isPinned, true);
      expect(NoteService.instance.pinnedNotes.contains(note), true);
    });

    test('ReminderService sets and snoozes reminders', () {
      final reminder = ReminderService.instance.addReminder(
        title: 'Team standup',
        time: '11:00 AM',
      );

      expect(reminder.title, 'Team standup');
      expect(reminder.isSnoozed, false);

      ReminderService.instance.snoozeReminder(reminder.id);
      expect(reminder.isSnoozed, true);
    });

    test('DeviceService toggles and searches smart devices', () {
      final light = DeviceService.instance.findDeviceByName('Light');
      expect(light, isNotNull);

      final wasOn = light!.isOn;
      final newState = DeviceService.instance.toggleDevice(light.id);
      expect(newState, !wasOn);
    });

    test('BrainService parses and executes task creation voice command', () async {
      final result = await BrainService.instance.processCommand(
        'Add task: Review orbital telemetry data today priority high',
        speakResponse: false,
      );

      expect(result.intentType, 'task');
      expect(result.isSuccess, true);
      expect(TaskService.instance.tasks.any((t) => t.title.contains('Review orbital telemetry')), true);
    });

    test('BrainService parses and executes note creation voice command', () async {
      final result = await BrainService.instance.processCommand(
        'Take a note: Primary sub-node password is Stark Industries 3000',
        speakResponse: false,
      );

      expect(result.intentType, 'note');
      expect(result.isSuccess, true);
    });

    test('BrainService reports system diagnostics and status telemetry', () async {
      final result = await BrainService.instance.processCommand(
        'Atlanta, run system diagnostics and status',
        speakResponse: false,
      );

      expect(result.intentType, 'telemetry');
      expect(result.displayText.contains('TELEMETRY STATUS'), true);
    });

    test('WavSynthesizer generates valid system boot sound with RIFF/WAVE header', () {
      final bootWav = WavSynthesizer.createSystemBootSound();
      expect(bootWav.length > 44, true);
      expect(String.fromCharCodes(bootWav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bootWav.sublist(8, 12)), 'WAVE');
    });

    test('BrainService addresses user as Boss and handles identity and Hey Atlanta', () async {
      final greetingResult = await BrainService.instance.processCommand(
        'hey atlanta',
        speakResponse: false,
      );
      expect(greetingResult.speechResponse.contains('Hello Boss! Its Atlanta at your service'), true);

      final identityResult = await BrainService.instance.processCommand(
        'who are you',
        speakResponse: false,
      );
      expect(identityResult.speechResponse.contains('Boss'), true);

      final emptyResult = await BrainService.instance.processCommand('', speakResponse: false);
      expect(emptyResult.speechResponse.contains('Boss'), true);
    });

    test('BrainService parses and executes native app launching intent', () async {
      final result = await BrainService.instance.processCommand(
        'open the clock application on my device',
        speakResponse: false,
      );

      expect(result.intentType, 'app_launch');
      expect(result.isSuccess, true);
      expect(result.speechResponse.contains('Clock'), true);
      expect(result.speechResponse.contains('Boss'), true);
    });

    test('BrainService parses and sets alarm intent', () async {
      final result = await BrainService.instance.processCommand(
        'hello Atlanta set a alarm for 9:00 p.m. today',
        speakResponse: false,
      );

      expect(result.intentType, 'alarm');
      expect(result.isSuccess, true);
      expect(result.speechResponse.contains('21:00'), true);
      expect(result.speechResponse.contains('Boss'), true);
      expect(ReminderService.instance.reminders.any((r) => r.time == '21:00'), true);
    });

    test('WavSynthesizer generates valid 44.1kHz PCM audio bytes for sci-fi sounds', () {
      final wakeWav = WavSynthesizer.createWakeSound();
      expect(wakeWav.length > 44, true); // RIFF header is 44 bytes

      // Verify 'RIFF' and 'WAVE' magic signatures
      expect(String.fromCharCodes(wakeWav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wakeWav.sublist(8, 12)), 'WAVE');

      final chirpWav = WavSynthesizer.createListeningChirp();
      expect(String.fromCharCodes(chirpWav.sublist(0, 4)), 'RIFF');

      final successWav = WavSynthesizer.createSuccessChime();
      expect(String.fromCharCodes(successWav.sublist(0, 4)), 'RIFF');
    });
  });
}
