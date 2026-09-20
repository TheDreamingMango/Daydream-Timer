import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stop_daydreaming/main.dart';
import 'package:stop_daydreaming/session_controller.dart';

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
}
