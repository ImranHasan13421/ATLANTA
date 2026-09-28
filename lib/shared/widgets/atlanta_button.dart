import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Design System — Button variants.
enum AtlantaButtonVariant { primary, secondary, ghost, danger }
enum AtlantaButtonSize { small, medium, large }

class AtlantaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AtlantaButtonVariant variant;
  final AtlantaButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const AtlantaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AtlantaButtonVariant.primary,
    this.size = AtlantaButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getStyle();
    final padding = _getPadding();
    final fontSize = _getFontSize();

    final VoidCallback? effectiveOnPressed = (isLoading || onPressed == null)
        ? null
        : () {
            SoundEffectsService.instance.playClick();
            onPressed!();
          };

    Widget child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getForegroundColor(),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: fontSize + 2),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    switch (variant) {
      case AtlantaButtonVariant.primary:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: buttonStyle.copyWith(
              padding: WidgetStatePropertyAll(padding),
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ),
            child: child,
          ),
        );
      case AtlantaButtonVariant.secondary:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: OutlinedButton(
            onPressed: effectiveOnPressed,
            style: buttonStyle.copyWith(
              padding: WidgetStatePropertyAll(padding),
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ),
            child: child,
          ),
        );
      case AtlantaButtonVariant.ghost:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: TextButton(
            onPressed: effectiveOnPressed,
            style: buttonStyle.copyWith(
              padding: WidgetStatePropertyAll(padding),
              textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ),
            child: child,
          ),
        );
      case AtlantaButtonVariant.danger:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.primaryWhite,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              elevation: 0,
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );
    }
  }

  ButtonStyle _getStyle() {
    switch (variant) {
      case AtlantaButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          elevation: 0,
        );
      case AtlantaButtonVariant.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryWhite,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        );
      case AtlantaButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        );
      case AtlantaButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          elevation: 0,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AtlantaButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AtlantaButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case AtlantaButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AtlantaButtonSize.small:
        return 12;
      case AtlantaButtonSize.medium:
        return 14;
      case AtlantaButtonSize.large:
        return 16;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case AtlantaButtonVariant.primary:
      case AtlantaButtonVariant.danger:
        return AppColors.primaryWhite;
      case AtlantaButtonVariant.secondary:
        return AppColors.primaryWhite;
      case AtlantaButtonVariant.ghost:
        return AppColors.primaryBlue;
    }
  }
}

/// Icon-only button for toolbars, actions, etc.
class AtlantaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const AtlantaIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                SoundEffectsService.instance.playClick();
                onPressed!();
              },
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size * 0.5,
            color: color ?? AppColors.secondaryText,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
