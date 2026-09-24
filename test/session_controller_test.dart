import 'package:daydream_timer/lock_screen_clock.dart';
import 'package:daydream_timer/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lock screen clock follows start and stop', () async {
    final clock = _RecordingLockScreen();
    final controller = SessionController(usePlatform: false, lockScreen: clock);
    addTearDown(controller.dispose);

    await controller.start();
    expect(controller.running, isTrue);
    expect(clock.starts, 1);

    await controller.stop();
    expect(controller.running, isFalse);
    expect(clock.ends, 1);
  });

  test('attach clears a leftover lock screen clock', () async {
    final clock = _RecordingLockScreen();
    final controller = SessionController(usePlatform: false, lockScreen: clock);
    addTearDown(controller.dispose);

    await controller.attach();
    expect(clock.ends, 1);
    expect(controller.running, isFalse);
  });
}

class _RecordingLockScreen implements LockScreenClock {
  var starts = 0;
  var ends = 0;

  @override
  Future<void> start(DateTime startedAt) async {
    starts += 1;
  }

  @override
  Future<void> end() async {
    ends += 1;
  }
}
