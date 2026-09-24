import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

enum PurchaseOutcome { unlocked, pending, canceled, failed }

/// Non-consumable product id. Create this in App Store Connect and Play Console.
const unlockProductId = 'daydream_timer_unlock';

/// Store billing for the one-time unlock. Tests pass a fake.
abstract class PurchaseGateway {
  Future<void> attach(void Function(PurchaseOutcome outcome) onUpdate);
  Future<bool> isAvailable();

  /// Localized store price, or null when the product is missing.
  Future<String?> loadUnlockPrice();
  Future<bool> buy();
  Future<bool> restore();
  void dispose();
}

class StorePurchaseGateway implements PurchaseGateway {
  StorePurchaseGateway({InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  void Function(PurchaseOutcome outcome)? _onUpdate;
  ProductDetails? _product;
  Completer<bool>? _restoreWait;

  @override
  Future<void> attach(void Function(PurchaseOutcome outcome) onUpdate) async {
    _onUpdate = onUpdate;
    _subscription ??= _store.purchaseStream.listen(
      _onPurchases,
      onError: (Object _) {
        _onUpdate?.call(PurchaseOutcome.failed);
        _finishRestore(false);
      },
    );
  }

  @override
  Future<bool> isAvailable() => _store.isAvailable();

  @override
  Future<String?> loadUnlockPrice() async {
    final response = await _store.queryProductDetails({unlockProductId});
    if (response.productDetails.isEmpty) return null;
    final product = response.productDetails.first;
    _product = product;
    return product.price;
  }

  @override
  Future<bool> buy() async {
    final product = _product;
    if (product == null) return false;
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<bool> restore() async {
    final wait = Completer<bool>();
    _restoreWait = wait;
    try {
      await _store.restorePurchases();
      return await wait.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
    } finally {
      if (identical(_restoreWait, wait)) _restoreWait = null;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    var sawUnlock = false;
    for (final purchase in purchases) {
      if (purchase.productID != unlockProductId) {
        if (purchase.pendingCompletePurchase) {
          await _store.completePurchase(purchase);
        }
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          sawUnlock = true;
          _onUpdate?.call(PurchaseOutcome.unlocked);
        case PurchaseStatus.pending:
          _onUpdate?.call(PurchaseOutcome.pending);
        case PurchaseStatus.canceled:
          _onUpdate?.call(PurchaseOutcome.canceled);
        case PurchaseStatus.error:
          _onUpdate?.call(PurchaseOutcome.failed);
      }
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
    if (sawUnlock) _finishRestore(true);
  }

  void _finishRestore(bool unlocked) {
    final wait = _restoreWait;
    if (wait != null && !wait.isCompleted) wait.complete(unlocked);
  }
}
