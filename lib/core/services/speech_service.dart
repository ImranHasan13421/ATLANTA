import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Speech-to-Text (STT) service for listening to voice commands.
class SpeechService extends ChangeNotifier {
  static final SpeechService instance = SpeechService._internal();

  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  double _soundLevel = 0.0;
  String _lastRecognizedWords = '';

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  double get soundLevel => _soundLevel;
  String get lastRecognizedWords => _lastRecognizedWords;

  Future<bool> initialize() async {
    if (_isAvailable) return true;

    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            _soundLevel = 0.0;
            notifyListeners();
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech recognition error: ${errorNotification.errorMsg}');
          _isListening = false;
          _soundLevel = 0.0;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Speech recognition initialize exception: $e');
      _isAvailable = false;
    }

    notifyListeners();
    return _isAvailable;
  }

  Future<void> startListening({
    required Function(String words, bool isFinal) onResult,
    Function(double soundLevel)? onSoundLevel,
  }) async {
    final available = await initialize();

    _lastRecognizedWords = '';
    _isListening = true;
    notifyListeners();

    if (available) {
      try {
        await _speech.listen(
          onResult: (result) {
            _lastRecognizedWords = result.recognizedWords;
            notifyListeners();
            onResult(result.recognizedWords, result.finalResult);
          },
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: false,
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
          ),
          onSoundLevelChange: (level) {
            // Normalize level (usually -100 to 10 or 0 to 10) to 0.0 - 1.0
            _soundLevel = (level.clamp(0.0, 10.0) / 10.0);
            notifyListeners();
            onSoundLevel?.call(_soundLevel);
          },
        );
        return;
      } catch (e) {
        debugPrint('Listen error, using simulated mic stream: $e');
      }
    }

    // Fallback: If hardware mic is unavailable, run simulated sound wave levels
    _simulateSoundLevels(onSoundLevel);
  }

  Timer? _simTimer;
  void _simulateSoundLevels(Function(double soundLevel)? onSoundLevel) {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }
      _soundLevel = (0.2 + (0.8 * (DateTime.now().millisecond / 1000.0))).clamp(0.0, 1.0);
      notifyListeners();
      onSoundLevel?.call(_soundLevel);
    });
  }

  Future<void> stopListening() async {
    _simTimer?.cancel();
    _isListening = false;
    _soundLevel = 0.0;
    notifyListeners();

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
  }
}
