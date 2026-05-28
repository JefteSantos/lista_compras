import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Gerencia a autenticação com o Google.
/// Usa o escopo drive.appdata para acesso à pasta privada do app no Drive.
class AuthService {
  AuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // No Web, o clientId é obrigatório. No Android, ele deve ser null para evitar conflito com o google-services.json.
    clientId: kIsWeb ? '958891505864-gpprnfpj92rnh1o1kp9igon9cis9g1pc.apps.googleusercontent.com' : null, 
    // O serverClientId não é suportado na Web e deve ser passado apenas em outras plataformas (como Android).
    serverClientId: kIsWeb ? null : '958891505864-gpprnfpj92rnh1o1kp9igon9cis9g1pc.apps.googleusercontent.com',
    scopes: [
      'https://www.googleapis.com/auth/drive.appdata',
      'email',
    ],
  );

  /// Instância interna do GoogleSignIn, usada por outros serviços (ex: DriveBackupService).
  static GoogleSignIn get googleSignIn => _googleSignIn;

  /// Abre a tela de login do Google.
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
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
