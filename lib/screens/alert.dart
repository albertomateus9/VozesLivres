import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safeherven_app/blocs/application_bloc.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/shared/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  Future<void> _makeCall(String number, BuildContext context) async {
    final Uri uri = Uri.parse("tel:$number");
    try {
      final launched = await launchUrl(uri);
      if (!context.mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível ligar para $number")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao realizar chamada: $e")),
      );
    }
  }

  void _shareEmergencyAlert(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);
    final pos = applicationBloc.currentLocation;
    final String coordsStr = pos != null
        ? "Minhas coordenadas atuais: https://maps.google.com/?q=${pos.latitude},${pos.longitude}"
        : "Localização atual indisponível no momento.";

    final String alertMsg =
        "🚨 ALERTA DE EMERGÊNCIA - VOZES LIVRES 🚨\n"
        "Preciso de ajuda urgente! $coordsStr";

    Clipboard.setData(ClipboardData(text: alertMsg));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mensagem de alerta copiada! Você pode colar no WhatsApp ou SMS."),
        backgroundColor: Color(0xFF0B2545),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SafeHervenAppBar("Alertas & Emergência", isHome: false),
      bottomNavigationBar: const MenuBottom(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 54, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "Canais de Emergência Direta",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Em caso de perigo imediato, acione os canais oficiais de socorro abaixo:",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _shareEmergencyAlert(context),
                    icon: const Icon(Icons.share_location, size: 20),
                    label: const Text(
                      "Copiar Alerta com Minha Localização",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildEmergencyTile(
              context,
              title: "Ligue 100 - Proteção à Criança e Adolescente",
              subtitle: "Disque Direitos Humanos para apoio e proteção de menores de idade.",
              number: "100",
              icon: Icons.shield_outlined,
              color: const Color(0xFF0B2545),
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              context,
              title: "Ligue 180 - Central da Mulher",
              subtitle: "Atendimento gratuito 24h para alunas e mulheres.",
              number: "180",
              icon: Icons.support_agent,
              color: const Color(0xFF0066CC),
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              context,
              title: "Ligue 190 - Polícia Militar / Patrulha Escolar",
              subtitle: "Para emergências ativas e perigo imediato na escola ou rua.",
              number: "190",
              icon: Icons.local_police_outlined,
              color: const Color(0xFFD32F2F),
            ),
            const SizedBox(height: 12),
            _buildEmergencyTile(
              context,
              title: "Ligue 188 - CVV (Apoio Emocional Escolar)",
              subtitle: "Suporte emocional gratuito e sigiloso 24h para estudantes.",
              number: "188",
              icon: Icons.favorite_border,
              color: Colors.teal.shade700,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0B2545),
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

  Widget _buildEmergencyTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _makeCall(number, context),
          child: const Text("Chamar"),
        ),
      ),
    );
  }
}

