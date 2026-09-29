import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_card.dart';

/// Atlanta Calendar screen (placeholder for V1).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: SafeArea(
        child: Row(
          children: [
            // ── LEFT: Date & Calendar Panel (230px) ──
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.neonCyan,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'NEURAL CALENDAR',
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

                  // Today card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.deepBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${DateTime.now().day}',
                                style: AppTypography.headlineSmall.copyWith(
                                  color: AppColors.neonCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _monthName(DateTime.now().month),
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today',
                                style: TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _dayName(DateTime.now().weekday),
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Quick hint
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.deepBackground.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Synced with Google Calendar & Outlook Neural Hub.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── RIGHT: Events Grid ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPCOMING EVENTS',
                      style: AppTypography.monoSmall.copyWith(
                        color: AppColors.neonCyan,
                        fontSize: 9.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _EventCard(
                            title: 'Project Meeting',
                            time: '3:00 PM — 4:00 PM',
                            date: 'Friday',
                            location: 'Conference Room A',
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EventCard(
                            title: 'Team Standup',
                            time: '9:00 AM — 9:30 AM',
                            date: 'Tomorrow',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _EventCard(
                            title: 'Code Review Session',
                            time: '2:00 PM — 3:00 PM',
                            date: 'Wed',
                            location: 'Online — Zoom',
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EventCard(
                            title: 'Sprint Retrospective',
                            time: '10:00 AM — 11:00 AM',
                            date: 'Yesterday',
                            color: AppColors.mutedText,
                            isPast: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return months[month - 1];
  }

  String _dayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[weekday - 1];
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final String? location;
  final Color color;
  final bool isPast;

  const _EventCard({
    required this.title,
    required this.time,
    required this.date,
    this.location,
    required this.color,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    return AtlantaCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: isPast ? AppColors.mutedText : AppColors.primaryWhite,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 13, color: AppColors.secondaryText),
                    const SizedBox(width: 4),
                    Text(
                      '$date • $time',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 13, color: AppColors.secondaryText),
                      const SizedBox(width: 4),
                      Text(location!, style: AppTypography.bodySmall),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
