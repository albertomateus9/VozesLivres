import 'dart:async';
import 'package:safeherven_app/models/app_user.dart';

/// Serviço local de sessão anônima e acesso direto sem login,
/// sem necessidade de cadastro, Firebase ou chaves de API.
class LocalAuthService {
  LocalAuthService._internal();

  static final LocalAuthService instance = LocalAuthService._internal();

  static const AppUser _defaultDirectUser = AppUser(
    uid: 'direct-local-student',
    displayName: 'Estudante',
    email: 'Acesso Direto • 100% Anônimo',
    isAnonymous: true,
  );

  final StreamController<AppUser?> _authController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Stream<AppUser?> get authStateChanges => _authController.stream;

  /// Retorna o usuário anônimo ativo ou o perfil padrão local sem exigir login.
  AppUser ensureSession() {
    return _currentUser ?? _defaultDirectUser;
  }

  /// Inicia o acesso direto e anônimo sem formulários ou senhas.
  Future<AppUser> enterDirectly() async {
    _currentUser = _defaultDirectUser;
    _authController.add(_defaultDirectUser);
    return _defaultDirectUser;
  }

  /// Retorna à tela inicial de acolhimento mantendo privacidade no dispositivo.
  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }
}
