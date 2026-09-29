import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_card.dart';
import '../../shared/widgets/status_indicator.dart';
import '../../core/services/device_service.dart';
import '../../core/services/native_device_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Helper to map known icon names to compile-time constant Material Icons, avoiding dynamic IconData tree-shaking failures.
IconData resolveLauncherIcon(String? name) {
  switch (name?.toLowerCase().trim()) {
    case 'camera':
      return Icons.camera_alt_rounded;
    case 'browser':
    case 'chrome':
    case 'language':
      return Icons.language_rounded;
    case 'youtube':
      return Icons.play_circle_fill_rounded;
    case 'maps':
      return Icons.map_rounded;
    case 'whatsapp':
      return Icons.chat_bubble_rounded;
    case 'settings':
      return Icons.settings_rounded;
    case 'gallery':
      return Icons.photo_library_rounded;
    case 'clock':
      return Icons.alarm_rounded;
    case 'calculator':
      return Icons.calculate_rounded;
    case 'music':
      return Icons.music_note_rounded;
    case 'messages':
    case 'message':
      return Icons.message_rounded;
    case 'files':
      return Icons.folder_rounded;
    default:
      return Icons.apps_rounded;
  }
}

/// App slot model for the 6-app quick launcher dock.
class LauncherAppSlot {
  final int index;
  final String name;
  final String query;
  final String? packageName;
  final String? iconBase64;
  final String iconName;
  final Color color;
  final IconData? _customIcon;

  const LauncherAppSlot({
    required this.index,
    required this.name,
    required this.query,
    this.packageName,
    this.iconBase64,
    this.iconName = 'apps',
    this.color = const Color(0xFF1D6FE8),
    IconData? icon,
  }) : _customIcon = icon;

  String get _resolvedIconName {
    if (iconName != 'apps') return iconName;
    final combined = '$query $name'.toLowerCase();
    if (combined.contains('camera')) return 'camera';
    if (combined.contains('browser') ||
        combined.contains('chrome') ||
        combined.contains('language')) {
      return 'browser';
    }
    if (combined.contains('youtube')) return 'youtube';
    if (combined.contains('map')) return 'maps';
    if (combined.contains('whatsapp')) return 'whatsapp';
    if (combined.contains('setting')) return 'settings';
    if (combined.contains('gallery') || combined.contains('photo')) return 'gallery';
    if (combined.contains('clock') || combined.contains('alarm')) return 'clock';
    if (combined.contains('calculator')) return 'calculator';
    if (combined.contains('music')) return 'music';
    if (combined.contains('message')) return 'messages';
    if (combined.contains('file')) return 'files';
    return 'apps';
  }

  IconData get icon => _customIcon ?? resolveLauncherIcon(_resolvedIconName);

  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'query': query,
        'packageName': packageName,
        'iconBase64': iconBase64,
        'iconName': _resolvedIconName,
        'iconCode': icon.codePoint,
        'colorValue': color.toARGB32(),
      };

  factory LauncherAppSlot.fromJson(Map<String, dynamic> json) {
    final query = json['query'] as String? ?? 'app';
    final name = json['name'] as String? ?? 'App';
    String inferred = json['iconName'] as String? ?? '';
    if (inferred.isEmpty || inferred == 'apps') {
      final combined = '$query $name'.toLowerCase();
      if (combined.contains('camera')) {
        inferred = 'camera';
      } else if (combined.contains('browser') ||
          combined.contains('chrome') ||
          combined.contains('language')) {
        inferred = 'browser';
      } else if (combined.contains('youtube')) {
        inferred = 'youtube';
      } else if (combined.contains('map')) {
        inferred = 'maps';
      } else if (combined.contains('whatsapp')) {
        inferred = 'whatsapp';
      } else if (combined.contains('setting')) {
        inferred = 'settings';
      } else if (combined.contains('gallery') || combined.contains('photo')) {
        inferred = 'gallery';
      } else if (combined.contains('clock') || combined.contains('alarm')) {
        inferred = 'clock';
      } else if (combined.contains('calculator')) {
        inferred = 'calculator';
      } else if (combined.contains('music')) {
        inferred = 'music';
      } else if (combined.contains('message')) {
        inferred = 'messages';
      } else if (combined.contains('file')) {
        inferred = 'files';
      } else {
        inferred = 'apps';
      }
    }

    return LauncherAppSlot(
      index: json['index'] as int? ?? 0,
      name: name,
      query: query,
      packageName: json['packageName'] as String?,
      iconBase64: json['iconBase64'] as String?,
      iconName: inferred,
      color: Color(json['colorValue'] as int? ?? 0xFF1D6FE8),
    );
  }
}

/// Available presets for configuring launcher app slots.
const List<Map<String, dynamic>> kAppPresets = [
  {'name': 'Camera', 'query': 'camera', 'icon': Icons.camera_alt_rounded, 'color': Color(0xFF22C55E)},
  {'name': 'Browser', 'query': 'chrome', 'icon': Icons.public_rounded, 'color': Color(0xFF3B82F6)},
  {'name': 'YouTube', 'query': 'youtube', 'icon': Icons.play_circle_fill_rounded, 'color': Color(0xFFEF4444)},
  {'name': 'Maps', 'query': 'maps', 'icon': Icons.map_rounded, 'color': Color(0xFF10B981)},
  {'name': 'WhatsApp', 'query': 'whatsapp', 'icon': Icons.chat_bubble_rounded, 'color': Color(0xFF25D366)},
  {'name': 'Settings', 'query': 'settings', 'icon': Icons.settings_rounded, 'color': Color(0xFF94A3B8)},
  {'name': 'Gallery', 'query': 'gallery', 'icon': Icons.photo_library_rounded, 'color': Color(0xFFA855F7)},
  {'name': 'Clock', 'query': 'clock', 'icon': Icons.alarm_rounded, 'color': Color(0xFFF59E0B)},
  {'name': 'Calculator', 'query': 'calculator', 'icon': Icons.calculate_rounded, 'color': Color(0xFF06B6D4)},
  {'name': 'Music', 'query': 'music', 'icon': Icons.music_note_rounded, 'color': Color(0xFFEC4899)},
  {'name': 'Messages', 'query': 'message', 'icon': Icons.message_rounded, 'color': Color(0xFF6366F1)},
  {'name': 'Files', 'query': 'files', 'icon': Icons.folder_rounded, 'color': Color(0xFFF97316)},
];

/// Atlanta Connected Devices, Real Phone Controller & 6-App Quick Launch Menu.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  double _brightness = 0.75;
  double _volume = 0.70;
  String _ringerMode = 'normal'; // normal, silent, vibrate
  bool _isMuted = false;
  DeviceHardwareInfo _deviceInfo = DeviceHardwareInfo.fallback();

  late List<LauncherAppSlot> _launcherApps;
  static const String _prefLauncherKey = 'atlanta_quick_launch_apps_v2';

  @override
  void initState() {
    super.initState();
    _initDefaultApps();
    _loadStoredApps();
    _fetchHardwareLevels();
    _fetchDeviceInfo();
  }

  void _initDefaultApps() {
    _launcherApps = [
      const LauncherAppSlot(index: 0, name: 'Camera', query: 'camera', iconName: 'camera', color: Color(0xFF22C55E)),
      const LauncherAppSlot(index: 1, name: 'Browser', query: 'chrome', iconName: 'browser', color: Color(0xFF3B82F6)),
      const LauncherAppSlot(index: 2, name: 'YouTube', query: 'youtube', iconName: 'youtube', color: Color(0xFFEF4444)),
      const LauncherAppSlot(index: 3, name: 'Maps', query: 'maps', iconName: 'maps', color: Color(0xFF10B981)),
      const LauncherAppSlot(index: 4, name: 'WhatsApp', query: 'whatsapp', iconName: 'whatsapp', color: Color(0xFF25D366)),
      const LauncherAppSlot(index: 5, name: 'Settings', query: 'settings', iconName: 'settings', color: Color(0xFF94A3B8)),
    ];
  }

  Future<void> _fetchDeviceInfo() async {
    final info = await NativeDeviceService.instance.getDeviceInfo();
    if (mounted) {
      setState(() => _deviceInfo = info);
    }
  }

  Future<void> _loadStoredApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefLauncherKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        final loaded = list.map((e) => LauncherAppSlot.fromJson(e as Map<String, dynamic>)).toList();
        if (loaded.length == 6) {
          setState(() => _launcherApps = loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> _saveStoredApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_launcherApps.map((e) => e.toJson()).toList());
      await prefs.setString(_prefLauncherKey, jsonStr);
    } catch (_) {}
  }

  Future<void> _fetchHardwareLevels() async {
    final b = await NativeDeviceService.instance.getBrightness();
    final v = await NativeDeviceService.instance.getVolume();
    if (mounted) {
      setState(() {
        _brightness = b;
        _volume = v;
      });
    }
  }

  Future<void> _setBrightness(double val) async {
    setState(() => _brightness = val);
    await NativeDeviceService.instance.setBrightness(val);
  }

  Future<void> _setVolume(double val) async {
    setState(() {
      _volume = val;
      _isMuted = val <= 0.01;
    });
    await NativeDeviceService.instance.setVolume(val);
  }

  Future<void> _setRingerMode(String mode) async {
    SoundEffectsService.instance.playClick();
    setState(() => _ringerMode = mode);
    await NativeDeviceService.instance.setRingerMode(mode);
    if (mode == 'vibrate') {
      await NativeDeviceService.instance.vibrateDevice(durationMs: 70);
    }
  }

  Future<void> _triggerVibration() async {
    SoundEffectsService.instance.playClick();
    await NativeDeviceService.instance.vibrateDevice(durationMs: 90);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.vibration_rounded, color: AppColors.neonCyan, size: 18),
              const SizedBox(width: 8),
              const Text('Haptic Vibration Command Executed'),
            ],
          ),
          backgroundColor: AppColors.cardSurface,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sleepDevice() async {
    SoundEffectsService.instance.playClick();
    await NativeDeviceService.instance.sleepDevice();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.nightlight_round, color: AppColors.warning, size: 18),
              SizedBox(width: 8),
              Text('Sleep Mode Initiated • Display Dimmed'),
            ],
          ),
          backgroundColor: AppColors.cardSurface,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchAppSlot(LauncherAppSlot slot) async {
    SoundEffectsService.instance.playClick();
    bool launched = false;
    if (slot.packageName != null && slot.packageName!.isNotEmpty) {
      launched = await NativeDeviceService.instance.launchAppByPackage(slot.packageName!);
    } else {
      launched = await NativeDeviceService.instance.launchApp(slot.query);
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Launching ${slot.name} via Atlanta...'),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showConfigureSlotDialog(int slotIndex) {
    SoundEffectsService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => _InstalledAppsPickerDialog(
        slotIndex: slotIndex,
        onSelect: (app) {
          setState(() {
            _launcherApps[slotIndex] = LauncherAppSlot(
              index: slotIndex,
              name: app.name,
              query: app.packageName,
              packageName: app.packageName,
              iconBase64: app.iconBase64,
              iconName: 'apps',
              color: AppColors.primaryBlue,
            );
          });
          _saveStoredApps();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DeviceService.instance,
      builder: (context, _) {
        final devices = DeviceService.instance.devices;
        final onlineCount = DeviceService.instance.onlineCount;
        final activeCount = DeviceService.instance.activeCount;

        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ── LEFT PANEL: Hardware Mesh Terminals (230px) ──
                Container(
                  width: 230,
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface.withValues(alpha: 0.6),
                    border: const Border(
                      right: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.devices_rounded, color: AppColors.neonCyan, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'CONNECTED DEVICES',
                                style: AppTypography.monoSmall.copyWith(
                                  color: AppColors.primaryWhite,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Hardware Mesh Info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.deepBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HARDWARE MESH',
                                style: AppTypography.monoSmall.copyWith(
                                  color: AppColors.neonCyan,
                                  fontSize: 8.5,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$onlineCount Terminals • $activeCount Active IoT',
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Protocol: AES-256 Mesh Link',
                                style: TextStyle(color: AppColors.mutedText, fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Terminals Header
                        Text(
                          'CLIENT TERMINALS',
                          style: AppTypography.monoSmall.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 8.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const _ClientTerminalCard(
                          name: 'This Host Terminal',
                          platform: 'Bridge Link Active',
                          icon: Icons.laptop_windows_rounded,
                          status: StatusType.online,
                          isCurrent: true,
                        ),
                        const SizedBox(height: 6),

                        // Mobile Node Card (Tap to Browse Files)
                        _ClientTerminalCard(
                          name: _deviceInfo.model.isNotEmpty && _deviceInfo.model != 'Device'
                              ? '${_deviceInfo.manufacturer.toUpperCase()} ${_deviceInfo.model}'
                              : 'Android Mobile Node',
                          platform: '${_deviceInfo.osVersion} • Tap to Explore Files',
                          icon: Icons.phone_android_rounded,
                          status: StatusType.online,
                          isCurrent: false,
                          badge: 'FILES',
                          onTap: () {
                            SoundEffectsService.instance.playClick();
                            context.go('/devices/mobile-files');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ── RIGHT PANEL: Phone Controller & 6-App Quick Launch Dock ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.settings_cell_rounded, color: AppColors.neonCyan, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _deviceInfo.model.isNotEmpty && _deviceInfo.model != 'Device'
                                        ? '${_deviceInfo.manufacturer.toUpperCase()} ${_deviceInfo.model.toUpperCase()} • APP NEXUS'
                                        : 'PHONE NEXUS & APP CONTROL',
                                    style: const TextStyle(
                                      color: AppColors.primaryWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '${_deviceInfo.osVersion} (SDK ${_deviceInfo.sdkInt}) • SoC: ${_deviceInfo.hardware}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.neonCyan,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.bolt_rounded, color: AppColors.success, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE LINK',
                                    style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── 1. REAL PHONE FEATURES (Brightness, Volume, Silent, Vibrate, Sleep) ──
                        AtlantaCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.tune_rounded, color: AppColors.neonCyan, size: 16),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'PHYSICAL DEVICE TELEMETRY & CONTROLS',
                                    style: TextStyle(
                                      color: AppColors.primaryWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Brightness Row
                              Row(
                                children: [
                                  Icon(Icons.brightness_6_rounded, color: AppColors.neonCyan, size: 18),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Brightness: ${(_brightness * 100).toInt()}%',
                                      style: const TextStyle(color: AppColors.primaryWhite, fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        activeTrackColor: AppColors.neonCyan,
                                        thumbColor: AppColors.neonCyan,
                                      ),
                                      child: Slider(
                                        value: _brightness.clamp(0.01, 1.0),
                                        onChanged: (val) => _setBrightness(val),
                                      ),
                                    ),
                                  ),
                                  _presetBtn('25%', () => _setBrightness(0.25)),
                                  const SizedBox(width: 4),
                                  _presetBtn('50%', () => _setBrightness(0.50)),
                                  const SizedBox(width: 4),
                                  _presetBtn('100%', () => _setBrightness(1.00)),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Volume Row
                              Row(
                                children: [
                                  Icon(
                                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                    color: _isMuted ? AppColors.warning : AppColors.neonCyan,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Volume: ${(_volume * 100).toInt()}%',
                                      style: const TextStyle(color: AppColors.primaryWhite, fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        activeTrackColor: AppColors.primaryBlue,
                                        thumbColor: AppColors.primaryBlue,
                                      ),
                                      child: Slider(
                                        value: _volume.clamp(0.0, 1.0),
                                        onChanged: (val) => _setVolume(val),
                                      ),
                                    ),
                                  ),
                                  _presetBtn('Mute', () => _setVolume(0.0)),
                                  const SizedBox(width: 4),
                                  _presetBtn('50%', () => _setVolume(0.50)),
                                  const SizedBox(width: 4),
                                  _presetBtn('Max', () => _setVolume(1.00)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: AppColors.border, height: 1),
                              const SizedBox(height: 10),

                              // Audio Mode Pills & Sleep / Vibrate buttons
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('Mode:', style: TextStyle(color: AppColors.mutedText, fontSize: 10.5)),
                                  _modePill(
                                    label: 'Normal',
                                    icon: Icons.notifications_active_rounded,
                                    isSelected: _ringerMode == 'normal',
                                    onTap: () => _setRingerMode('normal'),
                                  ),
                                  _modePill(
                                    label: 'Silent',
                                    icon: Icons.notifications_off_rounded,
                                    isSelected: _ringerMode == 'silent',
                                    onTap: () => _setRingerMode('silent'),
                                    activeColor: AppColors.warning,
                                  ),
                                  _modePill(
                                    label: 'Vibrate',
                                    icon: Icons.vibration_rounded,
                                    isSelected: _ringerMode == 'vibrate',
                                    onTap: () => _setRingerMode('vibrate'),
                                    activeColor: AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: _triggerVibration,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    icon: Icon(Icons.sensors_rounded, size: 14, color: AppColors.neonCyan),
                                    label: const Text('Test Vibrate', style: TextStyle(fontSize: 10.5, color: AppColors.primaryWhite)),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _sleepDevice,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.cardSurface,
                                      foregroundColor: AppColors.primaryWhite,
                                      side: const BorderSide(color: AppColors.border),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    icon: const Icon(Icons.bedtime_rounded, size: 14, color: Colors.amber),
                                    label: const Text('Sleep Option', style: TextStyle(fontSize: 10.5)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── 2. QUICK APP LAUNCHER (6 SLOTS) ──
                        AtlantaCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.apps_rounded, color: AppColors.neonCyan, size: 16),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'ASSISTANT APP LAUNCHER (6 SLOTS)',
                                    style: TextStyle(
                                      color: AppColors.primaryWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Tap gear to assign slot',
                                    style: TextStyle(color: AppColors.neonCyan.withValues(alpha: 0.7), fontSize: 9.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // 6-App Grid
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 500;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isWide ? 6 : 3,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: isWide ? 1.05 : 1.15,
                                    ),
                                    itemCount: _launcherApps.length,
                                    itemBuilder: (context, idx) {
                                      final slot = _launcherApps[idx];
                                      return _buildAppSlotCard(slot);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── 3. SMART IOT GRID ──
                        Text(
                          'NEURAL IOT DEVICES',
                          style: AppTypography.monoSmall.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 9.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: devices.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            return _buildDeviceControlCard(devices[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _presetBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        SoundEffectsService.instance.playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _modePill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final effectiveColor = activeColor ?? AppColors.neonCyan;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withValues(alpha: 0.2) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? effectiveColor : AppColors.border,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? activeColor : AppColors.secondaryText),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.primaryWhite,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSlotCard(LauncherAppSlot slot) {
    Widget iconWidget;
    if (slot.iconBase64 != null && slot.iconBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(slot.iconBase64!);
        iconWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(slot.icon, color: slot.color, size: 22),
          ),
        );
      } catch (_) {
        iconWidget = Icon(slot.icon, color: slot.color, size: 22);
      }
    } else {
      iconWidget = Icon(slot.icon, color: slot.color, size: 22);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: slot.color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: slot.color.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchAppSlot(slot),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: slot.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: slot.color.withValues(alpha: 0.4)),
                        ),
                        child: iconWidget,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slot.name,
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showConfigureSlotDialog(slot.index),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.deepBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                      ),
                      child: Icon(Icons.swap_horiz_rounded, color: AppColors.neonCyan, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceControlCard(AtlantaDevice device) {
    IconData icon;
    Color iconColor;

    switch (device.type) {
      case DeviceType.light:
        icon = Icons.lightbulb_rounded;
        iconColor = Colors.amber;
        break;
      case DeviceType.thermostat:
        icon = Icons.thermostat_rounded;
        iconColor = Colors.orange;
        break;
      case DeviceType.lock:
        icon = Icons.lock_rounded;
        iconColor = AppColors.neonCyan;
        break;
      case DeviceType.mainframe:
        icon = Icons.memory_rounded;
        iconColor = AppColors.primaryBlue;
        break;
      case DeviceType.audio:
        icon = Icons.speaker_rounded;
        iconColor = Colors.purpleAccent;
        break;
      case DeviceType.camera:
        icon = Icons.videocam_rounded;
        iconColor = AppColors.success;
        break;
      default:
        icon = Icons.devices_rounded;
        iconColor = AppColors.secondaryText;
    }

    return AtlantaCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderColor: device.isOn ? iconColor.withValues(alpha: 0.45) : AppColors.border,
      glowColor: device.isOn ? iconColor : null,
      glowIntensity: device.isOn ? 0.12 : 0.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: device.isOn ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withValues(alpha: device.isOn ? 0.5 : 0.2),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device.room,
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
                ),
              ],
            ),
          ),
          Switch(
            value: device.isOn,
            activeThumbColor: iconColor,
            onChanged: (val) {
              SoundEffectsService.instance.playClick();
              DeviceService.instance.toggleDevice(device.id);
            },
          ),
        ],
      ),
    );
  }
}

class _ClientTerminalCard extends StatelessWidget {
  final String name;
  final String platform;
  final IconData icon;
  final StatusType status;
  final bool isCurrent;
  final String? badge;
  final VoidCallback? onTap;

  const _ClientTerminalCard({
    required this.name,
    required this.platform,
    required this.icon,
    required this.status,
    this.isCurrent = false,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primaryBlue.withValues(alpha: 0.18)
                : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCurrent
                  ? AppColors.neonCyan.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.neonCyan, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.primaryWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.6)),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      platform,
                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 8.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusIndicator(
                label: 'Device Status',
                status: status,
                dotSize: 6,
                showLabel: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal dialog allowing the user to browse all real installed applications on their physical phone,
/// search through them, and assign any app (with its real device icon) to an Atlanta dock slot.
class _InstalledAppsPickerDialog extends StatefulWidget {
  final int slotIndex;
  final Function(InstalledAppInfo app) onSelect;

  const _InstalledAppsPickerDialog({
    required this.slotIndex,
    required this.onSelect,
  });

  @override
  State<_InstalledAppsPickerDialog> createState() => _InstalledAppsPickerDialogState();
}

class _InstalledAppsPickerDialogState extends State<_InstalledAppsPickerDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<InstalledAppInfo> _allApps = [];
  List<InstalledAppInfo> _filteredApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await NativeDeviceService.instance.getInstalledApps();
      if (mounted) {
        setState(() {
          _allApps = apps;
          _filteredApps = apps;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = _allApps;
      } else {
        _filteredApps = _allApps
            .where((a) =>
                a.name.toLowerCase().contains(query) ||
                a.packageName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.5)),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.install_mobile_rounded, color: AppColors.neonCyan, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELECT DEVICE APP (SLOT ${widget.slotIndex + 1})',
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Choose any installed app from your physical device',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mutedText, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 16),
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.primaryWhite, fontSize: 12.5),
              decoration: InputDecoration(
                hintText: 'Search installed applications...',
                hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.neonCyan, size: 18),
                isDense: true,
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.neonCyan),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonCyan),
                          const SizedBox(height: 12),
                          const Text(
                            'Scanning installed device applications...',
                            style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  : _filteredApps.isEmpty
                      ? Center(
                          child: Text(
                            'No installed apps match "${_searchCtrl.text}"',
                            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredApps.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, i) {
                            final app = _filteredApps[i];
                            return InkWell(
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                widget.onSelect(app);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  children: [
                                    _buildAppIcon(app.iconBase64),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            app.name,
                                            style: const TextStyle(
                                              color: AppColors.primaryWhite,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            app.packageName,
                                            style: const TextStyle(
                                              color: AppColors.mutedText,
                                              fontSize: 9.5,
                                              fontFamily: 'monospace',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_rounded, color: AppColors.neonCyan, size: 14),
                                          const SizedBox(width: 2),
                                          Text(
                                            'ASSIGN',
                                            style: TextStyle(
                                              color: AppColors.neonCyan,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(String? iconBase64) {
    if (iconBase64 != null && iconBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(iconBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackAppIcon(),
          ),
        );
      } catch (_) {}
    }
    return _fallbackAppIcon();
  }

  Widget _fallbackAppIcon() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.apps_rounded, color: AppColors.neonCyan, size: 18),
    );
  }
}
