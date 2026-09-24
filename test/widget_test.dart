import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daydream_timer/access_controller.dart';
import 'package:daydream_timer/main.dart';
import 'package:daydream_timer/session_controller.dart';
import 'package:daydream_timer/store_purchase.dart';
import 'package:daydream_timer/theme_controller.dart';

void main() {
  testWidgets('shows 00:00 and stopped', (tester) async {
    final controller = SessionController(usePlatform: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(DaydreamTimerApp(controller: controller));
    final elapsed = tester.widget<Semantics>(find.byKey(const Key('elapsed')));
    expect(elapsed.properties.label, '00:00');
    expect(find.text('stopped'), findsOneWidget);
    expect(find.byKey(const Key('disclaimer')), findsOneWidget);
  });

  testWidgets('tap the clock starts the session', (tester) async {
    final controller = SessionController(usePlatform: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(DaydreamTimerApp(controller: controller));
    await tester.tap(find.byKey(const Key('clock-frame')));
    await tester.pump();
    expect(find.text('running'), findsOneWidget);
    expect(find.text('stopped'), findsNothing);
    expect(find.byKey(const Key('disclaimer')), findsNothing);
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
      DaydreamTimerApp(controller: controller, themeController: theme),
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
    await tester.pumpWidget(DaydreamTimerApp(controller: controller));
    expect(find.byKey(const Key('quote')), findsOneWidget);
    expect(find.text('Unclench your jaw.'), findsOneWidget);
  });

  testWidgets('expired trial opens the paywall instead of starting', (
    tester,
  ) async {
    final controller = SessionController(usePlatform: false);
    final access = AccessController(
      persist: false,
      now: () => DateTime.utc(2026, 1, 4),
      trialStartedAt: DateTime.utc(2026, 1, 1),
    );
    addTearDown(controller.dispose);
    addTearDown(access.dispose);
    await tester.pumpWidget(
      DaydreamTimerApp(controller: controller, access: access),
    );

    expect(find.byKey(const Key('trial-remaining')), findsNothing);
    await tester.tap(find.byKey(const Key('clock-frame')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('paywall')), findsOneWidget);
    expect(find.text('keep the timer'), findsOneWidget);
    expect(find.text('running'), findsNothing);

    await tester.tap(find.byKey(const Key('paywall-dismiss')));
    await tester.pumpAndSettle();
    expect(find.text('stopped'), findsOneWidget);
  });

  testWidgets('unlocking from the paywall starts the session', (tester) async {
    final controller = SessionController(usePlatform: false);
    final purchases = _WidgetPurchases(price: r'$4.99');
    final access = AccessController(
      persist: false,
      now: () => DateTime.utc(2026, 1, 5),
      trialStartedAt: DateTime.utc(2026, 1, 1),
      purchases: purchases,
    );
    addTearDown(controller.dispose);
    addTearDown(access.dispose);
    await tester.pumpWidget(
      DaydreamTimerApp(controller: controller, access: access),
    );

    await tester.tap(find.byKey(const Key('clock-frame')));
    await tester.pumpAndSettle();
    expect(find.text('unlock · \$4.99'), findsOneWidget);

    await tester.tap(find.byKey(const Key('paywall-unlock')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(access.purchaseError, isNull);
    expect(access.unlocked, isTrue);
    expect(find.byKey(const Key('paywall')), findsNothing);
    expect(find.text('running'), findsOneWidget);
    await controller.stop();
  });
}

class _WidgetPurchases implements PurchaseGateway {
  _WidgetPurchases({required this.price});

  final String price;
  void Function(PurchaseOutcome outcome)? onUpdate;

  @override
  Future<void> attach(void Function(PurchaseOutcome outcome) onUpdate) async {
    this.onUpdate = onUpdate;
  }

  @override
  Future<bool> buy() async {
    onUpdate?.call(PurchaseOutcome.unlocked);
    return true;
  }

  @override
  void dispose() {}

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String?> loadUnlockPrice() async => price;

  @override
  Future<bool> restore() async => false;
}
