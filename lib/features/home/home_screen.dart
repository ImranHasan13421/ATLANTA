import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/atlanta_orb.dart';
import '../../core/services/task_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/services/device_service.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/brain_service.dart';
import '../../core/services/sound_effects_service.dart';

/// ATLANTA Horizontal Landscape AI Command Center Dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _commandController = TextEditingController();
  late AnimationController _orbPulseController;
  late AnimationController _hudRotateController;
  late AnimationController _scanlineController;
  late Animation<double> _orbPulseAnim;
  late Animation<double> _hudRotateAnim;
  late Animation<double> _scanlineAnim;
  bool _isProcessing = false;
  String _lastResponse = '';

  @override
  void initState() {
    super.initState();

    _orbPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _orbPulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _orbPulseController, curve: Curves.easeInOut),
    );

    _hudRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _hudRotateAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _hudRotateController, curve: Curves.linear),
    );

    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scanlineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanlineController, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundEffectsService.instance.playIntroVoice();
    });
  }

  @override
  void dispose() {
    _orbPulseController.dispose();
    _hudRotateController.dispose();
    _scanlineController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _handleCommand(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;
    SoundEffectsService.instance.playClick();
    _commandController.clear();

    setState(() => _isProcessing = true);

    final result = await BrainService.instance.processCommand(text, speakResponse: true);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastResponse = result.displayText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        TaskService.instance,
        ReminderService.instance,
        DeviceService.instance,
        ActivityService.instance,
      ]),
      builder: (context, _) => _buildLandscapeLayout(),
    );
  }

  Widget _buildLandscapeLayout() {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: Stack(
        children: [
          // ── Background grid & circuit traces ──
          CustomPaint(
            size: MediaQuery.sizeOf(context),
            painter: _HudBackgroundPainter(scanProgress: _scanlineAnim),
          ),

          // ── Main content ──
          SafeArea(
            child: Row(
              children: [
                // ═══ LEFT: Nav Rail + Today Card + Quote ═══
                _buildLeftSection(),

                // ═══ CENTER: Atlanta AI Core ═══
                Expanded(
                  flex: 4,
                  child: _buildCenterSection(),
                ),

                // ═══ RIGHT: System Status Dashboard ═══
                _buildRightSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // LEFT SECTION: Nav Rail + Today Card + Motivational Quote
  // ──────────────────────────────────────────────────────────────
  Widget _buildLeftSection() {
    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
        child: Column(
          children: [
            // ── ATLANTA logo ──
            Row(
              children: [
                Text(
                  'ATLANTA',
                  style: AppTypography.brandName.copyWith(
                    fontSize: 16,
                    letterSpacing: 4,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ],
            ),
            Text(
              'Your AI Assistant',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neonCyan,
                fontSize: 8,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // ── Nav Rail + Today Card Row ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nav Rail
                  _buildNavRail(),
                  const SizedBox(width: 6),
                  // Today Card + Quote
                  Expanded(child: _buildTodayAndQuote()),
                ],
              ),
            ),

            // ── Bottom greeting card ──
            _buildGreetingCard(),

            const SizedBox(height: 4),
            // ── Bottom branding ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ATLANTA',
                style: AppTypography.monoSmall.copyWith(
                  color: AppColors.mutedText,
                  fontSize: 7,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRail() {
    String currentRoute = '/home';
    try {
      currentRoute = GoRouterState.of(context).uri.path;
    } catch (_) {
      // Fallback for testing without GoRouter
    }

    final navItems = [
      _NavItem(Icons.home_rounded, 'Home', '/home'),
      _NavItem(Icons.chat_bubble_rounded, 'Chat', '/assistant'),
      _NavItem(Icons.build_rounded, 'Tools', '/tasks'),
      _NavItem(Icons.apps_rounded, 'Apps', '/devices'),
      _NavItem(Icons.person_rounded, 'Profile', '/settings'),
    ];

    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.15)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.map((item) {
              final isActive = currentRoute.startsWith(item.route);
              return GestureDetector(
                onTap: () {
                  SoundEffectsService.instance.playClick();
                  try {
                    context.go(item.route);
                  } catch (_) {}
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.primaryBlue.withValues(alpha: 0.3)
                              : Colors.transparent,
                          border: Border.all(
                            color: isActive
                                ? AppColors.neonCyan
                                : AppColors.border.withValues(alpha: 0.5),
                            width: isActive ? 1.5 : 0.8,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          size: 14,
                          color: isActive ? AppColors.neonCyan : AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 7,
                          color: isActive ? AppColors.neonCyan : AppColors.mutedText,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayAndQuote() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, dd MMM yyyy').format(now);
    final pendingTasks = TaskService.instance.pendingCount;
    final activeReminders = ReminderService.instance.activeReminders.length;

    return Column(
      children: [
        // ── TODAY card ──
        _GlassmorphicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: AppColors.primaryWhite,
                ),
              ),
              Text(
                dateStr,
                style: AppTypography.monoSmall.copyWith(
                  fontSize: 8,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 8),
              _TodayItem(
                icon: Icons.chat_bubble_outline_rounded,
                text: '${ActivityService.instance.activities.length} Activities',
                color: AppColors.neonCyan,
              ),
              Divider(color: AppColors.neonCyan.withValues(alpha: 0.15), height: 8),
              _TodayItem(
                icon: Icons.check_box_outlined,
                text: '$pendingTasks Tasks Pending',
                color: AppColors.warning,
              ),
              Divider(color: AppColors.neonCyan.withValues(alpha: 0.15), height: 8),
              _TodayItem(
                icon: Icons.code_rounded,
                text: '$activeReminders Reminders',
                color: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Motivational Quote ──
        _GlassmorphicCard(
          child: Row(
            children: [
              Icon(Icons.graphic_eq_rounded, color: AppColors.neonCyan, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Better plans today, bigger dreams tomorrow.\n— ATLANTA',
                  style: AppTypography.monoSmall.copyWith(
                    fontSize: 7.5,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard() {
    final timeStr = DateFormat('h:mm a').format(DateTime.now());

    return _GlassmorphicCard(
      child: Row(
        children: [
          // Atlanta AI icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/atlanta_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey Imran! 👋',
                  style: AppTypography.labelLarge.copyWith(fontSize: 11),
                ),
                Text(
                  "I'm Atlanta, your AI assistant. Ask me anything.",
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 7.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeStr,
            style: AppTypography.monoSmall.copyWith(fontSize: 7, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // CENTER SECTION: Atlanta AI Core Orb + HUD Rings + Input Bar
  // ──────────────────────────────────────────────────────────────
  Widget _buildCenterSection() {
    return Column(
      children: [
        // ── Title ──
        const SizedBox(height: 4),
        Text(
          'ATLANTA',
          style: AppTypography.brandName.copyWith(
            fontSize: 14,
            letterSpacing: 6,
            color: AppColors.primaryWhite.withValues(alpha: 0.9),
          ),
        ),
        Text(
          'AI ASSISTANT',
          style: AppTypography.monoSmall.copyWith(
            fontSize: 8,
            letterSpacing: 3,
            color: AppColors.neonCyan.withValues(alpha: 0.7),
          ),
        ),

        // ── Central Orb with HUD rings ──
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_orbPulseAnim, _hudRotateAnim]),
              builder: (context, _) {
                return GestureDetector(
                  onTap: () {
                    SoundEffectsService.instance.playWake();
                    context.push('/voice');
                  },
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _CentralHudPainter(
                        pulseValue: _orbPulseAnim.value,
                        rotationValue: _hudRotateAnim.value,
                        isProcessing: _isProcessing,
                      ),
                      child: Center(
                        child: AtlantaOrb(
                          size: 70,
                          state: _isProcessing ? OrbState.thinking : OrbState.idle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Response text ──
        if (_lastResponse.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _GlassmorphicCard(
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.neonCyan, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastResponse,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.primaryWhite,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Input Bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _GlassmorphicCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.chat_rounded, color: AppColors.mutedText, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _commandController,
                          onSubmitted: _handleCommand,
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 11,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 11),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Mic button
              GestureDetector(
                onTap: () {
                  SoundEffectsService.instance.playWake();
                  context.push('/voice');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.neonCyan, AppColors.primaryBlue],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.5),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 6),
              // Send button
              GestureDetector(
                onTap: () => _handleCommand(_commandController.text),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.6)),
                  ),
                  child: const Icon(Icons.send_rounded, color: AppColors.neonCyan, size: 16),
                ),
              ),
            ],
          ),
        ),

        // ── Bottom tagline ──
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Smarter Conversations. A Brighter You.',
            style: AppTypography.monoSmall.copyWith(
              fontSize: 7,
              color: AppColors.neonCyan.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // RIGHT SECTION: Status Dashboard + Online Badge
  // ──────────────────────────────────────────────────────────────
  Widget _buildRightSection() {
    final onlineDevices = DeviceService.instance.onlineCount;

    return SizedBox(
      width: 160,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
        child: Column(
          children: [
            // ── Online status ──
            _GlassmorphicCard(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Online',
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 10,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Always here for you',
                          style: AppTypography.monoSmall.copyWith(
                            fontSize: 7,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.person_outline, color: AppColors.neonCyan, size: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── System Health ──
            _SystemStatusCard(
              label: 'System Health',
              value: '87%',
              icon: Icons.monitor_heart_rounded,
              progress: 0.87,
              isCircular: true,
            ),
            const SizedBox(height: 6),

            // ── Connection ──
            _SystemStatusCard(
              label: 'Connection',
              value: 'Strong',
              icon: Icons.wifi_rounded,
              progress: 0.95,
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 6),

            // ── CPU ──
            _SystemStatusCard(
              label: 'CPU',
              value: '32%',
              icon: Icons.memory_rounded,
              progress: 0.32,
            ),
            const SizedBox(height: 6),

            // ── Storage ──
            _SystemStatusCard(
              label: 'Storage',
              value: '68%',
              icon: Icons.storage_rounded,
              progress: 0.68,
            ),

            const Spacer(),

            // ── Devices count ──
            Text(
              '$onlineDevices devices online',
              style: AppTypography.monoSmall.copyWith(
                fontSize: 7,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

/// Glassmorphism card with frosted glass effect
class _GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassmorphicCard({
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.cardSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.12),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.05),
                blurRadius: 12,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TodayItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _TodayItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
          ),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(fontSize: 8.5, color: AppColors.primaryWhite),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SystemStatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double progress;
  final bool isCircular;
  final Color? valueColor;

  const _SystemStatusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.progress,
    this.isCircular = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassmorphicCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (isCircular)
            SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.neonCyan),
                  ),
                  Text(
                    value,
                    style: AppTypography.monoSmall.copyWith(
                      fontSize: 7,
                      color: AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, size: 14, color: AppColors.neonCyan),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 8,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                if (!isCircular)
                  Text(
                    value,
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 10,
                      color: valueColor ?? AppColors.neonCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!isCircular) ...[
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        valueColor ?? AppColors.neonCyan,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════

/// Background HUD grid, circuit traces, and scanlines
class _HudBackgroundPainter extends CustomPainter {
  final Animation<double> scanProgress;

  _HudBackgroundPainter({required this.scanProgress}) : super(repaint: scanProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    // Grid lines
    const gridSpacing = 40.0;
    for (var x = 0.0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Scan line
    final scanY = scanProgress.value * size.height;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.neonCyan.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 20, size.width, 40));
    canvas.drawRect(Rect.fromLTWH(0, scanY - 20, size.width, 40), scanPaint);

    // Corner HUD brackets
    _drawCornerBracket(canvas, size, Offset(8, 8), false, false);
    _drawCornerBracket(canvas, size, Offset(size.width - 8, 8), true, false);
    _drawCornerBracket(canvas, size, Offset(8, size.height - 8), false, true);
    _drawCornerBracket(canvas, size, Offset(size.width - 8, size.height - 8), true, true);
  }

  void _drawCornerBracket(Canvas canvas, Size size, Offset pos, bool flipX, bool flipY) {
    final bracketPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const len = 20.0;
    final dx = flipX ? -1.0 : 1.0;
    final dy = flipY ? -1.0 : 1.0;

    final path = Path()
      ..moveTo(pos.dx + len * dx, pos.dy)
      ..lineTo(pos.dx, pos.dy)
      ..lineTo(pos.dx, pos.dy + len * dy);

    canvas.drawPath(path, bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _HudBackgroundPainter oldDelegate) => true;
}

/// Central concentric HUD rings around the orb
class _CentralHudPainter extends CustomPainter {
  final double pulseValue;
  final double rotationValue;
  final bool isProcessing;

  _CentralHudPainter({
    required this.pulseValue,
    required this.rotationValue,
    required this.isProcessing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 8;

    // ── Outer rings ──
    for (var i = 0; i < 4; i++) {
      final ringRadius = maxRadius - (i * 12) * pulseValue;
      final ringAlpha = 0.08 + (i * 0.03);
      final ringPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: ringAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // ── Segmented arcs (rotating) ──
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationValue);
    canvas.translate(-center.dx, -center.dy);

    for (var i = 0; i < 6; i++) {
      final arcRadius = maxRadius - 4 - (i * 6);
      final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
      final arcPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.12 - i * 0.015)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (i * 0.3);

      final startAngle = (i * math.pi / 3) + rotationValue * (i.isEven ? 1 : -1);
      canvas.drawArc(arcRect, startAngle, math.pi * 0.4, false, arcPaint);
    }

    // ── Radial markers ──
    for (var i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6);
      final innerR = maxRadius - 30;
      final outerR = maxRadius - 20;

      final p1 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.2)
        ..strokeWidth = 1.0;
      canvas.drawLine(p1, p2, tickPaint);
    }

    canvas.restore();

    // ── Counter-rotating inner arc ──
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotationValue * 0.5);
    canvas.translate(-center.dx, -center.dy);

    final innerArcRect = Rect.fromCircle(center: center, radius: maxRadius * 0.55);
    final innerArcPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(innerArcRect, 0, math.pi * 1.2, false, innerArcPaint);

    canvas.restore();

    // ── Outer glow ──
    final glowPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.04 * pulseValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxRadius * 0.4);
    canvas.drawCircle(center, maxRadius * 0.7, glowPaint);

    // ── Small indicator dots ──
    if (isProcessing) {
      for (var i = 0; i < 3; i++) {
        final dotAngle = rotationValue + (i * math.pi * 2 / 3);
        final dotR = maxRadius * 0.8;
        final dotPos = Offset(
          center.dx + dotR * math.cos(dotAngle),
          center.dy + dotR * math.sin(dotAngle),
        );
        final dotPaint = Paint()..color = AppColors.neonCyan;
        canvas.drawCircle(dotPos, 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CentralHudPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.rotationValue != rotationValue ||
        oldDelegate.isProcessing != isProcessing;
  }
}
