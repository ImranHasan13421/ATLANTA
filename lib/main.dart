import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/routing/app_router.dart';
import 'core/constants/supabase_constants.dart';
import 'core/services/sound_effects_service.dart';
import 'core/services/voice_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation on mobile devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive full-screen: hide status bar and navigation bar for cinematic feel
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Mobile Status Bar & Navigation Bar system chrome configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.deepBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Pre-initialize sound effects and services asynchronously
  SoundEffectsService.instance.initialize();
  VoiceService.instance.initialize();

  // Initialize Supabase backend
  try {
    await Supabase.initialize(
      url: SupabaseConstants.projectUrl,
      anonKey: SupabaseConstants.anonKey,
    ).timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('Supabase offline / initialization note: $e');
  }

  // Pre-initialize auth state
  await AuthService.instance.initialize();

  runApp(const AtlantaApp());
}

/// ATLANTA — Your Personal AI Assistant
class AtlantaApp extends StatelessWidget {
  const AtlantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'ATLANTA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
