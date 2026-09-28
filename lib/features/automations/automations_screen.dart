import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_card.dart';
import '../../core/services/automation_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Automations & Neural Protocols screen.
class AutomationsScreen extends StatelessWidget {
  const AutomationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AutomationService.instance,
      builder: (context, _) {
        final automations = AutomationService.instance.automations;
        final enabledCount = automations.where((a) => a.isEnabled).length;

        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ── LEFT: Control & Status Panel (230px) ──
                Container(
                  width: 230,
                  decoration: const BoxDecoration(
                    color: AppColors.cardSurface,
                    border: Border(
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
                                Icons.bolt_rounded,
                                color: AppColors.neonCyan,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NEURAL PROTOCOLS',
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
                        const SizedBox(height: 12),

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
                                'AUTOMATION ENGINE',
                                style: AppTypography.monoSmall.copyWith(
                                  color: AppColors.neonCyan,
                                  fontSize: 8.5,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$enabledCount of ${automations.length} Active',
                                    style: const TextStyle(
                                      color: AppColors.primaryWhite,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Telemetry Link: SYNCHRONIZED',
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Instructions / Info
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.deepBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUICK MANUAL',
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• Toggle switches to enable or disable background triggers.\n• Tap "Execute Now" to test a routine live.\n• Use voice: "Run system diagnostics".',
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 9.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── RIGHT: Protocols Grid (Responsive 2-column) ──
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: automations.length,
                    itemBuilder: (context, index) {
                      final auto = automations[index];
                      return _AutomationWorkflowCard(automation: auto);
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

class _AutomationWorkflowCard extends StatefulWidget {
  final AtlantaAutomation automation;

  const _AutomationWorkflowCard({required this.automation});

  @override
  State<_AutomationWorkflowCard> createState() => _AutomationWorkflowCardState();
}

class _AutomationWorkflowCardState extends State<_AutomationWorkflowCard> {
  String _currentExecutingStep = '';
  double _progress = 0.0;

  IconData _getIconData(String name) {
    switch (name) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'shield_rounded':
        return Icons.shield_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  Future<void> _execute() async {
    SoundEffectsService.instance.playScanning();
    setState(() {
      _currentExecutingStep = 'Initializing protocol...';
      _progress = 0.1;
    });

    await AutomationService.instance.executeAutomation(
      widget.automation.id,
      onProgress: (step, prog) {
        if (mounted) {
          setState(() {
            _currentExecutingStep = step;
            _progress = prog;
          });
        }
      },
    );

    await SoundEffectsService.instance.playSuccess();
    if (mounted) {
      setState(() {
        _currentExecutingStep = '';
        _progress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auto = widget.automation;

    return AtlantaCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: auto.isExecuting
          ? AppColors.neonCyan
          : (auto.isEnabled ? AppColors.neonCyan.withValues(alpha: 0.35) : AppColors.border),
      glowColor: auto.isExecuting ? AppColors.neonCyan : (auto.isEnabled ? AppColors.neonCyan : null),
      glowIntensity: auto.isExecuting ? 0.22 : (auto.isEnabled ? 0.08 : 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: auto.isEnabled
                      ? AppColors.primaryBlue.withValues(alpha: 0.15)
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(auto.iconName),
                  color: auto.isEnabled ? AppColors.neonCyan : AppColors.secondaryText,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auto.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      auto.triggerDesc,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: auto.isEnabled,
                activeThumbColor: AppColors.neonCyan,
                onChanged: (_) {
                  SoundEffectsService.instance.playClick();
                  AutomationService.instance.toggleAutomation(auto.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            auto.actionDesc,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryWhite.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),

          // Steps preview or live execution
          if (auto.isExecuting) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.neonCyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentExecutingStep,
                          style: AppTypography.monoSmall.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.cardSurface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.neonCyan),
                  ),
                ],
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: auto.steps.map((step) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 11, color: AppColors.neonCyan),
                      const SizedBox(width: 4),
                      Text(
                        step,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondaryText.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          // Run Now Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: auto.isExecuting ? null : _execute,
              icon: Icon(
                auto.isExecuting ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
                size: 16,
              ),
              label: Text(auto.isExecuting ? 'Running...' : 'Execute Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
