import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Status indicator dot with label.
class StatusIndicator extends StatelessWidget {
  final String label;
  final StatusType status;
  final double dotSize;
  final bool showLabel;

  const StatusIndicator({
    super.key,
    required this.label,
    this.status = StatusType.online,
    this.dotSize = 8,
    this.showLabel = true,
  });

  Color get _color {
    switch (status) {
      case StatusType.online:
        return AppColors.success;
      case StatusType.offline:
        return AppColors.mutedText;
      case StatusType.syncing:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.pending:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _color,
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

enum StatusType { online, offline, syncing, error, pending }

/// Empty state placeholder widget.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Action confirmation card (when Atlanta is about to perform an action).
class ActionConfirmationCard extends StatelessWidget {
  final String title;
  final String description;
  final ActionStatus status;
  final VoidCallback? onAllow;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const ActionConfirmationCard({
    super.key,
    required this.title,
    required this.description,
    this.status = ActionStatus.waitingConfirmation,
    this.onAllow,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_statusIcon, size: 20, color: _statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          _StatusBadge(status: status),
          if (status == ActionStatus.waitingConfirmation) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAllow,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Allow'),
                  ),
                ),
              ],
            ),
          ],
          if (status == ActionStatus.failed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color get _borderColor {
    switch (status) {
      case ActionStatus.waitingConfirmation:
        return AppColors.warning.withValues(alpha: 0.3);
      case ActionStatus.executing:
        return AppColors.primaryBlue.withValues(alpha: 0.3);
      case ActionStatus.completed:
        return AppColors.success.withValues(alpha: 0.3);
      case ActionStatus.failed:
        return AppColors.error.withValues(alpha: 0.3);
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case ActionStatus.waitingConfirmation:
        return Icons.help_outline_rounded;
      case ActionStatus.executing:
        return Icons.sync_rounded;
      case ActionStatus.completed:
        return Icons.check_circle_outline_rounded;
      case ActionStatus.failed:
        return Icons.error_outline_rounded;
    }
  }

  Color get _statusColor {
    switch (status) {
      case ActionStatus.waitingConfirmation:
        return AppColors.warning;
      case ActionStatus.executing:
        return AppColors.primaryBlue;
      case ActionStatus.completed:
        return AppColors.success;
      case ActionStatus.failed:
        return AppColors.error;
    }
  }
}

enum ActionStatus { waitingConfirmation, executing, completed, failed }

class _StatusBadge extends StatelessWidget {
  final ActionStatus status;

  const _StatusBadge({required this.status});

  String get _label {
    switch (status) {
      case ActionStatus.waitingConfirmation:
        return 'Waiting for confirmation';
      case ActionStatus.executing:
        return 'Executing...';
      case ActionStatus.completed:
        return 'Completed ✓';
      case ActionStatus.failed:
        return 'Action failed';
    }
  }

  Color get _color {
    switch (status) {
      case ActionStatus.waitingConfirmation:
        return AppColors.warning;
      case ActionStatus.executing:
        return AppColors.primaryBlue;
      case ActionStatus.completed:
        return AppColors.success;
      case ActionStatus.failed:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
