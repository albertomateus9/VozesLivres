import 'package:flutter/material.dart';
import 'package:safeherven_app/models/app_user.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/places.dart';
import 'package:safeherven_app/shared/appbar.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/shared/drawer.dart';
import 'package:safeherven_app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela inicial da aplicação Vozes Livres Escolar.
/// Acolhimento, prevenção ao bullying e proteção a estudantes e menores.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  /// Sessão local ativa (anônima e sem cadastro).
  final AppUser user;

  Future<void> _callEmergency100(BuildContext context) async {
    final Uri uri = Uri.parse('tel:100');
    try {
      final launched = await launchUrl(uri);
      if (!context.mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível realizar chamada para o Ligue 100'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao discar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : 'Estudante';

    return Scaffold(
      appBar: const SafeHervenAppBar('Início', isHome: true),
      drawer: const MenuDrawer(),
      bottomNavigationBar: const MenuBottom(currentIndex: 0),
      body: Column(
        children: [
          Semantics(
            label: 'Saudação de acolhimento para $displayName',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 18, 20, 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(36),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.primarySafety, AppColors.primaryDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 42),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 26,
                    top: 10,
                    bottom: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.canvasWarm,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Text(
                    'Olá, $displayName! Você está em um lugar seguro.',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primarySafety,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Semantics(
              container: true,
              label: 'Cartão de apresentação do Vozes Livres Escolar para estudantes',
              child: Container(
                constraints: const BoxConstraints(minHeight: 168),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(19),
                          bottomLeft: Radius.circular(19),
                        ),
                        child: Image.asset(
                          'assets/images/home/free-woman.jpeg',
                          width: 125,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Vozes Livres',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primarySafety,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.school_outlined,
                                    color: AppColors.warmthText,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Cultura de Paz na Escola',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.secondaryCalm,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Divider(height: 14),
                              const Text(
                                'Espaço seguro, confidencial e anônimo de acolhimento para estudantes. Prevenção ao bullying, apoio emocional e proteção de direitos.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _HomeResourceCard(
                  semanticsLabel: 'Abrir assistente de escuta e orientação para estudantes',
                  semanticsHint:
                      'Toque duas vezes para conversar de forma anônima sobre dilemas da escola',
                  title: 'Escuta & Orientação (Chatbot)',
                  subtitle:
                      'Precisa conversar sobre bullying, ansiedade, dilemas escolares ou pedir conselhos? Fale com a assistente de forma totalmente sigilosa.',
                  icon: Icons.chat_bubble_outline,
                  gradientColors: const [
                    AppColors.primarySafety,
                    AppColors.primaryDeep,
                  ],
                  subtitleColor: AppColors.onPrimaryMuted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                ),
                _HomeResourceCard(
                  semanticsLabel:
                      'Abrir contatos do Conselho Tutelar e redes de apoio infantil e juvenil',
                  title: 'Proteção à Criança e Adolescente',
                  subtitle:
                      'Acesse informações do Conselho Tutelar, Ligue 100 (Direitos Humanos), SaferNet e apoio psicológico para estudantes.',
                  icon: Icons.health_and_safety_outlined,
                  gradientColors: const [
                    AppColors.secondaryCalm,
                    AppColors.secondaryDeep,
                  ],
                  subtitleColor: AppColors.onSecondaryMuted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpScreen()),
                    );
                  },
                ),
                _HomeResourceCard(
                  semanticsLabel:
                      'Abrir mapa com escolas, postos de saúde e centros de apoio',
                  title: 'Mapa de Pontos de Apoio',
                  subtitle:
                      'Localize postos de saúde, escolas, centro de assistência social (CRAS) e locais seguros na sua comunidade.',
                  icon: Icons.location_on_outlined,
                  gradientColors: const [
                    AppColors.mapSlateTeal,
                    AppColors.mapSlateDeep,
                  ],
                  subtitleColor: AppColors.onMapSlateMuted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlacesScreen()),
                    );
                  },
                ),
                Semantics(
                  button: true,
                  label:
                      'Ligar para o Ligue 100 Disque Direitos Humanos e Proteção da Criança e Adolescente',
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.protectiveAlert,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: const Text(
                        'Proteção Escolar - Ligue 100',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Disque Direitos Humanos para crianças e adolescentes (Gratuito 24h)',
                        style: TextStyle(
                          color: AppColors.onAlertMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.protectiveAlert,
                          minimumSize: const Size(88, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _callEmergency100(context),
                        child: const Text(
                          'Ligar 100',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeResourceCard extends StatelessWidget {
  const _HomeResourceCard({
    required this.semanticsLabel,
    this.semanticsHint,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.subtitleColor,
    required this.onTap,
  });

  final String semanticsLabel;
  final String? semanticsHint;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: semanticsHint,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
