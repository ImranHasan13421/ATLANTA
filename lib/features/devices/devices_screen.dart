import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_card.dart';
import '../../shared/widgets/status_indicator.dart';
import '../../core/services/device_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Connected Devices & Smart Grid screen.
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

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
                // ── LEFT: Client Terminals & Telemetry (230px) ──
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
                            child: const Icon(
                              Icons.devices_rounded,
                              color: AppColors.neonCyan,
                              size: 16,
                            ),
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

                      // Status Badge Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.deepBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.neonCyan.withValues(alpha: 0.2),
                          ),
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
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Terminals
                      Text(
                        'ATLANTA CLIENT TERMINALS',
                        style: AppTypography.monoSmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 8.5,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      const _ClientTerminalCard(
                        name: 'This PC',
                        platform: 'Windows 11 (64-bit)',
                        icon: Icons.laptop_windows_rounded,
                        status: StatusType.online,
                        isCurrent: true,
                      ),
                      const SizedBox(height: 6),

                      const _ClientTerminalCard(
                        name: 'Mobile Node',
                        platform: 'Android 14 • Encrypted',
                        icon: Icons.phone_android_rounded,
                        status: StatusType.online,
                        isCurrent: false,
                      ),
                    ],
                  ),
                ),
              ),

                // ── RIGHT: Neural IoT Grid (2 columns or list) ──
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    itemCount: devices.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      return _buildDeviceControlCard(devices[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: AtlantaCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderColor: device.isOn
            ? iconColor.withValues(alpha: 0.45)
            : AppColors.border,
        glowColor: device.isOn ? iconColor : null,
        glowIntensity: device.isOn ? 0.12 : 0.0,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (device.isOn ? iconColor : AppColors.secondaryText)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: device.isOn ? iconColor : AppColors.secondaryText,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            device.room,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${device.statusText}',
                            style: TextStyle(
                              color: device.statusText == 'Online'
                                  ? AppColors.success
                                  : AppColors.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
            if (device.isOn && (device.type == DeviceType.light || device.type == DeviceType.thermostat)) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    device.type == DeviceType.thermostat
                        ? '${device.value.toInt()}°F'
                        : 'Power: ${device.value.toInt()}%',
                    style: AppTypography.monoSmall.copyWith(
                      color: iconColor,
                      fontSize: 11,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: iconColor,
                        thumbColor: iconColor,
                        inactiveTrackColor: AppColors.border,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: device.value,
                        min: device.type == DeviceType.thermostat ? 60 : 0,
                        max: device.type == DeviceType.thermostat ? 85 : 100,
                        onChanged: (v) {
                          DeviceService.instance.setDeviceValue(device.id, v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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

  const _ClientTerminalCard({
    required this.name,
    required this.platform,
    required this.icon,
    required this.status,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AtlantaCard(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      borderColor: isCurrent
          ? AppColors.neonCyan.withValues(alpha: 0.4)
          : AppColors.border.withValues(alpha: 0.5),
      glowColor: isCurrent ? AppColors.neonCyan : null,
      glowIntensity: isCurrent ? 0.12 : 0.04,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryWhite,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'NODE',
                          style: TextStyle(
                            fontSize: 7.5,
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          StatusIndicator(
            label: '',
            status: status,
            showLabel: false,
            dotSize: 6,
          ),
        ],
      ),
    );
  }
}
