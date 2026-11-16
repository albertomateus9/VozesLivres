import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/services/local_auth_service.dart';
import 'package:safeherven_app/shared/appbar.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = LocalAuthService.instance.ensureSession();
    final String name = (user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Estudante';

    return Scaffold(
      appBar: const SafeHervenAppBar('Configurações', isHome: false),
      bottomNavigationBar: const MenuBottom(currentIndex: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderSoft),
            ),
            elevation: 0,
            color: AppColors.surfaceElevated,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primarySafety,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primarySafety,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email ?? 'Acesso Direto • 100% Anônimo',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Preferências do Aplicativo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryCalm,
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderSoft),
            ),
            elevation: 0,
            color: AppColors.surfaceElevated,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.language, color: AppColors.primarySafety),
                  title: Text('Idioma'),
                  subtitle: Text(
                    'Português (Brasil)',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(Icons.check, color: AppColors.secondaryCalm),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primarySafety,
                  ),
                  title: const Text('Notificações de Alerta'),
                  subtitle: const Text(
                    'Receber avisos e atualizações de segurança',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  activeThumbColor: AppColors.primarySafety,
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: AppColors.primarySafety),
                  title: const Text('Privacidade & Proteção de Dados'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Seus dados permanecem locais no aparelho com total privacidade.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceHugTint,
              foregroundColor: AppColors.warmthTintText,
              side: BorderSide(
                color: AppColors.warmthTerracotta.withValues(alpha: 0.45),
              ),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await LocalAuthService.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            icon: const Icon(Icons.door_front_door_outlined),
            label: const Text(
              'Voltar à Entrada',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primarySafety,
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
