import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/sound_effects_service.dart';
import '../../core/services/voice_service.dart';
import '../../shared/widgets/atlanta_orb.dart';
import '../../shared/widgets/status_indicator.dart';

/// Atlanta Splash / Startup Screen.
///
/// Shows the Atlanta logo with initialization status indicators.
/// Plays cinematic intro opening sound and delivers vocal welcome greeting.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Status indicators
  bool _aiCoreReady = false;
  bool _databaseReady = false;
  bool _deviceReady = false;
  bool _sessionReady = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Play uploaded App Intro sound during the splash screen
    SoundEffectsService.instance.playAppIntro();

    _simulateInitialization();
  }

  Future<void> _simulateInitialization() async {
    // Stage 1: AI Core Initialization (1.5s)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _aiCoreReady = true);

    // Stage 2: Database Initialization (3.0s total)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _databaseReady = true);

    // Stage 3: Device Grid Initialization (4.2s total)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _deviceReady = true);

    // Stage 4: Secure Session Synchronization (5.2s total)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _sessionReady = true);

    // Stage 5: Transition to Dashboard exactly at 6.0 seconds (full audio duration)
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── LEFT: Logo Emblem & App Branding ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.35),
                                blurRadius: 28,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/atlanta_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ATLANTA',
                          style: AppTypography.brandName.copyWith(
                            fontSize: 16,
                            letterSpacing: 4,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your Personal AI Assistant',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 48),

                    // ── CENTER: Dynamic Neural Orb ──
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListenableBuilder(
                          listenable: VoiceService.instance,
                          builder: (context, _) {
                            final state = VoiceService.instance.isSpeaking
                                ? OrbState.speaking
                                : (_sessionReady ? OrbState.success : OrbState.thinking);
                            return AtlantaOrb(
                              size: 72,
                              state: state,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _sessionReady ? 'System Online' : 'Initializing Core...',
                            key: ValueKey(_sessionReady),
                            style: AppTypography.labelMedium.copyWith(
                              color: _sessionReady ? AppColors.success : AppColors.mutedText,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 48),

                    // ── RIGHT: Status Indicators & Progress ──
                    Container(
                      width: 230,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.05),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.security_rounded, color: AppColors.neonCyan, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'SYSTEM DIAGNOSTICS',
                                style: AppTypography.monoSmall.copyWith(
                                  color: AppColors.neonCyan,
                                  fontSize: 8.5,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _StatusRow(label: 'AI Core', ready: _aiCoreReady),
                          const SizedBox(height: 8),
                          _StatusRow(label: 'Database Mesh', ready: _databaseReady),
                          const SizedBox(height: 8),
                          _StatusRow(label: 'Device Grid', ready: _deviceReady),
                          const SizedBox(height: 8),
                          _StatusRow(label: 'Neural Session', ready: _sessionReady),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ready;

  const _StatusRow({required this.label, required this.ready});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: StatusIndicator(
            key: ValueKey(ready),
            label: '',
            status: ready ? StatusType.online : StatusType.pending,
            showLabel: false,
            dotSize: 6,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: ready
                  ? AppColors.secondaryText
                  : AppColors.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            ready ? 'Connected' : '...',
            key: ValueKey(ready),
            style: TextStyle(
              color: ready
                  ? AppColors.success.withValues(alpha: 0.8)
                  : AppColors.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
