import 'dart:async';
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
import '../../core/services/sound_effects_service.dart';
import '../../core/services/ota_update_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/native_device_service.dart';

/// ATLANTA Horizontal Landscape AI Command Center Dashboard with Real Hardware Telemetry,
/// Real-time Weather, In-App OTA Update System, and Sophisticated Cyber Aesthetics.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  late AnimationController _orbPulseController;
  late AnimationController _hudRotateController;
  late AnimationController _scanlineController;
  late Animation<double> _orbPulseAnim;
  late Animation<double> _hudRotateAnim;
  late Animation<double> _scanlineAnim;
  bool _isProcessing = false;

  // Live real-time hardware telemetry & clock
  Timer? _telemetryTimer;
  Timer? _otaCheckTimer;
  DateTime _currentTime = DateTime.now();
  double _cpuPercent = 34.0;
  StorageMetrics _storageMetrics = const StorageMetrics(
    totalBytes: 128000000000,
    usedBytes: 74240000000,
    freeBytes: 53760000000,
    percentUsed: 58.0,
  );
  NetworkMetrics _networkMetrics = const NetworkMetrics(
    isConnected: true,
    type: 'wifi',
    networkName: 'Neural Wi-Fi 5G',
    signalStrengthPercent: 94,
  );

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

    _fetchHardwareTelemetry();

    // Periodic telemetry and clock updater
    _telemetryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _currentTime = DateTime.now());
      if (timer.tick % 3 == 0) {
        _fetchHardwareTelemetry();
      }
    });

    // Check for In-App OTA Update and welcome sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundEffectsService.instance.playIntroVoice();
      _otaCheckTimer = Timer(const Duration(milliseconds: 1400), () async {
        if (!mounted) return;
        final hasUpdate = await OtaUpdateService.instance.checkForUpdates(isAutomatic: true);
        if (hasUpdate && mounted) {
          OtaUpdateService.instance.promptUpdateDialog(context);
        }
      });
    });
  }

  Future<void> _fetchHardwareTelemetry() async {
    try {
      final cpu = await NativeDeviceService.instance.getCpuUsage();
      final storage = await NativeDeviceService.instance.getStorageUsage();
      final network = await NativeDeviceService.instance.getNetworkInfo();
      if (mounted) {
        setState(() {
          _cpuPercent = cpu;
          _storageMetrics = storage;
          _networkMetrics = network;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _otaCheckTimer?.cancel();
    _telemetryTimer?.cancel();
    _orbPulseController.dispose();
    _hudRotateController.dispose();
    _scanlineController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        TaskService.instance,
        ReminderService.instance,
        DeviceService.instance,
        ActivityService.instance,
        WeatherService.instance,
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
                // ═══ LEFT: Nav Rail + Live System Telemetry (CPU/Storage/Network) ═══
                _buildLeftSection(),

                // ═══ CENTER: Clock + Real Weather + Atlanta AI Core + Input Bar ═══
                Expanded(
                  flex: 5,
                  child: _buildCenterSection(),
                ),

                // ═══ RIGHT: 4 Activities + Tasks + Reminders Box ═══
                _buildRightSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // LEFT SECTION: Nav Rail + Actual Live Telemetry (CPU, Storage, Network)
  // ──────────────────────────────────────────────────────────────
  Widget _buildLeftSection() {
    return SizedBox(
      width: 236,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6, right: 4),
        child: Column(
          children: [
            // ── ATLANTA logo & identity ──
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset('assets/images/atlanta_logo.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ATLANTA',
                    style: AppTypography.brandName.copyWith(
                      fontSize: 14,
                      letterSpacing: 2.0,
                      color: AppColors.primaryWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                  ),
                  child: Text('CORE v1.2', style: TextStyle(color: AppColors.neonCyan, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Nav Rail + Live Hardware Telemetry Row ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nav Rail
                  _buildNavRail(),
                  const SizedBox(width: 6),
                  // Live CPU, Storage & Network Status Card
                  Expanded(child: _buildLiveSystemTelemetryCard()),
                ],
              ),
            ),

            const SizedBox(height: 4),
            // ── Bottom greeting card ──
            _buildGreetingCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRail() {
    String currentRoute = '/home';
    try {
      currentRoute = GoRouterState.of(context).uri.path;
    } catch (_) {}

    final navItems = [
      _NavItem(Icons.home_rounded, 'Home', '/home'),
      _NavItem(Icons.chat_bubble_rounded, 'Chat', '/assistant'),
      _NavItem(Icons.build_rounded, 'Tasks', '/tasks'),
      _NavItem(Icons.apps_rounded, 'Apps', '/devices'),
      _NavItem(Icons.settings_rounded, 'Settings', '/settings'),
    ];

    return Container(
      width: 46,
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
                  padding: const EdgeInsets.symmetric(vertical: 3),
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

  /// Live System Hardware Telemetry Card: Actual CPU usage %, Used storage %, and Network Status
  Widget _buildLiveSystemTelemetryCard() {
    final cpuColor = _cpuPercent > 80
        ? AppColors.error
        : (_cpuPercent > 50 ? AppColors.warning : AppColors.neonCyan);

    final storageColor = _storageMetrics.percentUsed > 85
        ? AppColors.error
        : AppColors.primaryBlue;

    final isWifi = _networkMetrics.type == 'wifi';

    return _GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_board_rounded, color: AppColors.neonCyan, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'LIVE TELEMETRY',
                  style: AppTypography.monoSmall.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primaryWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                  boxShadow: [
                    BoxShadow(color: AppColors.success.withValues(alpha: 0.6), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 6),

          // ── 1. ACTUAL CPU USAGE ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.memory_rounded, size: 12, color: AppColors.secondaryText),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'CPU Load',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 8.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${_cpuPercent.toStringAsFixed(1)}%',
                style: TextStyle(color: cpuColor, fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_cpuPercent / 100.0).clamp(0.05, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.cardSurface,
              valueColor: AlwaysStoppedAnimation<Color>(cpuColor),
            ),
          ),
          const SizedBox(height: 8),

          // ── 2. ACTUAL STORAGE USAGE ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.storage_rounded, size: 12, color: AppColors.secondaryText),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Used Storage',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 8.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${_storageMetrics.percentUsed.toStringAsFixed(0)}%',
                style: TextStyle(color: storageColor, fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (_storageMetrics.percentUsed / 100.0).clamp(0.05, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.cardSurface,
              valueColor: AlwaysStoppedAnimation<Color>(storageColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_storageMetrics.formattedUsed} / ${_storageMetrics.formattedTotal}',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 7),
          ),
          const SizedBox(height: 8),

          // ── 3. CONNECTED NETWORK STATUS ──
          Row(
            children: [
              Icon(
                isWifi ? Icons.wifi_rounded : Icons.cell_tower_rounded,
                size: 13,
                color: _networkMetrics.isConnected ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _networkMetrics.networkName,
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                isWifi ? 'Wi-Fi' : 'Cellular',
                style: TextStyle(
                  color: isWifi ? AppColors.neonCyan : Colors.purpleAccent,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_networkMetrics.signalStrengthPercent}% signal',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return _GlassmorphicCard(
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withValues(alpha: 0.25),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.psychology_rounded, color: AppColors.neonCyan, size: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey Imran 👋',
                  style: AppTypography.labelLarge.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Neural Mesh Online',
                  style: AppTypography.monoSmall.copyWith(
                    fontSize: 7,
                    color: AppColors.neonCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // CENTER SECTION: Live Clock + Real Weather + Atlanta AI Core Orb + Input
  // ──────────────────────────────────────────────────────────────
  Widget _buildCenterSection() {
    final weather = WeatherService.instance.currentWeather;

    final timeFormatted = DateFormat('hh:mm:ss a').format(_currentTime);
    final dateFormatted = DateFormat('EEE, dd MMM yyyy').format(_currentTime);

    return Column(
      children: [
        // ── TOP HUD BAR: Real-time Clock & Present Location Weather ──
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.08),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live Digital Clock
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, color: AppColors.neonCyan, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeFormatted,
                              style: AppTypography.monoSmall.copyWith(
                                color: AppColors.primaryWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              dateFormatted,
                              style: TextStyle(color: AppColors.secondaryText, fontSize: 8),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Live Present Location Weather Widget
                Flexible(
                  child: GestureDetector(
                    onTap: () => WeatherService.instance.refreshWeather(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          ),
                          child: Icon(weather.icon, color: Colors.amber, size: 18),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      weather.cityName,
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    weather.formattedTemp,
                                    style: TextStyle(
                                      color: AppColors.neonCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${weather.condition} • ${weather.humidity}% hum',
                                style: const TextStyle(color: AppColors.mutedText, fontSize: 7.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Main Atlanta Core AI Orb with Holographic HUD Rings ──
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating outer HUD dashed ring
                AnimatedBuilder(
                  animation: _hudRotateAnim,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _hudRotateAnim.value,
                      child: CustomPaint(
                        size: const Size(200, 200),
                        painter: _HudRingPainter(
                          color: AppColors.neonCyan.withValues(alpha: 0.35),
                          isDashed: true,
                        ),
                      ),
                    );
                  },
                ),

                // Reverse rotating inner HUD ring
                AnimatedBuilder(
                  animation: _hudRotateAnim,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_hudRotateAnim.value * 0.7,
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: _HudRingPainter(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          isDashed: false,
                        ),
                      ),
                    );
                  },
                ),

                // Concentric Holographic Pulse Wave
                AnimatedBuilder(
                  animation: _orbPulseAnim,
                  builder: (context, child) {
                    return Container(
                      width: 140 * _orbPulseAnim.value,
                      height: 140 * _orbPulseAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: (1.0 - _orbPulseAnim.value) * 0.5),
                          width: 1.5,
                        ),
                      ),
                    );
                  },
                ),

                // Core AI Orb — tap navigates to voice screen
                GestureDetector(
                  onTap: () {
                    SoundEffectsService.instance.playWake();
                    context.push('/voice');
                  },
                  child: AtlantaOrb(
                    size: 114,
                    state: _isProcessing ? OrbState.thinking : OrbState.idle,
                    onTap: () {
                      SoundEffectsService.instance.playWake();
                      context.push('/voice');
                    },
                  ),
                ),

                // Futuristic Holographic Corner Brackets
                const SizedBox(
                  width: 210,
                  height: 210,
                  child: CustomPaint(painter: _HoloCornerPainter()),
                ),
              ],
            ),
          ),
        ),



        // ── Voice Mode Navigation Pill Underneath Orb ──
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () {
              SoundEffectsService.instance.playWake();
              context.push('/voice');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded, color: AppColors.neonCyan, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'TAP ORB TO ENTER VOICE MODE',
                    style: AppTypography.monoSmall.copyWith(
                      color: AppColors.primaryWhite,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonCyan, size: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // RIGHT SECTION: Box with 4 Activities, Tasks & Reminders
  // ──────────────────────────────────────────────────────────────
  Widget _buildRightSection() {
    final activities = ActivityService.instance.activities.take(4).toList();
    final pendingTasks = TaskService.instance.pendingCount;
    final activeReminders = ReminderService.instance.activeReminders.length;

    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6, left: 4),
        child: _GlassmorphicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Box Header
              Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded, color: AppColors.neonCyan, size: 14),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'OPERATIONS & TASKS',
                      style: TextStyle(
                        color: AppColors.primaryWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.radar_rounded, color: AppColors.neonCyan.withValues(alpha: 0.7), size: 14),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),

              // ── Quick Summary Badges (Tasks & Reminders) ──
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pendingTasks Tasks',
                            style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                          const Text('Pending Work', style: TextStyle(color: AppColors.secondaryText, fontSize: 7)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$activeReminders Alerts',
                            style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                          const Text('Scheduled', style: TextStyle(color: AppColors.secondaryText, fontSize: 7)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── 4 RECENT ACTIVITIES ──
              Text(
                'RECENT ACTIVITIES (4)',
                style: AppTypography.monoSmall.copyWith(
                  color: AppColors.mutedText,
                  fontSize: 7.5,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: activities.isEmpty
                    ? Center(
                        child: Text(
                          'No recent neural logs',
                          style: TextStyle(color: AppColors.mutedText, fontSize: 9),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: activities.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 4),
                        itemBuilder: (context, i) {
                          final act = activities[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_rounded, size: 12, color: AppColors.neonCyan),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act.title,
                                        style: const TextStyle(
                                          color: AppColors.primaryWhite,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        DateFormat('hh:mm a').format(act.timestamp),
                                        style: const TextStyle(color: AppColors.mutedText, fontSize: 7),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 6),

              // Quick Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        SoundEffectsService.instance.playClick();
                        context.go('/tasks');
                      },
                      child: Text(
                        'View Tasks →',
                        style: TextStyle(color: AppColors.neonCyan, fontSize: 8.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        SoundEffectsService.instance.playClick();
                        context.go('/reminders');
                      },
                      child: Text(
                        'Reminders →',
                        style: TextStyle(color: AppColors.neonCyan, fontSize: 8.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS & PAINTERS
// ═══════════════════════════════════════════════════════════════

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

/// Glassmorphic frosted card container
class _GlassmorphicCard extends StatelessWidget {
  final Widget child;

  const _GlassmorphicCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Circular dashed / solid HUD ring painter
class _HudRingPainter extends CustomPainter {
  final Color color;
  final bool isDashed;

  _HudRingPainter({required this.color, required this.isDashed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (!isDashed) {
      canvas.drawCircle(center, radius, paint);
      return;
    }

    const dashCount = 28;
    const sweep = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * sweep,
          sweep * 0.6,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HudRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isDashed != isDashed;
}

/// Futuristic holographic corner brackets painter
class _HoloCornerPainter extends CustomPainter {
  const _HoloCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const len = 12.0;
    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cyber background painter with circuit lines & scanline sweep
class _HudBackgroundPainter extends CustomPainter {
  final Animation<double> scanProgress;

  _HudBackgroundPainter({required this.scanProgress}) : super(repaint: scanProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.035)
      ..strokeWidth = 0.5;

    // Grid lines
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Moving horizontal scan line
    final scanY = size.height * scanProgress.value;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.neonCyan.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 10, size.width, 20));

    canvas.drawRect(Rect.fromLTWH(0, scanY - 10, size.width, 20), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _HudBackgroundPainter oldDelegate) => true;
}
