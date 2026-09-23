import 'package:flutter_test/flutter_test.dart';
import 'package:daydream_timer/quote_player.dart';
import 'package:daydream_timer/session_announcer.dart';
import 'package:daydream_timer/session_clock.dart';

void main() {
  test('minute then quote at two minutes', () {
    var now = Duration.zero;
    final clock = SessionClock(readElapsed: () => now);
    final announcer = SessionAnnouncer(
      quotes: QuotePlayer(const ['stay here']),
    );
    clock.start();

    now = const Duration(minutes: 1);
    expect(announcer.takePending(clock), ['one minute']);
    expect(announcer.quote, isNull);

    now = const Duration(minutes: 2);
    expect(announcer.takePending(clock), ['two minutes', 'stay here']);
    expect(announcer.quote, 'stay here');
  });

  test('after fifteen minutes quotes resume at 16:30', () {
    var now = Duration.zero;
    final clock = SessionClock(readElapsed: () => now);
    final announcer = SessionAnnouncer(
      quotes: QuotePlayer(const ['first', 'second', 'third']),
    );
    clock.start();

    now = const Duration(minutes: 15);
    final atFifteen = announcer.takePending(clock);
    expect(atFifteen.first, 'fifteen minutes');
    expect(atFifteen.last, 'first');

    now = const Duration(minutes: 16);
    expect(announcer.takePending(clock), ['sixteen minutes']);
    expect(announcer.quote, 'first');

    now = const Duration(minutes: 16, seconds: 30);
    expect(announcer.takePending(clock), ['second']);
    expect(announcer.quote, 'second');
  });

  test('keeps the spoken quote until the next one', () {
    var now = Duration.zero;
    final clock = SessionClock(readElapsed: () => now);
    final announcer = SessionAnnouncer(quotes: QuotePlayer(const ['a', 'b']));
    clock.start();
    now = const Duration(minutes: 2);
    announcer.takePending(clock);
    now = const Duration(minutes: 3);
    announcer.takePending(clock);
    expect(announcer.quote, 'a');
    now = const Duration(minutes: 4);
    announcer.takePending(clock);
    expect(announcer.quote, 'b');
  });
}
