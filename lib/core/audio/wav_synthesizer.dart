import 'dart:math' as math;
import 'dart:typed_data';

/// Procedural 44.1kHz 16-bit PCM WAV audio synthesizer for futuristic sci-fi sound effects.
///
/// Generates crystal-clear, zero-latency in-memory WAV byte arrays.
class WavSynthesizer {
  static const int sampleRate = 44100;

  /// Builds a complete WAV byte buffer from raw 16-bit mono PCM samples.
  static Uint8List buildWavHeaderAndData(List<int> samples) {
    final numSamples = samples.length;
    final subChunk2Size = numSamples * 2; // 16-bit = 2 bytes per sample
    final chunkSize = 36 + subChunk2Size;

    final bytes = ByteData(44 + subChunk2Size);

    // RIFF header
    bytes.setUint8(0, 0x52); // 'R'
    bytes.setUint8(1, 0x49); // 'I'
    bytes.setUint8(2, 0x46); // 'F'
    bytes.setUint8(3, 0x46); // 'F'
    bytes.setUint32(4, chunkSize, Endian.little);
    bytes.setUint8(8, 0x57); // 'W'
    bytes.setUint8(9, 0x41); // 'A'
    bytes.setUint8(10, 0x56); // 'V'
    bytes.setUint8(11, 0x45); // 'E'

    // fmt chunk
    bytes.setUint8(12, 0x66); // 'f'
    bytes.setUint8(13, 0x6d); // 'm'
    bytes.setUint8(14, 0x74); // 't'
    bytes.setUint8(15, 0x20); // ' '
    bytes.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    bytes.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    bytes.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    bytes.setUint32(24, sampleRate, Endian.little); // SampleRate
    bytes.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * 1 * 16/8)
    bytes.setUint16(32, 2, Endian.little); // BlockAlign (1 * 16/8)
    bytes.setUint16(34, 16, Endian.little); // BitsPerSample

    // data chunk
    bytes.setUint8(36, 0x64); // 'd'
    bytes.setUint8(37, 0x61); // 'a'
    bytes.setUint8(38, 0x74); // 't'
    bytes.setUint8(39, 0x61); // 'a'
    bytes.setUint32(40, subChunk2Size, Endian.little);

    // Write samples
    var offset = 44;
    for (var i = 0; i < numSamples; i++) {
      final s = samples[i].clamp(-32768, 32767);
      bytes.setInt16(offset, s, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// 1. Futuristic Wake-up / Activation Tone
  /// Upward sci-fi frequency sweep with shimmering harmonic resonance (like Jarvis booting up).
  static Uint8List createWakeSound({double durationSeconds = 0.45}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;

      // Exponential frequency sweep from 440 Hz up to 1800 Hz
      final freq = 440.0 * math.pow(1800.0 / 440.0, progress);

      // Primary sine + secondary harmonic shimmer + third sub-octave
      final fundamental = math.sin(2 * math.pi * freq * t);
      final harmonic = 0.35 * math.sin(2 * math.pi * (freq * 1.5) * t);
      final sub = 0.2 * math.sin(2 * math.pi * (freq * 0.5) * t);

      // Envelope: Fast attack (15ms), smooth sustain, gentle release
      double envelope;
      if (progress < 0.05) {
        envelope = progress / 0.05;
      } else if (progress > 0.75) {
        envelope = (1.0 - progress) / 0.25;
      } else {
        envelope = 1.0;
      }

      final mixed = (fundamental + harmonic + sub) * envelope * 24000;
      samples.add(mixed.toInt());
    }

    return buildWavHeaderAndData(samples);
  }

  /// 2. Futuristic Listening / Mic Active Chirp
  /// High-tech cyber dual-blip (880Hz -> 1760Hz rapid chirp).
  static Uint8List createListeningChirp({double durationSeconds = 0.18}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;

      // Two quick pulses
      final pulse1 = (progress < 0.45) ? math.sin(2 * math.pi * 980 * t) * math.sin(progress / 0.45 * math.pi) : 0.0;
      final pulse2 = (progress >= 0.5) ? math.sin(2 * math.pi * 1760 * t) * math.sin((progress - 0.5) / 0.5 * math.pi) : 0.0;

      final mixed = (pulse1 + pulse2) * 26000;
      samples.add(mixed.toInt());
    }

    return buildWavHeaderAndData(samples);
  }

  /// 3. Futuristic Confirmation / Success Chime
  /// Stark Industries style melodic cyber chord (C6 1046Hz -> E6 1318Hz -> G6 1567Hz -> C7 2093Hz)
  /// with smooth resonance decay.
  static Uint8List createSuccessChime({double durationSeconds = 0.55}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    const notes = [1046.5, 1318.5, 1567.98, 2093.0]; // C6, E6, G6, C7

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      var sum = 0.0;

      for (var n = 0; n < notes.length; n++) {
        final noteStartTime = n * 0.07;
        if (t >= noteStartTime) {
          final noteT = t - noteStartTime;
          final freq = notes[n];
          // Damped exponential decay
          final decay = math.exp(-6.0 * noteT);
          final sine = math.sin(2 * math.pi * freq * noteT);
          final overtone = 0.25 * math.sin(2 * math.pi * (freq * 2) * noteT);
          sum += (sine + overtone) * decay;
        }
      }

      final mixed = (sum * 16000).clamp(-32000.0, 32000.0);
      samples.add(mixed.toInt());
    }

    return buildWavHeaderAndData(samples);
  }

  /// 4. Futuristic Error / Warning Alert
  /// Dissonant high-tech dual frequency warning pulse.
  static Uint8List createErrorTone({double durationSeconds = 0.3}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;

      // Minor second dissonance: 330 Hz + 349 Hz
      final wave1 = math.sin(2 * math.pi * 330 * t);
      final wave2 = math.sin(2 * math.pi * 349.2 * t);

      // Tremolo pulse
      final tremolo = 0.5 + 0.5 * math.sin(2 * math.pi * 20 * t);
      final envelope = math.sin(progress * math.pi);

      final mixed = ((wave1 + wave2) * 0.5) * tremolo * envelope * 24000;
      samples.add(mixed.toInt());
    }

    return buildWavHeaderAndData(samples);
  }

  /// 5. Futuristic Scanning / Telemetry Ticks
  /// High-tech rapid rhythmic data pulse (like HUD telemetry processing).
  static Uint8List createScanningPulse({double durationSeconds = 0.25}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      // 3 fast pulses
      final phase = (t * 15) % 1.0;
      final pulse = (phase < 0.2) ? math.sin(2 * math.pi * 1400 * t) * (1.0 - phase / 0.2) : 0.0;
      final mixed = pulse * 20000;
      samples.add(mixed.toInt());
    }

    return buildWavHeaderAndData(samples);
  }

  /// 6. Futuristic Tactile Click / HUD Tap
  /// Micro-transient click for sleek button feedback.
  static Uint8List createClickFeedback({double durationSeconds = 0.035}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final decay = math.exp(-120.0 * t);
      final sine = math.sin(2 * math.pi * 1650 * t);
      final mixed = sine * decay * 28000;
      samples.add(mixed.toInt());
    }

    return buildWavHeaderAndData(samples);
  }

  /// 7. Cinematic Sci-Fi System Boot / Opening Sound
  /// Deep sub-bass swell into high-frequency quantum harmonic chord.
  static Uint8List createSystemBootSound({double durationSeconds = 1.3}) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    final samples = <int>[];

    const chord = [659.25, 987.77, 1318.51, 1661.22]; // E5, B5, E6, G#6

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final progress = i / totalSamples;

      // 1. Sub-bass swell
      final subFreq = 55.0 + (55.0 * progress);
      final subWave = math.sin(2 * math.pi * subFreq * t);
      final subEnv = (progress < 0.4)
          ? (progress / 0.4)
          : math.exp(-3.5 * (progress - 0.4));

      // 2. Rising frequency sweep
      final sweepFreq = 300.0 * math.pow(1600.0 / 300.0, progress.clamp(0.0, 0.7) / 0.7);
      final sweepWave = math.sin(2 * math.pi * sweepFreq * t);
      final sweepEnv = (progress > 0.1 && progress < 0.7)
          ? math.sin((progress - 0.1) / 0.6 * math.pi)
          : 0.0;

      // 3. Climax harmonic chord starting at 0.45s with lush decay
      var chordSum = 0.0;
      if (t >= 0.45) {
        final chordT = t - 0.45;
        final decay = math.exp(-3.8 * chordT);
        for (var n = 0; n < chord.length; n++) {
          final f = chord[n];
          chordSum += math.sin(2 * math.pi * f * chordT) * decay;
          chordSum += 0.25 * math.sin(2 * math.pi * (f * 1.5) * chordT) * decay;
        }
      }

      final mixed = ((subWave * subEnv * 0.45) +
              (sweepWave * sweepEnv * 0.35) +
              (chordSum * 0.45)) *
          24000;

      samples.add(mixed.clamp(-32000.0, 32000.0).toInt());
    }

    return buildWavHeaderAndData(samples);
  }
}
