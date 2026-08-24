import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Gerencia a autenticação com o Google.
/// Usa o escopo drive.appdata para acesso à pasta privada do app no Drive.
class AuthService {
  AuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static GoogleSignInAccount? _currentUser;
  static final StreamController<GoogleSignInAccount?> _userController =
      StreamController<GoogleSignInAccount?>.broadcast();

  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.appdata',
    'email',
  ];

  /// Inicializa o plugin do Google Sign-In.
  /// Deve ser chamado no início da aplicação.
  static Future<void> initialize() async {
    try {
      await _googleSignIn.initialize(
        clientId: kIsWeb ? '958891505864-gpprnfpj92rnh1o1kp9igon9cis9g1pc.apps.googleusercontent.com' : null,
        serverClientId: kIsWeb ? null : '958891505864-gpprnfpj92rnh1o1kp9igon9cis9g1pc.apps.googleusercontent.com',
      );

      _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _currentUser = event.user;
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          _currentUser = null;
        }
        _userController.add(_currentUser);
      });
    } catch (e) {
      debugPrint('Erro ao inicializar Google Sign-In: $e');
    }
  }

  /// Instância interna do GoogleSignIn, usada por outros serviços (ex: DriveBackupService).
  static GoogleSignIn get googleSignIn => _googleSignIn;

  /// Abre a tela de login do Google.
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.authenticate();
      _currentUser = account;
      _userController.add(account);
      return account;
    } catch (e) {
      debugPrint('ERRO NO GOOGLE SIGN-IN: $e');
      rethrow;
    }
  }

  /// Desloga o usuário atual.
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _userController.add(null);
    } catch (e) {
      debugPrint('Erro ao sair: $e');
    }
  }

  /// Tenta renovar a sessão silenciosamente (sem tela de login).
  /// Retorna null se o usuário não estiver logado.
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();
      _currentUser = account;
      _userController.add(account);
      return account;
    } catch (e) {
      debugPrint('Erro ao renovar sessão: $e');
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _currentUser;
  static bool get isSignedIn => _currentUser != null;

  /// Stream que emite o usuário atual sempre que há mudança de estado de login.
  static Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _userController.stream;

  static List<String> get scopes => _scopes;
}
