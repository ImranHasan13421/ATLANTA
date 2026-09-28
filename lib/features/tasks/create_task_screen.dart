import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_button.dart';
import '../../shared/widgets/atlanta_input.dart';
import '../../core/services/task_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Create / Edit Task screen.
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = 'medium';
  bool _reminderEnabled = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String dueDateStr = 'Today';
    if (_selectedDate != null) {
      final now = DateTime.now();
      if (_selectedDate!.year == now.year &&
          _selectedDate!.month == now.month &&
          _selectedDate!.day == now.day) {
        dueDateStr = 'Today';
      } else if (_selectedDate!.difference(now).inDays == 0 ||
          _selectedDate!.day == now.day + 1) {
        dueDateStr = 'Tomorrow';
      } else {
        dueDateStr = '${_selectedDate!.month}/${_selectedDate!.day}';
      }
      if (_selectedTime != null) {
        dueDateStr += ', ${_selectedTime!.format(context)}';
      }
    }

    TaskService.instance.addTask(
      title: title,
      description: _descController.text.trim(),
      dueDate: dueDateStr,
      priority: _priority,
    );

    if (_reminderEnabled) {
      ReminderService.instance.addReminder(
        title: title,
        time: _selectedTime != null ? _selectedTime!.format(context) : '10:00 AM',
        date: dueDateStr,
      );
    }

    SoundEffectsService.instance.playSuccess();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepBackground,
        title: Text('New Task', style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              SoundEffectsService.instance.playClick();
              context.push('/voice');
            },
            icon: const Icon(Icons.mic_rounded, size: 18, color: AppColors.neonCyan),
            label: const Text('Voice', style: TextStyle(color: AppColors.neonCyan)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            AtlantaTextField(
              controller: _titleController,
              label: 'Task Title',
              hint: 'What do you need to do?',
            ),
            const SizedBox(height: AppConstants.spacingXl),

            // Description
            AtlantaTextField(
              controller: _descController,
              label: 'Description (optional)',
              hint: 'Add details or notes...',
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            // Date
            Text(
              'Due Date',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primaryBlue,
                          surface: AppColors.secondaryBackground,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select due date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? AppColors.primaryWhite
                            : AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),

            // Priority
            Text(
              'Priority Level',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip('low', 'Low', AppColors.success),
                const SizedBox(width: 8),
                _buildPriorityChip('medium', 'Medium', AppColors.warning),
                const SizedBox(width: 8),
                _buildPriorityChip('high', 'High', AppColors.error),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXl),

            // Reminder toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reminder', style: AppTypography.bodyMedium),
                        Text(
                          'Get notified before due date',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _reminderEnabled,
                    activeThumbColor: AppColors.neonCyan,
                    onChanged: (v) => setState(() => _reminderEnabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingXxl),

            // ── Save button ──
            AtlantaButton(
              label: 'Save Task',
              onPressed: _saveTask,
              isExpanded: true,
              size: AtlantaButtonSize.large,
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // ── Voice / Assistant ──
            AtlantaButton(
              label: 'Speak Task to Atlanta',
              variant: AtlantaButtonVariant.secondary,
              icon: Icons.mic_rounded,
              onPressed: () {
                SoundEffectsService.instance.playClick();
                context.push('/voice');
              },
              isExpanded: true,
            ),
            const SizedBox(height: AppConstants.spacing3xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundEffectsService.instance.playClick();
          setState(() => _priority = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
