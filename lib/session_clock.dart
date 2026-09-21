/// Stopwatch-backed session time. Stopped elapsed is always zero; the next
/// start is a new session (reset, not pause).
class SessionClock {
  SessionClock({this.interval = const Duration(minutes: 1), this.readElapsed});

  final Duration interval;
  final Duration Function()? readElapsed;
  final Stopwatch _stopwatch = Stopwatch();

  bool _running = false;
  int _spokenMinute = 0;

  bool get isRunning => _running;

  Duration get elapsed {
    if (!_running) return Duration.zero;
    return readElapsed?.call() ?? _stopwatch.elapsed;
  }

  void start() {
    _spokenMinute = 0;
    _running = true;
    if (readElapsed == null) {
      _stopwatch
        ..reset()
        ..start();
    }
  }

  void stop() {
    _running = false;
    _spokenMinute = 0;
    _stopwatch
      ..stop()
      ..reset();
  }

  /// Whole-interval count that should be spoken now, or null.
  ///
  /// If fires were delayed, returns the **current** minute once and skips
  /// intermediates. Never returns 0.
  int? takePendingMinute() {
    if (!_running) return null;
    final current = elapsed.inMilliseconds ~/ interval.inMilliseconds;
    if (current <= _spokenMinute) return null;
    _spokenMinute = current;
    return current == 0 ? null : current;
  }
}

/// MM:SS until one hour, then H:MM:SS so long sessions do not overflow.
String formatElapsed(Duration elapsed) {
  final total = elapsed.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) return '$hours:$mm:$ss';
  return '$mm:$ss';
}
