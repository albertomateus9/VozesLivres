import 'package:flutter/material.dart';
import 'package:safeherven_app/models/app_user.dart';
import 'package:safeherven_app/screens/about.dart';
import 'package:safeherven_app/screens/alert.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/home.dart';
import 'package:safeherven_app/screens/places.dart';
import 'package:safeherven_app/services/local_auth_service.dart';
import 'package:safeherven_app/theme/app_colors.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.canvasWarm,
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
            colors: [AppColors.primarySafety, AppColors.secondaryCalm],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logos/white.png', width: 68, height: 68),
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
                    color: AppColors.surfaceHugTint,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
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
      final bool isEmergency = element == 'Alertas & Emergência';
      menuItems.add(
        ListTile(
          leading: Icon(
            icon,
            color: isEmergency
                ? AppColors.protectiveAlert
                : AppColors.secondaryCalm,
          ),
          title: Text(
            element,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isEmergency
                  ? AppColors.protectiveAlert
                  : AppColors.textPrimary,
            ),
          ),
          onTap: () {
            late Widget screen;
            switch (element) {
              case 'Início':
                screen = StreamBuilder<AppUser?>(
                  initialData: LocalAuthService.instance.currentUser,
                  stream: LocalAuthService.instance.authStateChanges,
                  builder: (context, snapshot) {
                    final user = snapshot.data ??
                        LocalAuthService.instance.ensureSession();
                    return HomeScreen(user: user);
                  },
                );
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

    menuItems.add(const Divider(indent: 16, endIndent: 16));
    menuItems.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceHugTint,
            foregroundColor: AppColors.warmthTintText,
            side: BorderSide(
              color: AppColors.warmthTerracotta.withValues(alpha: 0.45),
            ),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            await LocalAuthService.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          },
          icon: const Icon(Icons.door_front_door_outlined),
          label: const Text(
            'Voltar à Entrada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    return menuItems;
  }
}
