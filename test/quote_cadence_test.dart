import 'package:flutter_test/flutter_test.dart';
import 'package:daydream_timer/quote_cadence.dart';

void main() {
  test('every minute through fifteen', () {
    expect(latestDue(const Duration(seconds: 59)), Duration.zero);
    expect(latestDue(const Duration(seconds: 60)), const Duration(seconds: 60));
    expect(
      latestDue(const Duration(seconds: 119)),
      const Duration(seconds: 60),
    );
    expect(latestDue(const Duration(minutes: 14)), const Duration(minutes: 14));
    expect(latestDue(const Duration(minutes: 15)), denseUntil);
    expect(latestDue(const Duration(minutes: 16, seconds: 29)), denseUntil);
  });

  test('ninety seconds after fifteen, then every two minutes', () {
    const sixteenThirty = Duration(minutes: 16, seconds: 30);
    const eighteenThirty = Duration(minutes: 18, seconds: 30);
    expect(latestDue(sixteenThirty), sixteenThirty);
    expect(latestDue(const Duration(minutes: 18, seconds: 29)), sixteenThirty);
    expect(latestDue(eighteenThirty), eighteenThirty);
    expect(
      latestDue(const Duration(minutes: 20, seconds: 30)),
      const Duration(minutes: 20, seconds: 30),
    );
  });

  test('quotes every two minutes, then every due after fifteen', () {
    expect(quoteWith(const Duration(minutes: 2)), isTrue);
    expect(quoteWith(const Duration(minutes: 3)), isFalse);
    expect(quoteWith(denseUntil), isTrue);
    expect(quoteWith(const Duration(minutes: 16, seconds: 30)), isTrue);
  });

  test('QuoteCadence fires once per due quote boundary', () {
    final cadence = QuoteCadence();
    expect(cadence.takePending(const Duration(minutes: 1)), isFalse);
    expect(cadence.takePending(const Duration(minutes: 2)), isTrue);
    expect(cadence.takePending(const Duration(minutes: 2)), isFalse);
    expect(cadence.takePending(const Duration(minutes: 3)), isFalse);
    expect(cadence.takePending(const Duration(minutes: 4)), isTrue);
    expect(cadence.takePending(denseUntil), isTrue);
    expect(cadence.takePending(const Duration(minutes: 16)), isFalse);
    expect(
      cadence.takePending(const Duration(minutes: 16, seconds: 30)),
      isTrue,
    );
  });
}
