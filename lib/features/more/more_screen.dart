import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';

/// Mobile "More" menu — shows additional navigation options.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const List<_MenuItem> _items = [
    _MenuItem(Icons.sticky_note_2_rounded, 'Notes', '/notes',
        AppColors.warning),
    _MenuItem(Icons.notifications_rounded, 'Reminders', '/reminders',
        AppColors.success),
    _MenuItem(Icons.calendar_month_rounded, 'Calendar', '/calendar',
        AppColors.info),
    _MenuItem(Icons.history_rounded, 'Activity', '/activity',
        AppColors.primaryBlue),
    _MenuItem(Icons.devices_rounded, 'Devices', '/devices',
        AppColors.success),
    _MenuItem(Icons.folder_rounded, 'Files', '/files',
        AppColors.primaryBlueLight),
    _MenuItem(Icons.auto_awesome_rounded, 'Automations', '/automations',
        AppColors.secondaryBlue),
    _MenuItem(Icons.security_rounded, 'Permissions', '/permissions',
        AppColors.error),
    _MenuItem(Icons.settings_rounded, 'Settings', '/settings',
        AppColors.secondaryText),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepBackground,
        title: Text('More', style: AppTypography.headlineMedium),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppConstants.spacingMd,
          crossAxisSpacing: AppConstants.spacingMd,
          childAspectRatio: 1.0,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Material(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: InkWell(
              onTap: () => context.push(item.route),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryWhite,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _MenuItem(this.icon, this.label, this.route, this.color);
}
