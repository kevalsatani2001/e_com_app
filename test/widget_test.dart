import 'package:e_com_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders navigation shell', (WidgetTester tester) async {
    await tester.pumpWidget(const StoreApp());
    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });
}
