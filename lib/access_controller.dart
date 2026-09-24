import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'store_purchase.dart';

/// Three free days from first launch, then a one-time store unlock.
class AccessController extends ChangeNotifier {
  AccessController({
    DateTime Function()? now,
    this.store,
    this.purchases,
    this.persist = true,
    this.trialStartedAt,
    this.unlocked = false,
  }) : now = now ?? DateTime.now {
    if (!persist) {
      trialStartedAt ??= this.now();
      final gateway = purchases;
      if (gateway != null) unawaited(gateway.attach(_onPurchase));
    }
  }

  static const trialLength = Duration(days: 3);

  final DateTime Function() now;
  final bool persist;

  AccessStore? store;
  PurchaseGateway? purchases;
  DateTime? trialStartedAt;

  bool unlocked = false;
  bool purchasing = false;
  bool restoring = false;
  String? price;
  String? purchaseError;

  bool get canStart => unlocked || inTrial;

  bool get inTrial => _trialLeft > Duration.zero;

  Duration get _trialLeft {
    final started = trialStartedAt;
    if (unlocked || started == null) return Duration.zero;
    return started.add(trialLength).difference(now());
  }

  /// Quiet countdown while the trial is still open. Null once it has ended
  /// or the timer is unlocked.
  String? get trialLabel {
    final left = _trialLeft;
    if (left <= Duration.zero) return null;
    if (left < const Duration(days: 1)) return 'less than a day left';
    final days = (left.inHours / 24).ceil();
    return days == 1 ? '1 day left' : '$days days left';
  }

  bool get canBuy => price != null && !purchasing && !restoring && !unlocked;

  Future<void> load() async {
    if (!persist) return;
    final saved = store ?? PrefsAccessStore();
    store = saved;
    try {
      unlocked = unlocked || await saved.isUnlocked();
      if (!unlocked) {
        var started = await saved.trialStartedAt();
        if (started == null) {
          started = now();
          await saved.setTrialStartedAt(started);
        }
        trialStartedAt = started;
      }
    } catch (_) {
      trialStartedAt ??= now();
    }
    purchases ??= StorePurchaseGateway();
    await purchases!.attach(_onPurchase);
    notifyListeners();
  }

  Future<void> preparePaywall() async {
    final gateway = purchases;
    if (gateway == null || price != null) return;
    purchaseError = null;
    try {
      if (!await gateway.isAvailable()) {
        purchaseError = 'the store is not available right now';
        notifyListeners();
        return;
      }
      price = await gateway.loadUnlockPrice();
      if (price == null) {
        purchaseError = 'unlock is not available in this build yet';
      }
    } catch (_) {
      purchaseError = 'the store is not available right now';
    }
    notifyListeners();
  }

  Future<void> buy() async {
    if (purchasing || restoring || unlocked) return;
    final gateway = purchases;
    if (gateway == null || price == null) {
      purchaseError = 'unlock is not available in this build yet';
      notifyListeners();
      return;
    }
    purchasing = true;
    purchaseError = null;
    notifyListeners();
    try {
      final started = await gateway.buy();
      if (!started) {
        purchasing = false;
        purchaseError = 'could not unlock';
        notifyListeners();
      }
    } catch (_) {
      purchasing = false;
      purchaseError = 'could not unlock';
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (purchasing || restoring || unlocked) return;
    final gateway = purchases;
    if (gateway == null) {
      purchaseError = 'unlock is not available in this build yet';
      notifyListeners();
      return;
    }
    restoring = true;
    purchaseError = null;
    notifyListeners();
    try {
      final restored = await gateway.restore();
      if (restored || unlocked) {
        await _grant();
      } else {
        purchaseError = 'no purchase to restore';
      }
    } catch (_) {
      purchaseError = 'could not unlock';
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    purchases?.dispose();
    super.dispose();
  }

  void _onPurchase(PurchaseOutcome outcome) {
    switch (outcome) {
      case PurchaseOutcome.unlocked:
        unawaited(_grant());
        return;
      case PurchaseOutcome.pending:
        purchasing = true;
        purchaseError = null;
      case PurchaseOutcome.canceled:
        purchasing = false;
        purchaseError = null;
      case PurchaseOutcome.failed:
        purchasing = false;
        purchaseError = 'could not unlock';
    }
    notifyListeners();
  }

  Future<void> _grant() async {
    unlocked = true;
    purchasing = false;
    restoring = false;
    purchaseError = null;
    try {
      await store?.setUnlocked(true);
    } catch (_) {}
    notifyListeners();
  }
}

abstract class AccessStore {
  Future<DateTime?> trialStartedAt();
  Future<void> setTrialStartedAt(DateTime time);
  Future<bool> isUnlocked();
  Future<void> setUnlocked(bool value);
}

class PrefsAccessStore implements AccessStore {
  static const _trialKey = 'trial_started_at_ms';
  static const _unlockKey = 'unlocked';

  @override
  Future<DateTime?> trialStartedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_trialKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  Future<void> setTrialStartedAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trialKey, time.millisecondsSinceEpoch);
  }

  @override
  Future<bool> isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlockKey) ?? false;
  }

  @override
  Future<void> setUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlockKey, value);
  }
}
