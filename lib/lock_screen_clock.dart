import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Elapsed time on the iOS lock screen. Android already shows this in the
/// foreground-service notification.
abstract class LockScreenClock {
  Future<void> start(DateTime startedAt);
  Future<void> end();
}

class IosLockScreenClock implements LockScreenClock {
  IosLockScreenClock({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('daydream_timer/lock_screen');

  final MethodChannel _channel;

  @override
  Future<void> start(DateTime startedAt) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('start', {
        'startedAtMs': startedAt.millisecondsSinceEpoch,
      });
    } catch (_) {
      // The in-app clock still runs if Live Activities are unavailable.
    }
  }

  @override
  Future<void> end() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('end');
    } catch (_) {}
  }
}
