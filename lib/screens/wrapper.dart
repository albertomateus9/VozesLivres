import 'package:flutter/material.dart';
import 'package:safeherven_app/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isGuestMode = false;

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      setState(() {
        _isGuestMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuestMode) {
      return HomeScreen(user: _MockUser());
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        }

        return SignInScreen(
          providerConfigs: const [
            EmailProviderConfiguration(),
            GoogleProviderConfiguration(
              clientId: 'Your-client-id',
            ),
          ],
          headerBuilder: (context, constraints, _) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/logos/mixed-logo.png'),
              ),
            );
          },
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      action == AuthAction.signIn
                          ? "Entrar no Vozes Livres"
                          : "Cadastrar-se no Vozes Livres",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B2545),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2545),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _signInAnonymously(context),
                      icon: const Icon(Icons.person_outline),
                      label: const Text(
                        "Entrar Anonimamente",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isGuestMode = true;
                      });
                    },
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFF0066CC)),
                    label: const Text(
                      "Continuar como Convidado",
                      style: TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
          footerBuilder: (context, action) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Text(
                "Ao fazer login, você concorda com nossos Termos & Condições e Política de Privacidade.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            );
          },
        );
      },
    );
  }
}

class _MockUser implements User {
  @override
  String? get displayName => "Convidado";

  @override
  String? get email => "convidado@vozeslivres.org";

  @override
  bool get isAnonymous => true;

  @override
  String get uid => "guest_anon_123";

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}



