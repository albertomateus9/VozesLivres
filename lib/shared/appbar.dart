import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/settings/settings.dart';
import 'package:safeherven_app/services/local_auth_service.dart';
import 'package:safeherven_app/theme/app_colors.dart';

class SafeHervenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;
  final bool isHome;

  const SafeHervenAppBar(
    this.title, {
    super.key,
    required this.isHome,
  }) : preferredSize = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: AppColors.primarySafety,
      surfaceTintColor: Colors.transparent,
      centerTitle: isHome,
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
          tooltip: 'Notificações',
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sem novas notificações no momento.'),
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
            color: AppColors.primaryDeep,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.borderCalm.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Configurações',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.door_front_door_outlined,
                      color: AppColors.onPrimaryMuted,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Voltar à Entrada',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
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
        await LocalAuthService.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
        break;
    }
  }
}
