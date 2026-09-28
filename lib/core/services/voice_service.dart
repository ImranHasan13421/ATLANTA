import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-To-Speech (TTS) service powering Atlanta's intelligent voice.
class VoiceService extends ChangeNotifier {
  static final VoiceService instance = VoiceService._internal();

  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  double _speechRate = 0.50;
  double _pitch = 1.22; // Crystalline, high-tech female AI vocal timbre
  final double _volume = 1.0;

  bool get isSpeaking => _isSpeaking;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      // Dynamically select a high-fidelity female voice if available on system
      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List) {
          for (final voice in voices) {
            if (voice is Map) {
              final name = (voice['name'] ?? '').toString().toLowerCase();
              final locale = (voice['locale'] ?? '').toString().toLowerCase();
              final isFemale = name.contains('female') ||
                  name.contains('zira') ||
                  name.contains('hazel') ||
                  name.contains('samantha') ||
                  name.contains('catherine') ||
                  name.contains('susan') ||
                  name.contains('eva') ||
                  name.contains('victoria') ||
                  name.contains('karen') ||
                  name.contains('en-us-x-sfg');
              if (isFemale && (locale.contains('en') || locale.isEmpty)) {
                await _flutterTts.setVoice({
                  'name': voice['name'].toString(),
                  'locale': voice['locale']?.toString() ?? 'en-US',
                });
                debugPrint('VoiceService: Selected female voice: ${voice['name']}');
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('VoiceService: System voice selection fallback note: $e');
      }

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('VoiceService initialization note: $e');
    }
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  void setPitch(double pitchVal) {
    _pitch = pitchVal;
    _flutterTts.setPitch(pitchVal);
    notifyListeners();
  }

  /// Welcome greeting for the user/boss on system boot.
  Future<void> welcomeBoss() async {
    await speak("Hello Boss! Its Atlanta at your service");
  }

  /// Speaks text with futuristic cadence and emits speaking state.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await initialize();
      await _flutterTts.stop();
      _isSpeaking = true;
      notifyListeners();

      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
      debugPrint('Error in speak: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
