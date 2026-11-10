import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/places.dart';
import 'package:safeherven_app/screens/alert.dart';
import 'package:safeherven_app/shared/drawer.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/shared/appbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela inicial da aplicação Vozes Livres Escolar.
/// Acolhimento, prevenção ao bullying e proteção a estudantes e menores.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  /// Usuário atualmente autenticado via Firebase.
  final User user;

  Future<void> _callEmergency100(BuildContext context) async {
    final Uri uri = Uri.parse("tel:100");
    try {
      if (!await launchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Não foi possível realizar chamada para o Ligue 100")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao discar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final String displayName = (user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : "estudante";

    return Scaffold(
      appBar: const SafeHervenAppBar("Início", isHome: true),
      drawer: const MenuDrawer(),
      bottomNavigationBar: const MenuBottom(currentIndex: 0),
      body: Column(
        children: [
          // ==========================================
          // BANNER SUPERIOR DE BOAS-VINDAS ESCOLAR
          // ==========================================
          Semantics(
            label: "Saudação do aplicativo para o estudante $displayName",
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B2545), Color(0xFF134074)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B2545).withOpacity(0.4),
                    offset: const Offset(0.0, 4.0),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 25,
                    left: 0,
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.only(left: 20, right: 30),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Olá $displayName, seja bem-vindo(a) à escola!",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B2545),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: height * 0.015),

          // ==========================================
          // CARD INFORMATIVO PRINCIPAL ("Vozes Livres Escolar")
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Semantics(
              container: true,
              label: "Cartão de apresentação do Vozes Livres Escolar para estudantes",
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B2545).withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Image.asset(
                        "assets/images/home/free-woman.jpeg",
                        width: 135,
                        height: 190,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  "Vozes Livres",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B2545),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.school, color: Color(0xFF0066CC), size: 18),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Cultura de Paz na Escola",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0066CC),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Divider(height: 14),
                            const Text(
                              "Espaço seguro, confidencial e anônimo de acolhimento para estudantes. Prevenção ao bullying, apoio emocional e proteção dos direitos dos menores.",
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.3,
                                color: Colors.black87,
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

          const SizedBox(height: 10),

          // ==========================================
          // LISTA DE RECURSOS ESCOLARES
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                // Card 1: Chatbot de Acolhimento Escolar
                Semantics(
                  button: true,
                  label: "Abrir assistente de escuta e orientação para estudantes",
                  hint: "Toque duas vezes para conversar de forma anônima sobre dilemas da escola",
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B2545), Color(0xFF134074)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B2545).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Escuta & Orientação (Chatbot)",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chat_bubble_outline, color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Precisa conversar sobre bullying, ansiedade, dilemas escolares ou pedir conselhos? Fale com a assistente de forma totalmente sigilosa.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card 2: Rede de Proteção da Infância & Conselho Tutelar
                Semantics(
                  button: true,
                  label: "Abrir contatos do Conselho Tutelar e redes de apoio infantil e juvenil",
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066CC), Color(0xFF0B2545)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066CC).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Proteção à Criança e Adolescente",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.health_and_safety_outlined, color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Acesse informações do Conselho Tutelar, Ligue 100 (Direitos Humanos), SaferNet e apoio psicológico para estudantes.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card 3: Locais Seguros / Mapa
                Semantics(
                  button: true,
                  label: "Abrir mapa com escolas, postos de saúde e centros de apoio",
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PlacesScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Mapa de Pontos de Apoio",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.location_on_outlined, color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Localize postos de saúde, escolas, centro de assistência social (CRAS) e locais seguros na sua comunidade.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Banner de Chamada Rápida - Ligue 100 (Proteção a Menores)
                Semantics(
                  button: true,
                  label: "Ligar para o Ligue 100 Disque Direitos Humanos e Proteção da Criança e Adolescente",
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                      title: const Text(
                        "Proteção Escolar - Ligue 100",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: const Text(
                        "Disque Direitos Humanos para crianças e adolescentes (Gratuito 24h)",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFD32F2F),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _callEmergency100(context),
                        child: const Text("Ligar 100", style: TextStyle(fontWeight: FontWeight.bold)),
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




