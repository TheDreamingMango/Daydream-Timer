import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'minute_copy.dart';
import 'session_clock.dart';
import 'session_interval.dart';
import 'speaker.dart';

/// Top-level entry for the Android foreground-service isolate.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SessionTaskHandler());
}

/// Owns the clock and TTS while the Android foreground service is alive.
class SessionTaskHandler extends TaskHandler {
  final SessionClock _clock = SessionClock(interval: sessionInterval);
  final Speaker _speaker = Speaker();
  int _lastNotifiedSecond = -1;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    _clock.start();
    _broadcast();
    try {
      await _speaker.init();
    } catch (_) {
      // Clock still runs if TTS is missing.
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_clock.isRunning) return;
    _broadcast();
    final elapsed = _clock.elapsed;
    final second = elapsed.inSeconds;
    if (second != _lastNotifiedSecond) {
      _lastNotifiedSecond = second;
      FlutterForegroundTask.updateService(
        notificationTitle: 'stop daydreaming',
        notificationText: 'running  ${formatElapsed(elapsed)}',
      );
    }
    final minute = _clock.takePendingMinute();
    if (minute != null) {
      unawaited(_speaker.speak(minuteCopy(minute)));
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _speaker.stop();
    _clock.stop();
    FlutterForegroundTask.sendDataToMain({
      'running': false,
      'elapsedMs': 0,
    });
  }

  void _broadcast() {
    FlutterForegroundTask.sendDataToMain({
      'running': _clock.isRunning,
      'elapsedMs': _clock.elapsed.inMilliseconds,
    });
  }
}
