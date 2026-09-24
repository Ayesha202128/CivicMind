import 'package:flutter_test/flutter_test.dart';
import 'package:civicmind_app/main.dart';

void main() {
  testWidgets('CivicMind app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CivicMindApp());

    expect(find.text('CivicMind'), findsOneWidget);
    expect(find.text('Supabase Connected!'), findsOneWidget);
  });
}
