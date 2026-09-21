import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_daydreaming/main.dart';
import 'package:stop_daydreaming/session_controller.dart';
import 'package:stop_daydreaming/theme_controller.dart';

void main() {
  testWidgets('shows 00:00 and stopped', (tester) async {
    final controller = SessionController(usePlatform: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(StopDaydreamingApp(controller: controller));
    final elapsed = tester.widget<Semantics>(find.byKey(const Key('elapsed')));
    expect(elapsed.properties.label, '00:00');
    expect(find.text('stopped'), findsOneWidget);
  });

  testWidgets('tap the clock starts the session', (tester) async {
    final controller = SessionController(usePlatform: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(StopDaydreamingApp(controller: controller));
    await tester.tap(find.byKey(const Key('clock-frame')));
    await tester.pump();
    expect(find.text('running'), findsOneWidget);
    expect(find.text('stopped'), findsNothing);
    await controller.stop();
  });

  testWidgets('theme toggle switches brightness without starting', (
    tester,
  ) async {
    final controller = SessionController(usePlatform: false);
    final theme = ThemeController(persist: false);
    addTearDown(controller.dispose);
    addTearDown(theme.dispose);
    await tester.pumpWidget(
      StopDaydreamingApp(controller: controller, themeController: theme),
    );

    expect(theme.mode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byKey(const Key('clock-frame')))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

    expect(theme.mode, ThemeMode.light);
    expect(find.text('stopped'), findsOneWidget);
    expect(find.text('running'), findsNothing);
    expect(
      Theme.of(tester.element(find.byKey(const Key('clock-frame')))).brightness,
      Brightness.light,
    );
  });

  testWidgets('shows the current quote while running', (tester) async {
    final controller = SessionController(usePlatform: false);
    addTearDown(controller.dispose);
    controller.running = true;
    controller.quote = 'Unclench your jaw.';
    await tester.pumpWidget(StopDaydreamingApp(controller: controller));
    expect(find.byKey(const Key('quote')), findsOneWidget);
    expect(find.text('Unclench your jaw.'), findsOneWidget);
  });
}
