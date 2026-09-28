import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sound_effects_service.dart';
import 'status_indicator.dart';

/// Desktop sidebar navigation for Atlanta.
class AtlantaSidebar extends StatelessWidget {
  final int currentIndex;

  const AtlantaSidebar({
    super.key,
    required this.currentIndex,
  });

  static const List<_SidebarItem> _items = [
    _SidebarItem(Icons.home_rounded, 'Home', '/home'),
    _SidebarItem(Icons.chat_bubble_rounded, 'Assistant', '/assistant'),
    _SidebarItem(Icons.task_alt_rounded, 'Tasks', '/tasks'),
    _SidebarItem(Icons.sticky_note_2_rounded, 'Notes', '/notes'),
    _SidebarItem(Icons.notifications_rounded, 'Reminders', '/reminders'),
    _SidebarItem(Icons.calendar_month_rounded, 'Calendar', '/calendar'),
    _SidebarItem(Icons.folder_rounded, 'Files', '/files'),
    _SidebarItem(Icons.devices_rounded, 'Devices', '/devices'),
    _SidebarItem(Icons.auto_awesome_rounded, 'Automations', '/automations'),
    _SidebarItem(Icons.history_rounded, 'Activity', '/activity'),
    _SidebarItem(Icons.settings_rounded, 'Settings', '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Logo ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXl,
              vertical: AppConstants.spacingXxl,
            ),
            child: Row(
              children: [
                // Atlanta official logo
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.35),
                        blurRadius: 10,
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
                const SizedBox(width: 12),
                Text(
                  'ATLANTA',
                  style: AppTypography.brandName.copyWith(
                    fontSize: 16,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // ── Nav items ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isActive = index == currentIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: isActive
                        ? AppColors.navActiveBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    child: InkWell(
                      onTap: () {
                        SoundEffectsService.instance.playClick();
                        context.go(item.route);
                      },
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingLg,
                          vertical: AppConstants.spacingMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive
                                  ? AppColors.primaryBlue
                                  : AppColors.navInactive,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.primaryWhite
                                    : AppColors.secondaryText,
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Bottom section ──
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Connection status
                const Row(
                  children: [
                    StatusIndicator(
                      label: 'AI Core Online',
                      status: StatusType.online,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                // User profile
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      ),
                      child: const Center(
                        child: Text(
                          'I',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imran',
                            style: TextStyle(
                              color: AppColors.primaryWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Online',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.mutedText,
                      ),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  const _SidebarItem(this.icon, this.label, this.route);
}
