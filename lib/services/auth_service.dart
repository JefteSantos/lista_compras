import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Gerencia a autenticação com o Google.
/// Usa o escopo drive.appdata para acesso à pasta privada do app no Drive.
class AuthService {
  AuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.appdata'],
  );

  /// Instância interna do GoogleSignIn, usada por outros serviços (ex: DriveBackupService).
  static GoogleSignIn get googleSignIn => _googleSignIn;

  /// Abre a tela de login do Google.
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('Erro ao fazer login com Google: $e');
      return null;
    }
  }

  /// Desloga o usuário atual.
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Erro ao sair: $e');
    }
  }

  /// Tenta renovar a sessão silenciosamente (sem tela de login).
  /// Retorna null se o usuário não estiver logado.
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('Erro ao renovar sessão: $e');
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  static bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Stream que emite o usuário atual sempre que há mudança de estado de login.
  static Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;
}
