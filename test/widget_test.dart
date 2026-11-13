import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeherven_app/main.dart';
import 'package:safeherven_app/screens/about.dart';
import 'package:safeherven_app/screens/help.dart';

void main() {
  testWidgets('VozesLivresApp renders login options without paid APIs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VozesLivresApp());
    await tester.pump();

    expect(find.text('Vozes Livres'), findsOneWidget);
    expect(find.text('Entrar Anonimamente'), findsOneWidget);
  });

  testWidgets('AboutScreen and HelpScreen render offline content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
    await tester.pump();
    expect(find.text('Organizações de Apoio & ONGs'), findsOneWidget);
    expect(
      find.text('Ligue 100 - Disque Direitos Humanos (Proteção à Criança e Adolescente)'),
      findsOneWidget,
    );
  });
}
