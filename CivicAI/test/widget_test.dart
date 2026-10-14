import 'package:flutter_test/flutter_test.dart';
import 'package:civic_ai/main.dart';

void main() {
  testWidgets('JanSeva App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JanSevaApp());
    expect(find.text('JanSeva AI'), findsWidgets);
  });
}
