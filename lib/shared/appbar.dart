import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/settings/settings.dart';

class SafeHervenAppBar extends StatelessWidget implements PreferredSizeWidget {

  @override
  final Size preferredSize;

  final String title;
  final bool isHome;

  const SafeHervenAppBar(
    this.title, {
    super.key,
    required this.isHome,
  })  : preferredSize = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 3,
      backgroundColor: const Color(0xFF0B2545),
      shadowColor: const Color(0xFF0B2545).withValues(alpha: 0.4),
      centerTitle: isHome ? true : false,
      title: isHome
          ? Image.asset('assets/images/logos/white.png', height: 40)
          : Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sem novas notificações no momento."),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.white24,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: PopupMenuButton<int>(
            color: const Color(0xFF0B2545),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF0066CC), width: 1),
            ),
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: const [
                    Icon(Icons.settings, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Configurações",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    )
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Sair",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> onSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 1:
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        break;
    }
  }
}



