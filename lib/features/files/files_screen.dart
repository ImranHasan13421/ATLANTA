import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_card.dart';
import '../../shared/widgets/atlanta_input.dart';

/// Atlanta Files screen.
class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepBackground,
        title: Text('My Files', style: AppTypography.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AtlantaSearchField(hint: 'Search files...'),
            const SizedBox(height: AppConstants.spacingXl),

            // Categories
            Text(
              'CATEGORIES',
              style: AppTypography.labelSmall.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Wrap(
              spacing: AppConstants.spacingMd,
              runSpacing: AppConstants.spacingMd,
              children: const [
                _FolderChip(
                  icon: Icons.description_rounded,
                  label: 'Documents',
                  count: 24,
                  status: 'Allowed',
                ),
                _FolderChip(
                  icon: Icons.download_rounded,
                  label: 'Downloads',
                  count: 15,
                  status: 'Allowed',
                ),
                _FolderChip(
                  icon: Icons.image_rounded,
                  label: 'Pictures',
                  count: 156,
                  status: 'Allowed',
                ),
                _FolderChip(
                  icon: Icons.code_rounded,
                  label: 'Projects',
                  count: 8,
                  status: 'Allowed',
                ),
                _FolderChip(
                  icon: Icons.video_library_rounded,
                  label: 'Videos',
                  count: 32,
                  status: 'Allowed',
                ),
                _FolderChip(
                  icon: Icons.music_note_rounded,
                  label: 'Music',
                  count: 48,
                  status: 'Allowed',
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXxl),

            // Recent files
            Text('Recent Files', style: AppTypography.headlineSmall),
            const SizedBox(height: AppConstants.spacingLg),

            _FileItem(
              icon: Icons.picture_as_pdf_rounded,
              name: 'Project_Report_Final.pdf',
              type: 'PDF',
              date: 'Today, 2:30 PM',
              size: '2.4 MB',
              color: AppColors.error,
            ),
            _FileItem(
              icon: Icons.code_rounded,
              name: 'main.dart',
              type: 'Dart',
              date: 'Today, 11:00 AM',
              size: '12 KB',
              color: AppColors.primaryBlue,
            ),
            _FileItem(
              icon: Icons.image_rounded,
              name: 'screenshot_atlanta.png',
              type: 'Image',
              date: 'Yesterday',
              size: '340 KB',
              color: AppColors.success,
            ),
            _FileItem(
              icon: Icons.description_rounded,
              name: 'Meeting_Notes.docx',
              type: 'Document',
              date: 'Sep 26',
              size: '56 KB',
              color: AppColors.info,
            ),
            _FileItem(
              icon: Icons.table_chart_rounded,
              name: 'Budget_Q4.xlsx',
              type: 'Spreadsheet',
              date: 'Sep 25',
              size: '128 KB',
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String status;

  const _FolderChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AtlantaCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(fontSize: 13),
              ),
              Text(
                '$count files • $status',
                style: AppTypography.labelSmall.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FileItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String type;
  final String date;
  final String size;
  final Color color;

  const _FileItem({
    required this.icon,
    required this.name,
    required this.type,
    required this.date,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$type • $size • $date',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.more_vert_rounded,
            color: AppColors.mutedText,
            size: 20,
          ),
        ],
      ),
    );
  }
}
