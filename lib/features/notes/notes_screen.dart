import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_input.dart';
import '../../shared/widgets/atlanta_card.dart';
import '../../core/services/note_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta Notes / Notepad — Google Keep-style live notepad.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NoteService.instance,
      builder: (context, _) {
        var notes = NoteService.instance.notes;
        if (_searchQuery.isNotEmpty) {
          notes = notes
              .where((n) =>
                  n.title.toLowerCase().contains(_searchQuery) ||
                  n.content.toLowerCase().contains(_searchQuery) ||
                  n.category.toLowerCase().contains(_searchQuery))
              .toList();
        }

        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ── LEFT: Search & Note Controls (230px) ──
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
                                Icons.note_alt_rounded,
                                color: AppColors.neonCyan,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NEURAL NOTES',
                                style: AppTypography.monoSmall.copyWith(
                                  color: AppColors.primaryWhite,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${notes.length}',
                                style: const TextStyle(
                                  color: AppColors.neonCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search
                        AtlantaSearchField(
                          controller: _searchController,
                          hint: 'Search notes...',
                        ),
                        const SizedBox(height: 12),

                        // + Create Note button
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SoundEffectsService.instance.playClick();
                              context.push('/notes/create');
                            },
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text(
                              'New Note',
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
                        const SizedBox(height: 8),

                        // Voice Dictate
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SoundEffectsService.instance.playClick();
                              context.push('/voice');
                            },
                            icon: const Icon(Icons.mic_rounded, size: 15, color: AppColors.neonCyan),
                            label: const Text(
                              'Voice Dictation',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.neonCyan.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Note Telemetry / Hint
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.deepBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Say "Take a note..." or swipe cards to delete.',
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

                // ── RIGHT: Notes Grid (2 columns) ──
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.note_alt_outlined,
                                size: 48,
                                color: AppColors.mutedText,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No notes found',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "New Note" or say "Take a note to Atlanta"',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
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
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return _buildNoteCard(notes[index]);
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

  Widget _buildNoteCard(AtlantaNote note) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) {
        SoundEffectsService.instance.playClick();
        NoteService.instance.deleteNote(note.id);
      },
      child: AtlantaCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Color(note.colorValue),
        borderColor: note.isPinned
            ? AppColors.neonCyan
            : AppColors.border.withValues(alpha: 0.5),
        glowColor: note.isPinned ? AppColors.neonCyan : null,
        glowIntensity: note.isPinned ? 0.12 : 0.04,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryWhite,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  icon: Icon(
                    note.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    size: 16,
                    color: note.isPinned
                        ? AppColors.neonCyan
                        : AppColors.secondaryText,
                  ),
                  onPressed: () {
                    SoundEffectsService.instance.playClick();
                    NoteService.instance.togglePin(note.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              note.content,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryText,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.deepBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    note.category,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${note.updatedAt.hour}:${note.updatedAt.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.monoSmall.copyWith(
                    color: AppColors.mutedText,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
