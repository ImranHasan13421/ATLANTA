import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/atlanta_orb.dart';
import '../../shared/widgets/atlanta_hud.dart';
import '../../shared/widgets/atlanta_waveform.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/sound_effects_service.dart';
import '../../core/services/brain_service.dart';

/// Atlanta Live Voice Mode — immersive Iron Man / Stark-grade AI voice assistant.
class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  OrbState _orbState = OrbState.idle;
  String _transcription = '';
  String _response = '';
  double _soundLevel = 0.0;
  bool _isProcessing = false;
  final TextEditingController _commandInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickCommands = [
    'Open clock',
    'Set alarm for 9:00 p.m. today',
    'Open camera',
    'Open YouTube',
    'Open settings',
    'Add task: Review final design deliverables',
    'Turn on Living Room Lights',
    'Take note: Quantum firewall port is 8080',
    'Atlanta, what is your system status?',
  ];

  @override
  void initState() {
    super.initState();
    _initVoiceSession();
  }

  Future<void> _initVoiceSession() async {
    await SoundEffectsService.instance.initialize();
    await VoiceService.instance.initialize();
    await SpeechService.instance.initialize();

    // Play wake chime on entry
    await SoundEffectsService.instance.playWake();

    // Listen to TTS speaking changes
    VoiceService.instance.addListener(_handleVoiceStateChange);
  }

  void _handleVoiceStateChange() {
    if (!mounted) return;
    if (VoiceService.instance.isSpeaking) {
      if (_orbState != OrbState.speaking) {
        setState(() => _orbState = OrbState.speaking);
      }
    } else {
      if (_orbState == OrbState.speaking) {
        setState(() => _orbState = OrbState.success);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _orbState == OrbState.success) {
            setState(() => _orbState = OrbState.idle);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    VoiceService.instance.removeListener(_handleVoiceStateChange);
    SpeechService.instance.stopListening();
    _commandInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isProcessing) return;

    await SoundEffectsService.instance.playListeningChirp();

    setState(() {
      _orbState = OrbState.listening;
      _transcription = '';
      _response = '';
      _soundLevel = 0.0;
    });

    await SpeechService.instance.startListening(
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          _transcription = words;
        });

        if (isFinal && words.trim().isNotEmpty) {
          _submitVoiceCommand(words);
        }
      },
      onSoundLevel: (level) {
        if (!mounted) return;
        setState(() {
          _soundLevel = level;
        });
      },
    );
  }

  Future<void> _stopListeningAndProcess() async {
    await SpeechService.instance.stopListening();

    if (_transcription.trim().isNotEmpty) {
      _submitVoiceCommand(_transcription);
    } else {
      setState(() => _orbState = OrbState.idle);
    }
  }

  Future<void> _submitVoiceCommand(String command) async {
    if (_isProcessing || command.trim().isEmpty) return;

    await SpeechService.instance.stopListening();

    setState(() {
      _isProcessing = true;
      _orbState = OrbState.thinking;
    });

    await SoundEffectsService.instance.playScanning();

    // Process natural language command in Atlanta Brain
    final result = await BrainService.instance.processCommand(command, speakResponse: true);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _response = result.displayText;
      _orbState = result.isSuccess ? OrbState.speaking : OrbState.error;
    });

    // Auto-scroll down smoothly so response card is immediately visible
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTextInputDialog() {
    _commandInputController.clear();
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
              Row(
                children: [
                  const Icon(Icons.keyboard_command_key_rounded,
                      color: AppColors.neonCyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Direct Command Input',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _commandInputController,
                autofocus: true,
                style: const TextStyle(color: AppColors.primaryWhite),
                decoration: InputDecoration(
                  hintText: 'e.g. Open clock, Set alarm for 9pm, Add task...',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neonCyan),
                  ),
                ),
                onSubmitted: (text) {
                  Navigator.pop(ctx);
                  if (text.trim().isNotEmpty) {
                    setState(() => _transcription = text);
                    _submitVoiceCommand(text);
                  }
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = _commandInputController.text;
                    Navigator.pop(ctx);
                    if (text.trim().isNotEmpty) {
                      setState(() => _transcription = text);
                      _submitVoiceCommand(text);
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Execute'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: AtlantaHudOverlay(
        showTelemetry: false,
        child: SafeArea(
          child: Row(
            children: [
              // ═══ LEFT PANEL: Close, Telemetry & Command Suggestions ═══
              Container(
                width: 210,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withValues(alpha: 0.5),
                  border: Border(
                    right: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText, size: 20),
                          onPressed: () {
                            SoundEffectsService.instance.playClick();
                            context.pop();
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'VOICE COMMANDS',
                          style: AppTypography.monoSmall.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 8.5,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick Commands Vertical List
                    Expanded(
                      child: ListView.separated(
                        itemCount: _quickCommands.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final cmd = _quickCommands[index];
                          return GestureDetector(
                            onTap: () {
                              SoundEffectsService.instance.playClick();
                              setState(() => _transcription = cmd);
                              _submitVoiceCommand(cmd);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                cmd,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: AppColors.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ═══ CENTER PANEL: Orb, Waveform, Transcript & Controls ═══
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Column(
                    children: [
                      // Top Mode Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _orbState == OrbState.listening
                                    ? AppColors.neonCyan
                                    : (_orbState == OrbState.speaking
                                        ? AppColors.primaryBlue
                                        : AppColors.success),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _orbState == OrbState.listening
                                  ? 'LISTENING'
                                  : (_orbState == OrbState.thinking
                                      ? 'PROCESSING'
                                      : (_orbState == OrbState.speaking
                                          ? 'SYNTHESIZING'
                                          : 'SYSTEM ACTIVE')),
                              style: AppTypography.monoMedium.copyWith(
                                fontSize: 9,
                                letterSpacing: 1.2,
                                color: AppColors.primaryWhite,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Orb & Waveform (Compact)
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  if (_orbState == OrbState.idle) {
                                    _startListening();
                                  } else if (_orbState == OrbState.listening) {
                                    _stopListeningAndProcess();
                                  } else if (_orbState == OrbState.speaking) {
                                    VoiceService.instance.stop();
                                  }
                                },
                                child: AtlantaOrb(
                                  size: (_transcription.isNotEmpty || _response.isNotEmpty) ? 75 : 95,
                                  state: _orbState,
                                  showLabel: false,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Live Waveform
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: AtlantaWaveform(
                                  isListening: _orbState == OrbState.listening,
                                  isSpeaking: _orbState == OrbState.speaking,
                                  soundLevel: _soundLevel,
                                  height: 24,
                                  barCount: 22,
                                  primaryColor: AppColors.neonCyan,
                                  secondaryColor: AppColors.primaryBlue,
                                ),
                              ),

                              // Live Transcript Card
                              if (_transcription.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurface.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'LIVE TRANSCRIPT',
                                        style: AppTypography.monoSmall.copyWith(
                                          color: AppColors.neonCyan,
                                          fontSize: 8,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '"$_transcription"',
                                        style: const TextStyle(
                                          color: AppColors.primaryWhite,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Response Card
                              if (_response.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.asset('assets/images/atlanta_logo.png', width: 20, height: 20, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _response,
                                          style: const TextStyle(
                                            color: AppColors.primaryWhite,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Bottom Voice Controls
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Audio Toggle
                            _ControlCircle(
                              icon: VoiceService.instance.isSpeaking
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              label: 'Audio',
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                if (VoiceService.instance.isSpeaking) {
                                  VoiceService.instance.stop();
                                }
                              },
                            ),
                            const SizedBox(width: 24),

                            // Central Big Mic Button
                            _ControlCircle(
                              icon: _orbState == OrbState.listening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              label: _orbState == OrbState.listening
                                  ? 'Finish'
                                  : (_orbState == OrbState.thinking ? 'Busy' : 'Speak'),
                              isPrimary: true,
                              color: _orbState == OrbState.listening
                                  ? AppColors.error
                                  : AppColors.primaryBlue,
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                if (_orbState == OrbState.listening) {
                                  _stopListeningAndProcess();
                                } else {
                                  _startListening();
                                }
                              },
                            ),
                            const SizedBox(width: 24),

                            // Reset Session
                            _ControlCircle(
                              icon: Icons.refresh_rounded,
                              label: 'Reset',
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                VoiceService.instance.stop();
                                SpeechService.instance.stopListening();
                                setState(() {
                                  _orbState = OrbState.idle;
                                  _transcription = '';
                                  _response = '';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ═══ RIGHT PANEL: Hardware Telemetry & Keyboard Input ═══
              Container(
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withValues(alpha: 0.5),
                  border: Border(
                    left: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HARDWARE',
                          style: AppTypography.monoSmall.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 8.5,
                            letterSpacing: 1.2,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.keyboard_rounded, color: AppColors.secondaryText, size: 18),
                          tooltip: 'Type command',
                          onPressed: () {
                            SoundEffectsService.instance.playClick();
                            _showTextInputDialog();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _TelemetryStat(label: 'LATENCY', value: '14 MS'),
                    const SizedBox(height: 6),
                    _TelemetryStat(label: 'NEURAL NET', value: 'ACTIVE'),
                    const SizedBox(height: 6),
                    _TelemetryStat(label: 'QUANTUM CORE', value: '99.8%'),
                    const SizedBox(height: 6),
                    _TelemetryStat(label: 'AUDIO ENGINE', value: 'STEREO'),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'ATLANTA OS v2.0\nVOICE ENGINE ACTIVE',
                        style: AppTypography.monoSmall.copyWith(fontSize: 7, color: AppColors.mutedText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelemetryStat extends StatelessWidget {
  final String label;
  final String value;
  const _TelemetryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 7.5, color: AppColors.mutedText, letterSpacing: 0.8),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 9.5, color: AppColors.neonCyan, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ControlCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isPrimary;

  const _ControlCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primaryBlue,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isPrimary ? 64.0 : 46.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? color : AppColors.cardSurface,
              border: Border.all(
                color: isPrimary
                    ? color.withValues(alpha: 0.8)
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.secondaryText,
              size: isPrimary ? 30 : 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.secondaryText,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
