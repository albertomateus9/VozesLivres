import 'package:flutter_test/flutter_test.dart';
import 'package:safeherven_app/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeherven_app/screens/about.dart';

void main() {
  testWidgets('Smoke test - AboutScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScreen(),
      ),
    );
    expect(find.byType(AboutScreen), findsOneWidget);
  });
}
