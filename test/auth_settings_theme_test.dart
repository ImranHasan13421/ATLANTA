import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlanta/core/services/auth_service.dart';
import 'package:atlanta/core/services/notification_settings_service.dart';
import 'package:atlanta/core/theme/theme_controller.dart';
import 'package:atlanta/core/theme/app_colors.dart';
import 'package:atlanta/features/settings/settings_screen.dart';
import 'package:atlanta/features/auth/login_screen.dart';
import 'package:atlanta/features/auth/register_screen.dart';
import 'package:atlanta/features/devices/mobile_node_files_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService Tests', () {
    test('Initializes with default or stored user', () async {
      final auth = AuthService.instance;
      await auth.initialize();
      expect(auth.currentUser, isNotNull);
      expect(auth.isAuthenticated, true);
    });

    test('Registers a new user successfully', () async {
      final auth = AuthService.instance;
      await auth.initialize();
      final success = await auth.register(
        name: 'Commander Shepard',
        email: 'commander@ezzeai.corp',
        password: 'secure_password_123',
        terminalNode: 'Normandy SR-2',
      );
      expect(success, true);
      expect(auth.currentUser?.email, 'commander@ezzeai.corp');
      expect(auth.currentUser?.name, 'Commander Shepard');
      expect(auth.currentUser?.terminalNode, 'Normandy SR-2');
      expect(auth.isAuthenticated, true);
    });

    test('Updates profile call sign and status', () async {
      final auth = AuthService.instance;
      await auth.initialize();
      await auth.updateProfile(
        name: 'Chief Engineer',
        terminalNode: 'Vanguard-9',
      );
      expect(auth.currentUser?.name, 'Chief Engineer');
      expect(auth.currentUser?.terminalNode, 'Vanguard-9');
    });

    test('Logs out user and resets authentication state', () async {
      final auth = AuthService.instance;
      await auth.initialize();
      await auth.logout();
      expect(auth.isAuthenticated, false);
      expect(auth.currentUser, isNull);

      // Re-login
      final loggedIn = await auth.login(
        email: 'operator@ezzeai.corp',
        password: 'password123',
      );
      expect(loggedIn, true);
      expect(auth.currentUser?.email, 'operator@ezzeai.corp');
      expect(auth.isAuthenticated, true);
    });
  });

  group('ThemeController & AppColors Tests', () {
    test('Supports all required accent presets', () {
      final expectedLabels = [
        'Red',
        'Orange',
        'Purple',
        'Gold',
        'Green',
        'Gray',
        'Blue',
      ];

      final presetLabels = ThemeController.presets.values.map((p) => p.label).toList();
      for (final label in expectedLabels) {
        expect(presetLabels.contains(label), true, reason: 'Missing preset: $label');
      }
    });

    test('Dynamic AppColors change when accent color is updated', () async {
      final controller = ThemeController.instance;

      // Switch to Red
      await controller.setAccent(AtlantaAccent.red);
      expect(controller.currentAccent, AtlantaAccent.red);
      expect(AppColors.primaryBlue.toARGB32(), ThemeController.presets[AtlantaAccent.red]!.primary.toARGB32());
      expect(AppColors.neonCyan.toARGB32(), ThemeController.presets[AtlantaAccent.red]!.neon.toARGB32());

      // Switch to Orange
      await controller.setAccent(AtlantaAccent.orange);
      expect(controller.currentAccent, AtlantaAccent.orange);
      expect(AppColors.primaryBlue.toARGB32(), ThemeController.presets[AtlantaAccent.orange]!.primary.toARGB32());

      // Switch to Green
      await controller.setAccent(AtlantaAccent.green);
      expect(controller.currentAccent, AtlantaAccent.green);
      expect(AppColors.primaryBlue.toARGB32(), ThemeController.presets[AtlantaAccent.green]!.primary.toARGB32());

      // Switch to Gray
      await controller.setAccent(AtlantaAccent.gray);
      expect(controller.currentAccent, AtlantaAccent.gray);
      expect(AppColors.primaryBlue.toARGB32(), ThemeController.presets[AtlantaAccent.gray]!.primary.toARGB32());

      // Reset to Blue
      await controller.setAccent(AtlantaAccent.blue);
      expect(controller.currentAccent, AtlantaAccent.blue);
    });
  });

  group('NotificationSettingsService Tests', () {
    test('Toggles notification preferences and persists state', () async {
      final service = NotificationSettingsService.instance;

      expect(service.taskReminders, true);
      await service.setTaskReminders(false);
      expect(service.taskReminders, false);

      expect(service.scheduledAlarms, true);
      await service.setScheduledAlarms(false);
      expect(service.scheduledAlarms, false);

      expect(service.doNotDisturb, false);
      await service.setDoNotDisturb(true);
      expect(service.doNotDisturb, true);

      // Re-enable
      await service.setTaskReminders(true);
      await service.setScheduledAlarms(true);
      await service.setDoNotDisturb(false);
      expect(service.taskReminders, true);
      expect(service.scheduledAlarms, true);
      expect(service.doNotDisturb, false);
    });
  });

  group('Screen Rendering Tests', () {
    testWidgets('SettingsScreen renders categories and Appearance section without dark mode toggle', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const SettingsScreen(),
        ),
      );
      await tester.pump();

      // Navigation categories on the left panel
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Atlanta AI'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Account is default opened as requested
      expect(find.text('ACCOUNT & OPERATOR IDENTITY'), findsOneWidget);

      // Tap Appearance tab to test appearance settings
      await tester.tap(find.text('Appearance'));
      await tester.pump();

      // Appearance matrix view
      expect(find.text('VISUAL APPEARANCE & DYNAMIC ACCENT COLORS'), findsOneWidget);
      expect(find.text('APP ACCENT PALETTE'), findsOneWidget);

      // Verify NO dark mode toggle button exists anywhere
      expect(find.text('Dark Mode'), findsNothing);
      expect(find.text('Dark Mode Toggle'), findsNothing);
      expect(find.text('Enable Dark Mode'), findsNothing);

      // Tap on Account to verify Operator & Logout
      await tester.tap(find.text('Account'));
      await tester.pump();
      expect(find.text('ACCOUNT & OPERATOR IDENTITY'), findsOneWidget);
      expect(find.text('Logout Terminal'), findsWidgets);

      // Tap on Security to verify Permissions button
      await tester.tap(find.text('Security'));
      await tester.pump();
      expect(find.text('SECURITY & SYSTEM PERMISSIONS'), findsOneWidget);
      expect(find.text('Application Access Permissions'), findsOneWidget);

      // Tap on About to verify Legal & Version modals
      await tester.tap(find.text('About'));
      await tester.pump();
      expect(find.text('ABOUT ATLANTA & LEGAL POLICIES'), findsOneWidget);
      expect(find.text('MD. Imran Hasan'), findsOneWidget);
      expect(find.text('Terms of Neural Service'), findsOneWidget);
      expect(find.text('Privacy Policy & Zero-Telemetry Charter'), findsOneWidget);
    });

    testWidgets('LoginScreen and RegisterScreen render correctly', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const LoginScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const RegisterScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Initialize Terminal'), findsOneWidget);
      expect(find.text('Register Terminal Node'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('MobileNodeFilesScreen renders internal storage explorer and tabs', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const MobileNodeFilesScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('MOBILE NODE INTERNAL STORAGE'), findsOneWidget);
      expect(find.text('DEVICES'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Folders'), findsOneWidget);
      expect(find.text('Files'), findsOneWidget);
    });
  });
}
