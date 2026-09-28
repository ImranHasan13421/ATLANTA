import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/atlanta_button.dart';
import '../../core/services/note_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Create / Edit Note screen.
class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  Color _selectedColor = const Color(0xFF1A2840);
  bool _isPinned = false;
  String _category = 'General';

  static const List<Color> _colorOptions = [
    Color(0xFF111C2B), // Dark Navy
    Color(0xFF1A2840), // Steel Blue
    Color(0xFF172D24), // Cyber Emerald
    Color(0xFF281D3B), // Tech Purple
    Color(0xFF332014), // Amber Ochre
    Color(0xFF2B141E), // Crimson Dark
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note cannot be completely empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    NoteService.instance.addNote(
      title: title.isEmpty ? 'Untitled Memo' : title,
      content: body,
      category: _category,
      colorValue: _selectedColor.toARGB32(),
      isPinned: _isPinned,
    );

    SoundEffectsService.instance.playSuccess();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepBackground,
        title: Text('New Note', style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned
                  ? AppColors.neonCyan
                  : AppColors.secondaryText,
            ),
            onPressed: () {
              SoundEffectsService.instance.playClick();
              setState(() => _isPinned = !_isPinned);
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.neonCyan),
            onPressed: () {
              SoundEffectsService.instance.playClick();
              context.push('/voice');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primaryWhite,
              ),
              decoration: InputDecoration(
                hintText: 'Note title',
                hintStyle: AppTypography.headlineMedium.copyWith(
                  color: AppColors.mutedText,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['General', 'Project', 'Ideas', 'Personal', 'Work']
                    .map((cat) {
                  final isSel = _category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      selectedColor: AppColors.primaryBlue.withValues(alpha: 0.25),
                      backgroundColor: AppColors.cardSurface,
                      side: BorderSide(
                        color: isSel ? AppColors.neonCyan : AppColors.border,
                      ),
                      onSelected: (_) {
                        SoundEffectsService.instance.playClick();
                        setState(() => _category = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Body
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _bodyController,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primaryWhite,
                  height: 1.5,
                ),
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Start writing or dictating your note...',
                  hintStyle: TextStyle(color: AppColors.mutedText),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXxl),

            // Color picker
            Text(
              'Color Tag',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    SoundEffectsService.instance.playClick();
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.neonCyan : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spacingXxl),

            // Save Button
            AtlantaButton(
              label: 'Save Note',
              onPressed: _saveNote,
              isExpanded: true,
              size: AtlantaButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
