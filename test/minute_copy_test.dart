import 'package:flutter_test/flutter_test.dart';
import 'package:stop_daydreaming/minute_copy.dart';

void main() {
  test('one minute is singular', () {
    expect(minuteCopy(1), 'one minute');
  });

  test('two minutes is plural', () {
    expect(minuteCopy(2), 'two minutes');
  });

  test('twenty-one minutes', () {
    expect(minuteCopy(21), 'twenty-one minutes');
  });

  test('sixty minutes', () {
    expect(minuteCopy(60), 'sixty minutes');
  });
}
