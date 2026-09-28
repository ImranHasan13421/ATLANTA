import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atlanta/shared/widgets/atlanta_orb.dart';
import 'package:atlanta/features/home/home_screen.dart';
import 'package:atlanta/core/routing/app_router.dart';

void main() {
  testWidgets('AtlantaOrb renders with idle state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AtlantaOrb(
              size: 140,
              state: OrbState.idle,
              showLabel: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AtlantaOrb), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
  });

  testWidgets('AtlantaOrb renders with listening state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AtlantaOrb(
              size: 140,
              state: OrbState.listening,
              showLabel: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AtlantaOrb), findsOneWidget);
    expect(find.text('LISTENING...'), findsOneWidget);
  });

  testWidgets('SplashScreen renders with Atlanta brand and status indicators', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: AppRouter.router,
      ),
    );

    expect(find.byType(Image), findsWidgets);
    expect(find.text('AI Core'), findsOneWidget);
    expect(find.byType(AtlantaOrb), findsOneWidget);

    await tester.pump(const Duration(seconds: 7));
  });

  testWidgets('HomeScreen renders landscape layout with ATLANTA branding', (WidgetTester tester) async {
    // Landscape resolution matching mobile landscape
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    // The ATLANTA brand text should appear in center section
    expect(find.text('ATLANTA'), findsWidgets);
    // Should have the AI core orb
    expect(find.byType(AtlantaOrb), findsOneWidget);
  });

  testWidgets('HomeScreen renders desktop layout with system status cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    // System status cards in right section
    expect(find.text('System Health'), findsOneWidget);
    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
    expect(find.text('Storage'), findsOneWidget);
    // TODAY card in left section
    expect(find.text('TODAY'), findsOneWidget);
    // Online status
    expect(find.text('Online'), findsOneWidget);
  });
}
