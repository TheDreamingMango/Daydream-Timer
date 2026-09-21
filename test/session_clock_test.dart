import 'package:flutter_test/flutter_test.dart';
import 'package:stop_daydreaming/session_clock.dart';

void main() {
  test('stopped elapsed is always zero', () {
    final clock = SessionClock();
    expect(clock.isRunning, isFalse);
    expect(clock.elapsed, Duration.zero);
    expect(clock.takePendingMinute(), isNull);
  });

  test('start uses Stopwatch elapsed; stop resets', () async {
    final clock = SessionClock();
    clock.start();
    expect(clock.isRunning, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(clock.elapsed > Duration.zero, isTrue);
    clock.stop();
    expect(clock.isRunning, isFalse);
    expect(clock.elapsed, Duration.zero);
    expect(clock.takePendingMinute(), isNull);
  });

  test('minute boundary fires once', () {
    var now = Duration.zero;
    final clock = SessionClock(
      interval: const Duration(seconds: 60),
      readElapsed: () => now,
    );
    clock.start();
    expect(clock.takePendingMinute(), isNull);
    now = const Duration(seconds: 59);
    expect(clock.takePendingMinute(), isNull);
    now = const Duration(seconds: 60);
    expect(clock.takePendingMinute(), 1);
    expect(clock.takePendingMinute(), isNull);
  });

  test('90s freeze catch-up speaks current minute once', () {
    var now = Duration.zero;
    final clock = SessionClock(
      interval: const Duration(seconds: 60),
      readElapsed: () => now,
    );
    clock.start();
    now = const Duration(seconds: 90);
    expect(clock.takePendingMinute(), 1);
    expect(clock.takePendingMinute(), isNull);
  });

  test('skipped minutes speak only the current minute', () {
    var now = Duration.zero;
    final clock = SessionClock(
      interval: const Duration(seconds: 60),
      readElapsed: () => now,
    );
    clock.start();
    now = const Duration(seconds: 150);
    expect(clock.takePendingMinute(), 2);
    expect(clock.takePendingMinute(), isNull);
  });

  test('formatElapsed uses H:MM:SS after one hour', () {
    expect(formatElapsed(Duration.zero), '00:00');
    expect(formatElapsed(const Duration(minutes: 1, seconds: 5)), '01:05');
    expect(
      formatElapsed(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });
}
