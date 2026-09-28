import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../audio/wav_synthesizer.dart';

/// Service for generating and playing futuristic sci-fi sound effects
/// and official Atlanta audio assets.
class SoundEffectsService {
  static final SoundEffectsService instance = SoundEffectsService._internal();

  SoundEffectsService._internal();

  AudioPlayer? _ambientPlayer;
  AudioPlayer? _clickPlayer;
  bool _isSoundEnabled = true;
  double _volume = 0.85;

  // Synthesized sci-fi fallbacks
  Uint8List? _bootBytes;
  Uint8List? _wakeBytes;
  Uint8List? _chirpBytes;
  Uint8List? _successBytes;
  Uint8List? _errorBytes;
  Uint8List? _scanBytes;
  Uint8List? _clickBytes;

  bool _isInitialized = false;

  AudioPlayer? _getAmbientPlayer() {
    try {
      _ambientPlayer ??= AudioPlayer();
      return _ambientPlayer;
    } catch (_) {
      return null;
    }
  }

  AudioPlayer? _getClickPlayer() {
    try {
      _clickPlayer ??= AudioPlayer();
      return _clickPlayer;
    } catch (_) {
      return null;
    }
  }

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
    try {
      _ambientPlayer?.setVolume(_volume);
      _clickPlayer?.setVolume(_volume);
    } catch (_) {}
  }

  /// Initializes procedural fallbacks and sets player volume.
  /// Listens for playback completion to immediately stop/release to prevent noise artifacts.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _bootBytes = WavSynthesizer.createSystemBootSound();
      _wakeBytes = WavSynthesizer.createWakeSound();
      _chirpBytes = WavSynthesizer.createListeningChirp();
      _successBytes = WavSynthesizer.createSuccessChime();
      _errorBytes = WavSynthesizer.createErrorTone();
      _scanBytes = WavSynthesizer.createScanningPulse();
      _clickBytes = WavSynthesizer.createClickFeedback();

      final ambient = _getAmbientPlayer();
      final click = _getClickPlayer();
      await ambient?.setVolume(_volume);
      await click?.setVolume(_volume);
      await click?.setPlayerMode(PlayerMode.lowLatency);

      // Fix noise at end of audio: immediately stop player when playback completes
      ambient?.onPlayerComplete.listen((_) {
        try {
          ambient.stop();
        } catch (_) {}
      });
      click?.onPlayerComplete.listen((_) {
        try {
          click.stop();
        } catch (_) {}
      });

      _isInitialized = true;
    } catch (_) {
      // Audio fallback gracefully handled
    }
  }

  /// Plays uploaded App Intro sound during splash screen
  Future<void> playAppIntro() async {
    if (!_isSoundEnabled) return;
    try {
      final player = _getAmbientPlayer();
      if (player == null) return;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource('sounds/app_intro.mp3'), volume: _volume);
    } catch (e) {
      debugPrint('AppIntro asset playback note: $e');
      await playIntroBoot();
    }
  }

  bool _hasPlayedIntroVoice = false;

  /// Plays uploaded Intro Voice welcome sound when home screen starts.
  /// Guaranteed to only play ONCE per app session (when transitioning from splash screen).
  Future<void> playIntroVoice() async {
    if (!_isSoundEnabled || _hasPlayedIntroVoice) return;
    _hasPlayedIntroVoice = true;
    try {
      final player = _getAmbientPlayer();
      if (player == null) return;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource('sounds/intro_voice.mp3'), volume: _volume);
    } catch (e) {
      debugPrint('IntroVoice asset playback note: $e');
    }
  }

  /// Plays uploaded Button Click sound snappy and in sync across all buttons
  Future<void> playClick() async {
    if (!_isSoundEnabled) return;
    try {
      final player = _getClickPlayer();
      if (player == null) return;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource('sounds/button_click.mp3'), volume: _volume);
    } catch (_) {
      // Procedural click fallback
      try {
        final player = _getClickPlayer();
        final bytes = _clickBytes ?? WavSynthesizer.createClickFeedback();
        await player?.setReleaseMode(ReleaseMode.stop);
        await player?.play(BytesSource(bytes), volume: _volume);
      } catch (_) {}
    }
  }

  /// Plays sound bytes through ambient/effects player
  Future<void> _playBytes(Uint8List? bytes) async {
    if (!_isSoundEnabled || bytes == null) return;
    try {
      final player = _getAmbientPlayer();
      if (player == null) return;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(BytesSource(bytes), volume: _volume);
    } catch (_) {}
  }

  /// Plays cinematic futuristic system opening / startup sound.
  Future<void> playIntroBoot() async {
    await _playBytes(_bootBytes ?? WavSynthesizer.createSystemBootSound());
  }

  /// Plays futuristic assistant wake / activate chime.
  Future<void> playWake() async {
    await _playBytes(_wakeBytes ?? WavSynthesizer.createWakeSound());
  }

  /// Plays futuristic mic listening active blip.
  Future<void> playListeningChirp() async {
    await _playBytes(_chirpBytes ?? WavSynthesizer.createListeningChirp());
  }

  /// Plays Stark-grade confirmation chord when command finishes.
  Future<void> playSuccess() async {
    await _playBytes(_successBytes ?? WavSynthesizer.createSuccessChime());
  }

  /// Plays high-tech warning alert tone.
  Future<void> playError() async {
    await _playBytes(_errorBytes ?? WavSynthesizer.createErrorTone());
  }

  /// Plays fast HUD telemetry scanning sound.
  Future<void> playScanning() async {
    await _playBytes(_scanBytes ?? WavSynthesizer.createScanningPulse());
  }

  void dispose() {
    _ambientPlayer?.dispose();
    _clickPlayer?.dispose();
  }
}
