import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'session_announcer.dart';
import 'session_clock.dart';
import 'session_task.dart';
import 'speaker.dart';

/// UI-facing session. Android hosts clock+TTS in the FGS isolate; iOS (and
/// tests) run them in this isolate.
class SessionController extends ChangeNotifier {
  SessionController({this.usePlatform = true});

  final bool usePlatform;

  bool running = false;
  Duration elapsed = Duration.zero;
  String? quote;
  String? error;
  bool _busy = false;
  bool _attached = false;

  SessionClock? _clock;
  Speaker? _speaker;
  Timer? _ticker;

  Future<void> attach() async {
    if (_attached || !usePlatform || !Platform.isAndroid) return;
    _attached = true;
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    _initService();
    if (await FlutterForegroundTask.isRunningService) {
      running = true;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (running) {
      await stop();
    } else {
      await start();
    }
  }

  Future<void> start() async {
    if (running || _busy) return;
    _busy = true;
    error = null;
    notifyListeners();
    try {
      if (!usePlatform) {
        await _startLocal(speak: false);
        return;
      }
      if (Platform.isAndroid) {
        await _startAndroid();
      } else {
        await _startLocal(speak: true);
      }
    } catch (e) {
      error = 'could not start';
      running = false;
      elapsed = Duration.zero;
      quote = null;
      notifyListeners();
    } finally {
      _busy = false;
    }
  }

  Future<void> stop() async {
    _busy = true;
    try {
      _ticker?.cancel();
      _ticker = null;
      _clock?.stop();
      _clock = null;
      await _speaker?.stop();
      _speaker = null;
      if (usePlatform && Platform.isAndroid) {
        await FlutterForegroundTask.stopService();
      }
    } catch (_) {
      // Still reset the UI.
    } finally {
      running = false;
      elapsed = Duration.zero;
      quote = null;
      error = null;
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (_attached && Platform.isAndroid) {
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    }
    unawaited(_speaker?.stop());
    super.dispose();
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'session_timer',
        channelName: 'Session timer',
        channelDescription: 'Shown while the timer is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(200),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
        allowAutoRestart: false,
        // Keep the service alive after the activity pauses so the timer
        // continues while another app is in front.
        stopWithTask: false,
      ),
    );
  }

  Future<void> _startAndroid() async {
    await attach();
    _initService();
    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      final after = await FlutterForegroundTask.requestNotificationPermission();
      if (after != NotificationPermission.granted) {
        error = 'notifications required to run';
        running = false;
        notifyListeners();
        return;
      }
    }

    final result = await FlutterForegroundTask.startService(
      serviceTypes: [ForegroundServiceTypes.mediaPlayback],
      notificationTitle: 'daydream timer',
      notificationText: 'running  00:00',
      callback: startCallback,
    );
    if (result is ServiceRequestFailure) {
      error = 'could not start';
      running = false;
      notifyListeners();
      return;
    }
    running = true;
    elapsed = Duration.zero;
    quote = null;
    notifyListeners();
  }

  Future<void> _startLocal({required bool speak}) async {
    final clock = SessionClock();
    _clock = clock;
    final announcer = SessionAnnouncer();
    Speaker? speaker;
    clock.start();
    running = true;
    elapsed = Duration.zero;
    quote = null;
    notifyListeners();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      elapsed = clock.elapsed;
      final lines = announcer.takePending(clock);
      quote = announcer.quote;
      notifyListeners();
      if (lines.isNotEmpty && speaker != null) {
        unawaited(speaker.speakBurst(lines));
      }
    });
    if (speak) {
      speaker = Speaker();
      _speaker = speaker;
      try {
        await speaker.init();
      } catch (_) {
        // Clock still runs if TTS is missing.
      }
    }
  }

  void _onTaskData(Object data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    final nextRunning = map['running'] as bool? ?? running;
    final ms = (map['elapsedMs'] as num?)?.toInt() ?? elapsed.inMilliseconds;
    final nextQuote = map['quote'] as String?;
    running = nextRunning;
    elapsed = Duration(milliseconds: ms);
    quote = (nextQuote == null || nextQuote.isEmpty) ? null : nextQuote;
    notifyListeners();
  }
}
