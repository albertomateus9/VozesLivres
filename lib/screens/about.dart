import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/shared/appbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SafeHervenAppBar('Sobre o Vozes Livres Escolar', isHome: false),
      bottomNavigationBar: const MenuBottom(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/images/logos/mixed-logo.png',
                height: 110,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Vozes Livres Escolar",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B2545),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Cultura de Paz na Escola & Proteção a Estudantes",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066CC),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Foco no Ambiente Escolar & Menores",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B2545),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "O Vozes Livres Escolar é uma plataforma dedicada a estudantes, crianças e adolescentes. "
                      "Nosso compromisso é promover a Cultura de Paz no ambiente escolar, prevenindo o bullying, "
                      "cyberbullying, assédio e violação de direitos, garantindo um canal de escuta sigiloso e acolhedor.",
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Diretrizes e Segurança",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B2545),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• Acesso 100% Anônimo e Gratuito para menores de idade.\n"
                      "• Assistente Virtual para desabafo sobre dilemas da escola e saúde mental.\n"
                      "• Contato direto com o Ligue 100 (Direitos Humanos), Conselho Tutelar e SaferNet.\n"
                      "• Mapeamento de locais de apoio e proteção na comunidade.",
                      style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Projeto Educação & Ciência • EETEPA Vilhena Alves",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
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
}

