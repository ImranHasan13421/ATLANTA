import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/services/sound_effects_service.dart';
import 'atlanta_sidebar.dart';

/// The main app shell — provides responsive navigation.
///
/// In landscape mode: the child handles its own nav rail (HomeScreen has it built in).
/// On desktop: left sidebar + main content
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Routes for sidebar (desktop)
  static const List<String> _desktopRoutes = [
    '/home',
    '/assistant',
    '/tasks',
    '/notes',
    '/reminders',
    '/calendar',
    '/files',
    '/devices',
    '/automations',
    '/activity',
    '/settings',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    if (!isDesktop) return;

    for (var i = 0; i < _desktopRoutes.length; i++) {
      if (location.startsWith(_desktopRoutes[i])) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            AtlantaSidebar(currentIndex: _currentIndex),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // In landscape mobile mode:
    // If on /home: HomeScreen renders its own full cyber dashboard with nav rail.
    // If on sub-screens: provide a sleek left nav rail for seamless switching without overlapping buttons.
    final location = GoRouterState.of(context).uri.path;
    final isHome = location == '/home';

    if (isHome) {
      return Scaffold(
        backgroundColor: AppColors.deepBackground,
        body: widget.child,
      );
    }

    final navItems = [
      (Icons.home_rounded, 'Home', '/home'),
      (Icons.chat_bubble_rounded, 'Chat', '/assistant'),
      (Icons.build_rounded, 'Tasks', '/tasks'),
      (Icons.apps_rounded, 'Apps', '/devices'),
      (Icons.settings_rounded, 'Settings', '/settings'),
    ];

    return Scaffold(
      backgroundColor: AppColors.deepBackground,
      body: Row(
        children: [
          // ── Sleek Cyber-Tech Frosted Glass Landscape Nav Rail ──
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface.withValues(alpha: 0.55),
                  border: Border(
                    right: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: navItems.map((item) {
                      final (icon, label, route) = item;
                      final isActive = location.startsWith(route);
                      return GestureDetector(
                        onTap: () {
                          SoundEffectsService.instance.playClick();
                          context.go(route);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? AppColors.primaryBlue.withValues(alpha: 0.35)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.neonCyan
                                        : AppColors.border.withValues(alpha: 0.35),
                                    width: isActive ? 1.6 : 0.8,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.neonCyan.withValues(alpha: 0.45),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  icon,
                                  size: 15,
                                  color: isActive ? AppColors.neonCyan : AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 7.5,
                                  color: isActive ? AppColors.neonCyan : AppColors.mutedText,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // ── Screen Content ──
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
