import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bank_app/main.dart';

void main() {
  testWidgets('Bank App loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BankApp(),
      ),
    );

    expect(find.text('Bank App'), findsOneWidget);
  });
}