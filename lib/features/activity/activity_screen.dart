import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Activity / History screen — live audit trail.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _filter = 'All';

  static const List<String> _filters = [
    'All',
    'Voice',
    'Tasks',
    'Notes',
    'Device',
    'Automation',
    'Security',
  ];

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.voice:
        return Icons.mic_rounded;
      case ActivityType.task:
        return Icons.task_alt_rounded;
      case ActivityType.note:
        return Icons.note_alt_outlined;
      case ActivityType.reminder:
        return Icons.alarm_rounded;
      case ActivityType.device:
        return Icons.devices_rounded;
      case ActivityType.automation:
        return Icons.bolt_rounded;
      case ActivityType.security:
        return Icons.shield_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.voice:
        return AppColors.neonCyan;
      case ActivityType.task:
        return AppColors.primaryBlue;
      case ActivityType.note:
        return AppColors.warning;
      case ActivityType.device:
        return Colors.purpleAccent;
      case ActivityType.automation:
        return AppColors.success;
      case ActivityType.security:
        return AppColors.error;
      default:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ActivityService.instance,
      builder: (context, _) {
        var activities = ActivityService.instance.activities;
        if (_filter != 'All') {
          activities = activities
              .where((a) =>
                  a.type.name.toLowerCase() == _filter.toLowerCase() ||
                  (_filter == 'Device' && a.type == ActivityType.device) ||
                  (_filter == 'Tasks' && a.type == ActivityType.task) ||
                  (_filter == 'Notes' && a.type == ActivityType.note) ||
                  (_filter == 'Automation' && a.type == ActivityType.automation))
              .toList();
        }        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ── LEFT: Filters & Telemetry Log (230px) ──
                Container(
                  width: 230,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: const BoxDecoration(
                    color: AppColors.cardSurface,
                    border: Border(
                      right: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
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
                            child: Icon(
                              Icons.history_rounded,
                              color: AppColors.neonCyan,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AUDIT LOG',
                              style: AppTypography.monoSmall.copyWith(
                                color: AppColors.primaryWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${activities.length}',
                              style: TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category filters list
                      Expanded(
                        child: ListView.separated(
                          itemCount: _filters.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = _filter == filter;

                            return InkWell(
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                setState(() => _filter = filter);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.neonCyan.withValues(alpha: 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Clear History button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            SoundEffectsService.instance.playClick();
                            ActivityService.instance.clear();
                          },
                          icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.secondaryText),
                          label: const Text(
                            'Clear Logs',
                            style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── RIGHT: Activity Log List ──
                Expanded(
                  child: activities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.history_toggle_off_rounded,
                                size: 48,
                                color: AppColors.mutedText,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No activity logs',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Voice commands and system events will show here.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingLg,
                        ),
                        itemCount: activities.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: AppConstants.spacingSm),
                        itemBuilder: (context, index) {
                          final item = activities[index];
                          final color = _getColorForType(item.type);
                          final icon = _getIconForType(item.type);

                          final timeStr =
                              '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}';

                          return Container(
                            padding: const EdgeInsets.all(AppConstants.spacingMd),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusLg),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style:
                                            AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      timeStr,
                                      style: AppTypography.monoSmall.copyWith(
                                        color: AppColors.mutedText,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: item.status == 'success'
                                            ? AppColors.success.withValues(alpha: 0.15)
                                            : AppColors.warning.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: item.status == 'success'
                                              ? AppColors.success
                                              : AppColors.warning,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
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
}
