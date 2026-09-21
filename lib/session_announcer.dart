import 'minute_copy.dart';
import 'quote_cadence.dart';
import 'quote_player.dart';
import 'session_clock.dart';

/// Collects the next spoken lines for one clock tick: minute copy, then quote.
class SessionAnnouncer {
  SessionAnnouncer({QuotePlayer? quotes, QuoteCadence? cadence})
    : _quotes = quotes ?? QuotePlayer(),
      _cadence = cadence ?? QuoteCadence();

  final QuotePlayer _quotes;
  final QuoteCadence _cadence;

  /// Last quote handed to speech; shown on the timer until the next one.
  String? quote;

  List<String> takePending(SessionClock clock) {
    final lines = <String>[];
    final minute = clock.takePendingMinute();
    if (minute != null) {
      lines.add(minuteCopy(minute));
    }
    if (_cadence.takePending(clock.elapsed)) {
      final next = _quotes.take();
      if (next.isNotEmpty) {
        quote = next;
        lines.add(next);
      }
    }
    return lines;
  }
}
