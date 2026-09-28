import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';

/// Atlanta Permissions & Access screen.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepBackground,
        title: Text('Permissions & Access', style: AppTypography.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control what Atlanta is allowed to access and do.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXxl),

            _buildCategory('Files', [
              _PermItem('Documents', 'allowed'),
              _PermItem('Downloads', 'allowed'),
              _PermItem('Pictures', 'allowed'),
              _PermItem('Projects', 'allowed'),
              _PermItem('System Files', 'blocked'),
            ]),
            const SizedBox(height: AppConstants.spacingXl),

            _buildCategory('Applications', [
              _PermItem('Chrome', 'allowed'),
              _PermItem('VS Code', 'allowed'),
              _PermItem('Android Studio', 'ask'),
              _PermItem('Other Apps', 'ask'),
            ]),
            const SizedBox(height: AppConstants.spacingXl),

            _buildCategory('Browser', [
              _PermItem('Search Web', 'allowed'),
              _PermItem('Read Pages', 'ask'),
              _PermItem('Fill Forms', 'blocked'),
              _PermItem('Submit Forms', 'blocked'),
            ]),
            const SizedBox(height: AppConstants.spacingXl),

            _buildCategory('Accounts', [
              _PermItem('Google', 'allowed'),
              _PermItem('Microsoft', 'ask'),
              _PermItem('GitHub', 'ask'),
            ]),
            const SizedBox(height: AppConstants.spacing3xl),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, List<_PermItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLg,
                      vertical: AppConstants.spacingMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.resource,
                            style: AppTypography.bodyMedium,
                          ),
                        ),
                        _AccessBadge(level: item.access),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.only(left: AppConstants.spacingLg),
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
}

class _PermItem {
  final String resource;
  final String access; // 'allowed', 'ask', 'blocked'

  const _PermItem(this.resource, this.access);
}

class _AccessBadge extends StatelessWidget {
  final String level;

  const _AccessBadge({required this.level});

  Color get _color {
    switch (level) {
      case 'allowed':
        return AppColors.success;
      case 'ask':
        return AppColors.warning;
      case 'blocked':
        return AppColors.error;
      default:
        return AppColors.mutedText;
    }
  }

  String get _label {
    switch (level) {
      case 'allowed':
        return 'Allowed';
      case 'ask':
        return 'Ask Every Time';
      case 'blocked':
        return 'Blocked';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
