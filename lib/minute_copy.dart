const _ones = <String>[
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];

const _tens = <String>[
  '',
  '',
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety',
];

/// English cardinal for [n], used in spoken minute copy.
String cardinal(int n) {
  if (n < 0) {
    throw ArgumentError.value(n, 'n', 'must be non-negative');
  }
  if (n < 20) return _ones[n];
  if (n < 100) {
    final tens = n ~/ 10;
    final ones = n % 10;
    if (ones == 0) return _tens[tens];
    return '${_tens[tens]}-${_ones[ones]}';
  }
  if (n < 1000) {
    final hundreds = n ~/ 100;
    final rest = n % 100;
    final head = '${_ones[hundreds]} hundred';
    if (rest == 0) return head;
    return '$head ${cardinal(rest)}';
  }
  final thousands = n ~/ 1000;
  final rest = n % 1000;
  final head = '${cardinal(thousands)} thousand';
  if (rest == 0) return head;
  return '$head ${cardinal(rest)}';
}

/// Spoken copy for a whole-minute boundary: "one minute", "two minutes".
String minuteCopy(int minute) {
  if (minute < 1) {
    throw ArgumentError.value(minute, 'minute', 'must be at least 1');
  }
  final words = cardinal(minute);
  return minute == 1 ? '$words minute' : '$words minutes';
}
