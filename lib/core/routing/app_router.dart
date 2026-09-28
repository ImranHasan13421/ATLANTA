import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/voice/voice_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/tasks/create_task_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/notes/create_note_screen.dart';
import '../../features/reminders/reminders_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/devices/devices_screen.dart';
import '../../features/files/files_screen.dart';
import '../../features/automations/automations_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/more/more_screen.dart';

/// Atlanta App Router — using go_router for declarative navigation.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // ── Standalone routes (no nav shell) ──
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/voice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceScreen(),
      ),

      // ── Shell route (with nav) ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/assistant',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AssistantScreen(),
            ),
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasksScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CreateTaskScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CreateNoteScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/reminders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/files',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FilesScreen(),
            ),
          ),
          GoRoute(
            path: '/devices',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DevicesScreen(),
            ),
          ),
          GoRoute(
            path: '/automations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AutomationsScreen(),
            ),
          ),
          GoRoute(
            path: '/activity',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActivityScreen(),
            ),
          ),
          GoRoute(
            path: '/permissions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PermissionsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoreScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
