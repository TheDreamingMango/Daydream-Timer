import 'package:daydream_timer/access_controller.dart';
import 'package:daydream_timer/store_purchase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime.utc(2026, 1, 1, 12);

  AccessController trial({
    required DateTime at,
    bool unlocked = false,
    AccessStore? store,
    PurchaseGateway? purchases,
    bool persist = false,
  }) {
    final access = AccessController(
      persist: persist,
      now: () => at,
      trialStartedAt: start,
      unlocked: unlocked,
      store: store,
      purchases: purchases,
    );
    addTearDown(access.dispose);
    return access;
  }

  test('a new trial can start the timer', () {
    final access = trial(at: start);
    expect(access.canStart, isTrue);
    expect(access.trialLabel, '3 days left');
  });

  test('the trial lasts through the third day', () {
    final access = trial(at: start.add(const Duration(days: 2, hours: 23)));
    expect(access.canStart, isTrue);
    expect(access.inTrial, isTrue);
  });

  test('the trial ends at three days', () {
    final access = trial(at: start.add(const Duration(days: 3)));
    expect(access.canStart, isFalse);
    expect(access.inTrial, isFalse);
    expect(access.trialLabel, isNull);
  });

  test('an unlock starts after the trial', () {
    final access = trial(
      at: start.add(const Duration(days: 10)),
      unlocked: true,
    );
    expect(access.canStart, isTrue);
    expect(access.trialLabel, isNull);
  });

  test('trial copy counts down in days', () {
    expect(
      trial(at: start.add(const Duration(hours: 24))).trialLabel,
      '2 days left',
    );
    expect(
      trial(at: start.add(const Duration(hours: 48))).trialLabel,
      '1 day left',
    );
    expect(
      trial(at: start.add(const Duration(hours: 50))).trialLabel,
      'less than a day left',
    );
  });

  test('first launch records the trial start', () async {
    final store = MemoryAccessStore();
    final access = AccessController(
      now: () => start,
      store: store,
      purchases: FakePurchaseGateway(),
    );
    addTearDown(access.dispose);
    await access.load();
    expect(store.started, start);
    expect(access.canStart, isTrue);
  });

  test('a stored unlock skips the trial', () async {
    final store = MemoryAccessStore()..unlocked = true;
    final access = AccessController(
      now: () => start.add(const Duration(days: 30)),
      store: store,
      purchases: FakePurchaseGateway(),
    );
    addTearDown(access.dispose);
    await access.load();
    expect(access.unlocked, isTrue);
    expect(access.canStart, isTrue);
    expect(store.started, isNull);
  });

  test('buying grants the unlock', () async {
    final store = MemoryAccessStore();
    final purchases = FakePurchaseGateway(price: r'$4.99');
    final access = AccessController(
      persist: false,
      now: () => start.add(const Duration(days: 4)),
      trialStartedAt: start,
      store: store,
      purchases: purchases,
    );
    addTearDown(access.dispose);
    await access.preparePaywall();
    expect(access.price, r'$4.99');
    expect(access.canBuy, isTrue);

    await access.buy();
    purchases.emit(PurchaseOutcome.unlocked);
    await pumpEventQueue();

    expect(access.unlocked, isTrue);
    expect(store.unlocked, isTrue);
    expect(access.canStart, isTrue);
  });

  test('restore grants a previous unlock', () async {
    final store = MemoryAccessStore();
    final purchases = FakePurchaseGateway(restoreResult: true);
    final access = AccessController(
      persist: false,
      now: () => start.add(const Duration(days: 4)),
      trialStartedAt: start,
      store: store,
      purchases: purchases,
    );
    addTearDown(access.dispose);

    await access.restore();

    expect(access.unlocked, isTrue);
    expect(store.unlocked, isTrue);
    expect(access.purchaseError, isNull);
  });

  test('restore explains a missing purchase', () async {
    final purchases = FakePurchaseGateway(restoreResult: false);
    final access = AccessController(
      persist: false,
      now: () => start.add(const Duration(days: 4)),
      trialStartedAt: start,
      purchases: purchases,
    );
    addTearDown(access.dispose);

    await access.restore();

    expect(access.unlocked, isFalse);
    expect(access.purchaseError, 'no purchase to restore');
  });
}

class MemoryAccessStore implements AccessStore {
  DateTime? started;
  bool unlocked = false;

  @override
  Future<bool> isUnlocked() async => unlocked;

  @override
  Future<void> setTrialStartedAt(DateTime time) async {
    started = time;
  }

  @override
  Future<void> setUnlocked(bool value) async {
    unlocked = value;
  }

  @override
  Future<DateTime?> trialStartedAt() async => started;
}

class FakePurchaseGateway implements PurchaseGateway {
  FakePurchaseGateway({this.price, this.restoreResult = false});

  final String? price;
  final bool restoreResult;
  void Function(PurchaseOutcome outcome)? onUpdate;

  void emit(PurchaseOutcome outcome) => onUpdate?.call(outcome);

  @override
  Future<void> attach(void Function(PurchaseOutcome outcome) onUpdate) async {
    this.onUpdate = onUpdate;
  }

  @override
  Future<bool> buy() async => true;

  @override
  void dispose() {}

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String?> loadUnlockPrice() async => price;

  @override
  Future<bool> restore() async => restoreResult;
}
