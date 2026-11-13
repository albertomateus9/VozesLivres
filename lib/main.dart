import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeherven_app/blocs/application_bloc.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/places.dart';
import 'package:safeherven_app/screens/about.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/wrapper.dart';
import 'package:safeherven_app/screens/alert.dart';
import 'package:safeherven_app/screens/settings/settings.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VozesLivresApp());
}

class VozesLivresApp extends StatelessWidget {
  const VozesLivresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ApplicationBloc(),
      child: MaterialApp(
        title: 'Vozes Livres',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B2545),
            primary: const Color(0xFF0B2545),
            secondary: const Color(0xFF0066CC),
            error: const Color(0xFFD32F2F),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7FA),
          textTheme: GoogleFonts.jostTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0B2545),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const Wrapper(),
          '/about': (context) => const AboutScreen(),
          '/chat': (context) => const ChatScreen(),
          '/map': (context) => const PlacesScreen(),
          '/alert': (context) => const AlertScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/help': (context) => const HelpScreen(),
        },
      ),
    );
  }
}

