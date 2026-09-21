import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'session_announcer.dart';
import 'session_clock.dart';
import 'speaker.dart';

/// Top-level entry for the Android foreground-service isolate.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SessionTaskHandler());
}

/// Owns the clock and TTS while the Android foreground service is alive.
class SessionTaskHandler extends TaskHandler {
  final SessionClock _clock = SessionClock();
  final Speaker _speaker = Speaker();
  final SessionAnnouncer _announcer = SessionAnnouncer();
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
    final lines = _announcer.takePending(_clock);
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
    if (lines.isNotEmpty) {
      unawaited(_speaker.speakBurst(lines));
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _speaker.stop();
    _clock.stop();
    FlutterForegroundTask.sendDataToMain({
      'running': false,
      'elapsedMs': 0,
      'quote': '',
    });
  }

  void _broadcast() {
    FlutterForegroundTask.sendDataToMain({
      'running': _clock.isRunning,
      'elapsedMs': _clock.elapsed.inMilliseconds,
      'quote': _announcer.quote ?? '',
    });
  }
}
