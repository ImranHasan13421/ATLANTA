import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';

/// Atlanta Settings screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedCategoryIndex = 1; // Default to 'Atlanta AI'

  static const List<Map<String, dynamic>> _categories = [
    {'title': 'Account', 'icon': Icons.person_outline_rounded},
    {'title': 'Atlanta AI', 'icon': Icons.psychology_rounded},
    {'title': 'Voice', 'icon': Icons.mic_rounded},
    {'title': 'Notifications', 'icon': Icons.notifications_none_rounded},
    {'title': 'Appearance', 'icon': Icons.palette_outlined},
    {'title': 'Security', 'icon': Icons.security_rounded},
    {'title': 'About', 'icon': Icons.info_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: SafeArea(
        child: Row(
          children: [
            // ── LEFT: Profile & Category Selector (230px) ──
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
                  // Profile mini card
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                        ),
                        child: const Center(
                          child: Text(
                            'I',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
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
                              'Boss Imran',
                              style: TextStyle(
                                color: AppColors.primaryWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Primary Terminal',
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 8),

                  // Categories list
                  Expanded(
                    child: ListView.separated(
                      itemCount: _categories.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategoryIndex == index;

                        return InkWell(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            child: Row(
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  size: 16,
                                  color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cat['title'] as String,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

            // ── RIGHT: Selected Category Options ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: _buildSelectedCategoryContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0: // Account
        return _buildSection('Account Settings', [
          const _SettingsItem(Icons.person_outline_rounded, 'Profile Identity'),
          const _SettingsItem(Icons.email_outlined, 'Email Address', subtitle: 'imran@example.com'),
          const _SettingsItem(Icons.lock_outline_rounded, 'Encryption Key & Password'),
          const _SettingsItem(Icons.logout_rounded, 'Logout Terminal', color: AppColors.error),
        ]);
      case 1: // Atlanta AI
        return _buildSection('Neural AI Configuration', [
          const _SettingsItem(Icons.psychology_rounded, 'Model Engine', subtitle: 'Gemini Pro Latest / Flash 2.5'),
          const _SettingsItem(Icons.chat_outlined, 'Persona Style', subtitle: 'Futuristic JARVIS Assistant'),
          const _SettingsItem(Icons.memory_rounded, 'Context & Memory Mesh', subtitle: 'Persistent'),
          const _SettingsItem(Icons.record_voice_over_rounded, 'Voice Synthesis', subtitle: 'Atlanta Female Neural Voice'),
        ]);
      case 2: // Voice
        return _buildSection('Voice & Audio Systems', [
          const _SettingsItem(Icons.mic_rounded, 'Microphone Input', subtitle: 'Hardware Audio Bridge'),
          const _SettingsItem(Icons.hearing_rounded, 'Speech Recognition Engine', subtitle: 'Live Speech-to-Text'),
          const _SettingsItem(Icons.volume_up_rounded, 'Audio Playback SFX', subtitle: 'HQ Cyber Sounds Enabled'),
          const _SettingsItem(Icons.campaign_rounded, 'Wake Phrase', subtitle: '"Hey Atlanta"'),
        ]);
      case 3: // Notifications
        return _buildSection('Notifications & Alerts', [
          const _SettingsItem(Icons.task_alt_rounded, 'Task Reminders'),
          const _SettingsItem(Icons.alarm_rounded, 'Scheduled Alarms'),
          const _SettingsItem(Icons.computer_rounded, 'System Telemetry Alerts'),
        ]);
      case 4: // Appearance
        return _buildSection('Visual Appearance', [
          _SettingsItem(Icons.dark_mode_rounded, 'Cyber Dark HUD', trailing: _buildToggle(true)),
          const _SettingsItem(Icons.palette_rounded, 'Accent Color', subtitle: 'Electric Cyan & Deep Navy'),
          const _SettingsItem(Icons.animation_rounded, 'HUD Orb Animation Intensity', subtitle: 'Fluid Dynamic'),
        ]);
      case 5: // Security
        return _buildSection('Security & Privacy', [
          const _SettingsItem(Icons.security_rounded, 'Application Access Permissions', subtitle: 'Full Local Bridge'),
          const _SettingsItem(Icons.shield_rounded, 'Hardware Query Permissions', subtitle: 'QUERY_ALL_PACKAGES'),
          const _SettingsItem(Icons.timer_rounded, 'Biometric Lock / Session'),
        ]);
      default: // About
        return _buildSection('About Atlanta', [
          const _SettingsItem(Icons.info_outline_rounded, 'Version', subtitle: 'v1.2.0 Cyber-Core'),
          const _SettingsItem(Icons.description_outlined, 'Terms of Neural Service'),
          const _SettingsItem(Icons.privacy_tip_outlined, 'Privacy Policy'),
        ]);
    }
  }

  Widget _buildSection(String title, List<_SettingsItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.monoSmall.copyWith(
            color: AppColors.neonCyan,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final item = entry.value;
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.vertical(
                        top: entry.key == 0
                            ? Radius.circular(AppConstants.radiusLg)
                            : Radius.zero,
                        bottom: isLast
                            ? Radius.circular(AppConstants.radiusLg)
                            : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingLg,
                          vertical: AppConstants.spacingMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: item.color ?? AppColors.secondaryText,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      color: item.color ?? AppColors.primaryWhite,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  if (item.subtitle != null)
                                    Text(
                                      item.subtitle!,
                                      style: AppTypography.labelSmall.copyWith(fontSize: 10),
                                    ),
                                ],
                              ),
                            ),
                            item.trailing ??
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.mutedText,
                                  size: 18,
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.only(left: 48),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(bool value) {
    return Switch(
      value: value,
      activeThumbColor: AppColors.neonCyan,
      onChanged: (_) {},
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final Widget? trailing;

  const _SettingsItem(
    this.icon,
    this.label, {
    this.subtitle,
    this.color,
    this.trailing,
  });
}
