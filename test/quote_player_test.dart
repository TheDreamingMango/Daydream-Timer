import 'package:flutter_test/flutter_test.dart';
import 'package:daydream_timer/quote_player.dart';
import 'package:daydream_timer/quotes.dart';

void main() {
  test('walks in order and loops', () {
    final player = QuotePlayer(const ['a', 'b', 'c']);
    expect(player.take(), 'a');
    expect(player.take(), 'b');
    expect(player.take(), 'c');
    expect(player.take(), 'a');
    expect(player.take(), 'b');
  });

  test('empty list is silent', () {
    expect(QuotePlayer(const []).take(), isEmpty);
  });

  test('bundled list has one hundred ten quotes', () {
    expect(bundledQuotes, hasLength(110));
    final player = QuotePlayer();
    expect(player.take(), bundledQuotes.first);
    for (var i = 1; i < 110; i++) {
      player.take();
    }
    expect(player.take(), bundledQuotes.first);
  });
}
