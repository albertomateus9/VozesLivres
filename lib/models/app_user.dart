/// Representação local de usuário autenticado no Vozes Livres Escolar.
/// Não depende de servidores ou chaves externas pagas.
class AppUser {
  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.isAnonymous = false,
  });

  final String uid;
  final String? displayName;
  final String? email;
  final bool isAnonymous;
}
