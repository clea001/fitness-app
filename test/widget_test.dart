import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/app.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());
    expect(find.text('AI 健身助手'), findsOneWidget);
  });
}
