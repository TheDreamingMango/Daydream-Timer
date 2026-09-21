import 'quotes.dart';

/// Walks [bundledQuotes] in order and loops forever.
class QuotePlayer {
  QuotePlayer([List<String>? quotes]) : _quotes = quotes ?? bundledQuotes;

  final List<String> _quotes;
  int _index = 0;

  String take() {
    if (_quotes.isEmpty) return '';
    final quote = _quotes[_index];
    _index = (_index + 1) % _quotes.length;
    return quote;
  }
}
