import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Holographic HUD telemetry overlay inspired by Iron Man's JARVIS interface.
class AtlantaHudOverlay extends StatefulWidget {
  final Widget child;
  final bool showTelemetry;

  const AtlantaHudOverlay({
    super.key,
    required this.child,
    this.showTelemetry = true,
  });

  @override
  State<AtlantaHudOverlay> createState() => _AtlantaHudOverlayState();
}

class _AtlantaHudOverlayState extends State<AtlantaHudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background HUD Reticle & Grid
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _HudPainter(
                    angle: _rotationController.value * 2 * math.pi,
                  ),
                );
              },
            ),
          ),
        ),

        // Main content
        widget.child,

        // Telemetry readouts in the corners
        if (widget.showTelemetry) ...[
          Positioned(
            top: 16,
            left: 20,
            child: _buildTelemetryBlock(
              title: 'SYSTEM TELEMETRY',
              lines: [
                'CORE: ATLANTA-V3',
                'LINK: ENCRYPTED MESH',
                'QUANTUM SYNC: 99.8%',
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 20,
            child: _buildTelemetryBlock(
              title: 'HARDWARE SENSORS',
              alignRight: true,
              lines: [
                'LATENCY: 14 MS',
                'AUDIO SAMPLING: 44.1 KHZ',
                'NEURAL LOAD: 18.2%',
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTelemetryBlock({
    required String title,
    required List<String> lines,
    bool alignRight = false,
  }) {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.neonCyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonCyan.withValues(alpha: 0.8),
                  letterSpacing: 1.5,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...lines.map(
            (line) => Text(
              line,
              style: AppTypography.monoMedium.copyWith(
                color: AppColors.secondaryText.withValues(alpha: 0.5),
                fontSize: 8.5,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudPainter extends CustomPainter {
  final double angle;

  _HudPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final maxRadius = math.min(size.width, size.height) * 0.42;

    final ringPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric subtle background rings
    canvas.drawCircle(center, maxRadius * 0.6, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.9, ringPaint);

    // Rotating dashed outer arc
    final arcPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 4; i++) {
      final startAngle = angle + (i * math.pi / 2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius * 0.8),
        startAngle,
        math.pi / 4,
        false,
        arcPaint,
      );
    }

    // Counter-rotating inner compass ticks
    final tickPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    const tickCount = 24;
    for (var i = 0; i < tickCount; i++) {
      final tickAngle = -angle * 0.5 + (i * 2 * math.pi / tickCount);
      final r1 = maxRadius * 0.62;
      final r2 = (i % 6 == 0) ? maxRadius * 0.67 : maxRadius * 0.64;

      final p1 = Offset(center.dx + r1 * math.cos(tickAngle),
          center.dy + r1 * math.sin(tickAngle));
      final p2 = Offset(center.dx + r2 * math.cos(tickAngle),
          center.dy + r2 * math.sin(tickAngle));

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
