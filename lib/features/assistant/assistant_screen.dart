import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/status_indicator.dart';
import '../../core/services/brain_service.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/sound_effects_service.dart';

/// Atlanta AI Assistant / Chat Screen — live conversational interface.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isProcessing = false;
  bool _voiceReadout = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      isUser: false,
      text: 'Hello Boss! Its Atlanta at your service. All neural telemetry systems are online. How may I assist you today?',
      time: '09:00 AM',
    ),
  ];

  final List<String> _quickSuggestions = [
    'What are my tasks today?',
    'Turn on Living Room Lights',
    'Take a note: Project Atlanta v2',
    'Run system diagnostics',
    'Weather forecast',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    SoundEffectsService.instance.playClick();

    setState(() {
      _messages.add(_ChatMessage(
        isUser: true,
        text: text,
        time: _formatTime(DateTime.now()),
      ));
      _isProcessing = true;
    });

    if (presetText == null) {
      _messageController.clear();
    }
    _scrollToBottom();

    // Extract past conversation history for multi-turn Gemini reasoning
    final history = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'content': m.text,
            })
        .toList();

    // Call live Atlanta Brain with Cloud Gemini AI
    final result = await BrainService.instance.processCommand(
      text,
      speakResponse: false,
      conversationHistory: history,
    );

    if (!mounted) return;

    _MessageCard? card;
    if (result.intentType == 'task') {
      card = _MessageCard(
        type: 'task',
        title: 'Task Created',
        subtitle: result.displayText,
        icon: Icons.task_alt_rounded,
      );
    } else if (result.intentType == 'note') {
      card = _MessageCard(
        type: 'note',
        title: 'Note Recorded',
        subtitle: result.displayText,
        icon: Icons.note_alt_rounded,
      );
    } else if (result.intentType == 'reminder') {
      card = _MessageCard(
        type: 'reminder',
        title: 'Reminder Active',
        subtitle: result.displayText,
        icon: Icons.alarm_rounded,
      );
    } else if (result.intentType == 'device') {
      card = _MessageCard(
        type: 'device',
        title: 'Telemetry Grid Updated',
        subtitle: result.displayText,
        icon: Icons.bolt_rounded,
      );
    }

    setState(() {
      _isProcessing = false;
      _messages.add(_ChatMessage(
        isUser: false,
        text: result.speechResponse,
        time: _formatTime(DateTime.now()),
        card: card,
      ));
    });

    if (_voiceReadout) {
      VoiceService.instance.speak(result.speechResponse);
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: SafeArea(
        child: Row(
          children: [
            // ═══ LEFT PANEL: Controls & Quick Prompts ═══
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [AppColors.neonCyan, AppColors.primaryBlue],
                            ),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Atlanta Core', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                              const StatusIndicator(
                                label: 'Online & Synced',
                                status: StatusType.online,
                                dotSize: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: AppColors.border, height: 1),

                  // Actions row (Voice Readout & Voice Screen)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              SoundEffectsService.instance.playClick();
                              setState(() => _voiceReadout = !_voiceReadout);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: _voiceReadout
                                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                                    : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _voiceReadout ? AppColors.neonCyan : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _voiceReadout ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                    color: _voiceReadout ? AppColors.neonCyan : AppColors.secondaryText,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _voiceReadout ? 'Voice: ON' : 'Voice: OFF',
                                    style: TextStyle(
                                      color: _voiceReadout ? AppColors.neonCyan : AppColors.secondaryText,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            SoundEffectsService.instance.playClick();
                            context.push('/voice');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue.withValues(alpha: 0.15),
                              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                            ),
                            child: Icon(Icons.mic_rounded, color: AppColors.neonCyan, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section Title: Quick Prompts
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 4),
                    child: Text(
                      'NEURAL PROMPTS',
                      style: AppTypography.monoSmall.copyWith(
                        fontSize: 8.5,
                        color: AppColors.mutedText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Vertically Stacked Suggestions
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      itemCount: _quickSuggestions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final sug = _quickSuggestions[index];
                        return GestureDetector(
                          onTap: () => _sendMessage(sug),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_right_rounded, color: AppColors.neonCyan, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    sug,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.secondaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ═══ RIGHT PANEL: Messages Feed & Input Bar ═══
            Expanded(
              child: Column(
                children: [
                  // Messages Feed
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _MessageBubble(message: message);
                      },
                    ),
                  ),

                  // Processing Indicator
                  if (_isProcessing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.neonCyan,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Atlanta is formulating response...',
                            style: AppTypography.monoSmall.copyWith(
                              color: AppColors.neonCyan,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Compact Input bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryBackground,
                      border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(),
                              style: const TextStyle(
                                color: AppColors.primaryWhite,
                                fontSize: 12,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Type command or message to Atlanta...',
                                hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 12),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _sendMessage(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.neonCyan, AppColors.primaryBlue],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──

class _ChatMessage {
  final bool isUser;
  final String text;
  final String time;
  final _MessageCard? card;

  const _ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.card,
  });
}

class _MessageCard {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;

  const _MessageCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// ── Message Bubble ──

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble();
    }
    return _buildAtlantaBubble();
  }

  Widget _buildUserBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.time,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.mutedText,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingMd,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, const Color(0xFF1E5BB0)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtlantaBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/atlanta_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                    vertical: AppConstants.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface.withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.06),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      if (message.card != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                message.card!.icon,
                                color: AppColors.neonCyan,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.card!.title,
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.neonCyan,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      message.card!.subtitle,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primaryWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      message.time,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        SoundEffectsService.instance.playClick();
                        VoiceService.instance.speak(message.text);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            size: 13,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Speak',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
