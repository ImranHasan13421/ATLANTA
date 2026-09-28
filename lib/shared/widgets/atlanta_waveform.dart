import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Futuristic animated audio frequency waveform visualizer.
///
/// Reacts dynamically to microphone sound levels, speech synthesis, and AI processing states.
class AtlantaWaveform extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final double soundLevel; // 0.0 to 1.0
  final int barCount;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;

  const AtlantaWaveform({
    super.key,
    this.isListening = false,
    this.isSpeaking = false,
    this.soundLevel = 0.0,
    this.barCount = 28,
    this.height = 64,
    this.primaryColor = AppColors.neonCyan,
    this.secondaryColor = AppColors.primaryBlue,
  });

  @override
  State<AtlantaWaveform> createState() => _AtlantaWaveformState();
}

class _AtlantaWaveformState extends State<AtlantaWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WaveformPainter(
            animationValue: _animController.value,
            isListening: widget.isListening,
            isSpeaking: widget.isSpeaking,
            soundLevel: widget.soundLevel,
            barCount: widget.barCount,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animationValue;
  final bool isListening;
  final bool isSpeaking;
  final double soundLevel;
  final int barCount;
  final Color primaryColor;
  final Color secondaryColor;

  _WaveformPainter({
    required this.animationValue,
    required this.isListening,
    required this.isSpeaking,
    required this.soundLevel,
    required this.barCount,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = (size.width / (barCount * 1.6)).clamp(2.5, 6.0);
    final spacing = (size.width - (barCount * barWidth)) / (barCount + 1);
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final normalizedIndex = (i - (barCount / 2)) / (barCount / 2); // -1.0 to 1.0
      final gaussian = math.exp(-2.2 * normalizedIndex * normalizedIndex); // bell curve

      double heightMultiplier = 0.12; // idle baseline

      if (isListening) {
        // High reactivity to microphone amplitude + animated wave
        final wave = math.sin((i * 0.45) - (animationValue * 2 * math.pi));
        final reactiveBoost = soundLevel > 0.05 ? soundLevel * 1.8 : 0.25;
        heightMultiplier = (0.2 + (0.8 * reactiveBoost * gaussian.abs())) + (wave * 0.25);
      } else if (isSpeaking) {
        // Rhythmic pulsing harmonic wave
        final wave1 = math.sin((i * 0.35) + (animationValue * 4 * math.pi));
        final wave2 = math.cos((i * 0.6) - (animationValue * 2 * math.pi));
        heightMultiplier = (0.25 + 0.75 * gaussian) * ((wave1 + wave2 + 2) / 4);
      } else {
        // Gentle breathing idle wave
        final idleWave = math.sin((i * 0.2) + (animationValue * math.pi * 2));
        heightMultiplier = 0.1 + (0.12 * gaussian) + (0.06 * idleWave);
      }

      final barHeight = (size.height * heightMultiplier.clamp(0.08, 0.95));
      final x = spacing + i * (barWidth + spacing);
      final top = centerY - (barHeight / 2);
      final bottom = centerY + (barHeight / 2);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(x, top, x + barWidth, bottom),
        Radius.circular(barWidth / 2),
      );

      // Gradient from secondary to primary color
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          secondaryColor.withValues(alpha: 0.6),
          primaryColor,
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect.outerRect)
        ..style = PaintingStyle.fill;

      // Glow effect for active states
      if (isListening || isSpeaking) {
        final glowPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawRRect(rect, glowPaint);
      }

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.soundLevel != soundLevel ||
        oldDelegate.isListening != isListening ||
        oldDelegate.isSpeaking != isSpeaking;
  }
}
