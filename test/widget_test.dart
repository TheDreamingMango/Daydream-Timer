import 'package:flutter_test/flutter_test.dart';
import 'package:stop_daydreaming/main.dart';

void main() {
  testWidgets('shows Hello', (tester) async {
    await tester.pumpWidget(const StopDaydreamingApp());
    expect(find.text('Hello'), findsOneWidget);
  });
}
