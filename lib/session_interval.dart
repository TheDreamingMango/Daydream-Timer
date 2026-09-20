import 'package:flutter/foundation.dart';

/// Whole-minute boundary. Debug builds use 5s so device checks are short.
/// Override with `--dart-define=FAST_MINUTES=true` or `false`.
Duration get sessionInterval {
  const defined = bool.fromEnvironment('FAST_MINUTES');
  const hasDefine = bool.hasEnvironment('FAST_MINUTES');
  final fast = hasDefine ? defined : kDebugMode;
  return fast ? const Duration(seconds: 5) : const Duration(minutes: 1);
}

bool get isFastMinutes => sessionInterval < const Duration(minutes: 1);
