import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/atlanta_input.dart';
import '../../shared/widgets/status_indicator.dart';
import '../../core/services/task_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Task Manager.
///
/// Complete live task management with search, filter, tabs, and reactive task cards.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AtlantaTask> _getFilteredTasks(List<AtlantaTask> allTasks) {
    List<AtlantaTask> base;
    switch (_tabController.index) {
      case 1: // Today
        base = allTasks
            .where((t) => !t.isCompleted && t.dueDate.toLowerCase().contains('today'))
            .toList();
        break;
      case 2: // Upcoming
        base = allTasks.where((t) => !t.isCompleted).toList();
        break;
      case 3: // Completed
        base = allTasks.where((t) => t.isCompleted).toList();
        break;
      default: // All
        base = allTasks;
    }

    if (_searchQuery.isNotEmpty) {
      return base
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery) ||
              t.description.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskService.instance,
      builder: (context, _) {
        final allTasks = TaskService.instance.tasks;
        final filteredTasks = _getFilteredTasks(allTasks);

        final filterCategories = [
          ('All Tasks', allTasks.length, Icons.list_alt_rounded),
          ('Today', TaskService.instance.todayTasks.length, Icons.today_rounded),
          ('Upcoming', TaskService.instance.upcomingTasks.length, Icons.calendar_month_rounded),
          ('Completed', TaskService.instance.completedCount, Icons.check_circle_outline_rounded),
        ];

        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ═══ LEFT PANEL: Filters, Search & Add Task ═══
                Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground.withValues(alpha: 0.6),
                    border: Border(
                      right: BorderSide(
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Text('My Tasks', style: AppTypography.headlineSmall.copyWith(fontSize: 16)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${TaskService.instance.pendingCount}',
                                style: TextStyle(
                                  color: AppColors.neonCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                context.push('/voice');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                                ),
                                child: Icon(Icons.mic_rounded, color: AppColors.neonCyan, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Search
                        AtlantaSearchField(
                          controller: _searchController,
                          hint: 'Search tasks...',
                        ),
                        const SizedBox(height: 10),

                        // Filter categories
                        Text(
                          'FILTER BY',
                          style: AppTypography.monoSmall.copyWith(
                            fontSize: 8,
                            color: AppColors.mutedText,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        ...List.generate(filterCategories.length, (index) {
                          final (label, count, icon) = filterCategories[index];
                          final isSelected = _tabController.index == index;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: GestureDetector(
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                setState(() {
                                  _tabController.index = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(alpha: 0.25)
                                      : AppColors.cardSurface.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.neonCyan
                                        : AppColors.border.withValues(alpha: 0.6),
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
                                  children: [
                                    Icon(
                                      icon,
                                      size: 14,
                                      color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected ? AppColors.primaryWhite : AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.neonCyan.withValues(alpha: 0.2)
                                            : Colors.black.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.neonCyan : AppColors.mutedText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const Spacer(),

                        // "+ Add Task" Button
                        GestureDetector(
                          onTap: () {
                            SoundEffectsService.instance.playClick();
                            context.push('/tasks/create');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.neonCyan, AppColors.primaryBlue],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'New Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══ RIGHT PANEL: Tasks Grid / List ═══
                Expanded(
                  child: filteredTasks.isEmpty
                      ? Center(
                          child: EmptyState(
                            icon: Icons.task_alt_rounded,
                            title: 'No tasks found',
                            subtitle: _tabController.index == 3
                                ? 'No completed tasks yet.'
                                : 'Tap + New Task or speak to Atlanta to add objectives.',
                            action: ElevatedButton(
                              onPressed: () => context.push('/tasks/create'),
                              child: const Text('Create Task'),
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 550;
                            if (isWide) {
                              final col1 = <AtlantaTask>[];
                              final col2 = <AtlantaTask>[];
                              for (var i = 0; i < filteredTasks.length; i++) {
                                if (i.isEven) {
                                  col1.add(filteredTasks[i]);
                                } else {
                                  col2.add(filteredTasks[i]);
                                }
                              }

                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: col1
                                            .map((t) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: _DynamicTaskCard(
                                                    task: t,
                                                    onToggle: () {
                                                      SoundEffectsService.instance.playSuccess();
                                                      TaskService.instance.toggleTask(t.id);
                                                    },
                                                    onDelete: () {
                                                      SoundEffectsService.instance.playClick();
                                                      TaskService.instance.deleteTask(t.id);
                                                    },
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        children: col2
                                            .map((t) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: _DynamicTaskCard(
                                                    task: t,
                                                    onToggle: () {
                                                      SoundEffectsService.instance.playSuccess();
                                                      TaskService.instance.toggleTask(t.id);
                                                    },
                                                    onDelete: () {
                                                      SoundEffectsService.instance.playClick();
                                                      TaskService.instance.deleteTask(t.id);
                                                    },
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredTasks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return _DynamicTaskCard(
                                  task: task,
                                  onToggle: () {
                                    SoundEffectsService.instance.playSuccess();
                                    TaskService.instance.toggleTask(task.id);
                                  },
                                  onDelete: () {
                                    SoundEffectsService.instance.playClick();
                                    TaskService.instance.deleteTask(task.id);
                                  },
                                );
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
}

/// Dynamic-height cyberpunk task card adapting perfectly to task text length with neon status accents.
class _DynamicTaskCard extends StatelessWidget {
  final AtlantaTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _DynamicTaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Pending: Neon Red (#FF2A6D), Upcoming: Neon Blue (#00E5FF), Completed: Neon Green (#00E676)
    final Color neonColor;
    final String statusLabel;
    final IconData statusIcon;

    if (task.isCompleted) {
      neonColor = const Color(0xFF00E676); // Neon Green
      statusLabel = 'COMPLETED';
      statusIcon = Icons.check_circle_rounded;
    } else if (!task.dueDate.toLowerCase().contains('today')) {
      neonColor = const Color(0xFF00E5FF); // Neon Blue
      statusLabel = 'UPCOMING';
      statusIcon = Icons.schedule_rounded;
    } else {
      neonColor = const Color(0xFFFF2A6D); // Neon Red
      statusLabel = 'PENDING';
      statusIcon = Icons.priority_high_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: neonColor.withValues(alpha: task.isCompleted ? 0.35 : 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: neonColor.withValues(alpha: task.isCompleted ? 0.08 : 0.20),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            SoundEffectsService.instance.playClick();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom check circle
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? neonColor.withValues(alpha: 0.25)
                          : Colors.transparent,
                      border: Border.all(
                        color: neonColor,
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: neonColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: task.isCompleted
                        ? Icon(Icons.check, size: 13, color: neonColor)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Dynamic text body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header row with status badge & priority & due date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: neonColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: neonColor.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 9.5, color: neonColor),
                                const SizedBox(width: 3),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: neonColor,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (task.priority.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const Spacer(),
                          // Due Date
                          if (task.dueDate.isNotEmpty) ...[
                            const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.mutedText),
                            const SizedBox(width: 4),
                            Text(
                              task.dueDate,
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title (Dynamic height, wraps fully)
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted ? AppColors.mutedText : AppColors.primaryWhite,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          height: 1.25,
                        ),
                      ),

                      // Description (Only if present, dynamic height)
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: task.isCompleted
                                ? AppColors.mutedText.withValues(alpha: 0.7)
                                : AppColors.secondaryText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Delete quick button
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: AppColors.mutedText.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
