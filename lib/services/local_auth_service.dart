import 'dart:async';
import 'package:safeherven_app/models/app_user.dart';

/// Serviço local de sessão sem necessidade de Firebase ou chaves de API.
class LocalAuthService {
  LocalAuthService._internal();

  static final LocalAuthService instance = LocalAuthService._internal();

  final StreamController<AppUser?> _authController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Stream<AppUser?> get authStateChanges => _authController.stream;

  Future<AppUser> signInWithEmail({
    required String email,
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    final inferredName = trimmedEmail.contains('@')
        ? trimmedEmail.split('@').first
        : trimmedEmail;
    final user = AppUser(
      uid: 'local-${trimmedEmail.hashCode}',
      displayName: (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : (inferredName.isNotEmpty ? inferredName : 'Estudante'),
      email: trimmedEmail,
      isAnonymous: false,
    );
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  Future<AppUser> signInAnonymously() async {
    const user = AppUser(
      uid: 'anonymous-student',
      displayName: 'Estudante Protegido',
      email: 'Modo Anônimo (Privacidade Total)',
      isAnonymous: true,
    );
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  Future<AppUser> signInAsGuest() async {
    const user = AppUser(
      uid: 'guest-student',
      displayName: 'Estudante Visitante',
      email: 'Acesso Rápido Offline',
      isAnonymous: true,
    );
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }
}
