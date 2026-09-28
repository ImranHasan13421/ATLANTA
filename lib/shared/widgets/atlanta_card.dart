import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Design System — Glassmorphic Card variants with ambient cyber glow.
class AtlantaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final bool enableGlow;

  const AtlantaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppConstants.radiusLg,
    this.glowColor,
    this.glowIntensity = 0.08,
    this.enableGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.neonCyan.withValues(alpha: 0.2);
    final effectiveGlowColor = glowColor ?? effectiveBorderColor;
    final bg = backgroundColor ?? AppColors.cardSurface;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: effectiveGlowColor.withValues(alpha: glowIntensity),
                  blurRadius: 14,
                  spreadRadius: -1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      SoundEffectsService.instance.playClick();
                      onTap!();
                    },
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: AppColors.primaryBlue.withValues(alpha: 0.15),
              highlightColor: AppColors.neonCyan.withValues(alpha: 0.08),
              child: Container(
                padding: padding ?? const EdgeInsets.all(AppConstants.spacingLg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bg.withValues(alpha: 0.65),
                      bg.withValues(alpha: 0.35),
                    ],
                  ),
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: 1.0,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick action card used on the Home screen.
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AtlantaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryBlue).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primaryWhite,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Dashboard stat card showing a count and label.
class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primaryBlue;

    return AtlantaCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppConstants.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedText,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Task card for displaying a task item.
class TaskCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? dueDate;
  final String priority;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const TaskCard({
    super.key,
    required this.title,
    this.subtitle,
    this.dueDate,
    this.priority = 'medium',
    this.isCompleted = false,
    this.onTap,
    this.onToggle,
  });

  Color get _priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.priorityMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = priority.toLowerCase() == 'high';
    return AtlantaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: isCompleted
          ? AppColors.border.withValues(alpha: 0.5)
          : (isHigh
              ? AppColors.priorityHigh.withValues(alpha: 0.4)
              : AppColors.neonCyan.withValues(alpha: 0.25)),
      glowColor: isHigh ? AppColors.priorityHigh : AppColors.neonCyan,
      glowIntensity: isHigh ? 0.12 : 0.06,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle == null
                ? null
                : () {
                    SoundEffectsService.instance.playClick();
                    onToggle!();
                  },
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.neonCyan
                      : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? AppColors.mutedText
                        : AppColors.primaryWhite,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (dueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 11,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dueDate!,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.mutedText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 4, left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _priorityColor,
              boxShadow: [
                BoxShadow(
                  color: _priorityColor.withValues(alpha: 0.7),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Activity entry card.
class ActivityCard extends StatelessWidget {
  final IconData icon;
  final String action;
  final String? details;
  final String time;
  final Color? iconColor;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.action,
    this.details,
    required this.time,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryBlue)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: AppTypography.bodyMedium),
                if (details != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    details!,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(time, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}
