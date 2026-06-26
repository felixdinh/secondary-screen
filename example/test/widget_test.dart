import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:secondary_screen_example/main.dart';

void main() {
  testWidgets('shows the POS sales screen by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Point of Sale'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Order'), findsOneWidget);
    expect(find.text('No products added'), findsOneWidget);
  });

  testWidgets('routes sales, promotion, and order screens',
      (WidgetTester tester) async {
    expect(generateRoute(const RouteSettings(name: 'sales')), isNotNull);
    expect(generateRoute(const RouteSettings(name: 'presentation')), isNotNull);
    expect(
        generateRoute(const RouteSettings(name: 'order_display')), isNotNull);
  });
}
