import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/places.dart';
import 'package:safeherven_app/screens/about.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/home.dart';
import 'package:safeherven_app/screens/alert.dart';
import 'package:safeherven_app/screens/wrapper.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: buildMenuItems(context),
      ),
    );
  }

  List<Widget> buildMenuItems(BuildContext context) {
    IconData icon = Icons.check;
    final List<String> menuTitles = [
      'Início',
      'Locais Seguros',
      'Chat de Apoio',
      'Sobre o App',
      'Alertas & Emergência',
      'Obter Ajuda',
    ];
    List<Widget> menuItems = [];

    menuItems.add(
      DrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2545), Color(0xFF134074)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/images/logos/white.png", width: 70, height: 70),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Vozes Livres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    for (var element in menuTitles) {
      switch (element) {
        case 'Início':
          icon = Icons.home_rounded;
          break;
        case 'Locais Seguros':
          icon = Icons.location_on_rounded;
          break;
        case 'Chat de Apoio':
          icon = Icons.chat_bubble_rounded;
          break;
        case 'Sobre o App':
          icon = Icons.info_rounded;
          break;
        case 'Alertas & Emergência':
          icon = Icons.warning_amber_rounded;
          break;
        case 'Obter Ajuda':
          icon = Icons.health_and_safety_rounded;
          break;
      }
      Widget screen = Container();
      menuItems.add(
        ListTile(
          leading: Icon(
            icon,
            color: element == 'Alertas & Emergência'
                ? const Color(0xFFD32F2F)
                : const Color(0xFF0066CC),
          ),
          title: Text(
            element,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: element == 'Alertas & Emergência'
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF0B2545),
            ),
          ),
          onTap: () {
            switch (element) {
              case 'Início':
                screen = StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Wrapper();
                      }
                      return HomeScreen(user: snapshot.data!);
                    });
                break;
              case 'Locais Seguros':
                screen = const PlacesScreen();
                break;
              case 'Chat de Apoio':
                screen = const ChatScreen();
                break;
              case 'Sobre o App':
                screen = const AboutScreen();
                break;
              case 'Alertas & Emergência':
                screen = const AlertScreen();
                break;
              case 'Obter Ajuda':
                screen = const HelpScreen();
                break;
            }
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => screen),
            );
          },
        ),
      );
    }

    menuItems.add(const Divider(thickness: 1, indent: 16, endIndent: 16));
    menuItems.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4F7FA),
            foregroundColor: const Color(0xFFD32F2F),
            side: const BorderSide(color: Color(0xFFD32F2F), width: 1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text(
            "Sair da Conta",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    return menuItems;
  }
}

