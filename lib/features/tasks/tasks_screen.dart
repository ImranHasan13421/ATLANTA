import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/atlanta_card.dart';
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
                                style: const TextStyle(
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
                                child: const Icon(Icons.mic_rounded, color: AppColors.neonCyan, size: 14),
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
                              gradient: const LinearGradient(
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
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.1,
                          ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(
                              title: task.title,
                              subtitle: task.description.isNotEmpty ? task.description : null,
                              dueDate: task.dueDate,
                              priority: task.priority,
                              isCompleted: task.isCompleted,
                              onToggle: () {
                                SoundEffectsService.instance.playSuccess();
                                TaskService.instance.toggleTask(task.id);
                              },
                              onTap: () {
                                SoundEffectsService.instance.playClick();
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
