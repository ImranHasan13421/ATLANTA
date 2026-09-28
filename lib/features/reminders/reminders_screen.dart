import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_card.dart';
import '../../shared/widgets/status_indicator.dart';
import '../../core/services/reminder_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Reminders screen.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNewReminderSheet() {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '10:00 AM');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Reminder',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: AppColors.primaryWhite),
                decoration: InputDecoration(
                  hintText: 'What should Atlanta remind you about?',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                style: const TextStyle(color: AppColors.primaryWhite),
                decoration: InputDecoration(
                  hintText: 'Time (e.g. 5:00 PM, Tomorrow)',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      ReminderService.instance.addReminder(
                        title: title,
                        time: timeController.text.trim().isNotEmpty
                            ? timeController.text.trim()
                            : '10:00 AM',
                      );
                      SoundEffectsService.instance.playSuccess();
                    }
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.alarm_add_rounded, size: 18),
                  label: const Text('Set Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReminderService.instance,
      builder: (context, _) {
        final activeReminders = ReminderService.instance.activeReminders;
        final pastReminders = ReminderService.instance.pastReminders;
        final currentList =
            _tabController.index == 0 ? activeReminders : pastReminders;

        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ── LEFT: Reminder Controls & Filters (230px) ──
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
                                Icons.alarm_rounded,
                                color: AppColors.neonCyan,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NEURAL REMINDERS',
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
                        const SizedBox(height: 14),

                        // Tabs as vertical selector buttons
                        _buildFilterButton(
                          label: 'Active Reminders',
                          count: activeReminders.length,
                          isSelected: _tabController.index == 0,
                          onTap: () {
                            SoundEffectsService.instance.playClick();
                            setState(() => _tabController.index = 0);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildFilterButton(
                          label: 'Past & Done',
                          count: pastReminders.length,
                          isSelected: _tabController.index == 1,
                          onTap: () {
                            SoundEffectsService.instance.playClick();
                            setState(() => _tabController.index = 1);
                          },
                        ),
                        const SizedBox(height: 14),

                        // + Set Reminder button
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SoundEffectsService.instance.playClick();
                              _showNewReminderSheet();
                            },
                            icon: const Icon(Icons.add_alarm_rounded, size: 16),
                            label: const Text(
                              'New Reminder',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Voice Alarm hint
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.deepBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Say "Set alarm for 7:00 AM" or "Remind me to call John"',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── RIGHT: Reminders Grid ──
                Expanded(
                  child: currentList.isEmpty
                      ? Center(
                          child: EmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: 'No reminders',
                            subtitle: _tabController.index == 0
                                ? 'You have no active reminders.'
                                : 'No completed reminders.',
                            action: ElevatedButton(
                              onPressed: _showNewReminderSheet,
                              child: const Text('Set Reminder'),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.15,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            final reminder = currentList[index];
                            return _ReminderItem(
                              reminder: reminder,
                              onToggle: () {
                                SoundEffectsService.instance.playSuccess();
                                ReminderService.instance.toggleReminder(reminder.id);
                              },
                              onSnooze: () {
                                SoundEffectsService.instance.playClick();
                                ReminderService.instance.snoozeReminder(reminder.id);
                              },
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

  Widget _buildFilterButton({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.22) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : AppColors.border,
            width: isSelected ? 1.2 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : AppColors.deepBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? AppColors.neonCyan : AppColors.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final AtlantaReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onSnooze;

  const _ReminderItem({
    required this.reminder,
    required this.onToggle,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    return AtlantaCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderColor: reminder.isActive
          ? AppColors.neonCyan.withValues(alpha: 0.35)
          : AppColors.border.withValues(alpha: 0.4),
      glowColor: reminder.isActive ? AppColors.neonCyan : null,
      glowIntensity: reminder.isActive ? 0.08 : 0.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              reminder.isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.check_circle_rounded,
              color: reminder.isActive
                  ? AppColors.secondaryText
                  : AppColors.success,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    decoration: reminder.isActive
                        ? null
                        : TextDecoration.lineThrough,
                    color: reminder.isActive
                        ? AppColors.primaryWhite
                        : AppColors.mutedText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reminder.date}, ${reminder.time}',
                      style: AppTypography.monoSmall.copyWith(
                        color: AppColors.neonCyan,
                        fontSize: 10,
                      ),
                    ),
                    if (reminder.isSnoozed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '+15m',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (reminder.isActive)
            TextButton(
              onPressed: onSnooze,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                minimumSize: const Size(40, 26),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Snooze',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
