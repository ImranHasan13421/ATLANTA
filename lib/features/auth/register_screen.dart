import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/sound_effects_service.dart';
import '../../shared/widgets/atlanta_button.dart';
import '../../shared/widgets/atlanta_input.dart';

/// Atlanta Registration Screen.
///
/// Futuristic, responsive account registration terminal for creating
/// secure local and cloud credentials.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _terminalController = TextEditingController(text: 'Terminal Node-Alpha');

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _terminalController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please complete all required fields.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    if (!AuthService.isPasswordStrong(password)) {
      setState(() => _errorMessage =
          'Password requires at least 10 characters: 1 uppercase letter, 1 number, and 1 special character.');
      return;
    }

    SoundEffectsService.instance.playClick();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.instance.register(
      name: name,
      email: email,
      password: password,
      terminalNode: _terminalController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      setState(() {
        _errorMessage = AuthService.instance.errorMessage ?? 'Registration failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 480 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Official Atlanta Logo ──
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/atlanta_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Heading ──
                  Text(
                    'Initialize Terminal',
                    style: AppTypography.headlineLarge.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Register a new secure operator node for Atlanta',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Registration Card ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        AtlantaTextField(
                          controller: _nameController,
                          label: 'Operator Call-sign / Name',
                          hint: 'e.g. Boss Imran',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),

                        // Email
                        AtlantaTextField(
                          controller: _emailController,
                          label: 'Security Email',
                          hint: 'operator@terminal.net',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        // Terminal Node ID
                        AtlantaTextField(
                          controller: _terminalController,
                          label: 'Hardware Terminal Node',
                          hint: 'Primary Terminal Alpha',
                          prefixIcon: Icons.memory_rounded,
                        ),
                        const SizedBox(height: 14),

                        // Password
                        AtlantaTextField(
                          controller: _passwordController,
                          label: 'Master Encryption Key',
                          hint: 'Min. 10 chars (Aa, 1, !@#)',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppColors.secondaryText,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Live Password Strength Meter & Security Badges ──
                        _buildPasswordStrengthMeter(_passwordController.text),
                        const SizedBox(height: 12),

                        // Confirm Password
                        AtlantaTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Encryption Key',
                          hint: 'Repeat password',
                          prefixIcon: Icons.lock_clock_outlined,
                          obscureText: _obscureConfirm,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                              _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppColors.secondaryText,
                              size: 18,
                            ),
                          ),
                        ),

                        // ── Error Banner ──
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Register Button ──
                        AtlantaButton(
                          label: 'Register Terminal Node',
                          icon: Icons.rocket_launch_rounded,
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                          isExpanded: true,
                          size: AtlantaButtonSize.large,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Back to Login ──
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an active node? ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Sign In',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthMeter(String pass) {
    if (pass.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMinLength = AuthService.hasMinLength(pass);
    final hasUpper = AuthService.hasUppercase(pass);
    final hasNumber = AuthService.hasNumber(pass);
    final hasSpecial = AuthService.hasSpecialChar(pass);
    final strength = AuthService.calculatePasswordStrength(pass);

    Color strengthColor;
    String strengthLabel;
    double progress;

    switch (strength) {
      case 4:
        strengthColor = AppColors.success;
        strengthLabel = 'Strong (Military Grade)';
        progress = 1.0;
        break;
      case 3:
        strengthColor = AppColors.neonCyan;
        strengthLabel = 'Good';
        progress = 0.75;
        break;
      case 2:
        strengthColor = AppColors.warning;
        strengthLabel = 'Moderate';
        progress = 0.50;
        break;
      default:
        strengthColor = AppColors.error;
        strengthLabel = 'Weak';
        progress = 0.25;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: strengthColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Strength: $strengthLabel',
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildRequirementChip('10+ chars', hasMinLength),
              _buildRequirementChip('1 Uppercase', hasUpper),
              _buildRequirementChip('1 Number', hasNumber),
              _buildRequirementChip('1 Special (!@#)', hasSpecial),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementChip(String label, bool isMet) {
    final color = isMet ? AppColors.success : AppColors.mutedText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMet ? AppColors.success.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isMet ? AppColors.success : AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
