import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeherven_app/main.dart';
import 'package:safeherven_app/screens/about.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/home.dart';
import 'package:safeherven_app/screens/settings/settings.dart';
import 'package:safeherven_app/services/local_auth_service.dart';

void main() {
  tearDown(() async {
    await LocalAuthService.instance.signOut();
  });

  testWidgets('VozesLivresApp shows direct welcoming entry without login fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VozesLivresApp());
    await tester.pump();

    expect(find.text('Vozes Livres'), findsOneWidget);
    expect(find.text('Entrar Agora'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Entrar Anonimamente'), findsNothing);
    expect(find.text('Continuar como Convidado'), findsNothing);

    await tester.tap(find.text('Entrar Agora'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Olá, Estudante! Você está em um lugar seguro.'), findsOneWidget);
  });

  testWidgets('Direct shortcut opens Angel chat and keeps bottom home navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VozesLivresApp());
    await tester.pump();

    await tester.tap(find.text('Conversar com a Angel'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatScreen), findsOneWidget);

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('SettingsScreen allows returning to direct entry screen', (
    WidgetTester tester,
  ) async {
    await LocalAuthService.instance.enterDirectly();
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (context) => const VozesLivresApp(),
          '/settings': (context) => const SettingsScreen(),
        },
        initialRoute: '/settings',
      ),
    );
    await tester.pump();

    expect(find.text('Voltar à Entrada'), findsOneWidget);
    expect(find.text('Sair da Conta'), findsNothing);
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
