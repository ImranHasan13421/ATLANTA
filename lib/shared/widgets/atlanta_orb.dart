import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The states of the Atlanta AI Orb.
enum OrbState { idle, listening, thinking, speaking, executing, success, error }

/// Atlanta AI Orb — the signature visual element.
///
/// A circular futuristic AI core with animated rings and glow effects
/// that change based on state.
class AtlantaOrb extends StatefulWidget {
  final double size;
  final OrbState state;
  final VoidCallback? onTap;
  final bool showLabel;

  const AtlantaOrb({
    super.key,
    this.size = 140,
    this.state = OrbState.idle,
    this.onTap,
    this.showLabel = false,
  });

  @override
  State<AtlantaOrb> createState() => _AtlantaOrbState();
}

class _AtlantaOrbState extends State<AtlantaOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _updateAnimations();
  }

  @override
  void didUpdateWidget(AtlantaOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    // Reset all
    _pulseController.stop();
    _rotationController.stop();
    _rippleController.stop();

    switch (widget.state) {
      case OrbState.idle:
        _pulseController.repeat(reverse: true);
        break;
      case OrbState.listening:
        _rippleController.repeat();
        _pulseController.repeat(reverse: true);
        break;
      case OrbState.thinking:
        _rotationController.repeat();
        break;
      case OrbState.speaking:
        _pulseController.duration = const Duration(milliseconds: 800);
        _pulseController.repeat(reverse: true);
        break;
      case OrbState.executing:
        _rotationController.repeat();
        _pulseController.repeat(reverse: true);
        break;
      case OrbState.success:
        _pulseController.forward();
        break;
      case OrbState.error:
        _pulseController.forward();
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    switch (widget.state) {
      case OrbState.success:
        return AppColors.success;
      case OrbState.error:
        return AppColors.error;
      default:
        return AppColors.primaryBlue;
    }
  }

  Color get _glowColor {
    switch (widget.state) {
      case OrbState.success:
        return AppColors.success.withValues(alpha: 0.4);
      case OrbState.error:
        return AppColors.error.withValues(alpha: 0.4);
      default:
        return AppColors.orbGlow;
    }
  }

  String get _stateLabel {
    switch (widget.state) {
      case OrbState.idle:
        return 'Ready';
      case OrbState.listening:
        return 'Listening...';
      case OrbState.thinking:
        return 'Thinking...';
      case OrbState.speaking:
        return 'Speaking...';
      case OrbState.executing:
        return 'Executing...';
      case OrbState.success:
        return 'Done';
      case OrbState.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseAnimation,
              _rotationAnimation,
              _rippleAnimation,
            ]),
            builder: (context, child) {
              return SizedBox(
                width: widget.size * 1.6,
                height: widget.size * 1.6,
                child: CustomPaint(
                  painter: _OrbPainter(
                    pulseValue: _pulseAnimation.value,
                    rotationValue: _rotationAnimation.value,
                    rippleValue: _rippleAnimation.value,
                    primaryColor: _primaryColor,
                    glowColor: _glowColor,
                    state: widget.state,
                    orbSize: widget.size,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 16),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _primaryColor.withValues(alpha: 0.8),
              letterSpacing: 1.5,
            ),
            child: Text(_stateLabel.toUpperCase()),
          ),
        ],
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double pulseValue;
  final double rotationValue;
  final double rippleValue;
  final Color primaryColor;
  final Color glowColor;
  final OrbState state;
  final double orbSize;

  _OrbPainter({
    required this.pulseValue,
    required this.rotationValue,
    required this.rippleValue,
    required this.primaryColor,
    required this.glowColor,
    required this.state,
    required this.orbSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = orbSize / 2;

    // ── Outer glow ──
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.15 * pulseValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6);
    canvas.drawCircle(center, radius * 1.3 * pulseValue, glowPaint);

    // ── Ripple rings (listening/executing) ──
    if (state == OrbState.listening || state == OrbState.executing) {
      for (var i = 0; i < 3; i++) {
        final ripplePhase = (rippleValue + i * 0.33) % 1.0;
        final rippleRadius = radius * (1.1 + ripplePhase * 0.5);
        final rippleOpacity = (1.0 - ripplePhase) * 0.3;
        final ripplePaint = Paint()
          ..color = primaryColor.withValues(alpha: rippleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, rippleRadius, ripplePaint);
      }
    }

    // ── Orbit rings (thinking/executing) ──
    if (state == OrbState.thinking || state == OrbState.executing) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotationValue);
      canvas.translate(-center.dx, -center.dy);

      for (var i = 0; i < 3; i++) {
        final orbitRadius = radius * (1.05 + i * 0.08);
        final orbitPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.2 - i * 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        // Draw dashed arc
        final arcRect = Rect.fromCircle(center: center, radius: orbitRadius);
        canvas.drawArc(
            arcRect, i * 0.5, math.pi * 0.8 + i * 0.3, false, orbitPaint);
      }

      // Dot on orbit
      final dotAngle = rotationValue;
      final dotX = center.dx + radius * 1.15 * math.cos(dotAngle);
      final dotY = center.dy + radius * 1.15 * math.sin(dotAngle);
      final dotPaint = Paint()..color = primaryColor;
      canvas.drawCircle(Offset(dotX, dotY), 3, dotPaint);

      canvas.restore();
    }

    // ── Outer ring ──
    final outerRingPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * pulseValue, outerRingPaint);

    // ── Main orb gradient ──
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.9),
          primaryColor.withValues(alpha: 0.6),
          primaryColor.withValues(alpha: 0.2),
          primaryColor.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 0.7 * pulseValue),
      );
    canvas.drawCircle(center, radius * 0.7 * pulseValue, orbPaint);

    // ── Inner core ──
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.9),
          primaryColor.withValues(alpha: 0.8),
          primaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 0.25),
      );
    canvas.drawCircle(center, radius * 0.25, corePaint);

    // ── Success checkmark ──
    if (state == OrbState.success) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(center.dx - radius * 0.15, center.dy);
      path.lineTo(center.dx - radius * 0.02, center.dy + radius * 0.12);
      path.lineTo(center.dx + radius * 0.15, center.dy - radius * 0.1);
      canvas.drawPath(path, checkPaint);
    }

    // ── Error X ──
    if (state == OrbState.error) {
      final xPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final s = radius * 0.12;
      canvas.drawLine(
        Offset(center.dx - s, center.dy - s),
        Offset(center.dx + s, center.dy + s),
        xPaint,
      );
      canvas.drawLine(
        Offset(center.dx + s, center.dy - s),
        Offset(center.dx - s, center.dy + s),
        xPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.rotationValue != rotationValue ||
        oldDelegate.rippleValue != rippleValue ||
        oldDelegate.state != state;
  }
}
