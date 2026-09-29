import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/gemini_ai_service.dart';
import '../../core/services/notification_settings_service.dart';
import '../../core/services/native_device_service.dart';
import '../../core/services/sound_effects_service.dart';
import '../../core/services/ota_update_service.dart';
import '../../shared/widgets/atlanta_card.dart';

/// Atlanta Settings screen — fully functional Cyber Control Center.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedCategoryIndex = 0; // Default to 'Account' as requested

  static const List<Map<String, dynamic>> _categories = [
    {'title': 'Account', 'icon': Icons.person_outline_rounded},
    {'title': 'Atlanta AI', 'icon': Icons.psychology_rounded},
    {'title': 'Voice', 'icon': Icons.mic_rounded},
    {'title': 'Notifications', 'icon': Icons.notifications_none_rounded},
    {'title': 'Appearance', 'icon': Icons.palette_outlined},
    {'title': 'Security', 'icon': Icons.security_rounded},
    {'title': 'About', 'icon': Icons.info_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthService.instance,
        ThemeController.instance,
        GeminiAiService.instance,
        NotificationSettingsService.instance,
      ]),
      builder: (context, _) {
        final currentUser = AuthService.instance.currentUser;

        return Scaffold(
          backgroundColor: AppColors.deepBackground,
          body: SafeArea(
            child: Row(
              children: [
                // ── LEFT: Profile & Category Selector (230px) ──
                Container(
                  width: 230,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    border: Border(
                      right: BorderSide(
                        color: AppColors.neonCyan.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile mini card
                      InkWell(
                        onTap: () => setState(() => _selectedCategoryIndex = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: AppColors.neonCyan.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGlow,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    (currentUser?.name.isNotEmpty == true)
                                        ? currentUser!.name.substring(0, 1).toUpperCase()
                                        : 'A',
                                    style: TextStyle(
                                      color: AppColors.neonCyan,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUser?.name ?? 'Commander',
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      currentUser?.terminalNode ?? 'Primary Terminal',
                                      style: TextStyle(
                                        color: AppColors.neonCyan.withValues(alpha: 0.8),
                                        fontSize: 9.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: AppColors.border.withValues(alpha: 0.6), height: 1),
                      const SizedBox(height: 8),

                      // Categories list
                      Expanded(
                        child: ListView.separated(
                          itemCount: _categories.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = _selectedCategoryIndex == index;

                            return InkWell(
                              onTap: () {
                                SoundEffectsService.instance.playClick();
                                setState(() => _selectedCategoryIndex = index);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(alpha: 0.18)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.neonCyan.withValues(alpha: 0.5)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      size: 16,
                                      color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat['title'] as String,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

                // ── RIGHT: Selected Category Options ──
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: _buildSelectedCategoryContent(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildAccountSection();
      case 1:
        return _buildAtlantaAiSection();
      case 2:
        return _buildVoiceSection();
      case 3:
        return _buildNotificationsSection();
      case 4:
        return _buildAppearanceSection();
      case 5:
        return _buildSecuritySection();
      default:
        return _buildAboutSection();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 1. ACCOUNT SECTION & LOGOUT TERMINAL
  // ─────────────────────────────────────────────────────────────
  Widget _buildAccountSection() {
    final user = AuthService.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ACCOUNT & OPERATOR IDENTITY'),
        const SizedBox(height: AppConstants.spacingMd),
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.badge_outlined,
                title: 'Operator Call-sign',
                subtitle: user?.name ?? 'Commander',
                trailing: TextButton(
                  onPressed: _showEditProfileDialog,
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.email_outlined,
                title: 'Registered Security Email',
                subtitle: user?.email ?? 'imran@example.com',
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.memory_rounded,
                title: 'Hardware Terminal Node',
                subtitle: user?.terminalNode ?? 'Primary Terminal Alpha',
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.verified_user_outlined,
                title: 'Security Clearance Role',
                subtitle: user?.role ?? 'Terminal Commander',
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.logout_rounded,
                title: 'Logout Terminal',
                subtitle: 'Disconnect active session and return to secure sign-in terminal',
                titleColor: AppColors.error,
                trailing: ElevatedButton.icon(
                  onPressed: _confirmLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.15),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                  label: const Text('Logout Terminal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    final user = AuthService.instance.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final nodeCtrl = TextEditingController(text: user?.terminalNode ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        title: const Text('Update Operator Profile', style: TextStyle(fontSize: 16, color: AppColors.primaryWhite)),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.primaryWhite),
                decoration: const InputDecoration(labelText: 'Call-sign / Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nodeCtrl,
                style: const TextStyle(color: AppColors.primaryWhite),
                decoration: const InputDecoration(labelText: 'Terminal Node ID'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.instance.updateProfile(
                name: nameCtrl.text.trim(),
                terminalNode: nodeCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    SoundEffectsService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Disconnect Terminal Session?', style: TextStyle(color: AppColors.primaryWhite, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of Atlanta? All your local tasks and notes remain stored securely.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.logout();
              if (mounted) context.go('/login');
            },
            child: const Text('Confirm Logout'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. ATLANTA AI MODEL & NEURAL CONFIGURATION
  // ─────────────────────────────────────────────────────────────
  Widget _buildAtlantaAiSection() {
    final aiService = GeminiAiService.instance;
    final currentModel = aiService.currentModelInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('NEURAL AI & GEMINI CORE CONFIGURATION'),
        const SizedBox(height: AppConstants.spacingMd),
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Model Display & Selector
              _buildSettingRow(
                icon: Icons.psychology_rounded,
                title: 'Gemini Neural Model',
                subtitle: '${currentModel.name} • ${currentModel.speed}',
                trailing: ElevatedButton.icon(
                  onPressed: _showModelSelectionModal,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Switch Model', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.deepBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  currentModel.description,
                  style: TextStyle(color: AppColors.neonCyan.withValues(alpha: 0.9), fontSize: 11),
                ),
              ),
              const Divider(color: AppColors.border, height: 24),

              // Temperature Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune_rounded, size: 18, color: AppColors.secondaryText),
                      SizedBox(width: 10),
                      Text('Temperature / Creativity', style: TextStyle(color: AppColors.primaryWhite, fontSize: 13)),
                    ],
                  ),
                  Text(
                    aiService.temperature <= 0.3
                        ? '0.${(aiService.temperature * 10).toInt()} (Precise)'
                        : (aiService.temperature >= 0.8
                            ? '0.${(aiService.temperature * 10).toInt()} (Creative)'
                            : '0.${(aiService.temperature * 10).toInt()} (Balanced)'),
                    style: TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: aiService.temperature,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: AppColors.neonCyan,
                inactiveColor: AppColors.border,
                onChanged: (val) => aiService.setTemperature(val),
              ),
              const Divider(color: AppColors.border, height: 24),

              // Persona Style
              const Text('Persona Demeanor Style', style: TextStyle(color: AppColors.primaryWhite, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GeminiAiService.personaStyles.map((persona) {
                  final isSelected = aiService.personaStyle == persona;
                  return ChoiceChip(
                    label: Text(persona),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                    backgroundColor: AppColors.deepBackground,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    ),
                    side: BorderSide(color: isSelected ? AppColors.neonCyan : AppColors.border),
                    onSelected: (val) {
                      if (val) aiService.setPersonaStyle(persona);
                    },
                  );
                }).toList(),
              ),
              const Divider(color: AppColors.border, height: 24),

              // Custom API Key
              _buildSettingRow(
                icon: Icons.key_rounded,
                title: 'Google AI Studio API Key',
                subtitle: aiService.apiKey.isNotEmpty ? 'Custom/Environment Key Configured' : 'Using Default Core Key',
                trailing: TextButton(
                  onPressed: _showApiKeyDialog,
                  child: const Text('Configure Key', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showModelSelectionModal() {
    final aiService = GeminiAiService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.psychology_rounded, color: AppColors.neonCyan, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SELECT GEMINI AI MODEL',
                        style: TextStyle(
                          color: AppColors.primaryWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mutedText, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose the active Gemini model engine for conversational reasoning, commands, and tasks.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: GeminiAiService.availableModels.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final model = GeminiAiService.availableModels[index];
                    final isSelected = aiService.selectedModelId == model.id;

                    return InkWell(
                      onTap: () async {
                        SoundEffectsService.instance.playClick();
                        await aiService.setModel(model.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue.withValues(alpha: 0.15)
                              : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.neonCyan : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.neonCyan : AppColors.secondaryText,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.neonCyan,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        model.name,
                                        style: TextStyle(
                                          color: isSelected ? AppColors.neonCyan : AppColors.primaryWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: model.isPro
                                              ? Colors.purple.withValues(alpha: 0.2)
                                              : AppColors.success.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          model.speed,
                                          style: TextStyle(
                                            color: model.isPro ? Colors.purpleAccent : AppColors.success,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    model.description,
                                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 10.5),
                                  ),
                                ],
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
        );
      },
    );
  }

  void _showApiKeyDialog() {
    final aiService = GeminiAiService.instance;
    final keyCtrl = TextEditingController(text: aiService.apiKey);
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          title: const Text('Google AI Studio Key', style: TextStyle(color: AppColors.primaryWhite, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your Gemini API Key from Google AI Studio. Leave blank to use Atlanta built-in endpoint.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 11),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keyCtrl,
                obscureText: obscure,
                style: const TextStyle(color: AppColors.primaryWhite, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, size: 18),
                    onPressed: () => setDlgState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await aiService.updateApiKey(keyCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Key'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. VOICE SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildVoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('VOICE & AUDIO SYSTEMS'),
        const SizedBox(height: AppConstants.spacingMd),
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.mic_rounded,
                title: 'Microphone Input Engine',
                subtitle: 'Low-latency Hardware Audio Bridge Active',
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.hearing_rounded,
                title: 'Speech Recognition Mode',
                subtitle: 'Continuous & Push-To-Talk Multimodal',
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.record_voice_over_rounded,
                title: 'Voice Persona Synthesis',
                subtitle: 'Atlanta Futuristic Female Neural Voice',
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.campaign_rounded,
                title: 'Wake Command Phrase',
                subtitle: '"Hey Atlanta" or tap Central Orb',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. NOTIFICATIONS SETTINGS (FULLY FUNCTIONAL)
  // ─────────────────────────────────────────────────────────────
  Widget _buildNotificationsSection() {
    final notif = NotificationSettingsService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('NOTIFICATIONS & ALERT PROTOCOLS'),
        const SizedBox(height: AppConstants.spacingMd),
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.task_alt_rounded,
                title: 'Task & Objective Reminders',
                subtitle: 'Audible and visual alerts when scheduled tasks are due',
                trailing: Switch(
                  value: notif.taskReminders,
                  activeThumbColor: AppColors.neonCyan,
                  onChanged: (val) => notif.setTaskReminders(val),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.alarm_rounded,
                title: 'Scheduled Alarms',
                subtitle: 'System clock wake timers and morning briefing alarms',
                trailing: Switch(
                  value: notif.scheduledAlarms,
                  activeThumbColor: AppColors.neonCyan,
                  onChanged: (val) => notif.setScheduledAlarms(val),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.computer_rounded,
                title: 'System Telemetry Alerts',
                subtitle: 'Battery status, connected device links, and network health',
                trailing: Switch(
                  value: notif.systemTelemetry,
                  activeThumbColor: AppColors.neonCyan,
                  onChanged: (val) => notif.setSystemTelemetry(val),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.volume_up_rounded,
                title: 'Vocal Audio Feedback (TTS)',
                subtitle: 'Read status updates and responses out loud',
                trailing: Switch(
                  value: notif.voiceFeedback,
                  activeThumbColor: AppColors.neonCyan,
                  onChanged: (val) => notif.setVoiceFeedback(val),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.music_note_rounded,
                title: 'Cyber UI Sound Effects',
                subtitle: 'Tactile clicks, radar sweeps, and transition chimes',
                trailing: Switch(
                  value: notif.soundEffects,
                  activeThumbColor: AppColors.neonCyan,
                  onChanged: (val) => notif.setSoundEffects(val),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.do_not_disturb_on_rounded,
                title: 'Do Not Disturb Protocol',
                subtitle: 'Silence all non-critical notifications & auditory alerts',
                trailing: Switch(
                  value: notif.doNotDisturb,
                  activeThumbColor: AppColors.warning,
                  onChanged: (val) => notif.setDoNotDisturb(val),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. APPEARANCE (ACCENT COLORS: Red, Orange, Purple, Gold, Green, Gray)
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppearanceSection() {
    final themeCtrl = ThemeController.instance;

    final accentPresets = [
      (AtlantaAccent.red, 'Red', const Color(0xFFEF4444), 'Cyber Crimson'),
      (AtlantaAccent.orange, 'Orange', const Color(0xFFF97316), 'Solar Flare'),
      (AtlantaAccent.purple, 'Purple', const Color(0xFFA855F7), 'Neural Violet'),
      (AtlantaAccent.gold, 'Gold', const Color(0xFFEAB308), 'Imperial Gold'),
      (AtlantaAccent.green, 'Green', const Color(0xFF22C55E), 'Matrix Emerald'),
      (AtlantaAccent.gray, 'Gray', const Color(0xFF94A3B8), 'Stealth Slate'),
      (AtlantaAccent.blue, 'Blue', const Color(0xFF1D6FE8), 'Atlanta Cyan'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('VISUAL APPEARANCE & DYNAMIC ACCENT COLORS'),
        const SizedBox(height: 6),
        Text(
          'Select an accent preset below. The whole app theme color adapts instantly: glass tints, glow effects, borders, and animations.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText, fontSize: 11),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // Live Accent Swatches Grid
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_rounded, color: AppColors.neonCyan, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'APP ACCENT PALETTE',
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'ACTIVE: ${themeCtrl.currentPreset.label.toUpperCase()}',
                      style: TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Swatches Row
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: accentPresets.map((preset) {
                  final (accent, name, color, tag) = preset;
                  final isSelected = themeCtrl.currentAccent == accent;

                  return InkWell(
                    onTap: () {
                      SoundEffectsService.instance.playClick();
                      themeCtrl.setAccent(accent);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 105,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.16) : AppColors.deepBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: TextStyle(
                              color: isSelected ? color : AppColors.primaryWhite,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            tag,
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              // Live Preview Component Previewing Glass & Glow
              const Text(
                'LIVE GLOW & GLASS PREVIEW',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withValues(alpha: 0.25),
                        border: Border.all(color: AppColors.neonCyan),
                      ),
                      child: Icon(Icons.auto_awesome, color: AppColors.neonCyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Color: ${themeCtrl.currentPreset.label}',
                            style: const TextStyle(
                              color: AppColors.primaryWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All HUD cards, buttons, orbs, and neon lines are dynamically tinted.',
                            style: TextStyle(color: AppColors.neonCyan.withValues(alpha: 0.8), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => SoundEffectsService.instance.playClick(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.primaryWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Interactive Button', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 6. SECURITY & APPLICATION ACCESS PERMISSION REDIRECT
  // ─────────────────────────────────────────────────────────────
  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SECURITY & SYSTEM PERMISSIONS'),
        const SizedBox(height: AppConstants.spacingMd),
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.security_rounded,
                title: 'Application Access Permissions',
                subtitle: 'Open device system settings to inspect camera, mic, storage, & alarms',
                trailing: ElevatedButton.icon(
                  onPressed: () async {
                    SoundEffectsService.instance.playClick();
                    await NativeDeviceService.instance.openAppPermissions();
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open App Settings', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.shield_rounded,
                title: 'Hardware Query Permissions',
                subtitle: 'QUERY_ALL_PACKAGES active for universal app launching bridge',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('ACTIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.lock_outline_rounded,
                title: 'Local AES-256 Storage Encryption',
                subtitle: 'Private notes and user credentials are encrypted on-device',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('ENCRYPTED', style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 7. ABOUT (DETAILED VERSION, TERMS, PRIVACY POLICIES & DEVELOPER)
  // ─────────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ABOUT ATLANTA & LEGAL POLICIES'),
        const SizedBox(height: AppConstants.spacingMd),

        // ── DEVELOPER INFO CARD (MD. Imran Hasan) ──
        AtlantaCard(
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.neonCyan.withValues(alpha: 0.5),
          glowColor: AppColors.neonCyan,
          glowIntensity: 0.12,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.primaryBlue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'IH',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'MD. Imran Hasan',
                          style: TextStyle(
                            color: AppColors.primaryWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'LEAD DEVELOPER',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Creator of Atlanta AI Neural Core & Mobile Ecosystem',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // GitHub Logo Button
              ElevatedButton.icon(
                onPressed: () async {
                  SoundEffectsService.instance.playClick();
                  final url = Uri.parse('https://github.com/ImranHasan13421');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening https://github.com/ImranHasan13421')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24292E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.code_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'GitHub Profile',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        AtlantaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.info_outline_rounded,
                title: 'Version Detail Information',
                subtitle: 'v1.2.0 Cyber-Core • Flutter 3.41.7 • Multi-Mesh Architecture',
                trailing: ElevatedButton(
                  onPressed: _showVersionDetailDialog,
                  child: const Text('View Details', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.description_outlined,
                title: 'Terms of Neural Service',
                subtitle: 'Detailed operational rules, autonomous workflow terms, and access protocol',
                trailing: OutlinedButton(
                  onPressed: _showTermsDialog,
                  child: const Text('Read Terms', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy & Zero-Telemetry Charter',
                subtitle: 'Complete details on on-device data isolation, speech, and file privacy',
                trailing: OutlinedButton(
                  onPressed: _showPrivacyDialog,
                  child: const Text('Read Policy', style: TextStyle(fontSize: 11.5)),
                ),
              ),
              const Divider(color: AppColors.border, height: 20),
              _buildSettingRow(
                icon: Icons.system_update_rounded,
                title: 'In-App OTA Updates',
                subtitle: 'Check GitHub releases for latest APK payload and install directly',
                trailing: ElevatedButton.icon(
                  onPressed: () async {
                    SoundEffectsService.instance.playClick();
                    final hasUpdate = await OtaUpdateService.instance.checkForUpdates(isAutomatic: false);
                    if (!mounted) return;
                    if (hasUpdate) {
                      OtaUpdateService.instance.promptUpdateDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Atlanta Core is up to date (v1.2.0).'),
                          backgroundColor: AppColors.cardSurface,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Check Updates', style: TextStyle(fontSize: 11.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVersionDetailDialog() {
    SoundEffectsService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.4)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.terminal_rounded, color: AppColors.neonCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'ATLANTA SYSTEM DIAGNOSTIC INFO',
                        style: TextStyle(color: AppColors.primaryWhite, fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                _aboutDetailRow('System Version', 'v1.2.0 (Build 2026.09.29-PROD)'),
                _aboutDetailRow('Runtime Engine', 'Flutter 3.41.7 • Dart 3.11.5'),
                _aboutDetailRow('Neural Engine', 'Google AI Studio Gemini Multimodal Mesh'),
                _aboutDetailRow('Security Encryption', 'AES-256 GCM Hardware-Protected Keystore'),
                _aboutDetailRow('Active Client Node', 'Android 14 / Windows 11 Bridge Core'),
                _aboutDetailRow('Architecture', 'Event-Driven Reactive Provider & BLoC Pipeline'),
                _aboutDetailRow('Release Focus', 'Dynamic Accent Theming, Mobile Node File Explorer, Full Settings & Auth'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsDialog() {
    SoundEffectsService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.4)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TERMS OF NEURAL SERVICE', style: TextStyle(color: AppColors.primaryWhite, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mutedText, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    '1. ACCEPTANCE OF TERMS\n'
                    'By initializing, connecting to, or executing commands through the Atlanta AI Assistant ("System"), the operator agrees to be bound by these Terms of Neural Service. If you do not accept these terms, disconnect immediately.\n\n'
                    '2. AUTONOMOUS & AI COMMAND EXECUTION\n'
                    'Atlanta operates on multimodal cloud neural models provided by Google Gemini and local hardware bridges. While Atlanta strives for precision, AI-generated outputs, automated device controls, and summaries must be reviewed by the operator before taking high-risk actions.\n\n'
                    '3. DEVICE ACCESS & PERMISSIONS\n'
                    'Atlanta requires explicit permissions to query local applications, browse authorized internal storage directories, and interface with system audio. The operator retains full control over which permissions are granted via the system settings.\n\n'
                    '4. CLOUD API & DATA USAGE\n'
                    'Queries processed via Google AI Studio Gemini models adhere to enterprise privacy standards. No user queries or personal files are used to train public foundation models without explicit operator consent.\n\n'
                    '5. TERMINATION & SESSION PURGE\n'
                    'The operator may disconnect their terminal at any time using the "Logout Terminal" feature, which permanently unlinks active tokens from the device.',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 11.5, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Acknowledge & Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    SoundEffectsService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.4)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PRIVACY POLICY & DATA CHARTER', style: TextStyle(color: AppColors.primaryWhite, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mutedText, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    '1. LOCAL-FIRST PRIVACY PRINCIPLE\n'
                    'Atlanta is engineered from the ground up on a local-first paradigm. Your notes, tasks, alarms, and device configuration stay stored locally on your device in encrypted storage.\n\n'
                    '2. FILE & STORAGE EXPLORATION INTEGRITY\n'
                    'When browsing Mobile Node internal storage files, Atlanta operates in read-only telemetry mode. No file content is ever uploaded, indexed, or shared with third parties without direct, explicit operator command.\n\n'
                    '3. AUDIO & VOICE PROCESSING\n'
                    'Voice synthesis (TTS) and live speech transcription run using on-device engines whenever supported by the host operating system. Audio streams are discarded immediately following command parsing.\n\n'
                    '4. ZERO TELEMETRY TRACKING\n'
                    'Atlanta includes no third-party ad networks, trackers, or commercial telemetry frameworks. All network activity is strictly confined to executing user-requested queries via Google AI Studio and Supabase Auth.\n\n'
                    '5. DATA RETENTION & PURGE\n'
                    'You maintain sovereign ownership of all data. Clearing app cache or logging out wipes local session credentials permanently.',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 11.5, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('I Understand'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 11)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.primaryWhite, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.monoSmall.copyWith(
        color: AppColors.neonCyan,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: titleColor ?? AppColors.secondaryText, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor ?? AppColors.primaryWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 10.5),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
